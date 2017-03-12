defmodule SdnEpc.Forwarder do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe_messages_from_switch(datapatch_id, type) do
    GenServer.cast __MODULE__,
    {:handle_switch_msg, datapatch_id, type}
  end

  def open_ofp_channel(sup, switch_id, ip, port, version) do
    GenServer.call __MODULE__,
    {:open_of_channel, %{sup: sup, switch_id: switch_id, ip: ip,
                         port: port, version: version}}
  end

  def send_msg_to_switch(datapatch_id, msg) do
    GenServer.cast __MODULE__,
    {:send_msg_to_switch, datapatch_id: datapatch_id, msg: msg}
  end

  def send_msg_to_controller(switch_id, msg) do
    GenServer.cast __MODULE__,
    {:send_msg_to_controller, switch_id: switch_id, msg: msg}
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:open_of_channel, args}, _from, state) do
    {:ok, _conn_pid} = :ofp_channel.open args[:sup],
      args[:switch_id], {:remote_peer, args[:ip], args[:port], :tcp},
      controlling_process: __MODULE__, version: args[:version]
    {:reply, :ok, state}
  end

  def handle_cast({:handle_switch_msg, datapatch_id, type}, state) do
    :ofs_handler.subscribe datapatch_id, SdnEpc.OfshCall, type
    {:noreply, state}
  end
end
