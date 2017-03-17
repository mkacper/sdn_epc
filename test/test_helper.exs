ExUnit.start()

defmodule SdnEpc.OfsHandler.InMemory do
  def subscribe(_datapath_id, _callback_module, _type) do
    :ok
  end

  def send(_, {:test, msg}) do
    port = Application.get_env(:sdn_epc, :ofs_handler_test_port)
    addr = Application.get_env(:sdn_epc, :ofs_handler_test_addr)
    {:ok, socket} = :gen_tcp.connect(addr, port,
      [:binary, packet: 0, active: false, reuseaddr: true])
    :gen_tcp.send(socket, msg)
    :gen_tcp.close(socket)
  end
  def send(_, _) do
    :ok
  end
end

defmodule OfpMessage do
  def get(:packet_in) do
    field = {:in_port, <<0, 0, 0, 2>>}
    match = [field]
    packet_in = [
      buffer_id: :no_buffer,
      reason: :action,
      table_id: 0,
      cookie: <<0, 0, 0, 0, 0, 0, 0, 0>>,
      match: match,
      data: <<1, 2, 3, 4, 5>>,
    ]
    {:packet_in, 0, packet_in}
  end
  def get(:features_reply) do
    capabilities = [:aaa, :bbb, :ccc, :ddd]
    feature_reply = [
      datapath_mac: <<1, 2, 3>>,
      datapath_id: 0,
      n_buffers: 121,
      n_tables: 111,
      auxiliary_id: 0,
      capabilities: capabilities,
    ] 
    {:features_reply, 0, feature_reply}
  end
  def get(:port_desc_reply) do
    flags = []
    port = [
      port_no: 1,
      hw_addr: <<1, 2, 3>>,
      name: "aaa",
      config: [],
      state: [],
      curr: [:aa, :bb],
      advertised: [],
      supported: [],
      peer: [],
      curr_speed: 100_000,
      max_speed: 0
    ]
    ports =
    for _ <- 1..5 do
      port
    end
    port_desc_reply = [flags: flags, ports: ports]
    {:port_desc_reply, 0, port_desc_reply}
  end
end
