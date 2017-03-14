defmodule SdnEpc.OfshCalls do

  require Logger

  # :ofs_handler callbacks

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    {:ok, ofpc_sup} = start_ofp_channel_sup()
    open_ofp_channel(ofpc_sup)
    SdnEpc.Forwarder.subscribe_messages_from_switch(datapatch_id, :packet_in)
    SdnEpc.Forwarder.subscribe_messages_from_switch(datapatch_id, :features_reply)
    SdnEpc.Forwarder.subscribe_messages_from_switch(datapatch_id, :port_desc_reply)
    {:ok, datapatch_id}
  end

  def handle_message(msg, _datapatch_id)  do
    Logger.info("Message received from switch")
    SdnEpc.Forwarder.send_msg_to_controller(1, msg)
  end

  # Helper functions

  defp start_ofp_channel_sup do
    Supervisor.start_child(SdnEpc.OfpcsSup, [1])
  end

  defp open_ofp_channel(ofpc_sup) do
    chan_conf = Application.get_all_env(:sdn_epc)
    SdnEpc.Forwarder.open_ofp_channel(ofpc_sup, chan_conf[:channel_id],
      chan_conf[:controller_ip], chan_conf[:controller_port],
      chan_conf[:ofp_version])
  end
end
