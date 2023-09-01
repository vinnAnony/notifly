defmodule NotiflyWeb.UserSettingsLive do
  use NotiflyWeb, :live_view

  alias Notifly.Accounts

  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-2xl">
      <.header class="text-center">
        Account Settings
        <:subtitle>Manage your account information</:subtitle>
      </.header>

      <div class="space-y-12 divide-y">
        <div>
          <.simple_form
            for={@user_details_form}
            id="user_details_form"
            phx-submit="update_user_details"
            phx-change="validate_user_details"
          >
            <.input field={@user_details_form[:first_name]} type="text" label="First Name" required />
            <.input field={@user_details_form[:last_name]} type="text" label="Last Name" required />
            <.input field={@user_details_form[:msisdn]} type="text" label="Phone Number" required />
            <.input field={@user_details_form[:email]} type="email" label="Email" required />
            <.input
              field={@user_details_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@user_details_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Modify</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              field={@password_form[:email]}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input field={@password_form[:password]} type="password" label="New password" required />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Password</.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user_details_changeset = Accounts.change_user_details(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:user_details_form_current_password, nil)
      |> assign(:current_user_details, user)
      |> assign(:current_email, user.email)
      |> assign(:user_details_form, to_form(user_details_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_user_details", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    user_details_form =
      socket.assigns.current_user
      |> Accounts.change_user_details(user_params)
      |> to_form()

    {:noreply, assign(socket, user_details_form: user_details_form, user_details_form_current_password: password)}
  end

  def handle_event("update_user_details", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_details(user, password, user_params) do
      {:ok, _updated_user} ->
        {:noreply, socket |> put_flash(:info, "Details updated successfully.") |> assign(user_details_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :user_details_form, to_form(changeset))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
