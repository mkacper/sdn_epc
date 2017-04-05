ExUnit.start()

defmodule SdnEpc.OfsHandler.InMemory do
  def subscribe(datapath_id, _callback_module, type) do
    case Process.whereis(SdnEpc.ForwarderTest) do
      nil -> :ok
      _ -> Kernel.send(SdnEpc.ForwarderTest, {datapath_id, type})
    end
  end

  def send(datapath_id, {:test, msg}) do
    case Process.whereis(SdnEpc.ForwarderTest) do
      nil -> :ok
      _ -> Kernel.send(SdnEpc.ForwarderTest, {datapath_id, msg})
    end
  end
  def send(_, _) do
    :ok
  end
end

defmodule SdnEpc.OfpChannel.InMemory do
  def send(datapath_id, _msg) do
    Kernel.send(SdnEpc.ForwarderTest, datapath_id)
  end

  def open(sup, datapath_id, {:remote_peer, ip, port, _}, [_,
        {:version, version}]) do
    case Process.whereis(SdnEpc.ForwarderTest) do
      nil -> :ok
      _ -> Kernel.send(SdnEpc.ForwarderTest, {sup, datapath_id, ip, port,
                                             version})
    end
    {:ok, nil}
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
