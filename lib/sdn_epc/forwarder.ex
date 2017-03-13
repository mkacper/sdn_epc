defmodule SdnEpc.Forwarder do
  require Logger
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe_messages_from_switch(datapatch_id, type) do
    GenServer.cast __MODULE__,
    {:handle_switch_msg, datapatch_id: datapatch_id, type: type}
  end

  def open_ofp_channel(sup, switch_id, ip, port, version) do
    GenServer.call __MODULE__,
    {:open_of_channel, %{sup: sup, switch_id: switch_id, ip: ip,
                         port: port, version: version}}
  end

  def send_msg_to_switch(datapatch_id, msg) do
    GenServer.cast __MODULE__,
    {:send_msg_to_switch, datapatch_id, msg}
  end

  def send_msg_to_controller(switch_id, msg) do
    GenServer.cast __MODULE__,
    {:send_msg_to_controller, switch_id, msg}
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:open_of_channel, args}, _from, state) do
    {:ok, _conn_pid} = :ofp_channel.open args[:sup],
      "ofp_channel_" <> args[:switch_id],
      {:remote_peer, args[:ip], args[:port], :tcp},
      controlling_process: __MODULE__, version: args[:version]
    {:reply, :ok, state}
  end

  def handle_cast({:handle_switch_msg, datapatch_id: datapatch_id,
                  type: type}, state) do
    :ofs_handler.subscribe datapatch_id, SdnEpc.OfshCalls, type
    {:noreply, state}
  end
  def handle_cast({:send_msg_to_controller, switch_id,
                   msg = {:packet_in, _, _}}, state) do
    msg_converted = SdnEpc.Converter.ofp_packet_in msg
    :ofp_channel.send switch_id, msg_converted
    Logger.info "Packet in message send to controller"
    {:noreply, state}
  end
end
