defmodule TODOS do
  use Agent

  # returns the pid of the current todo_list
  def new_todo_list() do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    pid
  end

  @spec add_todo(atom | pid | {atom, any} | {:via, atom, any}, any, any) ::
          atom | pid | {atom, any} | {:via, atom, any}
  def add_todo(todo_list, todo_number, todo_item) do
    Agent.update(todo_list, fn list ->
      Map.put(list, todo_number, todo_item)
    end)

    todo_list
  end

  def print_todos(todo_list) do
    Agent.get(todo_list, fn list ->
      keys = Map.keys(list)
      Enum.each(keys, fn key -> IO.puts("#{key}. #{list[key]}") end)
    end)
  end

  def delete_todo(todo_list, key) do
    Agent.get_and_update(todo_list, fn map ->
      {:ok, value} = Map.fetch(map, key)

      val = Map.pop(map, key)

      if map_size(map) == 1 do
        IO.puts("the list is empty")
        val
      end

      val
    end)
  end
end
