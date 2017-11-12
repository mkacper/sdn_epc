defmodule SdnEpc.Policymaker do
  require Logger
  use GenServer
  @window_size Application.get_env(:sdn_epc, :window_size)
  @treshold Application.get_env(:sdn_epc, :treshold)
  @ipv4_ether_type 0x0800
  @mnesia_packet_store Application.get_env(:sdn_epc, :mnesia_packet_store)
  @mnesia_stat_store Application.get_env(:sdn_epc, :mnesia_stat_store)
  @moduledoc """
  The modules is resposible for DDoS policy. It caluclates randomness
  of the incoming packets (entropy) based on it's destatination addresses.
  """

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

  def get_mean_treshold() do
    GenServer.call(__MODULE__, :get_tresholds)
  end

  ## GenServer callbacks

  def init([]) do
    {:ok, []}
  end

  def handle_call(:get_tresholds, _from, tresholds) do
    t = List.foldl(tresholds, 0, fn(t, acc) -> t + acc end) / length(tresholds)
    {:reply, {t, length(tresholds)}, []}
  end

  def handle_cast(:packet_in, state) do
    current_window_size =  get_current_window_size()
    t = handle_packet_in(current_window_size)
    {:noreply, List.flatten([t | state])} #for stats purposes
  end

  ## Helpers

  defp get_current_window_size() do
    [{_, _, size}] = SdnEpc.KeyValStore.read(@mnesia_stat_store, :packets)
    size
  end

  defp handle_packet_in(current_window_size) when
    current_window_size > @window_size - 1 do
    update_packets_stats()
    treshold =
      get_window()
      |> get_treshold
    tresholds = get_tresholds()
    {policy, new_tresholds} = check_tresholds([treshold | tresholds])
    update_tresholds(new_tresholds)
    introduce_policy(policy)
    treshold # for stats
  end
  defp handle_packet_in(_) do
    []
  end

  defp update_window([_, _, _, _, _, data: data]) do
    data
    |> get_dst_ip
    |> inc_ip
  end

  defp get_dst_ip(data) do
    data
    |> get_ipv4_header
    |> get_ipv4_dst_addr
  end

  defp get_ipv4_header(<<_no_matter_fields::binary-size(12),
    <<@ipv4_ether_type::size(16)>>, payload::binary>>), do: payload
  defp get_ipv4_header(_), do: nil

  defp get_ipv4_dst_addr(nil), do: nil
  defp get_ipv4_dst_addr(<<_no_matter_fields::binary-size(16), dst1::integer,
    dst2::integer, dst3::integer, dst4::integer, _rest::binary>>) do
    {dst1, dst2, dst3, dst4}
  end

  defp inc_ip(nil), do: false
  defp inc_ip(addr) do
    update_packet_store(addr)
    update_stat_store()
  end

  defp update_packet_store(addr) do
    addr
    |> get_packet_record
    |> verify_packet_record
    |> update_packet_record
  end

  defp get_packet_record(addr) do
    {addr, SdnEpc.KeyValStore.read(@mnesia_packet_store, addr)}
  end

  defp verify_packet_record({addr, nil}) do
    {addr, 1}
  end
  defp verify_packet_record({_, [{_, addr, occurence}]}) do
    {addr, occurence + 1}
  end

  defp update_packet_record(key_val_pair) do
    SdnEpc.KeyValStore.write(@mnesia_packet_store, key_val_pair)
  end

  defp update_stat_store() do
    get_stat_record()
    |> update_stat_record
  end

  defp get_stat_record() do
    SdnEpc.KeyValStore.read(@mnesia_stat_store, :packets)
  end

  defp update_stat_record([{_, key, packets}]) do
    SdnEpc.KeyValStore.write(@mnesia_stat_store, {key, packets + 1})
  end

  defp notify_policymaker(false), do: :ok
  defp notify_policymaker(_), do: GenServer.cast(__MODULE__, :packet_in)

  defp get_window() do
    SdnEpc.KeyValStore.dump_to_list_and_clear(@mnesia_packet_store)
  end

  defp get_treshold(window) do
    window
    |> get_true_window_size()
    |> caluclate_addr_prob(window)
    |> calculate_treshold
  end

  defp get_true_window_size(window) do
    List.foldl(window, 0, fn({_, _, x}, w_size) -> x + w_size end)
  end

  defp caluclate_addr_prob(w_size, window) do
    Enum.map(window, fn({_, addr, occurs}) -> {addr, occurs/w_size} end)
  end

  defp calculate_treshold(window_prob) do
    -1 * List.foldl(window_prob, 0,
       fn({_, p}, h) -> h + (p * :math.log10(p)) end)
  end

  defp get_tresholds() do
    [{_, _, tresholds}] = SdnEpc.KeyValStore.read(@mnesia_stat_store, :tresholds)
    tresholds
  end

  defp check_tresholds(tresholds) when length(tresholds) < 5 do
    {true, tresholds}
  end
  defp check_tresholds(tresholds) do
    {Enum.all?(tresholds, &(&1 > @treshold)), []}
  end

  defp update_packets_stats() do
    SdnEpc.KeyValStore.write(@mnesia_stat_store, {:packets, 0})
  end

  defp update_tresholds(tresholds) do
    SdnEpc.KeyValStore.write(@mnesia_stat_store, {:tresholds, tresholds})
  end

  defp introduce_policy(true), do: []
  defp introduce_policy(false) do
    IO.puts("DDos deteced")
  end

end
