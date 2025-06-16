defmodule PotamoiWeb.PageController do
  use PotamoiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
