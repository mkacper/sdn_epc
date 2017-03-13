defmodule SdnEpc do
  use Application

  def start(_type, _args) do
    SdnEpc.Supervisor.start_link()
  end
end
