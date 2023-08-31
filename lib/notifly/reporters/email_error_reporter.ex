defmodule Notifly.Reporters.EmailErrorReporter do
  alias NotiflyWeb.Endpoint
  alias Notifly.Emails.Email
  alias Notifly.Emails.GroupEmails
  alias Notifly.Emails
  alias Notifly.Repo
  def handle_event([:oban, :job, :exception], _, %{attempt: attempt} = meta, _) do
      if attempt == 1 do
        context = Map.take(meta, [:id, :args, :queue, :worker])

        IO.puts("FAILED EMAIL JOB")
        IO.inspect(meta.reason)
        IO.puts("FAILED EMAIL JOB CONTEXT")
        IO.inspect(context)
        IO.puts("FAILED EMAIL ID")
        IO.inspect(context.args["email_id"])

        # Update email status
        email_id = context.args["email_id"]
        email = Repo.get(Email, email_id)
        Emails.update_email(email, %{status: :failed})
        # update sent group emails count
        if email.ge_id do
          group_email = Repo.get(GroupEmails, email.ge_id)
          new_failed_count = group_email.failed_emails + 1
          new_pending_count = group_email.pending_emails - 1

          # Update group email status
          GroupEmails.update_group_email(group_email, %{failed_emails: new_failed_count, pending_emails: new_pending_count, status: :failed})
        end
        Endpoint.broadcast(context.args["channel"], "email:failed", %{email_id: email_id, status: :failed})
      end
    end
end
