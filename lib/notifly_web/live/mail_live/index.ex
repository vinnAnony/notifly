defmodule NotiflyWeb.MailLive.Index do
  require Logger
  alias Notifly.Emails
  use NotiflyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :emails, Emails.list_user_emails(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket|> assign(:page_title, "Inbox")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    email = Emails.get_email!(id)
    {:ok, _} = Emails.delete_email(email)

    {:noreply,
      socket
      |> put_flash(:info, "Email deleted successfully.")
      |> redirect(to: ~p"/mailbox")}
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, role, _} -> role end)
  end
end
