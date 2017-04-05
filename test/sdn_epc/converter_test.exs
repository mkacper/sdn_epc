defmodule SdnEpc.ConverterTest do
  use ExUnit.Case, async: true
  require Record

  test "convert packet in message" do
    # GIVEN
    msg = OfpMessage.get(:packet_in)
    # WHEN
    ofp_message = {_, _, _, _, ofp_msg_content} = SdnEpc.Converter.convert(msg)
    
    # THEN
    assert Record.is_record(ofp_message, :ofp_message)
    assert Record.is_record(ofp_msg_content, :ofp_packet_in)
  end

  test "convert features reply" do
    # GIVEN
    msg = OfpMessage.get(:features_reply) 

    # WHEN
    ofp_message = {_, _, _, _, ofp_msg_content} = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(ofp_message, :ofp_message)
    assert Record.is_record(ofp_msg_content, :ofp_features_reply)
  end

  test "convert port desc reply" do
    # GIVEN
    msg = OfpMessage.get(:port_desc_reply)
    # WHEN
    ofp_message = {_, _, _, _, ofp_msg_content} = SdnEpc.Converter.convert(msg)

    # THEN
    assert Record.is_record(ofp_message, :ofp_message)
    assert Record.is_record(ofp_msg_content, :ofp_port_desc_reply)
  end
end
