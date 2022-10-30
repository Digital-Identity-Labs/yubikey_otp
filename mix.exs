defmodule YubikeyOTP.MixProject do
  use Mix.Project

  def project do
    [
      app: :yubikey_otp,
      version: "0.2.4",
      elixir: "~> 1.7",
      description: "Elixir client library for validating Yubikey one-time-passwords (OTPs)",
      package: package(),
      name: "YubikeyOTP",
      source_url: "https://github.com/Digital-Identity-Labs/yubikey_otp",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [
        tool: ExCoveralls
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:hackney]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, ">= 1.3.0"},
      {:hackney, ">= 1.15.2"},
      {:certifi, "~> 2.5.1"},
      {:puid, "~> 2.0"},
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test},
      {:benchee, "~> 1.0.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:earmark, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_unit_assert_match, "~> 0.3.0", only: :test},
      {:ex_matchers, "~> 0.1.3", only: :test},
      {:doctor, "~> 0.17.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Digital-Identity-Labs/yubikey_otp"
      }
    ]
  end
end
