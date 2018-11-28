Application.ensure_all_started(:hound)

defmodule BrowserTest do
  use ExUnit.Case, async: true
	use Hound.Helpers

	doctest AirNow.Browser

	@url Application.get_env( :airnow, :url )
	@zip Application.get_env( :airnow, :default_zip )

	test "check JavaScript alert on invalid zip code" do
		init_hound_session()
		navigate_to( @url )

		# fill out an invalid zip code, triggering a JavaScript alert
		find_element( :id, "zipcode" )
			|> fill_field( "12" )
		find_element( :id, "submit" )
			|> click()

		assert_raise Hound.Error, ~r/5 digit Zip Codes only/, fn -> 
			find_element( :id, "zipcode" )
				|> fill_field( @zip )
		end
	end
	
	test "check clear JavaScript alert then navigation on valid zip code" do
		init_hound_session()
		navigate_to( @url )
		assert page_title() == "AirNow"

		# fill out an invalid zip code, triggering a JavaScript alert
		find_element( :id, "zipcode" )
			|> fill_field( "12" )
		find_element( :id, "submit" )
			|> click()

		# clear the JavaScript alert then submit a valid zip code
		accept_dialog()
		find_element( :id, "zipcode" )
			|> fill_field( @zip )
		find_element( :id, "submit" )
			|> click()
	
		assert page_title() == "AIRNow - San Jose, CA Air Quality"
		
		end_hound_session()
	end

	#
	# Private
	#

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
