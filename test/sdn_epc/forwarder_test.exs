defmodule SdnEpc.ForwarderTest do
  use ExUnit.Case, async: true
  import SdnEpc.Forwarder

  test "save datapath id" do
    # GIVEN
    Process.register(self(), SdnEpc.ForwarderTest)
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = "hello_world"

    # WHEN
    save_datapath_id(datapath_id)
    send(SdnEpc.Forwarder, {:ofp_message, self(), {:test, msg}})

    # THEN
    assert_receive({^datapath_id, ^msg})
  end

  test "subscribe messages from switch" do
    # GIVEN
    Process.register(self(), SdnEpc.ForwarderTest)
    datapath_id = '00:00:00:00:00:00:00:01'
    types = [:hello, :world]

    # WHEN
    subscribe_messages_from_switch(datapath_id, types)

    # THEN
    for type <- types, do: assert_receive({^datapath_id, ^type})
  end

  test "send message to controller" do
    # GIVEN
    Process.register(self(), SdnEpc.ForwarderTest)
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = OfpMessage.get(:packet_in)

    # WHEN
    send_msg_to_controller(datapath_id, msg)
    # THEN
    assert_receive(^datapath_id)
  end

  test "open ofp channel" do
    # GIVEN
    Process.register(self(), SdnEpc.ForwarderTest)
    datapath_id = "1"
    sup = 1
    ip = {0,0,0,0}
    port = 0
    version = 0

    # WHEN
    open_ofp_channel(sup, datapath_id, ip, port, version)

    # THEN
    assert_receive({^sup, ^datapath_id, ^ip, ^port, ^version})
  end
end
