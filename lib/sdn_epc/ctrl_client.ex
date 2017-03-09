defmodule SdnEpc.CtrlClient do

  def start_channel_sup(switch_id) do
    {:ok, sup_pid} = :ofp_channel_sup.start_link 1
  end

  def open_channel(channel_sup_pid, switch_id, ip, port, ctrl_proc, version) do
    ip_tuple = ip |> String.split(".") |> List.to_tuple
    {:ok, conn_pid} = :ofp_channel.open channel_sup_pid,
      "ofp_channel_" <> switch_id, {:remote_peer, ip_tuple, port, :tcp},
      [{:controlling_process, ctrl_proc}, {:version, version}]
  end
end
