defmodule Largo.Responders.MemmoryResponder do
  @behaviour Largo.Responders.Responder
  alias Largo.{Value, Repo}
  import Ecto.Query

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
    case Ecto.Query.from(v in Value, where: v.key == ^key) |> Repo.one do
      nil -> {:ok, build_colored_message("No encontré la clave #{key}", "warn")}
      value -> {:ok, build_kv_message([{value.key, value.value}], "hmmmmmmm", "good")}
    end
  end

  defp delete(key) do
    key = clean_key(key)
    case Ecto.Query.from(v in Value, where: v.key == ^key) |> Repo.one do
      nil -> {:ok, build_colored_message("No encontré la clave #{key}", "warning")}
      value ->
        case Repo.delete(value) do
          {:error, _} -> {:ok, build_colored_message("No pude borrar la clave #{key}", "danger")}
          {:ok, value} -> {:ok, build_colored_message("Borré la clave #{value.key}. Último valor: #{value.value}", "good")}
        end
    end
  end

  defp list do
    msg = Repo.all(Value)
      |> Enum.map(&{&1.key, &1.value})
      |> build_kv_message("*hmmmmm*", "good")
    {:ok, msg}
  end

  defp save(key, value) do
    key = clean_key(key)
    case Repo.get_by(Value, key: key) do
      nil ->
        Value.changeset(%Value{}, %{key: key, value: String.trim(value)})
        |> Repo.insert!
        {:ok, build_colored_message("guardado...", "good")}
      db_val ->
        Value.changeset(db_val, %{value: String.trim(value)})
        |> Repo.update!
        {:ok, build_colored_message("actualizado...", "good")}
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
