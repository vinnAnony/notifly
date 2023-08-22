defmodule Notifly.Accounts.Role do
  alias Notifly.Repo
  alias Notifly.Accounts.Role
  alias Notifly.Accounts.RolePermissions
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :slug, :string

    has_many :role_permissions, RolePermissions
    has_many :permissions,
    through: [:role_permissions, :permission]

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end


  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert!()
  end
end
