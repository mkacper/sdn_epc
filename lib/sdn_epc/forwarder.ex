defmodule SdnEpc.Forwarder do
  require Logger
  use GenServer
  @ofs_handler Application.get_env(:sdn_epc, :ofs_handler)
  @ofp_channel Application.get_env(:sdn_epc, :ofp_channel)
  @moduledoc """
  Provides functionalities to send/receive OpenFlow messages to/from SDN switch
  and controller.
  """

  # Client API

  @doc """
  Starts SdnEpc.Forwarder process.

  Returns {:ok, pid}
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Save switch datapath which is necessary to send OpenFlow messages to switch.

  Returns :ok

  ## Example
      SdnEpc.Forwarder.save_datapath_id('00:00:00:00:00:00:00:01')
      :ok
  """
  def save_datapath_id(datapath_id) do
    GenServer.cast(__MODULE__, {:save_datapath_id, datapath_id})
  end

  @doc """
  Subscribes OpenFlow messages of particular types.

  Returns :ok

  ## Example
      SdnEpc.Forwarder.subscribe_messages_from_switch('00:00:00:00:00:00:00:01,
        [:packet_in])
  """
  def subscribe_messages_from_switch(datapath_id, types) do
    GenServer.cast(__MODULE__,
      {:subscribe_switch_msg, datapath_id: datapath_id, types: types})
  end

  @doc """
  Opens OpenFlow channel to communicate app with controller.

  Returns {:ok, pid}

  ## Example

      SdnEpc.Forwarder.open_ofp_channel(sup_pid, "1", {192, 168, 0, 1}, 6653, 4)
  """
  def open_ofp_channel(sup, switch_id, ip, port, version) do
    GenServer.call(__MODULE__,
      {:open_of_channel, %{sup: sup, switch_id: switch_id, ip: ip,
                         port: port, version: version}})
  end

  @doc """
  Sends OpenFlow message to controller.

  Returns :ok
  """
  def send_msg_to_controller(switch_id, msg) do
    GenServer.cast(__MODULE__,
      {:send_msg_to_controller, switch_id, msg})
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:open_of_channel, args}, _from, state) do
    {:ok, _conn_pid} = @ofp_channel.open(args[:sup],
      args[:switch_id], {:remote_peer, args[:ip], args[:port], :tcp},
      controlling_process: __MODULE__, version: args[:version])
    {:reply, :ok, state}
  end

  def handle_cast({:save_datapath_id, datapath_id}, _state) do
    {:noreply, %{datapath_id: datapath_id}}
  end
  def handle_cast({:subscribe_switch_msg, datapath_id: datapath_id,
                  types: types}, state) do
    Enum.each(types,
      &(@ofs_handler.subscribe(datapath_id, SdnEpc.OfshCall, &1)))
    {:noreply, state}
  end
  def handle_cast({:send_msg_to_controller, switch_id, msg}, state) do
    msg_converted = SdnEpc.Converter.convert(msg)
    @ofp_channel.send(switch_id, msg_converted)
    Logger.debug("Message send to controller")
    {:noreply, state}
  end

  def handle_info({:ofp_message, _from, msg},
    state = %{datapath_id: datapath_id}) do
    @ofs_handler.send(datapath_id, msg)
    Logger.debug("Message send to switch")
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end
end
