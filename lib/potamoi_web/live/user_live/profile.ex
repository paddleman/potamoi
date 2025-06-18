defmodule PotamoiWeb.UserLive.Profile do
  use PotamoiWeb, :live_view

  alias Potamoi.Accounts

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_user_profile(user)

    {:ok,
     socket
     |> assign(:page_title, "Profile")
     |> assign(:show_modal, false)
     |> assign_form(changeset)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 1,
       # 2MB
       max_file_size: 2_000_000
     )
     |> allow_upload(:background,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 1,
       # 5MB
       max_file_size: 5_000_000
     )}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
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
    avatar_urls =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        # Create unique filename
        filename =
          "avatar_#{socket.assigns.current_scope.user.id}_#{System.unique_integer()}_#{entry.client_name}"

        dest_path = Path.join("priv/static/uploads", filename)

        # Ensure uploads directory exists
        File.mkdir_p!(Path.dirname(dest_path))

        # Copy uploaded file
        File.cp!(path, dest_path)

        # Return the URL path
        {:ok, "/uploads/#{filename}"}
      end)

    background_urls =
      consume_uploaded_entries(socket, :background, fn %{path: path}, entry ->
        # Create unique filename
        filename =
          "background_#{socket.assigns.current_scope.user.id}_#{System.unique_integer()}_#{entry.client_name}"

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
         |> assign(:show_modal, false)
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
