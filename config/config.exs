# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :largo, default_message_parameters: %{
  as_user: true
}

# redefine in <env>.secret.exs
config :slack, api_token: ""

configs = ["#{Mix.env}.exs", "#{Mix.env}.secret.exs"]

Enum.map(configs, fn f ->
  if File.exists? "config/" <> f do
    import_config f
  end
end)
