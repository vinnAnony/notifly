defmodule NotiflyWeb.MailLive.Compose do
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
    |>assign(:email, %Email{})
    |>assign(form: to_form(Emails.change_email(%Email{})))}
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
    end
  end

  defp send_email(socket, "bulk", email_params) do
    # TODO: Send bulk/group email
  end
end
