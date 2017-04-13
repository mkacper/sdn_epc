defmodule SdnEpc.PolicymakerStash do

  def start_link() do
    Agent.start_link(fn() -> nil end, name: __MODULE__)
  end

  def get_drop_start_time() do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

  def set_drop_start_time(start_time) do
    Agent.update(__MODULE__, fn(_state) -> start_time end )
  end
end
