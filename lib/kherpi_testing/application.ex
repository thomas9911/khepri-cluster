defmodule KherpiTesting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # topologies = [
    #   example: [
    #     strategy: Cluster.Strategy.LocalEpmd
    #   ]
    # ]

    topologies = [
      example: [
        strategy: KherpiStrategy,
        config: [
          strategy: Cluster.Strategy.LocalEpmd,
          args: []
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: KherpiTesting.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KherpiTesting.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
