defmodule Notifly.Emails.EmailNotifier do
  import Swoosh.Email

  alias Notifly.Mailer

  def deliver(recipient, sender, subject, body) do
    email =
      new()
      |> to({recipient.name, recipient.email})
      |> from({sender.first_name, sender.email})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
