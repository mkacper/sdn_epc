defmodule SdnEpc.Converter do
  require Record
  require SdnEpc.OfpmRecord
  @moduledoc """
  This modules provides converting OpenFlow messages received from
  `:ofs_handler` lib to Erlang/Elixir records.
  """

  @type ofp_message() :: {:ofp_message, integer(), integer(), tuple()}

  @ofp_version Application.get_env(:sdn_epc, :ofp_version)

  @doc """
  Convert OpenFlow message to Elixir/Erlang record.
  """
  @spec convert(msg :: tuple()) :: ofp_message() 
  def convert(msg) do
    SdnEpc.OfpmRecord.ofp_message(
      version: @ofp_version,
      xid: elem(msg, 1),
      body: build_body(msg))
  end

  defp build_body({:packet_in, _xid, body}) do
    ofp_packet_in(body)
  end
  defp build_body({:features_reply, _xid, body}) do
    ofp_features_reply(body)
  end
  defp build_body({:port_desc_reply, _xid, body}) do
    ofp_port_desc_reply(body)
  end

  defp ofp_packet_in([
    buffer_id: buffer_id,
    reason: reason,
    table_id: table_id,
    cookie: cookie,
    match: match,
    data: data
  ]) do
    match_rec =
      SdnEpc.OfpmRecord.ofp_match(
        fields: Enum.map(match, &(ofp_field(&1))))
    SdnEpc.OfpmRecord.ofp_packet_in(
      buffer_id: buffer_id,
      total_len: byte_size(data),
      reason: reason,
      table_id: table_id,
      cookie: cookie,
      match: match_rec,
      data: data)
  end

  defp ofp_field({name, value}) do
    SdnEpc.OfpmRecord.ofp_field(name: name, value: value)
  end

  defp ofp_features_reply([
    datapath_mac: datapatch_mac,
    datapath_id: datapatch_id,
    n_buffers: n_buffers,
    n_tables: n_tables,
    auxiliary_id: auxiliary_id,
    capabilities: capabilities
  ]) do
    SdnEpc.OfpmRecord.ofp_features_reply(
      datapath_mac: datapatch_mac,
      datapath_id: datapatch_id,
      n_buffers: n_buffers,
      n_tables: n_tables,
      auxiliary_id: auxiliary_id,
      capabilities: capabilities)
  end

  defp ofp_port_desc_reply([
    flags: flags,
    ports: ports
  ]) do
    SdnEpc.OfpmRecord.ofp_port_desc_reply(
      flags: flags,
      body: Enum.map(ports, &(ofp_port(&1))))
  end

  defp ofp_port([
    port_no: port_no,
    hw_addr: hw_addr,
    name: name,
    config: config,
    state: state,
    curr: curr,
    advertised: advertised,
    supported: supported,
    peer: peer,
    curr_speed: curr_speed,
    max_speed: max_speed
  ]) do
    SdnEpc.OfpmRecord.ofp_port(
      port_no: port_no,
      hw_addr: hw_addr,
      name: name,
      config: config,
      state: state,
      curr: curr,
      advertised: advertised,
      supported: supported,
      peer: peer,
      curr_speed: curr_speed,
      max_speed: max_speed)
  end
end
