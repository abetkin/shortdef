ExUnit.start

defmodule GuardsTest do
  use ShortDef
  use ExUnit.Case

  def f1(is_integer(x), y, is_binary(z)), do: 0
  def f1(is_binary(x), y, is_integer(z)), do: 1
  def f1(x, y, z), do: 2

  defguard is_char(x) when is_binary(x) and byte_size(x) == 1

  def f2([%{is_char(x)}], {%{y}}) do
    x <> y
  end

  test "" do
    0 = f1(3, 5, "g")
    1 = f1("", 5, 9)
    2 = f1(0, 0, 0)
  end

  test "2" do
    "fg" = f2([%{x: "f"}], {%{y: "g"}})
  end
end
