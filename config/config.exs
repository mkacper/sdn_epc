# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :sdn_epc, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:sdn_epc, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

config :sdn_epc,
  ofp_version: 4,
  channel_id: "1",
  controller_ip: {192,168,56,101},
  controller_port: 6653,
  switch_id: 1,
  ofm_record: "deps/of_protocol/include/of_protocol.hrl",
  ofmb_record: "deps/of_protocol/include/ofp_v4.hrl",
  ofs_handler: :ofs_handler,
  ofp_channel: :ofp_channel

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

config(:exometer, report: [reporters: [{:exometer_report_graphite, [
                                                prefix: 'SdnEpc',
                                                host: '127.0.0.1',
                                                port: 2003,
                                                api_key: ''
                                              ]}]])

config(:elixometer, reporter: :exometer_report_graphite,
  env: Mix.env,
  metric_prefix: "myapp")

import_config "#{Mix.env}.exs"
