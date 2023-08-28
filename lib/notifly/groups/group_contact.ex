defmodule Notifly.Groups.GroupContact do
  alias Notifly.Repo
  alias Notifly.Groups.GroupContact
  alias Notifly.Contacts.Contact
  alias Notifly.Groups.Group
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_contacts" do

    belongs_to :group, Group
    belongs_to :contact, Contact

    timestamps()
  end

  @doc false
  def changeset(group_contact, attrs) do
    group_contact
    |> cast(attrs, [:group_id, :contact_id])
    |> validate_required([:group_id, :contact_id])
  end


  def list_group_contacts(group) do
    group = Repo.get(Group, group.id) |> Repo.preload(:contacts)
    group.contacts
  end

  def create_group_contact(attrs) do
    %GroupContact{}
    |> GroupContact.changeset(attrs)
    |> Repo.insert!()
  end

  def delete_group_contact(%GroupContact{} = group_contact) do
    Repo.delete(group_contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking changes.
  """
  def change_group_contact(%GroupContact{} = group_contact, attrs \\ %{}) do
    GroupContact.changeset(group_contact, attrs)
  end
end
