defmodule Notifly.Workers.EmailWorker do
  alias Notifly.Emails.EmailNotifier
  use Oban.Worker, queue: :mailers, max_attempts: 1, priority: 3, tags: ["bulk_email"]

  alias NotiflyWeb.{Endpoint}
  def perform(%{"channel" => channel, "sender" => sender, "recipient" => recipient, "subject" => subject, "body" => body}) do
    send_email(recipient, sender, subject, body)
    await_email(channel)
  end

  defp send_email(recipient, sender, subject, body) do
    job_pid = self()

    # Send email
    Task.async(fn ->
      email_delivery = EmailNotifier.deliver(recipient, sender, subject, body)
      with {:ok, email} <- email_delivery do
        send(job_pid, {:sent, email})
      end
    end)
  end

  defp await_email(channel) do
    receive do
      {:progress, percent} ->
        Endpoint.broadcast(channel, "email:progress", percent)
        await_email(channel)

      {:sent, zip_path} ->
        Endpoint.broadcast(channel, "email:sent", zip_path)
    after
      10_000 ->
        Endpoint.broadcast(channel, "email:failed", "sending email failed")
        raise RuntimeError, "no progress after 10s"
    end
  end
end
