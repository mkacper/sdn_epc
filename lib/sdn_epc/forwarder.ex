defmodule SdnEpc.Forwarder do
  require Logger
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def save_datapath_id(datapath_id) do
    GenServer.cast(__MODULE__, {:save_datapath_id, datapath_id})
  end
  def subscribe_messages_from_switch(datapath_id, types) do
    GenServer.cast(__MODULE__,
      {:subscribe_switch_msg, datapath_id: datapath_id, types: types})
  end

  def open_ofp_channel(sup, switch_id, ip, port, version) do
    GenServer.call(__MODULE__,
      {:open_of_channel, %{sup: sup, switch_id: switch_id, ip: ip,
                         port: port, version: version}})
  end

  def send_msg_to_switch(datapath_id, msg) do
    GenServer.cast(__MODULE__,
      {:send_msg_to_switch, datapath_id, msg})
  end

  def send_msg_to_controller(switch_id, msg) do
    GenServer.cast(__MODULE__,
      {:send_msg_to_controller, switch_id, msg})
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:open_of_channel, args}, _from, state) do
    {:ok, _conn_pid} = :ofp_channel.open(args[:sup],
      "ofp_channel_" <> args[:switch_id],
      {:remote_peer, args[:ip], args[:port], :tcp},
      controlling_process: __MODULE__, version: args[:version])
    {:reply, :ok, state}
  end

  def handle_cast({:save_datapath_id, datapath_id}, _state) do
    {:noreply, %{datapath_id: datapath_id}}
  end
  def handle_cast({:subscribe_switch_msg, datapath_id: datapath_id,
                  types: types}, state) do
    Enum.map(types,
      &(:ofs_handler.subscribe(datapath_id, SdnEpc.OfshCalls, &1)))
    {:noreply, state}
  end
  def handle_cast({:send_msg_to_controller, switch_id, msg}, state) do
    msg_converted = SdnEpc.Converter.convert(msg)
    :ofp_channel.send(switch_id, msg_converted)
    Logger.debug("Message send to controller")
    {:noreply, state}
  end

  def handle_info({:ofp_message, _from, msg},
    state = %{datapath_id: datapath_id}) do
    :ofs_handler.send(datapath_id, msg)
    Logger.debug("Message send to switch")
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end
end
