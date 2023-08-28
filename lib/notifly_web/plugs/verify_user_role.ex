defmodule NotiflyWeb.VerifyUserRole do
  @moduledoc """
  This plug ensures that a user has a particular role before accessing a given route.
  """
use NotiflyWeb, :verified_routes

alias Notifly.Accounts.User
alias Notifly.Repo

import Plug.Conn
import Phoenix.Controller

def init(config), do: config

  def call(conn, roles) do
    user = Repo.get(User, conn.assigns.current_user.id) |> Repo.preload(:roles)
    current_user_roles = Enum.map(user.roles, fn role -> role.slug end)

    assign(conn, :roles, current_user_roles)

    current_user_roles
    |> has_role?(roles)
    |> maybe_halt(conn)
  end

  defp maybe_halt(true, conn), do: conn
  defp maybe_halt(_any, conn) do
    conn
    |> redirect(to: get_referrer(conn))
  end

  defp has_role?(curr_user_roles, roles) when is_list(roles) do
    Enum.any?(curr_user_roles, fn role -> role in roles end)
  end

  defp has_role?(_user, _role), do: false

  defp get_referrer(conn) do
    referrer = hd(get_req_header(conn, "referer"))
    case URI.parse(referrer) do
      %{path: path} -> path
      "/users/log_in" -> ~p"/mailbox"
      _ -> ~p"/mailbox"
    end
  end

  @doc """
  Checks if a user has specified role - for template rendering
  """
  def has_role_ui?(current_user, roles) do
    user = Repo.get(User, current_user.id) |> Repo.preload(:roles)
    curr_user_roles = Enum.map(user.roles, fn role -> role.slug end)

    Enum.any?(curr_user_roles, fn role -> role in roles end)
  end
end
