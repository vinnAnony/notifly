defmodule NotiflyWeb.UserLive.Index do
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
end
