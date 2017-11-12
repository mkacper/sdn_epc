defmodule SdnEpc.ForwarderTest do
  use ExUnit.Case, async: true

  setup_all do
    Supervisor.start_child(SdnEpc.ForwarderSup, [:forwarder_test])
    :ok
  end

  test "save datapath id" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = "hello_world"

    # WHEN
    SdnEpc.Forwarder.save_datapath_id(:forwarder_test, datapath_id)
    send(:forwarder_test, {:ofp_message, self(), {:test, self(), msg}})

    # THEN
    assert_receive({^datapath_id, ^msg})
  end

  test "send message to controller" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    msg = OfpMessage.get(:packet_in)

    # WHEN
    SdnEpc.Forwarder.send_msg_to_controller(:forwarder_test,
      {datapath_id, self()}, msg)
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
    SdnEpc.Forwarder.open_ofp_channel(:forwarder_test, sup, datapath_id, ip,
      port, version)

    # THEN
    assert_receive({^me, ^datapath_id, ^ip, ^port, ^version})
  end
end
