defmodule SdnEpc.OfshCall do
  require Logger
  @moduledoc false

  # :ofs_handler callbacks

  def init(_mode, _ip, datapath_id, _features, _version, _connection, _opts) do
    establish_connection_with_controller(datapath_id)
    subscribe_for_switch_messages(datapath_id)
    {:ok, datapath_id}
  end

  def handle_message(msg, datapath_id)  do
    Logger.debug("Message received from switch")
    switch_id = convert_mac_addr_to_int(datapath_id)
    forwarder = get_forwarder_name(datapath_id)
    SdnEpc.Forwarder.send_msg_to_controller(forwarder, switch_id, msg)
  end

  # Helper functions

  defp establish_connection_with_controller(datapath_id) do
    {:ok, ofpc_sup} = start_ofp_channel_sup(datapath_id)
    forwarder = List.to_atom(datapath_id)
    Supervisor.start_child(SdnEpc.ForwarderSup, [forwarder])
    open_ofp_channel(forwarder, ofpc_sup)
  end

  defp start_ofp_channel_sup(datapath_id) do
    switch_id = convert_mac_addr_to_int(datapath_id)
    Supervisor.start_child(SdnEpc.OfpcsSup, [switch_id])
  end

  defp convert_mac_addr_to_int(mac) do
    mac |> List.to_string() |> String.replace(":", "") |> String.to_integer(16)
  end

  defp open_ofp_channel(forwarder, ofpc_sup) do
    chan_conf = Application.get_all_env(:sdn_epc)
    SdnEpc.Forwarder.open_ofp_channel(forwarder, ofpc_sup, chan_conf[:channel_id],
      chan_conf[:controller_ip], chan_conf[:controller_port],
      chan_conf[:ofp_version])
  end

  defp subscribe_for_switch_messages(datapath_id) do
    forwarder = get_forwarder_name(datapath_id)
    SdnEpc.Forwarder.save_datapath_id(forwarder, datapath_id)
    SdnEpc.Forwarder.subscribe_messages_from_switch(forwarder,
      [:packet_in, :features_reply, :port_desc_reply])
  end

  defp get_forwarder_name(datapath_id) do
    List.to_existing_atom(datapath_id)
  end
end
