defmodule NotiflyWeb.GroupLive.GroupEmails do
  alias Notifly.Contacts.Contact
  alias Notifly.Accounts.User
  alias Notifly.Workers.EmailWorker
  alias Notifly.Emails.GroupEmails
  alias Notifly.Groups.Group
  alias Notifly.Repo
  use NotiflyWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    group = Repo.get(Group, id)
    group_emails = GroupEmails.list_group_emails(group)

    if connected?(socket) do
      NotiflyWeb.Endpoint.subscribe("email_worker")
    end

    {:ok, stream(socket, :group_emails, group_emails)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    group = Repo.get(Group, id)

    {:noreply, socket
    |> assign(:page_title, "#{group.name} Emails")}
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    # TODO: fetch failed emails belonging to this g_e
    group_email = GroupEmails.get_group_email_pre_emails(id)

    Enum.each(group_email.emails, fn email ->
      if email.status == :failed do
        sender = Repo.get(User, email.sender_id)
        contact = Repo.get(Contact, email.contact_id)

        args = %{
          "channel"=> "email_worker",
          "email_id"=> email.id,
          "sender" => %{"id" => sender.id, "first_name" => sender.first_name, "last_name" => sender.last_name, "email" => sender.email},
          "recipient" => %{"id" => contact.id, "email" => contact.email, "name" => contact.name},
          "subject" => email.subject,
          "body" => email.body
        }
        EmailWorker.perform(%Oban.Job{args: args})
      end
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(payload, socket) do
    if is_map(payload) && Map.has_key?(payload, :event) do
      case payload.event do
        "group_email:sent" ->
          group_email = GroupEmails.get_group_email(payload.payload.group_email_id)
          group_emails = GroupEmails.list_group_emails(group_email.group)
          {:noreply,stream(socket, :group_emails, group_emails, reset: true)}

        _ -> {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, group_email, _} -> group_email end)
  end
end
