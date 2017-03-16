use Mix.Config

config :sdn_epc,
  ofp_version: 4,
  channel_id: "1",
  controller_ip: {192,168,56,101},
  controller_port: 6653,
  switch_id: 1,
  ofm_record: "deps/of_protocol/include/of_protocol.hrl",
  ofmb_record: "deps/of_protocol/include/ofp_v4.hrl"

config :of_driver,
  listen_ip: {0,0,0,0},
	listen_port: 6653,
	listen_opts: [:binary, {:packet, :raw}, {:active, false}, {:reuseaddr, true}],
  of_compatible_versions: [4],
  callback_module: :ofs_handler_driver,
  enable_ping: false,
  ping_timeout: 1000,
  ping_idle: 5000,
  multipart_timeout: 30000       # IMPLEMENT

config :ofs_handler,
  callback_module: SdnEpc.OfshCall,
  peer: "localhost",
  callback_opts: []

config :logger, level: :debug
