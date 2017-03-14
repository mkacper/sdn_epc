defmodule SdnEpc.Converter do
  require SdnEpc.OfpmRecord

  @ofp_version Application.get_env(:sdn_epc, :ofp_version)

  def convert({:packet_in, xid, body}) do
    packet_in_rec = ofp_packet_in(body)
    SdnEpc.OfpmRecord.ofp_message(
      version: @ofp_version,
      xid: xid,
      body: packet_in_rec)
  end
  def convert({:features_reply, xid, body}) do
    features_reply_rec = ofp_features_reply(body)
    SdnEpc.OfpmRecord.ofp_message(
      version: @ofp_version,
      xid: xid,
      body: features_reply_rec)
  end
  def convert({:port_desc_reply, xid, body}) do
    port_desc_reply_rec = ofp_port_desc_reply(body)
    SdnEpc.OfpmRecord.ofp_message(
      version: @ofp_version,
      xid: xid,
      body: port_desc_reply_rec)
  end

  defp ofp_packet_in([
    buffer_id: buffer_id,
    reason: reason,
    table_id: table_id,
    cookie: cookie,
    match: [in_port: value],
    data: data
  ]) do
    field_rec =
      SdnEpc.OfpmRecord.ofp_field(
        name: :in_port,
        value: value)
    match_rec =
      SdnEpc.OfpmRecord.ofp_match(
        fields: [
          field_rec
        ])
    SdnEpc.OfpmRecord.ofp_packet_in(
      buffer_id: buffer_id,
      total_len: byte_size(data),
      reason: reason,
      table_id: table_id,
      cookie: cookie,
      match: match_rec,
      data: data)
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
