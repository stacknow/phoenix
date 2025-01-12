defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  # Define a simple pipeline that will just accept the request without additional processing
  pipeline :simple do
    plug :accepts, ["text/plain"]  # Allow text responses
  end

  # Define the root route for Hello, World!
  scope "/", HelloWorldWeb do
    pipe_through :simple  # Use the minimal :simple pipeline

    get "/", PageController, :index  # Map the root URL ("/") to the index action of the PageController
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hello_world, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: HelloWorldWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
