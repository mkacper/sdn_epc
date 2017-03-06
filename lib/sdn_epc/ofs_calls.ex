defmodule SdnEpc.OfshCalls do

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    response = {:ok, datapatch_id}
    inspect response
  end
end
