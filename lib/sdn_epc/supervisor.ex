defmodule SdnEpc.Supervisor do
  use Supervisor
  @moduledoc """
  The main application's supervisor module.
  """

  @doc """
  Starts main supervisor.
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(SdnEpc.Forwarder, []),
      supervisor(SdnEpc.OfpcsSup, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
