# ShortDef

The library adds short syntax for maps as well as in-place guards definitions.

Basically, allows you to write `%{x}` instead of `%{x: x}` and `%MyStruct{x}` instead of
`%MyStruct{x: x}`.

```elixir
defmodule S do
  defstruct [:x, :y]
  use ShortDef

  def f(%S{x, y: y}), do: {x, y}
end
```

Works **only** in global function definitions (def).

Also lets you define the guards inline:

```elixir
defmodule M do
  use ShortDef

  # Equivalent to
  # def is_bounded(list, len) when is_list(list) and is_integer(len)
  def is_bounded(is_list(list), is_integer(len)) do
    length(list) < len
  end
end
```

Works **only** for guards, the builtin ones or defined with `defguard`.

You can combine these features too:

```elixir
def f(%{is_integer(x)}) do
```

The library is 100% syntactic sugar with 0% semantics.

## Similar libs

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `shortdef` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shortdef, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/shortdef](https://hexdocs.pm/shortdef).

