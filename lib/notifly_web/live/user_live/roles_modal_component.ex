defmodule NotiflyWeb.UserLive.RolesModalComponent do

  require Logger
  alias Notifly.Accounts.User
  alias Notifly.Repo
  use NotiflyWeb, :live_component

  @impl true
  def update(assigns, socket) do
     socket
     |> assign(:assigns, assigns)

    user = Repo.get(User, assigns.user.id) |> Repo.preload(:roles)
    selected_user_roles = user.roles

    {:ok, stream(socket, :user_roles, selected_user_roles)}
  end

  def has_role?(streams, roles) when is_list(roles) do
    user_roles = streams.user_roles.inserts |> Enum.map(fn {_id, _order, role, _} -> role end)
    user_roles_list = Enum.map(user_roles, fn role -> role.slug end)
    Enum.any?(user_roles_list, fn role -> role in roles end)
  end
end
