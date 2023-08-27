defmodule Notifly.Repo.Migrations.CreateGroupEmails do
  use Ecto.Migration

  def change do
    create table(:group_emails) do
      add :status, :string
      add :no_of_emails, :integer
      add :success_emails, :integer
      add :failed_emails, :integer
      add :pending_emails, :integer
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:group_emails, [:group_id])
  end
end
