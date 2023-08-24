defmodule Notifly.Groups.Group do
  alias Notifly.Groups.GroupContact
  alias Notifly.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string

    belongs_to :owner, User
    has_many :group_contacts, GroupContact
    has_many :contacts,
    through: [:group_contacts, :contact]

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name,:owner_id])
    |> validate_required([:name,:owner_id])
  end
end
