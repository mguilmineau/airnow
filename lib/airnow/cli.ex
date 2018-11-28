# Must run chromedriver.exe while this runs
# After modifying this file:
# mix escript.build && escript airnow -z "95051"
defmodule AirNow.Cli do

  def main( args ) do
    args
			|> parse_args
			|> case do
			{ [ help: true ], _, _ } -> process( :help )
      { params, _, _} -> process( params )
		end
  end

	#
	# Private
	#

  defp parse_args( args ) do
    OptionParser.parse(
			args,
			switches: [ zip: :string, directory: :string, help: :boolean ],
			aliases: [ z: :zip, d: :directory, h: :help ]
		)
	end
	
	defp process( :help ) do
		IO.puts """
			Usage:
				escript airnow -h # this message
				escript airnow # use default values
				escript airnow -z 95051 -d d:/tmp
				mix loop # run permanently the mix task Loop
			"""
    System.halt(0)
  end

	defp process( params ) do
		# IO.puts "Client: Processing #{inspect params}"
		AirNow.Workflow.process( [
			zip: params[:zip],
			directory: params[:directory]
			] )
	end
	
end
