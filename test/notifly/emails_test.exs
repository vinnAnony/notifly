defmodule Notifly.EmailsTest do
  use Notifly.DataCase

  alias Notifly.Emails

  describe "emails" do
    alias Notifly.Emails.Email

    import Notifly.EmailsFixtures

    @invalid_attrs %{body: nil, status: nil, subject: nil, type: nil}

    test "list_emails/0 returns all emails" do
      email = email_fixture()
      assert Emails.list_emails() == [email]
    end

    test "get_email!/1 returns the email with given id" do
      email = email_fixture()
      assert Emails.get_email!(email.id) == email
    end

    test "create_email/1 with valid data creates a email" do
      valid_attrs = %{body: "some body", status: "some status", subject: "some subject", type: "some type"}

      assert {:ok, %Email{} = email} = Emails.create_email(valid_attrs)
      assert email.body == "some body"
      assert email.status == "some status"
      assert email.subject == "some subject"
      assert email.type == "some type"
    end

    test "create_email/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_email(@invalid_attrs)
    end

    test "update_email/2 with valid data updates the email" do
      email = email_fixture()
      update_attrs = %{body: "some updated body", status: "some updated status", subject: "some updated subject", type: "some updated type"}

      assert {:ok, %Email{} = email} = Emails.update_email(email, update_attrs)
      assert email.body == "some updated body"
      assert email.status == "some updated status"
      assert email.subject == "some updated subject"
      assert email.type == "some updated type"
    end

    test "update_email/2 with invalid data returns error changeset" do
      email = email_fixture()
      assert {:error, %Ecto.Changeset{}} = Emails.update_email(email, @invalid_attrs)
      assert email == Emails.get_email!(email.id)
    end

    test "delete_email/1 deletes the email" do
      email = email_fixture()
      assert {:ok, %Email{}} = Emails.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_email!(email.id) end
    end

    test "change_email/1 returns a email changeset" do
      email = email_fixture()
      assert %Ecto.Changeset{} = Emails.change_email(email)
    end
  end
end
