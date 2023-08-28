defmodule NotiflyWeb.GroupLive.AddToGroupComponent do

  require Logger
  alias Notifly.Groups.GroupContact
  alias Notifly.Repo
  alias Notifly.Contacts
  alias Notifly.Groups.Group
  use NotiflyWeb, :live_component

  @impl true
  def update(assigns, socket) do
    group_with_contacts = Repo.get(Group, assigns.group.id) |> Repo.preload(:contacts)
    contacts_in_group = group_with_contacts.contacts
    user_contacts = Contacts.list_contacts(assigns.current_user)

    # get contacts not in group
    available_contacts = Enum.filter(user_contacts, fn contact ->
      not Enum.member?(contacts_in_group, contact)
    end)

    {:ok, socket
    |> assign(:assigns, assigns)
    |> assign(form: to_form(GroupContact.change_group_contact(%GroupContact{})))
    |> assign(:user_contacts, available_contacts)}
  end

  @impl true
  def handle_event("save", %{"group_contact" => group_contact_params}, socket) do
    group = socket.assigns.assigns.group
    group_contact_params = Map.put(group_contact_params,"group_id", group.id)
    GroupContact.create_group_contact(group_contact_params)

    {:noreply,
      socket
      |> put_flash(:info, "Contact added successfully.")
      |> redirect(to: ~p"/groups/#{group}")}
  end
end
