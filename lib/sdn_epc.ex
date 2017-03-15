defmodule SdnEpc do
  use Application
  @moduledoc """
  Application main module for starting the whole app.
  """

  @doc """
  Starts the main supervisor and link to it. In fact it is an Application
  behaviour callback `c:start/2`

  Returns `{:ok, pid}`
  """
  def start(_type, _args) do
    SdnEpc.Supervisor.start_link()
  end
end
