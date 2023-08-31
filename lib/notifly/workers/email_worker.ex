defmodule Notifly.Workers.EmailWorker do
  require Logger
  alias Notifly.Emails.GroupEmails
  alias Notifly.Emails.Email
  alias Notifly.Repo
  alias Notifly.Emails
  alias Notifly.Emails.EmailNotifier
  alias NotiflyWeb.{Endpoint}

  use Oban.Worker, queue: :mailers, max_attempts: 5, priority: 3, tags: ["bulk_email"]

  defstruct []

  defimpl Notifly.Reportable do
    @threshold 1

    def reportable?(_worker, attempt), do: attempt > @threshold
  end

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
        # Update email status
        email = Repo.get(Email, email_id)
        Emails.update_email(email, %{status: :sent})
        # update sent group emails count
        if email.ge_id do
          group_email = Repo.get(GroupEmails, email.ge_id)
          new_success_count = group_email.success_emails + 1
          new_pending_count = group_email.pending_emails - 1
          GroupEmails.update_group_email(group_email, %{success_emails: new_success_count, pending_emails: new_pending_count})
        end

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
