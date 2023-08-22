defmodule Notifly.Accounts.UserRoles do
  alias Notifly.Accounts.Role
  alias Notifly.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do

    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  @doc false
  def changeset(user_roles, attrs) do
    user_roles
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
  end
end
