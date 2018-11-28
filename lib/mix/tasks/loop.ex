# http://joeyates.info/2015/07/25/create-a-mix-task-for-an-elixir-project/
# mix loop

defmodule Mix.Tasks.Loop do
	use Mix.Task

  def run(_) do
		Application.ensure_all_started(:airnow)

		try do
			AirNow.Workflow.process()
		catch
			# As AirNow regularly goes down while their hourly update takes place,
			# we will regularly get :exit.
			# Let it fail and resume the process one minute later
			:exit, e -> IO.puts( "Error: #{inspect e}" )
		end
		:timer.sleep( :timer.minutes( 1 ) )
		run( :infinity )
	end
end

