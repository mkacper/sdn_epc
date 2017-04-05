defmodule SdnEpc.OfshCall do
  require Logger
  @moduledoc false

  # :ofs_handler callbacks

  def init(_mode, _ip, datapath_id, _features, _version, _connection, _opts) do
    {:ok, ofpc_sup} = start_ofp_channel_sup()
    open_ofp_channel(ofpc_sup)
    SdnEpc.Forwarder.save_datapath_id(datapath_id)
    SdnEpc.Forwarder.subscribe_messages_from_switch(datapath_id,
      [:packet_in, :features_reply, :port_desc_reply])
    {:ok, datapath_id}
  end

  def handle_message(msg, _datapath_id)  do
    Logger.debug("Message received from switch")
    switch_id = Application.get_env(:sdn_epc, :switch_id)
    SdnEpc.Forwarder.send_msg_to_controller(switch_id, msg)
  end

  # Helper functions

  defp start_ofp_channel_sup() do
    switch_id = Application.get_env(:sdn_epc, :switch_id)
    Supervisor.start_child(SdnEpc.OfpcsSup, [switch_id])
  end

  defp open_ofp_channel(ofpc_sup) do
    chan_conf = Application.get_all_env(:sdn_epc)
    SdnEpc.Forwarder.open_ofp_channel(ofpc_sup, chan_conf[:channel_id],
      chan_conf[:controller_ip], chan_conf[:controller_port],
      chan_conf[:ofp_version])
  end
end
