# AirNow
# Mathieu 2018-11-18 to 2018-11-28

This public GitHub project shares my ~ 2-week experience learning Elixir and applying what I'd learned on a simple project.

First: Getting Started, Mix and OTP and Meta Programming sections at https://elixir-lang.org/getting-started/introduction.html,
practiced with the KV example. 
Then: manga_downloadr analysis for a real-world example
Then: read threads on https://elixirforum.com for syntactical best practices
Then: this project

Project:
  Go to https://www.airnow.gov/, 
	select zip code 95051, 
	download current and forecast pollution level (Air Quality Index / AQI),
	download current and forecast image,
	repeat every minute,
	do not save duplicate images (sha256 check),
	store AQI history in memory and on file (DETS),
	offer command-line access,
	send e-mail when crossing a * 50 threshold.

Objective:
  Use Elixir objects: Supervisors, GenServer, Tasks, Mix Tasks, Agents, escript
	Use erlang storage: :ets, :dets
	Use tests: mix test, doctest
	Use web scape library (Hound), use email library (Swoosh), use HTML parser library (Floki)
	Use minimal try/rescue, let processes fail
	Use function guards and function captures
	Use string formatting (dates)
	
How I got started:
  * installed erlang 21.1 (on windows...)
  * installed Elixir
  * created folder d:\elixir
    mix new airnow --module AirNow
    cd airnow
  * added escript to project and deps (HTTPoison, Floki) to mix.exs
    mix deps.get
    mix compile # asked to install "rebar3"
  * created cli.ex
    mix escript.build
    escript airnow -z 95051
  * onwards with development: created workflow.ex, etc.

How to run:
	* First make sure chromedriver.exe is running in a separate window
		http://chromedriver.chromium.org/downloads
		Run mix hound to check that it connects properly
  * Run once for a given zip code:
	  mix escript.build && escript airnow -z "95051"
	* Run as a loop
    mix loop
	* Query AQI history from command line (one number every minute)
		iex -S mix
		AirNow.AQI.aqi_history( "95051" )
	* Run tests in test/ and inline doctests
		mix test
		
Questions / Comments welcome.