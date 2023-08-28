defmodule NotiflyWeb.GroupLive.Show do
  use NotiflyWeb, :live_view

  alias Notifly.Groups

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    group = Groups.get_group_with_contacts(id)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, group.name))
     |> assign(:group, group)
     |> assign(:group_contacts, group.contacts)}
  end

  defp page_title(:add_to_group, group_name), do: "#{group_name}"
  defp page_title(:show, group_name), do: "#{group_name}"
  defp page_title(:edit, group_name), do: "Edit #{group_name}"
end
