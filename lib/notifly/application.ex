defmodule Notifly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NotiflyWeb.Telemetry,
      # Start the Ecto repository
      Notifly.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Notifly.PubSub},
      # Start Finch
      {Finch, name: Notifly.Finch},
      # Start the Endpoint (http/https)
      NotiflyWeb.Endpoint,
      # Start a worker by calling: Notifly.Worker.start_link(arg)
      # {Notifly.Worker, arg}
      {Oban, repo: Notifly.Repo}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Notifly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NotiflyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
