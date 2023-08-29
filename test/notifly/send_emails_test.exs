defmodule Notifly.SendEmailsTest do
  alias Notifly.Emails
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  test "send single email" do
    user = create_user(%{
      first_name: "Vinn",
      last_name: "Tester",
      email: "tony.stark@example.com",
      msisdn: "0712345678"
      })
    contact = create_contact(%{
      username: "ironman",
      email: "tony.stark@example.com",
      owner_id: 1
      })
    subject = "Test email subject"
    body = """
    Test email body
    """
    type = "single"
    assert_email_sent Emails.send_single_email(%{})
  end
end
