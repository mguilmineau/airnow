use Mix.Config

config :airnow,
	default_tmp: "d:/tmp", # yes, I developed this on windows...
	default_zip: "95051",
	url: "https://www.airnow.gov",
	# https://www.whoishostingthis.com/tools/user-agent/
	user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

config :airnow, AirNow.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.gmail.com",
  ssl: true,
  tls: :never, # bad record mac when on port 587 with TLS - appears to be a known erlang SSL issue
  auth: :always,
  port: 465,
  retries: 2,
  no_mx_lookups: false

config :hound,
	driver: "chrome_driver",
	browser: "chrome_headless",
	retry_time: 500,
	genserver_timeout: 480000

# load full name, username and password from private.exs config file
#
#config :airnow,
#	name: "...",
#	email_username: "...",
#	email_password: "..."
#
#config :airnow, AirNow.Mailer,
#  username: "...",
#  password: "..."

import_config "private.exs"
