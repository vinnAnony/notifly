defmodule NotiflyWeb.MailLive.Compose do
  require Logger
  alias Notifly.Workers.EmailWorker
  alias Notifly.Contacts.Contact
  alias Notifly.Accounts.User
  alias Notifly.Repo
  alias Notifly.Emails.GroupEmails
  alias Notifly.Groups
  alias Notifly.Contacts
  alias Notifly.Emails.Email
  alias Notifly.Emails
  use NotiflyWeb, :live_view

@impl true
  def mount(_params, _session, socket) do
    {:ok, socket
    |>assign(my_contacts: Contacts.list_contacts(socket.assigns.current_user))
    |>assign(my_groups: Groups.list_groups(socket.assigns.current_user))
    |>assign(:show_contacts, false)
    |>assign(:show_groups, false)
    |>assign(:email, %Email{})
    |>assign(form: to_form(Emails.change_email(%Email{})))}
  end

  def handle_event("change_recipient", %{"email" => value}, socket) do
    case value["type"] do
      "single" -> {:noreply, socket |> assign(:show_groups, false) |> assign(:show_contacts, true)}
      "bulk" -> {:noreply, socket |> assign(:show_groups, true) |> assign(:show_contacts, false)}
      _ -> {:noreply, socket |> assign(:show_groups, false) |> assign(:show_contacts, false)}

    end
  end

  @impl true
  def handle_event("validate", %{"email" => email_params}, socket) do
    changeset =
      socket.assigns.email
      |> Emails.change_email(email_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("send", %{"email" => email_params}, socket) do
    email_params = Map.put(email_params,"sender_id", socket.assigns.current_user.id)

    send_email(socket, email_params["type"], email_params)
  end

  defp send_email(socket, "single", email_params) do

    case Emails.send_single_email(email_params) do
      {:ok,_} ->
        {:noreply,
         socket
         |>assign(form: to_form(Emails.change_email(%Email{})))
         |> put_flash(:info, "Email sent successfully")
         |> redirect(to: ~p"/mailbox")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp send_email(socket, "bulk", email_params) do
    group = Groups.get_group_with_contacts(email_params["contact_id"])
    group_contacts = group.contacts

    no_of_emails = length(group_contacts)
    group_email = GroupEmails.create_group_email(%{no_of_emails: no_of_emails,group_id: group.id})

    Enum.map(group_contacts, fn contact ->
      # Update contact_id
      email_params = Map.put(email_params,"contact_id", contact.id)
      email_params = Map.put(email_params,"ge_id", group_email.id)

      sender = Repo.get(User, email_params["sender_id"])
      contact = Repo.get(Contact, email_params["contact_id"])

      # Insert email entry in db
      save_email = Emails.create_email(%{body: email_params["body"],subject: email_params["subject"],
        name: contact.name, email: contact.email,
        type: email_params["type"],ge_id: email_params["ge_id"],sender_id: email_params["sender_id"],
        contact_id: email_params["contact_id"]})
      case save_email do
        {:ok, email_entry} ->
          # update pending emails count
          new_count = Repo.get(GroupEmails, group_email.id).pending_emails + 1
          GroupEmails.update_group_email(group_email, %{pending_emails: new_count})

          #Add email to job queue
          %{channel: "email_worker",
          email_id: email_entry.id,
          sender: %{id: sender.id, first_name: sender.first_name, last_name: sender.last_name, email: sender.email},
          recipient: %{id: contact.id, email: contact.email, name: contact.name},
          subject: email_entry.subject,
          body: email_entry.body}
          |> EmailWorker.new()
          |> Oban.insert()
      end
    end)

    # Execute queue
    Oban.start_queue(queue: :mailers, limit: 1)

    #TODO: Capture failed emails - still reading as pending
    #TODO: Update group email status
    # GroupEmails.update_group_email(group_email, %{status: :sent})
    #TODO: Update group email status END

    {:noreply,
         socket
         |>assign(form: to_form(Emails.change_email(%Email{})))
         |> put_flash(:info, "Email sent successfully")
         |> redirect(to: ~p"/mailbox")}
  end
end
