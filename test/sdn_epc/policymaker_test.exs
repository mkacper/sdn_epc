defmodule SdnEpc.PolicymakerTest do
  use ExUnit.Case, async: false

  @count_duration Application.get_env(:sdn_epc, :pic_count_duration)
  @msgs_limit Application.get_env(:sdn_epc, :pic_msgs_limit)
  @drop_duration Application.get_env(:sdn_epc, :pic_drop_duration)

  setup do
    Application.stop(:sdn_epc)
    :ok = Application.start(:sdn_epc)
  end

  test "detect DDos" do
    # GIVEN
    msg = OfpMessage.get(:packet_in)
    receive_timeout = SdnEpc.TestHelper.calculate_receive_timeout(@drop_duration)
    datapath_id = '01'

    # WHEN
    simulate_ddos(msg)
    SdnEpc.Forwarder.send_msg_to_controller({datapath_id, self()}, msg)

    # THEN
    refute_receive(^datapath_id, receive_timeout)
  end

  test "change blocking_time to false after drop duration
    (when DDoS occured)" do
    # GIVEN
    msg = OfpMessage.get(:packet_in)
    drop_duration_timeout = @drop_duration * 1000 + 1100
    datapath_id = '01'

    # WHEN
    simulate_ddos(msg)
    Process.sleep(drop_duration_timeout)
    SdnEpc.Forwarder.send_msg_to_controller({datapath_id, self()}, msg)

    # THEN
    assert_receive(^datapath_id)
  end

  test "kill Forwarder after switch mode call timeout" do
    # GIVEN
    sw_mode_timeout = 10
    count_duration_timeout = @count_duration * 1000
    msg = OfpMessage.get(:packet_in)
    datapath_id = '01'
    send_fake_msg =
    fn() ->
      for _ <- 1..100 do
        SdnEpc.Forwarder.send_msg_to_controller(datapath_id, msg)
      end
    end

    # WHEN
    Application.put_env(:sdn_epc, :pm_sw_mode_timeout, sw_mode_timeout)
    Process.send_after(self(), :stop, count_duration_timeout)
    fill_up_forwarder_when_count_duration(sw_mode_timeout, send_fake_msg)

    # THEN
    refute Process.whereis(SdnEpc.Forwarder)
  end

  defp simulate_ddos(msg) do
    timeout_to_detect_ddos = @count_duration * 1000
    for _ <- 1..100 do
      SdnEpc.Policymaker.update_msgs_stats(msg)
    end
    Process.sleep(timeout_to_detect_ddos)
  end

  defp fill_up_forwarder_when_count_duration(timeout, fun) do
    receive do
      :stop -> :ok
    after
      timeout ->
        spawn(fun)
        fill_up_forwarder_when_count_duration(timeout, fun)
    end
  end
end
