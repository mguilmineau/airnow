# http://joeyates.info/2015/07/25/create-a-mix-task-for-an-elixir-project/
# mix hound
defmodule Mix.Tasks.Hound do
	use Mix.Task
  use Hound.Helpers

	@shortdoc "Playground with Hound"
	
  def run(_) do
		Application.ensure_all_started(:hound)
		
		Hound.start_session( additional_capabilities: %{
                          chromeOptions: %{ "args" => [
                            "--user-agent=#{Hound.Browser.user_agent(:chrome)}",
                            "--headless",
                            "--disable-gpu"
                            ]}
                          })
    navigate_to "http://akash.im"
    IO.inspect page_title()

    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end
