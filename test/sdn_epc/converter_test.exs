defmodule SdnEpc.ConverterTest do
  use ExUnit.Case, async: true
  require Record

  test "convert packet in message" do
    # GIVEN
    msg = OfpMessage.get(:packet_in)
    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record msg_converted
  end

  test "convert features reply" do
    # GIVEN
    msg = OfpMessage.get(:features_reply) 

    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(msg_converted)
  end

  test "convert port desc reply" do
    # GIVEN
    msg = OfpMessage.get(:port_desc_reply)
    # WHEN
    msg_converted = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(msg_converted)
  end
end
