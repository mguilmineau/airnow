defmodule AirNow.Extracter do

  @doc ~S"""
		Look up relevant info on HTML source of AirNow page, previously downloaded by AirNow.Browser
		
		## Examples
		
			iex> html = AirNow.Browser.download_page( "95051" ) ; nil
			nil
			iex> Regex.scan( ~r/About AirNow/, html )
			[["About AirNow"]]
			iex> html |> Floki.find("table[class='AQData'] td[background]") |> Enum.count > 1
			true
	"""

	def extract_data( html ) do
		%{	current_aqi: extract( html, :current_aqi, "N/A" ),
				current_img: extract( html, :current_image, nil ),
				forecast_aqi: extract( html, :forecast_aqi, "N/A" ),
				forecast_img: extract( html, :forecast_image, nil )
		 }
	end

	#
	# Private
	#

	defp extract( html, func, default ) do
		# dynamically invoked functions must be public, so @doc false them
		try do apply( __MODULE__, func, [ html ] ) rescue _ -> default end
	end
	
	@doc false
	def current_aqi( html ) do
		html
			|> Floki.find("table[class='AQData']")
			|> AirNow.Extracter.filter( ~r/Air Quality Index/ )
			|> Enum.at(0)
			|> Floki.find( "td[background" )
			# three items at most: Current Conditions, Ozone Details, PM2.5 Details
			|> Enum.at(0)
			|> Floki.text
			|> String.replace( ~r/\s/, "" )
			|> String.to_integer
	end
	
	@doc false
	def forecast_aqi( html ) do
		html
			|> Floki.find("table[class='AQData']")
			|> AirNow.Extracter.filter( ~r/Tomorrow/ )
			|> Floki.find( "td[background" )
			# four items at most: two for AQ Forecast Today and Tomorrow, and two smaller ones for AQI Pollutant Details Today and Tomorrow
			|> Floki.find( "td[height=27]")
			# collect the second one
			|> Enum.at(1)
			|> Floki.text
			|> String.replace( ~r/\s/, "" )
			|> String.to_integer
	end
	
	@doc false
	def current_image( html ) do
		html
			|> Floki.find( "div[id='cur'] img" )
			|> List.first
			|> Floki.attribute( "src" )
			|> List.first
	end

	@doc false
	def forecast_image( html ) do
		html
			|> Floki.find( "div[id='fc'] img" )
			|> List.first
			|> Floki.attribute( "src" )
			|> List.first
	end

	#
	# Function to filter out a Floki result (list) based on a Regexp match in any of its element
	# Keep filter() public so that it can be used in iex
	#

	# keep only those where subfilter is true
	def filter( list, regexp ),				do: Enum.filter( list, &subfilter( &1, regexp ) )
	defp subfilter( list, regexp )		when is_list( list ), do: Enum.any?( list, &subfilter( &1, regexp ) )
	defp subfilter( tuple, regexp )		when is_tuple( tuple ), do: subfilter( Tuple.to_list( tuple ), regexp )
	defp subfilter( string, regexp )	when is_binary( string ), do: Regex.match?( regexp, string )
	defp subfilter( _, _ ),						do: raise "Extracter: Unsupported Structure"
	
end
