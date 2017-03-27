defmodule SlackIntegration.Responder do
  @callback respond(string) :: {:ok, string} | :noresponse
end
