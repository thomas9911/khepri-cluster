defmodule KherpiStrategy do
  use GenServer
  use Cluster.Strategy

  import Logger

  alias Cluster.Strategy.State

  @default_polling_interval 5_000
  @default_store :khepri

  # check: https://github.com/bitwalker/libcluster/blob/main/lib/strategy/kubernetes_dns_srv.ex

  # def start_link([%{config: config} = state]) do
  #     strategy = Keyword.fetch!(config, :strategy)
  #     args = Keyword.get(config, :args, [])

  #     state
  #     |> Map.put(:config, args)
  #     |> List.wrap()
  #     |> strategy.start_link()
  #     |> IO.inspect()
  # end

  #   def start_link(args), do: GenServer.start_link(__MODULE__, args)

  #   @impl true
  #   def init([%{config: config} = state]) do
  #     :khepri.start()
  #     Logger.error("start")

  #     strategy = Keyword.fetch!(config, :strategy)
  #     args = Keyword.get(config, :args, [])

  #     res =
  #       case state
  #       |> Map.put(:config, args)
  #       |> List.wrap()
  #       |> strategy.start_link() do
  #         :ignore -> state,
  #         {:ok, state} -> state
  #         e -> raise e
  #       end

  #     # Process.send_after(
  #     #   self(),
  #     #   :load,
  #     #   5000
  #     # )

  #     {:ok, state, 0}
  #   end

  def start_link([%{config: config} = state] = args) do
    :khepri.start()
    Logger.info("start khepri")

    strategy = Keyword.fetch!(config, :strategy)
    config = Keyword.get(config, :args, [])

    case state
         |> Map.put(:config, config)
         |> List.wrap()
         |> strategy.start_link() do
      :ignore -> GenServer.start_link(__MODULE__, args)
      {:ok, pid} -> {:ok, pid}
      e -> e
    end
  end

  @impl true
  def init([state]) do
    Process.flag(:trap_exit, true)

    # forces timeout
    {:ok, state, 0}
  end

  @impl true
  def handle_info(:timeout, state) do
    handle_info(:load, state)
  end

  def handle_info(:load, state) do
    {:noreply, load(state)}
  end

  defp load(state) do
    me = node()

    if :khepri_cluster.nodes(@default_store) -- [me] == [] and Node.list() != [] do
      # if we join to one we join to all
      Node.list()
      |> List.first()
      |> :khepri_cluster.join()
    else
      :ok
    end

    Process.send_after(
      self(),
      :load,
      polling_interval(state)
    )

    state
  end

  defp polling_interval(%State{config: config}) do
    Keyword.get(config, :polling_interval, @default_polling_interval)
  end

  def terminate(reason, _state) do
    cleanup()

    reason
  end

  def handle_info({:EXIT, _from, reason}, state) do
    cleanup()

    {:stop, reason, state}
  end

  defp cleanup do
    # disconnect from cluster
    :khepri_cluster.reset()

    Logger.info("shutting down")
  end
end
