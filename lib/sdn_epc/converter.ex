defmodule SdnEpc.Converter do
  require SdnEpc.OfpmRecord

  def ofp_packet_in({:packet_in, xid, [
                                buffer_id: buffer_id,
                                reason: reason,
                                table_id: table_id,
                                cookie: cookie,
                                match: [in_port: value],
                                data: data
                              ]}) do
    field_rec =
      SdnEpc.OfpmRecord.ofp_field(
        name: :in_port,
        value: value
        )
    match_rec =
      SdnEpc.OfpmRecord.ofp_match(
        fields: [
          field_rec
        ])
    packet_in_rec =
      SdnEpc.OfpmRecord.ofp_packet_in( 
        buffer_id: buffer_id,
        total_len: byte_size(data),
        reason: reason,
        table_id: table_id,
        cookie: cookie,
        match: match_rec,
        data: data)
    SdnEpc.OfpmRecord.ofp_message(
      version: Application.get_env(:sdn_epc, :ofp_version),
      xid: xid,
      body: packet_in_rec)
  end
end
