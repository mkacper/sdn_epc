defmodule SdnEpc.SupervisorTest do
  use ExUnit.Case, async: true

  test "is SdnEpc.Forwarder started" do
    {:ok, _} = Application.ensure_all_started(:sdn_epc)
    assert Process.whereis(SdnEpc.Forwarder)
  end

  test "is SdnEpc.OfpcsSup started" do
    {:ok, _} = Application.ensure_all_started(:sdn_epc)
    assert Process.whereis(SdnEpc.OfpcsSup)
  end
end
