defmodule SdnEpc.Policymaker do
  require Logger
  use GenServer
  @count_duration Application.get_env(:sdn_epc, :pic_count_duration)
  @msgs_limit Application.get_env(:sdn_epc, :pic_msgs_limit)
  @drop_duration Application.get_env(:sdn_epc, :pic_drop_duration)
  @check_policy_timeout 1000
  @moduledoc false

  defstruct(temp_msg_counter: 0, msg_counter_samples: [], blocking_time: false)

  # Client API

  @spec start_link() :: GenServer.on_start()
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec update_msgs_stats(msg :: SdnEpc.Converter.ofp_message()) :: term()
  def update_msgs_stats(_msg) do
    GenServer.cast(__MODULE__, :new_message)
  end

  # Server callbacks

  def init(:ok) do
    state =
      Map.put(%__MODULE__{}, :msg_counter_samples,
        create_default_msg_counter_samples())
    check_policy_timer_start()
    {:ok, state}
  end

  def handle_cast(:new_message, state) do
    new_state = Map.update(state, :temp_msg_counter, 0, &(&1 + 1))
    {:noreply, new_state}
  end

  def handle_info(:check_policy, state = %{blocking_time: true}) do
    new_state = update_state_msg_stats(state)
    {:noreply, new_state}
  end
  def handle_info(:check_policy, state = %{blocking_time: false}) do
    new_state =
      state
      |> update_state_msg_stats()
      |> calculate_msgs_stats()
      |> check_policy()
    Logger.debug("Policy checked")
    {:noreply, new_state}
  end
  def handle_info(:end_blocking_time, state) do
    new_state = Map.put(state, :blocking_time, false)
    Logger.debug("blocking time change to false")
    {:noreply, new_state}
  end

  defp update_state_msg_stats(state = %{temp_msg_counter: tmc,
                              msg_counter_samples: mcs}) do
    updated_mcs =
      mcs
      |> Enum.drop(1)
      |> Enum.concat([tmc])
    Map.put(state, :msg_counter_samples, updated_mcs)
    |> Map.put(:temp_msg_counter, 0)
  end

  defp calculate_msgs_stats(state = %{msg_counter_samples: mcs}) do
    {Enum.reduce(mcs, 0, fn(x, acc) -> acc + x end), state}
  end

  defp check_policy({msgs_sum, state}) when msgs_sum < @msgs_limit do
    kill_forwarder_if_not_respond(SdnEpc.Forwarder.forward())
    check_policy_timer_start
    state
  end
  defp check_policy({msgs_sum, state}) do
    new_state = Map.put(state, :blocking_time, true)
    blocking_time_timer_start()
    kill_forwarder_if_not_respond(SdnEpc.Forwarder.block())
    check_policy_timer_start()
    new_state
  end

  defp kill_forwarder_if_not_respond(:ok), do: :ok
  defp kill_forwarder_if_not_respond(_) do
    Process.exit(Process.whereis(SdnEpc.Forwarder), :kill)
  end

  defp check_policy_timer_start() do
    Process.send_after(self(), :check_policy, @check_policy_timeout)
  end

  defp blocking_time_timer_start() do
    Process.send_after(self(), :end_blocking_time, @drop_duration)
  end

  defp create_default_msg_counter_samples() do
    for _ <- 1..@count_duration, do: 0
  end
end
