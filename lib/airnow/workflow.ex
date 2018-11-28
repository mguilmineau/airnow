defmodule AirNow.Workflow do
	use GenServer

	@defaults %{
		directory: Application.get_env( :airnow, :default_tmp	),
		zip:       Application.get_env( :airnow, :default_zip	)
	}

	#
	# Client API
	#

	@doc "Start a Workflow process"
  def start_link( state ), do: GenServer.start_link( __MODULE__, state, name: __MODULE__ )

	@doc "Execute a Workflow process"
	def process(), do: GenServer.call( __MODULE__, :process, 60_000 )
	def process( [ zip: zip, directory: directory ] ), do: GenServer.call( __MODULE__,
		{ :process, zip: zip, directory: directory }, 60_000 )
	
	#
  # Server Callbacks
	#

	@doc false	
	def init( state ), do: { :ok, state }

	@doc false
	# synchronous calls	
  def handle_call( { :process, zip: zip, directory: directory }, _from, state ) do
		data = process( zip || @defaults[:zip], directory || @defaults[:directory] )
    { :reply, data, state }
  end
  def handle_call( :process, from, state ), do: handle_call( { :process, zip: nil, directory: nil }, from, state )

	@doc false
	def handle_info( _msg, state ) do
		# IO.puts "Handle Info: #{inspect( msg )}"
		{ :noreply, state }
	end

	@doc false
	def terminate( reason, _state) do
		IO.puts "Workflow terminated: #{inspect( reason ) }" 
    :ok
  end

	#
	# Private
	#
	
	defp process( zip, directory ) do
		IO.puts( "Processing zip #{zip} in dir #{directory}" )
		File.mkdir_p!( directory )

		zip
			|> AirNow.Browser.download_page
			|> AirNow.Extracter.extract_data
			|> AirNow.Downloader.download_images( zip, directory )
			|> update_state( zip )
			# send e-mail if a * 50 threshold was crossed
			|> AirNow.Mailer.notify_aqi_change
	end
	
	defp update_state( data, zip ) do
		AirNow.AQI.save( zip, data[:current_aqi] )
    IO.puts "Completed at #{data[:ltd]}. Current AQI is #{AirNow.AQI.current_aqi( zip )} from #{AirNow.AQI.previous_aqi( zip )}. Tomorrow: #{data[:forecast_aqi]}"
		zip
  end

end
