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
  ofp_channel: SdnEpc.OfpChannel.InMemory,
  pic_count_duration: 2,
  pic_msgs_limit: 10,
  pic_drop_duration: 2
