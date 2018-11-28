# AirNow
##### Mathieu 2018-11-18 to 2018-11-28

This GitHub project shares my 2-week experience learning Elixir and applying what I'd learned on a simple project.

1. Read [Getting Started, Mix and OTP and Meta Programming](https://elixir-lang.org/getting-started/introduction.html). Practiced with the KV example.
2. Analyzed manga_downloadr for a real-world example.
3. Read threads on [Elixir Forum](https://elixirforum.com) to absorbe best practices.
4. Started this project.

**Project**
  * Go to [AirNow.gov](https://www.airnow.gov/)
  * select zip code 95051
  * download current and forecast pollution level (Air Quality Index / AQI)
  * download current and forecast image
  * repeat every minute
  * do not save duplicate images (sha256 check)
  * store AQI history in memory and on file (DETS)
  * offer command-line access
  * send e-mail when crossing a * 50 threshold

**Objective**

  * Use Elixir objects: Supervisors, GenServer, Tasks, Mix Tasks, Agents, escript
  * Use erlang storage: :ets, :dets
  * Use tests: mix test, doctest
  * Use web scrape library (Hound), use email library (Swoosh), use HTML parser library (Floki)
  * Use minimal try/rescue, let processes fail
  * Use function guards and function captures
  * Use string formatting (dates)

**How I got started**

  * installed erlang 21.1 (on windows...)
  * installed Elixir
  * created project on disk
	```
	mix new airnow --module AirNow
	cd airnow
	```
  * added escript to project and deps (HTTPoison, Floki) to mix.exs
	```
	mix deps.get
	mix compile # asked to install "rebar3"
	```
  * created cli.ex
	```
	mix escript.build
	escript airnow -z 95051
	```
  * onwards with development: created workflow.ex, etc.

**How to run**

  * Create and configure config/private.exs (check config/config.exs for details)

  * Compile
	```
	mix deps.get
	mix compile
	```

  * Make sure [chromedriver.exe](http://chromedriver.chromium.org/downloads) is running in a separate window.
		Check that it connects successfully
	```
	mix hound
	```
    
  * Run the AirNow application once for a given zip code
	```
	mix escript.build && escript airnow -z "95051" -d "d:/Tmp"
	```
  * Run the AirNow application as a loop, connecting once per minute
	```
	mix loop
	```
  * Query Air Quality Index(AQI) history from the command line (one number every minute)
	```
	iex -S mix
	AirNow.AQI.aqi_history( "95051" )
	```
  * Run tests in test/ and inline doctests
	```
	mix test
	```
	
Questions / Comments welcome!
