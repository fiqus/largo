defmodule SlackIntegration.HelloResponder do
  @behaviour SlackIntegration.Responder
  
  @matchers [
    ~r/Hola/iu,
    ~r/Buen(os)? d[íi]as?/iu
  ]

  def respond(message) do
    if should_respond?(message) do
      {:ok, "buenas!"}
    else
      :noresponse
    end
  end

  defp should_respond?(message) do
    Enum.reduce_while(@matchers, false, fn re, acc -> 
      case Regex.run(re, message) do
        nil -> {:cont, false}
        _ -> {:halt, true}
      end
    end)
  end
end
