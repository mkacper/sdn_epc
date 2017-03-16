defmodule SdnEpc.ForwarderTest do
  use ExUnit.Case, async: true
  import SdnEpc.Forwarder

  test "save datapath id" do
    assert save_datapath_id('00:00:00:00:00:00:01') == :ok
  end

  test "subscribe messages from switch" do
    assert subscribe_messages_from_switch(
      '00:00:00:00:00:00:00:01', [:aa, :bb]) == :ok
  end

  test "send message to switch" do
    # GIVEN
    msg = {:ofp_message, 0, :msg}
    pid = Process.whereis(SdnEpc.Forwarder)

    # WHEN
    send(SdnEpc.Forwarder, msg)

    # THEN
    assert Process.alive?(pid) # need improvement
  end
end
