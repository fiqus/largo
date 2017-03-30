use Mix.Config

#we don't want to start the websocket client when testing
config :largo, enable_ws_client: false
