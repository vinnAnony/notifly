defmodule Notifly.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :code_name, :string
      add :name, :string

      timestamps()
    end
  end
end
