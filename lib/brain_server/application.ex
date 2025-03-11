defmodule BrainServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BrainServerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:brain_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BrainServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BrainServer.Finch},
      # Start a worker by calling: BrainServer.Worker.start_link(arg)
      # {BrainServer.Worker, arg},
      BrainServer.Game,
      # Start to serve requests, typically the last entry
      BrainServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BrainServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BrainServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
