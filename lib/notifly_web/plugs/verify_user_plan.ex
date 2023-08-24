defmodule NotiflyWeb.Plugs.VerifyUserPlan do
  require Logger
  use NotiflyWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller


  @doc """
  Used for routes that require the user to have a Gold Plan.
  """
  def require_gold_plan(conn, _opts) do
    user_plan = conn.assigns.current_user.plan
    Logger.info(user_plan)
    if user_plan == :gold do
      conn
    else
      conn
      |> put_flash(:error, "Feature only available to Gold Plan users")
      |> redirect(to: get_referrer(conn))
    end
  end

  #Helper function to get the previous URL from the referrer header
  defp get_referrer(conn) do
    referrer = hd(get_req_header(conn, "referer"))
    case URI.parse(referrer) do
      %{path: path} -> path
      "/users/log_in" -> ~p"/mailbox"
      _ -> ~p"/mailbox"
    end
  end
end
