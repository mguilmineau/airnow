defmodule AirNow.AQI do
	# never restart AQI
	use Agent, restart: :temporary
	
	@moduledoc """
		AQI storage %{ zip -> [ current_aqi, previous_aqi, previous_aqis... ] }
		Used for threshold crossing trigger
	"""

	# doctest (mix test)
  @doc ~S"""
		Store and retrieve AQI information per zip
		
		## Examples
		
			iex> AirNow.AQI.save( "12345", "25" ) ; nil
			nil
			iex> AirNow.AQI.save( "12345", "33" ) ; nil
			nil
			iex> AirNow.AQI.current_aqi( "12345" )
			"33"
			iex> AirNow.AQI.previous_aqi( "12345" )
			"25"
	"""

	def start_link( _opts ), do: Agent.start_link( fn -> %{ } end, name: AQI )
		
	def current_aqi( zip ) do
		aqis = aqis( zip )
		if ( aqis == nil ), do: nil, else: Enum.at( aqis, 0 )
	end

	def previous_aqi( zip ) do
		aqis = aqis( zip )
		if ( aqis == nil ), do: nil, else: Enum.at( aqis, 1 )
	end
	
	def save( zip, aqi ) do
		aqis = aqis( zip )
		Agent.update( AQI, &Map.put( &1, zip, [ aqi | aqis ] ) )
		# dump asynchronously to DETS for command-line querying and for previous value when restarting
		# https://code.tutsplus.com/articles/ets-tables-in-elixir--cms-29526
		Task.async( fn -> save_on_disk( zip ) end )
	end
	
	# This can be queried from command line:
	# iex -S mix
	# AirNow.AQI.aqi_history( "95051" )
	def aqi_history( zip ) do
		:dets.open_file( :file_table, [ {:file, 'aqis.txt' } ] )
		data = :dets.lookup( :file_table, zip )
		# IO.puts( "Retrieved #{inspect data, charlists: :as_lists}")
		:dets.close( :file_table )
		cond do
			Enum.empty?( data ) -> [ ]
			true -> ( { _zip, aqis } = ( data |> List.first ) ; aqis )
		end
	end
	
	#
	# Private
	#
	
	defp save_on_disk( zip ) do
		:dets.open_file( :file_table, [ {:file, 'aqis.txt' } ] )
		:dets.insert( :file_table, { zip, aqis( zip ) } )
		:dets.close( :file_table )
	end

	defp aqis( zip ) do
		# read from memory if available
		Agent.get( AQI, &Map.get( &1, zip ) ) ||
		# otherwise retrieve from disk
		aqi_history( zip ) ||
		# worst case, we start with an empty list
		[ ]
	end
end
