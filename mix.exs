defmodule AirNow.MixProject do
  use Mix.Project

  def project do
    [
      app: :airnow,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
			escript: [main_module: AirNow.Cli],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [ :logger, :hound, :gen_smtp, :swoosh ],
			mod: { AirNow, [ ] }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
	# Run mix deps.get after modifying
  defp deps do
    [
			{ :httpoison,	"~> 1.4" },
			{ :hound,			"~> 1.0" },
			{ :floki, 		"~> 0.20"},
			{ :gen_smtp,	"~> 0.13"},
			{ :swoosh,		"~> 0.20"}
    ]
  end
end
