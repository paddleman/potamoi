defmodule PotamoiWeb.SplashLive do
  use PotamoiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.splash_app flash={@flash}>
      <div class="hero bg-base-200/50">
        <div class="hero-content flex-col lg:flex-row">
          <img
          src={~p"/images/potamoi.png"}
            class="max-w-sm rounded-lg shadow-2xl"
          />
          <div>
            <h1 class="text-5xl font-bold">Welcome to Potamoi!</h1>
            <p class="py-6">For the River Gods Amongst Us.</p>
            <button class="btn btn-primary">Log In</button>
          </div>
        </div>
      </div>
    </Layouts.splash_app>
    """
  end
end
