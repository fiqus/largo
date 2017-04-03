defmodule Largo.Responders.MemmoryResponder do
  @behaviour Largo.Responders.Responder
  use Database
  use Amnesia
  alias Amnesia.Selection

  @matchers [
    {~r/Guard[aá]\s+(?<key>.+)[=:](?<value>.+)$/iu, :save},
    {~r/Tra[eé]\s+todo/iu, :list},
    {~r/Tra[eé]\s+(?<key>.+)$/iu, :get},
    {~r/Borr[aá]\s+(?<key>.+)$/iu, :delete}
  ]

  def respond(message) do
    case parse(message) do
      {:save, %{"key" => key, "value" => value}} ->
        save(key, value)
      {:list, %{}} ->
        list()
      {:get, %{"key" => key}} ->
        get(key)
      {:delete, %{"key" => key}} ->
        delete(key)
      _ -> :noresponse
    end
  end

  defp parse(message) do
    Enum.reduce_while(@matchers, false, fn {re, name}, _acc ->
      case Regex.named_captures(re, message) do
        nil -> {:cont, nil}
        captures -> {:halt, {name, captures}}
      end
    end)
  end

  defp get(key) do
    key = clean_key(key)
    Amnesia.transaction do
      case Value.read_at(key, :key) do
        nil -> {:ok, build_colored_message("No encontré la clave #{key}", "warn")}
        values -> {:ok, build_kv_message([{hd(values).key, hd(values).value}], "hmmmmmmm", "good")}
      end
    end
  end

  defp delete(key) do
    key = clean_key(key)
    Amnesia.transaction do
      case Value.read_at(key, :key) do
        nil -> {:ok, build_colored_message("No encontré la clave #{key}", "warning")}
        values ->
          case Value.delete(hd(values)) do
            :error -> {:ok, build_colored_message("No pude borrar la clave #{key}", "danger")}
            :ok -> {:ok, build_colored_message("Borré la clave #{hd(values).key}. Último valor: #{hd(values).value}", "good")}
          end
        end
    end
  end

  defp list do
    Amnesia.transaction do
      msg = Value.where(1 == 1) |> Amnesia.Selection.values
        |> Enum.map(&{&1.key, &1.value})
        |> build_kv_message("*hmmmmm*", "good")
      {:ok, msg}
    end
  end

  defp save(key, value) do
    key = clean_key(key)
    Amnesia.transaction do
      case Value.read_at(key, :key) do
        nil ->
          %Value{key: key, value: String.trim(value)} |> Value.write
          {:ok, build_colored_message("guardado...", "good")}
        _ ->
          %Value{value: String.trim(value)} |> Value.write
          {:ok, build_colored_message("actualizado...", "good")}
      end
    end
  end
  
  defp build_kv_message(kvs, text, color \\ "") do
    fields = Enum.map(kvs, fn {key, value} -> %{title: key, value: value, short: false} end)
    fallback = Enum.map(kvs, fn {key, value} -> "#{key}: #{value}" end) |> Enum.join("/n")
    {"", %{attachments: Poison.encode!([%{
                                          fallback: fallback,
                                          color: color,
                                          pretext: text,
                                          fields: fields
                                        }])}}
  end

  defp build_colored_message(text, color) do
    {"", %{attachments: Poison.encode!([%{
                                          fallback: text,
                                          color: color,
                                          text: text,
                                        }])}}
  end



  defp clean_key(key) do
    key
      |> String.trim()
      |> String.capitalize()
  end
end
