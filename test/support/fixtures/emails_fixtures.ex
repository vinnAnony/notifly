defmodule Notifly.EmailsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Notifly.Emails` context.
  """

  @doc """
  Generate a email.
  """
  def email_fixture(attrs \\ %{}) do
    {:ok, email} =
      attrs
      |> Enum.into(%{
        body: "some body",
        status: "some status",
        subject: "some subject",
        type: "some type"
      })
      |> Notifly.Emails.create_email()

    email
  end
end
