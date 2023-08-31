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
    user = Accounts.get_user!(id)

    if id == socket.assigns.current_user.id do
      {:noreply,
         socket
         |> put_flash(:error, "Cannot delete your own account.")
         |> redirect(to: ~p"/users")}
    else
      if NotiflyWeb.VerifyUserRole.has_role_ui?(user, ["superuser"]) do
        {:noreply,
           socket
           |> put_flash(:error, "Cannot delete superuser account. Revoke superuser role first.")
           |> redirect(to: ~p"/users")}
      else
        Accounts.delete_user(user)
        {:noreply, stream(socket, :users, Accounts.list_users())}
      end
    end
  end

  @impl true
  def handle_event("upgrade", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    Accounts.User.upgrade_user_plan(user)

    {:noreply,stream(socket, :users, Accounts.list_users(), reset: true)}
  end

  @impl true
  def handle_event("downgrade", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    Accounts.User.downgrade_user_plan(user)

    {:noreply,stream(socket, :users, Accounts.list_users(), reset: true)}
  end

  @impl true
  def handle_event("grant_role", %{"role_slug" => role_slug}, socket) do
    user = Accounts.get_user!(socket.assigns.user.id)
    Accounts.grant_role_to_user(user, role_slug)

    stream(socket, :users, Accounts.list_users(), reset: true)
    {:noreply,
         socket
         |> put_flash(:info, "#{role_slug} role granted successfully.")
         |> redirect(to: ~p"/users/#{user.id}/roles")}
  end

  def handle_event("revoke_role", %{"role_slug" => role_slug}, socket) do
    user = Accounts.get_user!(socket.assigns.user.id)
    Accounts.revoke_role_to_user(user, role_slug)

    stream(socket, :users, Accounts.list_users(), reset: true)
    {:noreply,
         socket
         |> put_flash(:info, "#{role_slug} role revoked successfully.")
         |> redirect(to: ~p"/users/#{user.id}/roles")}
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, user, _} -> user end)
  end
end
