defmodule ShortDef.MixProject do
  use Mix.Project

  def project() do
    [
      app: :shortdef,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ShortDef",
      source_url: "https://github.com/abetkin/shortdef",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
    ]
  end

  def application() do
    []
  end

  defp description() do
    "Lets you use short syntax for maps and define guards inline"
  end

  defp package() do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/abetkin/shortdef"}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end
end
