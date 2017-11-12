defmodule SdnEpc.Forwarder do
  require Logger
  use GenServer
  @ofs_handler Application.get_env(:sdn_epc, :ofs_handler)
  @ofp_channel Application.get_env(:sdn_epc, :ofp_channel)
  @moduledoc """
  Provides functionalities to send/receive OpenFlow messages to/from SDN switch
  and controller.
  """

  defstruct([:datapath_id])

  # Client API

  @doc """
  Starts SdnEpc.Forwarder process.
  """
  @spec start_link(name :: atom()) :: GenServer.on_start()
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Save switch datapath which is necessary to send OpenFlow messages to switch.

  ## Example

      iex> Supervisor.start_child(SdnEpc.ForwarderSup, [:forwarder])
      iex> SdnEpc.Forwarder.save_datapath_id(:forwarder,
      ...> '00:00:00:00:00:00:00:01')
      :ok
  """
  @spec save_datapath_id(forwarder :: atom(), id :: charlist()) :: term()
  def save_datapath_id(forwarder, datapath_id) do
    GenServer.cast(forwarder, {:save_datapath_id, datapath_id})
  end

  @doc """
  Subscribes OpenFlow messages of particular types.

  ## Example

      iex> Supervisor.start_child(SdnEpc.ForwarderSup, [:forwarder])
      iex> SdnEpc.Forwarder.subscribe_messages_from_switch(:forwarder,
      ...> [:packet_in])
      :ok
  """
  @spec subscribe_messages_from_switch(forwarder :: atom(),
    types :: [atom()]) :: term()
  def subscribe_messages_from_switch(forwarder, types) do
    GenServer.cast(forwarder,
      {:subscribe_switch_msg, types: types})
  end

  @doc """
  Opens OpenFlow channel to communicate app with controller.

  ## Example

      iex> {:ok, pid} = Supervisor.start_child(SdnEpc.OfpcsSup, [1])
      iex> Supervisor.start_child(SdnEpc.ForwarderSup,
      ...> [:forwarder])
      iex> SdnEpc.Forwarder.open_ofp_channel(:forwarder, pid, "1",
      ...> {192, 168, 0, 1}, 6653, 4)
      :ok
  """
  @spec open_ofp_channel(forwarder :: atom(), sup :: pid(), id :: binary(),
    ip :: :inet.ip_address(), port :: :inet.port_number(),
    version :: integer()) :: term()
  def open_ofp_channel(forwarder, sup, switch_id, ip, port, version) do
    GenServer.call(forwarder,
      {:open_of_channel, %{sup: sup, switch_id: switch_id, ip: ip,
                         port: port, version: version}})
  end

  @doc """
  Sends OpenFlow message to controller.
  """
  @spec send_msg_to_controller(forwarder :: atom(), id :: binary(),
    SdnEpc.Converter.ofp_message()) :: term()
  def send_msg_to_controller(forwarder, switch_id, msg) do
    GenServer.cast(forwarder, {:send_msg_to_controller, switch_id, msg})
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %__MODULE__{}}
  end

  def handle_call({:open_of_channel, args}, _from, state) do
    {:ok, _conn_pid} = @ofp_channel.open(args[:sup],
      args[:switch_id], {:remote_peer, args[:ip], args[:port], :tcp},
      controlling_process: self(), version: args[:version])
    {:reply, :ok, state}
  end

  def handle_cast({:save_datapath_id, datapath_id}, _state) do
    {:noreply, %__MODULE__{datapath_id: datapath_id}}
  end
  def handle_cast({:subscribe_switch_msg, types: types},
    state = %__MODULE__{datapath_id: datapath_id}) do
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
    state = %__MODULE__{datapath_id: datapath_id}) do
    @ofs_handler.send(datapath_id, msg)
    Logger.debug("Message send to switch")
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end
end
