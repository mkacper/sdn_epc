defmodule SdnEpc do
  use Application
  @moduledoc """
  Application main module for starting the whole app.
  """

  @doc """
  Starts the main supervisor and links to it.

  In fact it is an Application behaviour callback `c:start/2`
  """
  @spec start(type :: Application.start_type(),
    args :: term()) :: Supervisor.on_start_child()
  def start(_type, _args) do
    SdnEpc.Supervisor.start_link()
  end
end
