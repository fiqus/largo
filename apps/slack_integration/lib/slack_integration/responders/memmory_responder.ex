defmodule SlackIntegration.MemmoryResponder do
  @behaviour SlackIntegration.Responder
  alias Database.{Value, Repo}
  import Ecto.Query 

  @matchers [
    {~r/Guard[aá]\s+(?<key>.+)[=:](?<value>.+)$/iu, :save},
    {~r/Tra[eé]\s+todo/iu, :list},
    {~r/Tra[eé]\s+(?<key>.+)$/iu, :get},
    {~r/Borr[aá]\s+(?<key>.+)$/iu, :delete}
  ]

  def respond(message) do
    case parse(message) do
      {:save, %{"key" => key, "value" => value} = captures} ->
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
    Enum.reduce_while(@matchers, false, fn {re, name}, acc -> 
      case Regex.named_captures(re, message) do
        nil -> {:cont, nil}
        captures -> {:halt, {name, captures}}
      end
    end)
  end

  defp get(key) do
    key = clean_key(key)
    case Ecto.Query.from(v in Value, where: v.key == ^key) |> Repo.one do
      nil -> {:ok, "No encontré la clave #{key}"}
      value -> {:ok, "• #{value.key}: #{value.value}"}
    end
  end

  defp delete(key) do
    key = clean_key(key)
    case Ecto.Query.from(v in Value, where: v.key == ^key) |> Repo.one do
      nil -> {:ok, "No encontré la clave #{key}"}
      value ->
        case Repo.delete(value) do
          {:error, _} -> {:ok, "No pude borrar la clave #{key}"}
          {:ok, value} -> {:ok, "Borré la clave #{value.key}. Último valor: #{value.value}"}
        end
    end
  end

  defp list do
    msg = Repo.all(Value)
      |> Enum.map(&"• *#{&1.key}*: #{&1.value}")
      |> Enum.join("\n")
    {:ok, msg}
  end

  defp save(key, value) do
    key = clean_key(key)
    case Repo.get_by(Value, key: key) do
      nil ->
        Value.changeset(%Value{}, %{key: key, value: String.trim(value)})
        |> Repo.insert!
        {:ok, "guardado!"}
      db_val ->
        Value.changeset(db_val, %{value: String.trim(value)})
        |> Repo.update!
        {:ok, "actualizado!"}
    end
  end

  defp clean_key(key) do
    key
      |> String.trim()
      |> String.capitalize()
  end 
end
