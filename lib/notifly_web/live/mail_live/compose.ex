defmodule NotiflyWeb.MailLive.Compose do
  require Logger
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

    Enum.map(group_contacts, fn contact ->
      # Update contact_id
      email_params = Map.put(email_params,"contact_id", contact.id)
      send_email(socket,"single",email_params)
    end)
  end
end
