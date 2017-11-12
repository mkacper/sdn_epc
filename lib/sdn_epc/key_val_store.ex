defmodule SdnEpc.KeyValStore do
  require Record
  @mnesia_packet_store Application.get_env(:sdn_epc, :mnesia_packet_store)
  @mnesia_stat_store Application.get_env(:sdn_epc, :mnesia_stat_store)
  @moduledoc """
  The module provides API for storing and manipulating data.
  """

  Record.defrecord :record, key: nil, val: nil

  ## Client API

  def init_basic_schema() do
    init()
    create_basic_stores()
  end

  def init() do
    configure_cluster_nodes()
  end

  def new(name) do
    create_store(name)
  end

  def write(name, {key, val}) do
    record = record(key: key, val: val)
    write_record_to_store(name, record)
  end

  def read(name, key) do
    read_record_from_store(name, key)
  end

  def dump_to_list_and_clear(name) do
    dump_and_clear_store(name)
  end

  ## Helpers

  defp configure_cluster_nodes() do
    :mnesia.change_config(:extra_db_nodes, Node.list)
  end

  defp create_store(name) do
    :mnesia.create_table(name,
      [attributes: get_record_fields(),
       record_name: :record,
       ram_copies: Node.list,
       type: :set])
  end

  defp get_record_fields() do
    get_record_info()
    |> Keyword.keys
  end

  defp get_record_info do
    record()
    |> record
  end

  defp create_basic_stores() do
    for store <- [@mnesia_stat_store, @mnesia_packet_store], do: new(store)
    write(@mnesia_stat_store, {:packets, 0})
    write(@mnesia_stat_store, {:tresholds, []})
  end

  defp write_record_to_store(name, record) do
    f = fn() -> :mnesia.write(name, record, :write) end
    :mnesia.activity(:sync_transaction, f)
  end

  defp read_record_from_store(name, key) do
    f = fn() -> :mnesia.read(name, key) end
    :mnesia.activity(:sync_transaction, f)
    |> verify_result()
  end

  defp verify_result([]) do
    nil
  end
  defp verify_result(res) do
    res
  end

  defp dump_and_clear_store(name) do
    catch_all_spec = [{:"_",[],[:"$_"]}]
    f = fn() ->
      :mnesia.select(name, catch_all_spec)
    end
    select = :mnesia.activity(:sync_transaction, f)
    :mnesia.clear_table(name)
    select
  end

end
