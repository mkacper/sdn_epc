defmodule SdnEpc.ConverterTest do
  use ExUnit.Case, async: true
  require Record

  test "convert packet in message" do
    # GIVEN
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
    msg = {:packet_in, 0, packet_in}

    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record msg_converted
  end

  test "convert features reply" do
    # GIVEN
    capabilities = [:aaa, :bbb, :ccc, :ddd]
    feature_reply = [
      datapath_mac: <<1, 2, 3>>,
      datapath_id: 0,
      n_buffers: 121,
      n_tables: 111,
      auxiliary_id: 0,
      capabilities: capabilities,
    ] 
    msg = {:features_reply, 0, feature_reply}

    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(msg_converted)
  end

  test "convert port desc reply" do
    # GIVEN
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
    msg = {:port_desc_reply, 0, port_desc_reply}

    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(msg_converted)
  end
end
