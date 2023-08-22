defmodule Notifly.Repo do
  use Ecto.Repo,
    otp_app: :notifly,
    adapter: Ecto.Adapters.Postgres
end
