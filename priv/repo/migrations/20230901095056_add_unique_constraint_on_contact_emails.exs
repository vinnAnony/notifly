defmodule Notifly.Repo.Migrations.AddUniqueConstraintOnContactEmails do
  use Ecto.Migration

  def change do
    create unique_index(:contacts, [:email])
  end
end
