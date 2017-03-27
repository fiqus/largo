defmodule Database.Value do
  use Ecto.Schema
  import Ecto.Changeset

  schema "values" do
    field :key, :string
    field :value, :string
    field :last_updater, :string, default: ""

    timestamps()
  end

  def changeset(value, params \\ %{}) do
    value
    |> cast(params, [:key, :value, :last_updater])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
    |> validate_exclusion(:key, ~w(todo))
  end
end
