defmodule Notifly.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
