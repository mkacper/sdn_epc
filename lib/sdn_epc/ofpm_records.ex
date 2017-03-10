defmodule SdnEpc.OfpmRecords do
  require Record

  ofm_path = Application.get_env :sdn_epc, :ofm_record
  ofpi_path = Application.get_env :sdn_epc, :ofpi_record

  of_message = Record.extract :ofp_message, from: ofm_path 
  of_packet_in = Record.extract :ofp_packet_in, from: ofpi_path 

  Record.defrecord :of_message, of_message
  Record.defrecord :of_packet_in, of_packet_in
end
