# Emails can also be sent straight with gen_smtp from iex -S mix:
# :gen_smtp_client.send( { "<email>", ["<email>"],
# "Subject: testing\r\nFrom: Myself \r\nTo: Myself \r\n\r\nThis is the email body"},
#  [ {:relay, "smtp.gmail.com"}, {:username, "<email>"},
#    {:password, "<password>"},  {:port, 465}, {:ssl, true}, {:auth, "always"},
#		 {:retries, 2}, {:tls, "never"} ] )

defmodule AirNow.Mailer do
  use Swoosh.Mailer, otp_app: :airnow
	import Swoosh.Email

	#
	# Only send an e-mail notification if we crossed into another AQI group (multiple of 50)
	# Good / Moderate / USG / Unhealthy / Very Unhealthy / Hazardous
	#
	
	def notify_aqi_change( zip ), do: notify_aqi_change( AirNow.AQI.previous_aqi( zip ), AirNow.AQI.current_aqi( zip ))
	
	#
	# Private
	#
	
	defp notify_aqi_change( old_aqi, new_aqi ) when old_aqi == nil or new_aqi == nil, do: :ok
	defp notify_aqi_change( old_aqi, new_aqi ) when old_aqi == "N/A" or new_aqi == "N/A", do: :ok
	defp notify_aqi_change( old_aqi, new_aqi ) when trunc( old_aqi / 50 ) == trunc( new_aqi / 50 ), do: :ok
	
	defp notify_aqi_change( old_aqi, new_aqi ) do
		subject = if trunc( old_aqi / 50 ) > trunc( new_aqi / 50 ),
			do:   "AQI Decreased From #{old_aqi} To #{new_aqi} - now #{description( new_aqi )}",
			else: "AQI Increased From #{old_aqi} To #{new_aqi} - now #{description( new_aqi )}"
		user = Application.get_env( :airnow, :admin_user )
		new()
			|> to( { user.name, user.email } )
			|> from( { "AirNow@Elixir", user.email } )
			|> subject( subject )
			|> html_body("<h1>#{subject}</h1>")
			|> text_body("#{subject}\n")
			|> deliver()
	end

	defp description( aqi ) do
		cond do
			aqi < 51	-> "Good"
			aqi < 101	-> "Moderate"
			aqi < 151	-> "Unhealthy for Sensitive Groups"
			aqi < 201	-> "Unhealthy"
			aqi < 251	-> "Very Unhealthy"
			aqi < 501	-> "Hazardous"
			true			-> "Off Chart!"
		end
	end
	
end
