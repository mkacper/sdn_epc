defmodule SdnEpc.PolicymakerTest do
  use ExUnit.Case, async: false

  test "detect DDos" do
    # GIVEN
    self = self()
    time = 10
    drop_time = 10
    msgs_stats = %{start_time: System.system_time(:seconds) - time * 1000, count: 100}

    # WHEN
    timer = fn() -> Process.send_after(self, :ok, drop_time * 1000 + 1000) end
    spawn(timer)

    # THEN
    check_forward_policy(msgs_stats)
  end

  defp check_forward_policy(msgs_stats) do
    for _ <- 1..100 do
      assert !SdnEpc.Policymaker.forward?(msgs_stats)
      Process.sleep(100)
    end
    receive do
      :ok ->
        msgs_stats = %{start_time: System.system_time(:seconds), count: 0}
        assert SdnEpc.Policymaker.forward?(msgs_stats)
    end
  end
end
