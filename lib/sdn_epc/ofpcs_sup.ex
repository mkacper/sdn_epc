defmodule SdnEpc.OfpcsSup do
  use Supervisor
  @moduledoc """
  Supervisor module for OpenFlow channels.
  """

  @doc """
  Starts OpenFlow channel supervisor.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(:ofp_channel_sup, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
