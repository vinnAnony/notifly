defmodule Notifly.Emails.GroupEmails do
  alias Notifly.Groups.Group
  alias Notifly.Emails.Email
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_emails" do
    field :failed_emails, :integer
    field :no_of_emails, :integer
    field :pending_emails, :integer
    field :status, :string
    field :success_emails, :integer

    belongs_to :group, Group
    has_many :emails, Email, foreign_key: :ge_id

    timestamps()
  end

  @doc false
  def changeset(group_emails, attrs) do
    group_emails
    |> cast(attrs, [:group, :status, :no_of_emails, :success_emails, :failed_emails, :pending_emails])
    |> validate_required([:group, :status, :no_of_emails, :success_emails, :failed_emails, :pending_emails])
  end
end
