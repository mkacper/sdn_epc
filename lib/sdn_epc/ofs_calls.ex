defmodule SdnEpc.OfshCalls do

  def init(_mode, _ip, datapatch_id, _features, _version, _connection, _opts) do
    {:ok, datapatch_id}
  end
end
