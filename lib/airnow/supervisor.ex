defmodule AirNow.Supervisor do
	use Supervisor

	def start_link( opts ), do: Supervisor.start_link( __MODULE__, :ok, opts )
	
	def init( :ok ) do
		children = [
			{ AirNow.AQI, name: AirNow.AQI },
			{ AirNow.Downloader, name: AirNow.Downloader },
			{ AirNow.Workflow, name: AirNow.Workflow }
		]

		# Workflow will crash regularly due to unavailable or changing websites.
		# We want it automatically restart.
		# AirNow.Downloader will also crash regularly, but we want it to crash independently.
		# AirNow.AQI must keep going in parallel.
		Supervisor.init( children, strategy: :one_for_one )
	end
end
