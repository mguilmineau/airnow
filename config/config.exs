use Mix.Config

# load full name, username and password from private config file
# config :airnow, name: "..."
# config :airnow, email_username: "..."
# config :airnow, email_password: "..."
import_config "private.exs"

config :airnow, admin_user: %{ name: Application.get_env( :airnow, :name ), email: Application.get_env( :airnow, :email_username ) }
config :airnow, default_tmp: "d:/tmp" # yes, I developed this on windows...
config :airnow, default_zip: "95051"
config :airnow, url: "https://www.airnow.gov"
# https://www.whoishostingthis.com/tools/user-agent/
config :airnow, user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

config :airnow, AirNow.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.gmail.com",
  username: Application.get_env( :airnow, :email_username ),
  password: Application.get_env( :airnow, :email_password ),
  ssl: true,
  tls: :never, # bad record mac when on port 587 with TLS - appears to be a known erlang SSL issue
  auth: :always,
  port: 465,
  retries: 2,
  no_mx_lookups: false

config :hound, driver: "chrome_driver", browser: "chrome_headless"
config :hound, retry_time: 500
config :hound, genserver_timeout: 480000
