defmodule ShortDef do
  defmacro __using__(_) do
    quote do
      import Kernel, except: [def: 2]
      import ShortDef, only: [def: 2]
    end
  end

  defmacro def(head, body) do
    new_head = transform_head(head)
    # |> IO.inspect(label: :new_head)

    quote do
      Kernel.def(unquote(new_head), unquote(body))
    end
  end

  def transform_head({:when, [line: line], [head, condition]}) do
    new_head = transform_head(head)

    case new_head do
      {:when, [line: _], [h, c]} ->
        c = condition |> merge_condition(c)
        {:when, [line: line], [h, c]}

      _ ->
        {:when, [line: line], [new_head, condition]}
    end
  end

  def transform_head(head) do
    {fun_name, [line: line], args} = head
    # transforming a list of args = transforming a single arg that is a list
    {new_args, guards} = transform_arg(args, [])
    new_head = {fun_name, [line: line], new_args}


    case guards do
      [] ->
        new_head

      [c] ->
        {:when, [line: line], [new_head, c]}

      _ ->
        c = {:and, [line: line], guards}
        {:when, [line: line], [new_head, c]}
    end
  end

  defp merge_condition(c1, c2) do
    list1 =
      case c1 do
        {:and, [line: _], list} -> list
        _ -> [c1]
      end

    list2 =
      case c2 do
        {:and, [line: _], list} -> list
        _ -> [c2]
      end

    [line: line] = elem(c1, 1)
    {:and, [line: line], list1 ++ list2}
  end

  def transform_arg({:=, [line: line], [arg, var]}, guards) do
    {new_arg, guards} = transform_arg(arg, guards)

    {
      {:=, [line: line], [new_arg, var]},
      guards
    }
  end

  def transform_arg(args, guards) when is_list(args) do
    # Apply transform_arg for every arg

    {new_args, guards} =
      args
      |> Enum.reduce({[], guards}, fn arg, {new_args, new_guards} ->
        {new_arg, new_guards} = transform_arg(arg, new_guards)
        {[new_arg | new_args], new_guards}
      end)

    new_args = new_args |> Enum.reverse()

    {new_args, guards}
  end

  def transform_arg({:%, [line: line], [aliases, inner_map]}, guards) do
    {new_map, guards} = transform_arg(inner_map, guards)

    {
      {:%, [line: line], [aliases, new_map]},
      guards
    }
  end

  def transform_arg({:%{}, [line: line], items}, guards) when is_list(items) do
    # Apply transform_item for every item

    {new_items, guards} =
      items
      |> Enum.reduce({[], guards}, fn item, {new_items, new_guards} ->
        {new_item, new_guards} = transform_item(item, new_guards)
        {[new_item | new_items], new_guards}
      end)

    new_items = new_items |> Enum.reverse()

    {
      {:%{}, [line: line], new_items},
      guards
    }
  end

  def transform_arg({:{}, [line: line], args}, guards) when is_list(args) do
    {new_args, guards} = transform_arg(args, guards)

    {
      {:{}, [line: line], new_args},
      guards
    }
  end

  def transform_arg({first, second}, guards) do
    # 2-element tuple for some reason is a special case
    {new_first, guards} = transform_arg(first, guards)
    {new_second, guards} = transform_arg(second, guards)

    {
      {new_first, new_second},
      guards
    }
  end

  def transform_arg({name, [line: _], [x]} = g, guards) when is_atom(name) do
    # Responsible for the guard short form:
    # def f(is_integer(x)) do end -> def f(x) when is_integer(x) do end

    guards = [g | guards]
    transform_arg(x, guards)
  end

  def transform_arg(arg, guards) do
    {arg, guards}
  end

  def transform_item({name, [line: line], nil}, guards) when is_atom(name) do
    # Responsible for the short form of maps:
    # %{x} -> %{x: x}

    {
      {name, {name, [line: line], nil}},
      guards
    }
  end

  def transform_item({name, value}, guards) when is_atom(name) do
    {value, guards} = transform_arg(value, guards)

    {
      {name, value},
      guards
    }
  end

  def transform_item(
    {
      guard_name, [line: _l1],
      [{item_name, [line: _l2], nil} = item]
    } = g,
    guards)
  when is_atom(guard_name) and is_atom(item_name) do
    # Responsible for the guard short form when it's a map item:
    # def f(%{is_integer(x)}) do end
    # -> def f(%{x: x}) when is_integer(x) do end

    guards = [g | guards]
    transform_item(item, guards)
  end
end
