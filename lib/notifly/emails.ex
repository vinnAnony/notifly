defmodule Notifly.Emails do
  @moduledoc """
  The Emails context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Notifly.Accounts.User
  alias Notifly.Contacts.Contact
  alias Notifly.Emails.EmailNotifier
  alias Notifly.Repo

  alias Notifly.Emails.Email

  @doc """
  Returns the list of emails sent by a user.
  """
  def list_user_emails(user) do
    Email
    |> where([e], e.sender_id == ^user.id)
    |> order_by(desc: :id)
    |> Repo.all
    |> Repo.preload(:sender)
    |> Repo.preload(:contact)
  end

  @doc """
  Returns the list of emails sent for a group email transaction.
  """
  def get_group_emails_entry(ge_id) do
    Email
    |> where([e], e.ge_id == ^ge_id)
    |> Repo.all
  end

  @doc """
  Gets a single email.

  Raises `Ecto.NoResultsError` if the Email does not exist.

  ## Examples

      iex> get_email!(123)
      %Email{}

      iex> get_email!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email!(id) do
    Repo.get!(Email, id)
    |> Repo.preload(:sender)
    |> Repo.preload(:contact)
  end

  @doc """
  Creates a email.

  ## Examples

      iex> create_email(%{field: value})
      {:ok, %Email{}}

      iex> create_email(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email(attrs \\ %{}) do
    %Email{}
    |> Email.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email.

  ## Examples

      iex> update_email(email, %{field: new_value})
      {:ok, %Email{}}

      iex> update_email(email, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_email(%Email{} = email, attrs) do
    email
    |> Email.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a email.

  ## Examples

      iex> delete_email(email)
      {:ok, %Email{}}

      iex> delete_email(email)
      {:error, %Ecto.Changeset{}}

  """
  def delete_email(%Email{} = email) do
    Repo.delete(email)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email changes.

  ## Examples

      iex> change_email(email)
      %Ecto.Changeset{data: %Email{}}

  """
  def change_email(%Email{} = email, attrs \\ %{}) do
    Email.changeset(email, attrs)
  end

  @doc """
  Sends a single email

  """
  @spec send_single_email(%{}):: :ok
  def send_single_email(email_params) do
    ge_id = email_params["ge_id"]
    contact_id = email_params["contact_id"]
    sender_id = email_params["sender_id"]
    subject = email_params["subject"]
    body = email_params["body"]

    type = email_params["type"]
    contact = Repo.get(Contact, contact_id)
    sender = Repo.get(User, sender_id)

    {:ok, email_entry} = create_email(%{body: body,subject: subject,type: type,ge_id: ge_id,sender_id: sender.id,contact_id: contact.id})

    email_delivery = EmailNotifier.deliver(contact, sender, subject, body)
      with {:ok, _metadata} <- email_delivery do
        update_email(email_entry, %{status: :sent})
        {:ok, "Sent successfully."}
      else
        {:error, reason} -> IO.puts("Failed to send email. Reason: #{reason}")
        _ -> :error
      end
  end

  @doc """
  Sends bulk/group email

  """
  def send_bulk_email() do

  end
end
