defmodule SdnEpc.Policymaker do

  @count_duration Application.get_env(:sdn_epc, :pic_count_duration)
  @msgs_limit Application.get_env(:sdn_epc, :pic_msgs_limit)
  @drop_duration Application.get_env(:sdn_epc, :pic_drop_duration)

  # API functions

  @spec forward?(%{start_time: integer(),
                   count: integer()}) :: boolean()
  def forward?(%{start_time: start_time, count: count_msgs}) do
    SdnEpc.PolicymakerStash.get_drop_start_time()
    |> get_drop_duration()
    |> _forward?(start_time, count_msgs)
  end

  # Helper functions

  defp _forward?(drop_duration, _, _) when drop_duration <= @drop_duration do
    false
  end
  defp _forward?(_, start_time, count_msgs) do
    !drop?(get_count_duration(start_time), count_msgs)
  end

  defp drop?(count_duration, count_msgs) when count_duration >= @count_duration
    and count_msgs >= @msgs_limit do
    SdnEpc.PolicymakerStash.set_drop_start_time(System.system_time(:seconds))
    true
  end
  defp drop?(_, _) do
    SdnEpc.PolicymakerStash.set_drop_start_time(nil)
    false
  end

  defp get_drop_duration(nil) do
      @drop_duration + 1
  end
  defp get_drop_duration(start_time) do
    System.system_time(:seconds) - start_time
  end

  defp get_count_duration(start_time) do
    System.system_time(:seconds) - start_time 
  end
end
