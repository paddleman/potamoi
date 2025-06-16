defmodule Potamoi.Repo do
  use Ecto.Repo,
    otp_app: :potamoi,
    adapter: Ecto.Adapters.Postgres
end
