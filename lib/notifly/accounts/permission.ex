defmodule Notifly.Accounts.Permission do
  alias Notifly.Repo
  alias Notifly.Accounts.Permission
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :code_name, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:code_name, :name])
    |> validate_required([:code_name, :name])
  end

  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert!()
  end
end
