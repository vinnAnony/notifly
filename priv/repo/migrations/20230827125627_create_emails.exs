defmodule Notifly.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :name, :string
      add :email, :string
      add :subject, :string
      add :body, :text
      add :type, :string
      add :status, :string, default: "pending"
      add :contact_id, references(:contacts, on_delete: :nothing), null: true
      add :ge_id, references(:group_emails, on_delete: :delete_all), null: true
      add :sender_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:emails, [:ge_id])
    create index(:emails, [:sender_id])
  end
end
