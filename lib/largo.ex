defmodule Largo do
  use Slack

  @default_params Application.get_env(:largo, :default_message_parameters)

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
      Map.has_key?(message, :user) and message.user== slack.me.id ->
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
  def handle_info(_, _, state), do: {:ok, state}

  @responders [Largo.Responders.DemoResponder,
               Largo.Responders.HelloResponder,
               Largo.Responders.MemmoryResponder]
  

  defp respond(text, channel, slack) do
    resp = Enum.reduce_while(@responders, "", fn responder, _acc ->
      case responder.respond(text) do
        {:ok, response} ->
          {:halt, response}
        _ ->
          {:cont, ""}
      end
    end)
    if resp != "" do
      do_response(resp, channel, slack)
    end
  end

  defp do_response(resp, channel, slack) when is_binary(resp) do
    IO.puts("do_response str")
    IO.inspect(resp)
    IO.inspect(@default_params)
    IO.inspect(Application.get_env(:largo, :default_message_parameters))
    Slack.Web.Chat.post_message(channel, resp, @default_params)
  end

  defp do_response(resp, channel, slack) when is_list(resp) do
    IO.puts("do_response list")
    IO.inspect(resp)
    Enum.map(resp, &do_response(&1, channel, slack))
  end

  defp do_response({resp, params}, channel, _slack) when is_binary(resp) and is_map(params) do
    IO.puts("do_response params")
    IO.inspect(resp)
    Slack.Web.Chat.post_message(channel, resp, Map.merge(@default_params, params))
  end
end
