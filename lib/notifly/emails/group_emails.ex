defmodule Notifly.Emails.GroupEmails do
  alias Notifly.Repo
  alias Notifly.Emails.GroupEmails
  alias Notifly.Groups.Group
  alias Notifly.Emails.Email
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_emails" do
    field :failed_emails, :integer, default: 0
    field :no_of_emails, :integer
    field :pending_emails, :integer, default: 0
    field :status, Ecto.Enum, values: [:pending, :sent, :failed], default: :pending
    field :success_emails, :integer, default: 0

    belongs_to :group, Group
    has_many :emails, Email, foreign_key: :ge_id

    timestamps()
  end

  @doc false
  def changeset(group_emails, attrs) do
    group_emails
    |> cast(attrs, [:group_id, :status, :no_of_emails, :success_emails, :failed_emails, :pending_emails])
    |> validate_required([:group_id, :status, :no_of_emails, :success_emails, :failed_emails, :pending_emails])
  end

  def create_group_email(attrs \\ %{}) do
    %GroupEmails{}
    |> GroupEmails.changeset(attrs)
    |> Repo.insert!()
  end

  def update_group_email(%GroupEmails{} = group_email, attrs) do
    group_email
    |> GroupEmails.changeset(attrs)
    |> Repo.update()
  end
end
