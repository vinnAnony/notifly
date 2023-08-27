defmodule Notifly.Contacts.Contact do
  alias Notifly.Emails.Email
  alias Notifly.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :email, :string
    field :name, :string

    belongs_to :owner, User
    has_many :emails, Email

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :email,:owner_id])
    |> validate_required([:name, :email,:owner_id])
    |> assoc_constraint(:owner)
  end
end
