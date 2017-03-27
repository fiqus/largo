defmodule Database.Repo.Migrations.CreateKeyValues do
  use Ecto.Migration

  def change do
    create table(:keys) do
    end
    create table(:values) do
      add :key, :string
      add :value, :string
      add :last_updater, :string

      timestamps
    end

    create unique_index(:values, [:key])
  end
end
