defmodule Potamoi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PotamoiWeb.Telemetry,
      Potamoi.Repo,
      {DNSCluster, query: Application.get_env(:potamoi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Potamoi.PubSub},
      # Start a worker by calling: Potamoi.Worker.start_link(arg)
      # {Potamoi.Worker, arg},
      # Start to serve requests, typically the last entry
      PotamoiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Potamoi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PotamoiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
