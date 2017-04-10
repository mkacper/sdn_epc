defmodule SdnEpc.Mixfile do
  use Mix.Project

  def project do
    [app: :sdn_epc,
     version: "0.1.0",
     name: "SdnEpc",
     source_url: "https://github.com/mkacper/sdn_epc",
     elixir: "~> 1.4.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test,
                         "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :of_driver, :ofs_handler, :of_protocol,
                         :of_msg_lib, :exometer, :elixometer],
    mod: {SdnEpc, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:lager, "~> 3.2.1", override: true},
      {:ofs_handler,
       git: "https://github.com/FlowForwarding/ofs_handler", branch: "master"},
      {:ex_doc, "~> 0.15.0"},
      {:excoveralls, "~> 0.6", only: :test},
      {:inch_ex, "~>0.5.6", only: :dev},
      {:elixometer, github: "pinterest/elixometer"},
      {:exometer, github: "Feuerlabs/exometer"},
      {:edown, "~> 0.8.1", override: true},
      {:parse_trans, "~> 3.0.0", override: true},
      {:setup, github: "uwiger/setup", manager: :rebar, override: true},
      {:exometer_core, "~> 1.4.0", override: true},
      {:meck, "~> 0.8.4", override: true},
    ]
  end
end
