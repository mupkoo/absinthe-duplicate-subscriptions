# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :showcase, ShowcaseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YI+vJ6S4rLxdhR/0a9RUnVypjiE78drYVookBrgQ1o1kqMIi0immSE9jAF9Ywkhg",
  render_errors: [view: ShowcaseWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Showcase.PubSub,
  live_view: [signing_salt: "dB2S+j6v"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
