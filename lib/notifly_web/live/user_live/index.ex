defmodule NotiflyWeb.UserLive.Index do
  alias Notifly.Accounts.User
  alias Notifly.Repo
  use NotiflyWeb, :live_view

  alias Notifly.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Users")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :edit_role, %{"id" => id}) do
    user = Repo.get!(User, id)

    socket
    |> assign(:page_title, "Edit Role")
    |> assign(:user, user)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if id == socket.assigns.current_user.id do
      {:noreply,
         socket
         |> put_flash(:error, "Cannot delete your own account.")
         |> redirect(to: ~p"/users")}
    else
      user = Accounts.get_user!(id)
      {:ok, _} = Accounts.delete_user(user)

      {:noreply, stream_delete(socket, :users, user)}
    end
  end

  @impl true
  def handle_event("upgrade", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    {:ok, _} = Accounts.User.upgrade_user_plan(user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("downgrade", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    {:ok, _} = Accounts.User.downgrade_user_plan(user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("grant_role", %{"role_slug" => role_slug}, socket) do
    user = Accounts.get_user!(socket.assigns.user.id)

    {:ok, _} = Accounts.grant_role_to_user(user, role_slug)
    {:noreply, socket}
  end

  def handle_event("revoke_role", %{"role_slug" => role_slug}, socket) do
    user = Accounts.get_user!(socket.assigns.user.id)

    {:ok, _} = Accounts.revoke_role_to_user(user, role_slug)
    updated_user = Repo.get(User, socket.assigns.user.id) |> Repo.preload(:roles)
    {:noreply, stream_delete(socket, :user, updated_user)}
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, user, _} -> user end)
  end
end
