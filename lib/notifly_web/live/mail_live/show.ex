defmodule NotiflyWeb.MailLive.Show do
  alias Notifly.Emails
  use NotiflyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    selected_email = Emails.get_email!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(selected_email.subject))
     |> assign(:selected_email, selected_email)}
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

  defp page_title(page_title), do: "#{page_title}"
end
