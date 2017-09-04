defmodule SdnEpc.ForwarderSup do
  use Supervisor
  @moduledoc """
  Supervisor module for OpenFlow channels.
  """

  @doc """
  Starts OpenFlow channel supervisor.
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(SdnEpc.Forwarder, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
