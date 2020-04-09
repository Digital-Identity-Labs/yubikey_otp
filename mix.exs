defmodule YubikeyOTP.MixProject do
  use Mix.Project

  def project do
    [
      app: :yubikey_otp,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3.0"},
      {:hackney, "~> 1.15.2"},
      {:certifi, "~> 2.5"},
      {:puid, "~> 1.1"},
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10.3", only: :test},
      {:benchee, "~> 0.14.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.19.2", only: :dev, runtime: false},
      {:earmark, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_unit_assert_match, "~> 0.3.0", only: :test},
      {:ex_matchers, "~> 0.1.3", only: :test}
    ]
  end
end
