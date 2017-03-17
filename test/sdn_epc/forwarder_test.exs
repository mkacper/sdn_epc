defmodule SdnEpc.ForwarderTest do
  use ExUnit.Case, async: true
  import SdnEpc.Forwarder

  test "save datapath id" do
    # GIVEN
    datapath_id = '00:00:00:00:00:00:00:01'
    port = Application.get_env(:sdn_epc, :ofs_handler_test_port)
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: 0, active: false, reuseaddr: true])
    
    # WHEN
    save_datapath_id(datapath_id)
    send(SdnEpc.Forwarder, {:ofp_message, self(), {:test, "hello_world"}})
    {:ok, client} = :gen_tcp.accept(socket)

    # THEN
    assert :gen_tcp.recv(client, 0) == {:ok, "hello_world"}
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
