defmodule NotiflyWeb.VerifyUserPermissions do
  alias Notifly.Accounts.User
  alias Notifly.Repo

  import Ecto.Query

  def has_permission?(user, permission_to_verify) do

    permissions = from(u in User,
    where: u.id == ^user.id,
    join: ur in assoc(u, :user_roles),
    join: r in assoc(ur, :role),
    join: rp in assoc(r, :role_permissions),
    join: p in assoc(rp, :permission),
    select: p
  )
  |> Repo.all()

  unique_permissions = Enum.uniq_by(permissions, &(&1.id))

  Enum.any?(unique_permissions, fn permission ->
    permission.code_name == permission_to_verify
    end)
  end
end
