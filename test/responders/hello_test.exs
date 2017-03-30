defmodule HelloTest do
  use ExUnit.Case, async: true
  alias Largo.Responders.HelloResponder

  test "responds to hello" do
    assert {:ok, _} = HelloResponder.respond("hola")
    assert {:ok, _} = HelloResponder.respond("Hola")
    assert {:ok, _} = HelloResponder.respond("buen dia")
    assert {:ok, _} = HelloResponder.respond("buen día")
    assert {:ok, _} = HelloResponder.respond("buenos días")
  end

  test "doesnt respond to something else" do
    assert :noresponse = HelloResponder.respond("blabla")
  end
end
