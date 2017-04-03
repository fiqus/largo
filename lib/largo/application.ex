defmodule Largo.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    default_workers = []

    slack_workers = if Application.get_env(:largo, :enable_ws_client, true) do
      [worker(Slack.Bot, [Largo, [], Application.get_env(:slack, :api_token)])]
    else
      []
    end

    children = default_workers ++ slack_workers

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Largo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
