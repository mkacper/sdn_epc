defmodule SdnEpc.ForwarderTest do
  use ExUnit.Case, async: true

  test "save datapath id" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = "hello_world"

    # WHEN
    SdnEpc.Forwarder.save_datapath_id(datapath_id)
    send(SdnEpc.Forwarder, {:ofp_message, self(), {:test, self(), msg}})

    # THEN
    assert_receive({^datapath_id, ^msg})
  end

  test "subscribe messages from switch" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    types = [:hello, :world]

    # WHEN
    SdnEpc.Forwarder.subscribe_messages_from_switch({datapath_id, self()}, types)

    # THEN
    for type <- types, do: assert_receive({^datapath_id, ^type})
  end

  test "send message to controller" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = OfpMessage.get(:packet_in)

    # WHEN
    SdnEpc.Forwarder.send_msg_to_controller({datapath_id, self()}, msg)
    # THEN
    assert_receive(^datapath_id)
  end

  test "open ofp channel" do
    # GIVEN
    me = self()
    datapath_id = "1"
    sup = {:test, me}
    ip = {0,0,0,0}
    port = 0
    version = 0

    # WHEN
    SdnEpc.Forwarder.open_ofp_channel(sup, datapath_id, ip, port, version)

    # THEN
    assert_receive({^me, ^datapath_id, ^ip, ^port, ^version})
  end
end
