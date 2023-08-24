defmodule Notifly.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:groups, [:owner_id])
  end
end
