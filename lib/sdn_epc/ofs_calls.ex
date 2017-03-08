defmodule SdnEpc.OfshCalls do

  require Logger

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    Logger.info "Datapath id is #{datapatch_id}"
    IO.inspect datapatch_id
    {:ok, datapatch_id}
  end

  def handle_message(msg = {:packet_in, xid, body}, datapatch_id)  do
    Logger.info "Packet in message received" 
    IO.inspect msg
    :ok
  end
end
