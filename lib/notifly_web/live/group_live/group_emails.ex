defmodule NotiflyWeb.GroupLive.GroupEmails do
  alias Notifly.Emails.GroupEmails
  alias Notifly.Groups.Group
  alias Notifly.Repo
  use NotiflyWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    group = Repo.get(Group, id)
    group_emails = GroupEmails.list_group_emails(group)

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

    {:noreply, socket}
  end

  defp render_stream(stream) do
    stream.inserts |> Enum.map(fn {_id, _order, role, _} -> role end)
  end
end
