defmodule SdnEpc.OfshCalls do

  require Logger

  # :ofs_handler callbacks

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    {:ok, ofpc_sup} = start_ofp_channel_sup()
    open_ofp_channel ofpc_sup
    SdnEpc.Forwarder.subscribe_messages_from_switch datapatch_id, :packet_in
    {:ok, datapatch_id}
  end

  def handle_message(msg = {:packet_in, _xid, _body}, _datapatch_id)  do
    Logger.info "Packet in message received"
    IO.inspect msg
    :ok
  end

  # Helper functions

  defp start_ofp_channel_sup do
    ofpc_sup_spec = Supervisor.Spec.supervisor(:ofp_channel_sup, [1])
    Supervisor.start_child SdnEpc.Supervisor, ofpc_sup_spec
  end

  defp open_ofp_channel(ofpc_sup) do
    chan_conf = Application.get_all_env :sdn_epc
    SdnEpc.Forwarder.open_ofp_channel ofpc_sup, chan_conf[:channel_id],
      chan_conf[:controller_ip], chan_conf[:controller_port],
      chan_conf[:channel_version]
  end
end
