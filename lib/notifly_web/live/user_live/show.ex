defmodule NotiflyWeb.UserLive.Show do
  require Logger
  alias Notifly.Emails
  alias Notifly.Accounts
  use NotiflyWeb, :live_view


  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)
    {:ok, stream(socket, :user_mails, Emails.list_user_emails(user))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    selected_user = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title("#{selected_user.first_name} #{selected_user.last_name}"))
     |> assign(:selected_user, selected_user)}
  end

  defp page_title(selected_user_name), do: "#{selected_user_name}"
end
