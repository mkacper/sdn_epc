defmodule SdnEpc.OfshCalls do

  require Logger

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    SdnEpc.Forwarder.subscribe_messages_from_switch datapatch_id, :packet_in
    {:ok, datapatch_id}
  end

  def handle_message(msg = {:packet_in, _xid, _body}, _datapatch_id)  do
    Logger.info "Packet in message received" 
    IO.inspect msg
    :ok
  end
end
