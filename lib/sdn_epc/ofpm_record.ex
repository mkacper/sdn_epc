defmodule SdnEpc.OfpmRecord do
  require Record
  @moduledoc false

  ofm_path = Application.get_env(:sdn_epc, :ofm_record)
  ofmb_path = Application.get_env(:sdn_epc, :ofmb_record)

  @types [
    ofp_message: ofm_path,
    ofp_packet_in: ofmb_path,
    ofp_match: ofmb_path,
    ofp_field: ofmb_path,
    ofp_features_reply: ofmb_path,
    ofp_port_desc_reply: ofmb_path,
    ofp_port: ofmb_path,
  ]

  for {type, path} <- @types do
    record = Record.extract(type, from: path)
    Record.defrecord(type, record)
  end
end
