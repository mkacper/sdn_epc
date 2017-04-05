defmodule SdnEpcTest do
  use ExUnit.Case
  doctest SdnEpc

  test "is main supervisor started with app" do
    {:ok, _} = Application.ensure_all_started(:sdn_epc)
    assert Process.whereis(SdnEpc.Supervisor)
  end
end
