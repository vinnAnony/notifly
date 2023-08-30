defmodule NotiflyWeb.MailLive.Index do
  require Logger
  alias Notifly.Workers.EmailWorker
  alias Notifly.Accounts.User
  alias Notifly.Contacts.Contact
  alias Notifly.Repo
  alias Notifly.Emails.Email
  alias Notifly.Emails
  use NotiflyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      NotiflyWeb.Endpoint.subscribe("email_worker")
    end

    {:ok, stream(socket, :emails, Emails.list_user_emails(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket|> assign(:page_title, "Outbox")}
  end

  @impl true
  def handle_info(payload, socket) do
    if is_map(payload) && Map.has_key?(payload, :event) do
      case payload.event do
        "email:sent" ->
          # update email status - update stream
          {:noreply,stream(socket, :emails, Emails.list_user_emails(socket.assigns.current_user), reset: true)}
        "email:failed" ->
          # update email status
          {:noreply,stream(socket, :emails, Emails.list_user_emails(socket.assigns.current_user), reset: true)}
      end
    else
      {:noreply, socket}
    end
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

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    email = Repo.get(Email, id)
    sender = Repo.get(User, email.sender_id)
    contact = Repo.get(Contact, email.contact_id)

    EmailWorker.perform(%{
      "channel"=> "email_worker",
      "email_id"=> id,
      "sender" => sender,
      "recipient" => contact,
      "subject" => email.subject,
      "body" => email.body
     })

    {:noreply, socket}
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, email, _} -> email end)
  end
end
