defmodule SdnEpc.Policymaker do
  require Logger
  use GenServer
  @window_size Application.get_env(:sdn_epc, :window_size)
  @treshold Application.get_env(:sdn_epc, :treshold)
  @moduledoc """
  The modules is resposible for DDoS policy. It caluclates randomness
  of the incoming packets (entropy) based on it's destatination addresses.
  """

  defstruct packets: 0, tresholds: [] 

  ## Client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update({:packet_in, _, body}) do
    Task.start(__MODULE__, :update_async_packet_in, [body])
  end
  def update(_) do
    :ok
  end

  def update_async_packet_in(packet_in) do
    packet_in
    |> update_window
    |> notify_policymaker
  end

  ## GenServer callbacks

  def init([]) do
    create_ets()
    {:ok, %__MODULE__{}}
  end

  def handle_cast(:packet_in,
    state = %__MODULE__{packets: packets}) when packets < @window_size - 1 do
    new_state = %__MODULE__{state | packets: packets + 1}
    {:noreply, new_state}
  end
  def handle_cast(:packet_in, %__MODULE__{tresholds: tresholds}) do
    treshold =
      get_window()
      |> get_treshold
    {policy, tresholds} = check_tresholds([treshold | tresholds])
    introduce_policy(policy)
    new_state = %__MODULE__{packets: 0, tresholds: tresholds}
    {:noreply, new_state}
  end

  ## Helpers

  defp update_window([_, _, _, _, _, data: data]) do
    data
    |> get_dst_ip
    |> inc_ip
  end

  defp get_dst_ip(data) do
    data
    |> :pkt.decode
    |> get_ipv4_header
    |> get_ipv4_dst_addr
  end

  defp get_ipv4_header({:ok, {headers, _}}) do
    headers
    |> List.keyfind(:ipv4, 0)
  end

  defp get_ipv4_dst_addr(nil), do: nil
  defp get_ipv4_dst_addr(ipv4), do: elem(ipv4, 12)

  defp inc_ip(nil), do: false
  defp inc_ip(addr) do
    :ets.update_counter(__MODULE__, addr, {2, 1}, {addr, 0})
  end

  defp notify_policymaker(false), do: :ok
  defp notify_policymaker(_), do: GenServer.cast(__MODULE__, :packet_in)

  defp create_ets() do
    ets_opts = [:named_table, :public, write_concurrency: true,
                read_concurrency: true]
    :ets.new(__MODULE__, ets_opts)
  end

  defp get_window() do
    window = :ets.tab2list(__MODULE__)
    :ets.delete_all_objects(__MODULE__)
    window
  end

  defp get_treshold(window) do
    window
    |> get_true_window_size()
    |> caluclate_addr_prob(window)
    |> calculate_treshold
  end

  defp get_true_window_size(window) do
    List.foldl(window, 0, fn({_, x}, w_size) -> x + w_size end)
  end

  defp caluclate_addr_prob(w_size, window) do
    Enum.map(window, fn({addr, occurs}) -> {addr, occurs/w_size} end)
  end

  defp calculate_treshold(window_prob) do
    -1 * List.foldl(window_prob, 0,
       fn({_, p}, h) -> h + (p * :math.log10(p)) end)
  end

  defp check_tresholds(tresholds) when length(tresholds) < 5 do
    {:true, tresholds}
  end
  defp check_tresholds(tresholds) do
    {Enum.all?(tresholds, &(&1 > @treshold)), []}
  end

  defp introduce_policy(true), do: []
  defp introduce_policy(false) do
    IO.puts("DDos deteced")
  end

end
