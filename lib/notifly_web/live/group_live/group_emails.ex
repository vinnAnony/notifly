defmodule NotiflyWeb.GroupLive.GroupEmails do
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
  def handle_event("retry", %{"id" => _id}, socket) do
    # TODO: fetch failed emails belonging to this g_e
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
