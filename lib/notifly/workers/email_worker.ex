defmodule Notifly.Workers.EmailWorker do
  require Logger
  alias Notifly.Emails.Email
  alias Notifly.Repo
  alias Notifly.Emails
  alias Notifly.Emails.EmailNotifier
  use Oban.Worker, queue: :mailers, max_attempts: 5, priority: 3, tags: ["bulk_email"]

  alias NotiflyWeb.{Endpoint}
  def perform(%Oban.Job{args: %{"channel" => channel, "email_id" => email_id, "sender" => sender, "recipient" => recipient, "subject" => subject, "body" => body}}) do
    send_email(channel, email_id, recipient, sender, subject, body)
    await_email(channel,email_id)
  end

  defp send_email(_channel, email_id, recipient, sender, subject, body) do
    job_pid = self()

    # Send email
    Task.async(fn ->
      email_delivery = EmailNotifier.worker_email_delivery(recipient, sender, subject, body)
      with {:ok, _email} <- email_delivery do
        send(job_pid, {:sent, email_id})
      else
        _ -> send(job_pid, {:failed, email_id})
      end
    end)
  end

  defp await_email(channel, email_id) do
    receive do
      {:progress, percent} ->
        Endpoint.broadcast(channel, "email:progress", %{email_id: email_id, status: :pending, progress: percent})
        await_email(channel,email_id)

      {:sent, _message} ->
        Emails.update_email(Repo.get(Email, email_id), %{status: :sent})
        Endpoint.broadcast(channel, "email:sent", %{email_id: email_id, status: :sent, progress: 100})

      {:failed, _message} ->
        Endpoint.broadcast(channel, "email:failed", %{email_id: email_id, status: :failed ,progress: 0})
    after
      10_000 ->
        Endpoint.broadcast(channel, "email:failed", %{email_id: email_id, status: :failed ,progress: 0})
        raise RuntimeError, "no progress after 10s"
    end
  end
end
