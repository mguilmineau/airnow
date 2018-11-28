defmodule AirNow do
	use Application

  @moduledoc """
		Goes to https://www.airnow.gov/,
		Select zip code and submit,
		Retrieve current and forecast pollution level (AQI),
		Download current and forecast images.
		Do this every minute.
		Do not download the same image multiple times.
		E-mail if forecast crosses a multiple of 50 from previous value.
  """
	
	# Must run chromedriver.exe while this runs
	# Execute using mix loop or escript airnow -z 94043
	def start( _type, _args ), do: AirNow.Supervisor.start_link( name: AirNow.Supervisor )
	
end
