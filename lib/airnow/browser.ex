Application.ensure_all_started(:hound)

defmodule AirNow.Browser do
	use Hound.Helpers

	@url Application.get_env( :airnow, :url )

	# doctest (mix test)
  @doc ~S"""
		Retrieve HTML source of AirNow page, after selection of zip code
		
		## Examples
		
			iex> html = AirNow.Browser.download_page( "95051" ) ; nil
			nil
			iex(14)> Regex.scan( ~r/About AirNow/, html )
			[["About AirNow"]]
	"""
	
	def download_page( zip ) do
		init_hound_session()
		navigate_to( @url )
		submit_zip( zip )
		
		# If we want to inspect cookies (not needed for this project)
		# IO.inspect Enum.map( cookies(), fn x -> { x["name"], x["value"] } end ) |> Enum.into( %{} )
		
		html = page_source()
		end_hound_session()
		html
	end
	
	#
	# Private
	#
	
	defp submit_zip( zip ) do
		find_element( :id, "zipcode" )
			|> fill_field( zip )
		find_element( :id, "submit" )
			|> click()
	end

	defp init_hound_session() do
		# https://github.com/HashNuke/hound/issues/135
		Hound.start_session( additional_capabilities: %{
                          chromeOptions: %{ "args" => [
                            "--user-agent=#{Hound.Browser.user_agent(:chrome)}",
                            "--headless",
                            "--disable-gpu"
                            ]},
													cssSelectorsEnabled: true,
													javascriptEnabled: true
                          })
	end
							
	def end_hound_session() do
		Hound.end_session
	end
	
end
