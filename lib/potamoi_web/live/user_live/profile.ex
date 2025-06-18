defmodule PotamoiWeb.UserLive.Profile do
  use PotamoiWeb, :live_view

  alias Potamoi.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-8">
      <!-- Header with current avatar and background -->
      <div class="relative mb-8">
        <!-- Background Image -->
        <div
          class="h-48 w-full rounded-xl bg-gradient-to-r from-base-300 to-base-200 bg-cover bg-center relative"
          style={if @current_scope.user.background_url, do: "background-image: url(#{@current_scope.user.background_url})", else: ""}
        >
          <div class="absolute inset-0 bg-black bg-opacity-30 rounded-xl"></div>
        </div>

        <!-- Avatar -->
        <div class="absolute -bottom-16 left-8">
          <div class="w-32 h-32 rounded-full border-4 border-base-100 overflow-hidden bg-base-200">
            <img
              src={@current_scope.user.avatar_url || "/images/default-avatar.png"}
              alt="Profile Avatar"
              class="w-full h-full object-cover"
            />
          </div>
        </div>
      </div>

      <!-- User Info -->
      <div class="ml-8 pt-16 mb-8">
        <h1 class="text-3xl font-bold">
          {@current_scope.user.full_name || @current_scope.user.username || "Anonymous User"}
        </h1>
        <p class="text-base-content/70 text-lg">@{@current_scope.user.username || "username"}</p>
        <p :if={@current_scope.user.bio} class="mt-4 text-base-content/90">
          {@current_scope.user.bio}
        </p>
      </div>

      <!-- Edit Profile Form -->
      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <h2 class="card-title text-2xl mb-6">Edit Profile</h2>

          <.form for={@form} phx-submit="save" phx-change="validate" class="space-y-6">
            <!-- Username -->
            <.input
              field={@form[:username]}
              type="text"
              label="Username"
              placeholder="Your unique username"
              required
            />

            <!-- Full Name -->
            <.input
              field={@form[:full_name]}
              type="text"
              label="Full Name"
              placeholder="Your full name"
            />

            <!-- Bio -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Bio</span>
              </label>
              <textarea
                name={@form[:bio].name}
                id={@form[:bio].id}
                class={[
                  "textarea textarea-bordered h-24",
                  @form[:bio].errors != [] && "textarea-error"
                ]}
                placeholder="Tell us a bit about yourself..."
                maxlength="500"
              >{Phoenix.HTML.Form.input_value(@form, :bio)}</textarea>
              <label class="label">
                <span class="label-text-alt text-base-content/60">
                  {String.length(Phoenix.HTML.Form.input_value(@form, :bio) || "")} / 500 characters
                </span>
              </label>
              <p :for={msg <- Enum.map(@form[:bio].errors, &translate_error(&1))} class="mt-1.5 flex gap-2 items-center text-sm text-error">
                <.icon name="hero-exclamation-circle" class="size-5" />
                {msg}
              </p>
            </div>

            <!-- Avatar URL -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Avatar Image</span>
              </label>
              <.live_file_input upload={@uploads.avatar} />
              <div :for={entry <- @uploads.avatar.entries} class="mt-2">
                <div class="flex items-center gap-2">
                  <.live_img_preview entry={entry} class="w-16 h-16 rounded-full object-cover" />
                  <span class="text-sm">{entry.client_name}</span>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                    class="btn btn-ghost btn-sm"
                  >
                    &times;
                  </button>
                </div>
                <progress class="progress progress-primary w-full mt-1" value={entry.progress} max="100">
                  {entry.progress}%
                </progress>
              </div>
              <p class="text-sm text-base-content/60 mt-1">Upload your profile picture (JPG, PNG, GIF, or WebP, max 2MB)</p>
            </div>

            <!-- Background URL -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Background Image</span>
              </label>
              <.live_file_input upload={@uploads.background} />
              <div :for={entry <- @uploads.background.entries} class="mt-2">
                <div class="flex items-center gap-2">
                  <.live_img_preview entry={entry} class="w-24 h-16 rounded object-cover" />
                  <span class="text-sm">{entry.client_name}</span>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                    class="btn btn-ghost btn-sm"
                  >
                    &times;
                  </button>
                </div>
                <progress class="progress progress-primary w-full mt-1" value={entry.progress} max="100">
                  {entry.progress}%
                </progress>
              </div>
              <p class="text-sm text-base-content/60 mt-1">Upload your profile background image (JPG, PNG, GIF, or WebP, max 5MB)</p>
            </div>

            <!-- Action Buttons -->
            <div class="flex gap-4 pt-6">
              <.button type="submit" variant="primary" phx-disable-with="Saving..." class="flex-1">
                Save Profile
              </.button>
              <.link
                navigate={~p"/potamoi"}
                class="btn btn-outline flex-1"
              >
                Cancel
              </.link>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_user_profile(user)

    {:ok,
     socket
     |> assign(:page_title, "Profile")
     |> assign_form(changeset)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 1,
       max_file_size: 2_000_000  # 2MB
     )
     |> allow_upload(:background,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 1,
       max_file_size: 5_000_000  # 5MB
     )}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref) |> cancel_upload(:background, ref)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # Process uploaded files
    avatar_urls = consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      # Create unique filename
      filename = "avatar_#{socket.assigns.current_scope.user.id}_#{System.unique_integer()}_#{entry.client_name}"
      dest_path = Path.join("priv/static/uploads", filename)

      # Ensure uploads directory exists
      File.mkdir_p!(Path.dirname(dest_path))

      # Copy uploaded file
      File.cp!(path, dest_path)

      # Return the URL path
      {:ok, "/uploads/#{filename}"}
    end)

    background_urls = consume_uploaded_entries(socket, :background, fn %{path: path}, entry ->
      # Create unique filename
      filename = "background_#{socket.assigns.current_scope.user.id}_#{System.unique_integer()}_#{entry.client_name}"
      dest_path = Path.join("priv/static/uploads", filename)

      # Ensure uploads directory exists
      File.mkdir_p!(Path.dirname(dest_path))

      # Copy uploaded file
      File.cp!(path, dest_path)

      # Return the URL path
      {:ok, "/uploads/#{filename}"}
    end)

    # Add uploaded file URLs to user params
    user_params_with_uploads =
      user_params
      |> maybe_add_avatar_url(avatar_urls)
      |> maybe_add_background_url(background_urls)

    case Accounts.update_user_profile(socket.assigns.current_scope.user, user_params_with_uploads) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully!")
         |> assign(:current_scope, %{socket.assigns.current_scope | user: user})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp maybe_add_avatar_url(params, []), do: params
  defp maybe_add_avatar_url(params, [url | _]), do: Map.put(params, "avatar_url", url)

  defp maybe_add_background_url(params, []), do: params
  defp maybe_add_background_url(params, [url | _]), do: Map.put(params, "background_url", url)

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
