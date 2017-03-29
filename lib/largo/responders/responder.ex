defmodule Largo.Responders.Responder do
  @callback respond(String.t()) :: {:ok, String.t()} | :noresponse
end
