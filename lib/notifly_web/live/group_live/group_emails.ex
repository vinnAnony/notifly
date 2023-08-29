defmodule NotiflyWeb.GroupLive.GroupEmails do
  alias Notifly.Groups.Group
  alias Notifly.Repo
  use NotiflyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    group = Repo.get(Group, id)
    {:noreply, socket|> assign(:page_title, "#{group.name} Emails")}
  end
end
