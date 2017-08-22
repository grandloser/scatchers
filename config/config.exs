# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :scatchers, Scatchers.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3rVZoicOes03ePXh0k1ET11HBkIza1pQDeLuSfP2mbqc1vZUvbKMVJEB6KRvfki2",
  render_errors: [view: Scatchers.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Scatchers.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :scatchers, Scatchers.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.gmail.com",
  port: 465,
  username: "busanmaninseoul@gmail.com",
  password: "qntksaos2",
  tls: :if_available, # can be `:always` or `:never`
  ssl: true, # can be `true`
  retries: 1


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
