defmodule Notifly.Emails.Email do
  alias Notifly.Emails.GroupEmails
  alias Notifly.Contacts.Contact
  alias Notifly.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :name, :string
    field :email, :string
    field :body, :string
    field :subject, :string
    field :status, Ecto.Enum, values: [:pending, :sent, :failed], default: :pending
    field :type, Ecto.Enum, values: [:single, :bulk]

    belongs_to :sender, User
    belongs_to :contact, Contact
    belongs_to :ge, GroupEmails

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:subject, :body, :name, :email, :type, :status, :contact_id, :ge_id, :sender_id])
    |> validate_required([:subject, :body, :name, :email, :type, :contact_id, :sender_id])
    |> foreign_key_constraint(:contact_id)
  end
end
