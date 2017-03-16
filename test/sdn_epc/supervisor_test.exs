defmodule SdnEpc.SupervisorTest do
  use ExUnit.Case, async: true

  test "is SdnEpc.Forwarder started" do
    {:ok, _} = Application.ensure_all_started(:sdn_epc)
    assert SdnEpc.Forwarder
    |> Process.whereis()
    |> Process.alive?()
  end

  test "is SdnEpc.OfpcsSup started" do
    {:ok, _} = Application.ensure_all_started(:sdn_epc)
    assert SdnEpc.OfpcsSup
    |> Process.whereis()
    |> Process.alive?()
  end
end
