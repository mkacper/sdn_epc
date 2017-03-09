defmodule SdnEpc.Supervisor do
  use Supervisor

  def start_link do
    res = Supervisor.start_link __MODULE__, [], name: __MODULE__
    start_ofp_channel_sup()
    start_worker()
    res
  end

  def start_ofp_channel_sup do
    ofpc_sup_spec = supervisor(:ofp_channel_sup, [1])
    {:ok, ofpc_sup } = Supervisor.start_child __MODULE__, ofpc_sup_spec
    Process.register ofpc_sup, :ofp_channel_sup
  end

  def start_worker do
    Supervisor.start_child __MODULE__, worker(SdnEpc.Forwarder, []) 
    chan_conf = Application.get_all_env :sdn_epc
    SdnEpc.Forwarder.open_ofp_channel chan_conf[:channel_id],
      chan_conf[:controller_ip], chan_conf[:controller_port],
      chan_conf[:channel_version]
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end
end
