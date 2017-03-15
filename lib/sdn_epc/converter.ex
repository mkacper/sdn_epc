defmodule SdnEpc.Converter do
  require SdnEpc.OfpmRecord

  @ofp_version Application.get_env(:sdn_epc, :ofp_version)

  def convert({:packet_in, xid, body}) do
    packet_in_rec = ofp_packet_in(body)
    build_ofp_msg(xid, packet_in_rec)
  end
  def convert({:features_reply, xid, body}) do
    features_reply_rec = ofp_features_reply(body)
    build_ofp_msg(xid, features_reply_rec)
  end
  def convert({:port_desc_reply, xid, body}) do
    port_desc_reply_rec = ofp_port_desc_reply(body)
    build_ofp_msg(xid, port_desc_reply_rec)
  end

  defp build_ofp_msg(xid, record) do
    SdnEpc.OfpmRecord.ofp_message(
      version: @ofp_version,
      xid: xid,
      body: record)
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
