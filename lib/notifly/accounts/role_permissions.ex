defmodule Notifly.Accounts.RolePermissions do
  alias Notifly.Repo
  alias Notifly.Accounts.RolePermissions
  alias Notifly.Accounts.Role
  alias Notifly.Accounts.Permission
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_permissions" do

    belongs_to :role, Role
    belongs_to :permission, Permission

    timestamps()
  end

  @doc false
  def changeset(role_permissions, attrs) do
    role_permissions
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
  end

  def create_role_permission(attrs \\ %{}) do
    %RolePermissions{}
    |> RolePermissions.changeset(attrs)
    |> Repo.insert!()
  end
end
