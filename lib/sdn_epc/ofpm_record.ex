defmodule SdnEpc.OfpmRecord do
  require Record

  ofm_path = Application.get_env(:sdn_epc, :ofm_record)
  ofmb_path = Application.get_env(:sdn_epc, :ofmb_record)

  ofp_message = Record.extract(:ofp_message, from: ofm_path)
  ofp_packet_in = Record.extract(:ofp_packet_in, from: ofmb_path)
  ofp_match = Record.extract(:ofp_match, from: ofmb_path)
  ofp_field = Record.extract(:ofp_field, from: ofmb_path)
  ofp_features_reply = Record.extract(:ofp_features_reply, from: ofmb_path)
  ofp_port_desc_reply = Record.extract(:ofp_port_desc_reply, from: ofmb_path)
  ofp_port = Record.extract(:ofp_port, from: ofmb_path)

  Record.defrecord(:ofp_message, ofp_message)
  Record.defrecord(:ofp_packet_in, ofp_packet_in)
  Record.defrecord(:ofp_match, ofp_match)
  Record.defrecord(:ofp_field, ofp_field)
  Record.defrecord(:ofp_features_reply, ofp_features_reply)
  Record.defrecord(:ofp_port_desc_reply, ofp_port_desc_reply)
  Record.defrecord(:ofp_port, ofp_port)
end
