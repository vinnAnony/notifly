defmodule Notifly.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :name, :string
      add :email, :string
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:contacts, [:owner_id])
  end
end
