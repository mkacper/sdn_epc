defmodule SdnEpc.OfpmRecord do
  require Record

  ofm_path = Application.get_env(:sdn_epc, :ofm_record)
  ofpi_path = Application.get_env(:sdn_epc, :ofpi_record)

  ofp_message = Record.extract(:ofp_message, from: ofm_path)
  ofp_packet_in = Record.extract(:ofp_packet_in, from: ofpi_path)
  ofp_match = Record.extract(:ofp_match, from: ofpi_path)
  ofp_field = Record.extract(:ofp_field, from: ofpi_path)

  Record.defrecord(:ofp_message, ofp_message)
  Record.defrecord(:ofp_packet_in, ofp_packet_in)
  Record.defrecord(:ofp_match, ofp_match)
  Record.defrecord(:ofp_field, ofp_field)
end
