defmodule SdnEpc.SwManage do

  def handle_packet_in_msg(datapatch_id) do
    :ofs_handler.subscribe(datapatch_id, SdnEpc.OfshCalls, :packet_in)
  end
end
