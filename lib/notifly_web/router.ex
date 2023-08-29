defmodule NotiflyWeb.Router do
  alias NotiflyWeb.VerifyUserRole
  use NotiflyWeb, :router

  import NotiflyWeb.UserAuth
  import NotiflyWeb.Plugs.VerifyUserPlan

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NotiflyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :default do
    plug VerifyUserRole, ["default","admin","superuser"]
  end
  pipeline :admin do
    plug VerifyUserRole, ["admin","superuser"]
  end
  pipeline :superuser do
    plug VerifyUserRole, ["superuser"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NotiflyWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", NotiflyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:notifly, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NotiflyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", NotiflyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{NotiflyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", NotiflyWeb do
    pipe_through [:browser, :require_authenticated_user, :default]

    live_session :require_authenticated_user,
      root_layout: {NotiflyWeb.Layouts, :auth_root},
      on_mount: [{NotiflyWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # --------------- Notifly app routes --------------------
      # Contacts
      live "/contacts", ContactLive.Index, :index
      live "/contacts/new", ContactLive.Index, :new
      live "/contacts/:id/edit", ContactLive.Index, :edit

      live "/contacts/:id", ContactLive.Show, :show
      live "/contacts/:id/show/edit", ContactLive.Show, :edit

      # Mailbox
      live "/mailbox", MailLive.Index
      live "/mails/new", MailLive.Compose
      live "/mails/:id", MailLive.Show
    end
  end

  scope "/", NotiflyWeb do
    pipe_through [:browser, :require_authenticated_user, :require_gold_plan, :default,]

    live_session :require_gold_plan,
      root_layout: {NotiflyWeb.Layouts, :auth_root},
      on_mount: [{NotiflyWeb.UserAuth, :ensure_authenticated}] do

      # Groups
      live "/groups", GroupLive.Index, :index
      live "/groups/new", GroupLive.Index, :new
      live "/groups/:id/edit", GroupLive.Index, :edit

      live "/groups/:id", GroupLive.Show, :show
      live "/groups/:id/show/edit", GroupLive.Show, :edit

      # TODO: Group contacts
      live "/groups/:id/contacts/new", GroupLive.Show, :add_to_group

      # TODO: Group emails
      live "/groups/:id/mails", GroupLive.GroupEmails
    end
  end

  scope "/", NotiflyWeb do
    pipe_through [:browser, :require_authenticated_user, :admin,]

    live_session :admin,
      root_layout: {NotiflyWeb.Layouts, :auth_root},
      on_mount: [{NotiflyWeb.UserAuth, :ensure_authenticated}] do

      # Users
      live "/users/", UserLive.Index, :index
      live "/users/:id", UserLive.Show
    end
  end

  scope "/", NotiflyWeb do
    pipe_through [:browser, :require_authenticated_user, :superuser,]

    live_session :superuser,
      root_layout: {NotiflyWeb.Layouts, :auth_root},
      on_mount: [{NotiflyWeb.UserAuth, :ensure_authenticated}] do

      # User roles
      live "/users/:id/roles", UserLive.Index, :edit_role
    end
  end

  scope "/", NotiflyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{NotiflyWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
