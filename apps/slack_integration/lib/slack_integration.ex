defmodule SlackIntegration do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message", subtype: "message_changed"}, slack, state) do
    IO.inspect(message)
    handle_event(Map.put(message.message, :channel, message.channel), slack, state)
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    IO.inspect(message)
    cond do
      message.user == slack.me.id ->
        IO.puts "mensaje ignorado"
        nil #Ignore own messages
      true ->
        msgchan = message.channel
        mention = "<@#{slack.me.id}> "
        base = byte_size(mention)

        case {slack.ims, message.text} do
          {%{^msgchan => _}, _} ->
            respond(message.text, message.channel, slack)
          {_, <<^mention::binary-size(base), rest::binary>>} ->
            respond(rest, message.channel, slack)
          _ ->
            IO.puts "mensaje ignorado"
            nil
        end
    end
    {:ok, state}
  end
  
  def handle_event(_, _, state), do: {:ok, state}
  
  @responders [SlackIntegration.HelloResponder, 
               SlackIntegration.MemmoryResponder]

  defp respond(text, channel, slack) do
    resp = Enum.reduce_while(@responders, "", fn responder, acc -> 
      case responder.respond(text) do
        {:ok, response} ->
          {:halt, response}
        _ ->
          {:cont, ""}
      end
    end)
    if resp != "" do
      send_message(resp, channel, slack)
    end
  end


  def handle_info(_, _, state), do: {:ok, state}
end
