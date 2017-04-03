# Largo

Largo is a Slack Integration done in Elixir to store key/values in your Slack chat.

## Dependencies
You need to install Erlang and Elixir, we strongly recommend:
http://elixir-lang.org/install.html

## Installation

1. Install the dependencies:
`mix deps.get`

2. Copy your Slack API-KEY token in `api_token` under `config/dev.secret.exs`

3. Create the Mnesia database
`mix amnesia.create -d Database --disk`

4. Run the app!
`iex -S mix`

## Uses
You can tag @largo bot in your Slack chat or just chat directly with it.

- @largo guarda foo=bar
- @largo trae foo
- @largo guarda hora reunion=10:00 am
- @largo trae todo
- @largo borra foo
- @largo trae todo