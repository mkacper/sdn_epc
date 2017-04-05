defmodule SdnEpc.OfpmRecordTest do
  use ExUnit.Case, async: true
  require SdnEpc.OfpmRecord
  require Record

  test "create ofp_message record" do
    SdnEpc.OfpmRecord.ofp_message()
    |> Record.is_record(:ofp_message)
    |> assert()
  end
end
