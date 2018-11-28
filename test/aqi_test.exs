defmodule AQITest do
  use ExUnit.Case, async: false

	doctest AirNow.AQI

	@zip Application.get_env( :airnow, :default_zip	)

	test "stores values by key" do
    AirNow.AQI.save( @zip, nil )
    assert AirNow.AQI.current_aqi( @zip ) == nil

    AirNow.AQI.save( @zip, 52 )
    assert AirNow.AQI.current_aqi( @zip ) == 52
    assert AirNow.AQI.previous_aqi( @zip ) == nil

    AirNow.AQI.save( @zip, 51 )
    assert AirNow.AQI.current_aqi( @zip ) == 51
    assert AirNow.AQI.previous_aqi( @zip ) == 52
  end

	test "survives a Workflow crash" do
    AirNow.AQI.save( @zip, 53 )
    assert AirNow.AQI.current_aqi( @zip ) == 53

		GenServer.stop( AirNow.Workflow, :shutdown )
		assert AirNow.AQI.current_aqi( @zip ) == 53
		
    AirNow.AQI.save( @zip, 54 )
		assert AirNow.AQI.previous_aqi( @zip ) == 53
		assert AirNow.AQI.current_aqi( @zip ) == 54
	end
	
	test "are temporary workers" do
    assert Supervisor.child_spec( AirNow.AQI, []).restart == :temporary
  end	

end
