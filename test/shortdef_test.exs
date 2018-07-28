defmodule M do
  defstruct [x: 0, y: 1]
end

defmodule N do
  defstruct [a: :a, b: 0]
end

defmodule DefTest do

  use ShortDef

  # smoke tests

  def s1(%M{}) do end
  def s2(%M{x: x} = m) do end
  def s3(%M{} = m) do end
  def s4(1, %M{} = m, y, %N{}) do end
  def s5(x, [y], 0) do end
  def t1(x, y \\ 0) when x < 1000 and y < 100 do end
  def t2(%M{x: x} = m) when map_size(m) != 0 and x < 10 do end

  # tests

  def u1(%M{}) do end
  def u2(%M{x} = m) do end
  def u3(%M{x, y: y} = m) do end
  def u4(1, %M{x} = m, y, %N{}) do end
  def u5(x, [%{y}, z, 1, 2, 3]) do end
  def u6(x, {%{y}, 0, z}) do end
  def u7(x, %{xx, x: %{y}, z: 0}) do end
  def v1(x, y \\ 0) when x < 1000 and y < 100 do end
  def v2(%M{x} = m) when map_size(m) != 0 and x < 10 do end
  def v3({x, %{y: [%{z}]}}) do
    x + z
  end

  def v4({%{y: [%{z}]}}) do end


  use ExUnit.Case

  test "1" do
    m = %M{x: 1, y: 2}

    s1(m)
    s2(m)
    s3(m)
    s4(1, m, 5, %N{})
    s5(0, [0], 0)
    t1(0, 9)
    t2(m)

    u1(m)
    u2(m)
    u3(m)
    u4(1, m, 5, %N{})
    u5(0, [%{y: 0}, 0, 1, 2, 3])
    u6(0, {%{y: 0}, 0, 0})
    u7(0, %{xx: 0, x: %{y: 0}, z: 0})
    v1(0, 9)
    v2(m)
    1 = v3({0, %{y: [%{z: 1}]}})
    v4({%{y: [%{z: 1}]}})
  end

end


defmodule Test4 do
  use ExUnit.Case
  use ShortDef

  def s4(1, y) do end

  test "" do
    s4(1, 5)
  end
end
