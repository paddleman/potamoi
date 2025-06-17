defmodule PotamoiWeb.HomeLive do
  use PotamoiWeb, :live_view

  alias Potamoi.Accounts

  def mount(_params, _session, socket) do

    {:ok, socket}
  end
  def render(assigns) do
    ~H"""
    <Layouts.main_app flash={@flash} current_scope={@current_scope}>
      <div class="hero bg-base-200/50">
        <div class="hero-content flex-col lg:flex-row">
          <img
          src={~p"/images/potamoi.png"}
            class="max-w-sm rounded-lg shadow-2xl"
          />
          <div>
            <h1 class="text-5xl font-bold">Welcome to Potamoi!</h1>
            <p class="py-6">For the River Gods Amongst Us.</p>
            <button class="btn btn-primary" >Start</button>
          </div>
        </div>
      </div>
    </Layouts.main_app>
    """
  end



end
