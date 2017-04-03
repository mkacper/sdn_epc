use Mix.Config

config :sdn_epc,
  ofp_version: 4,
  channel_id: "1",
  controller_ip: {192,168,56,101},
  controller_port: 6653,
  switch_id: 1,
  ofm_record: "deps/of_protocol/include/of_protocol.hrl",
  ofmb_record: "deps/of_protocol/include/ofp_v4.hrl",
  ofs_handler: SdnEpc.OfsHandler.InMemory,
  ofs_handler_test_addr: {127,0,0,1},
  ofs_handler_test_port: 1111
