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
    Agent.cast(todo_list, fn state ->
      has_key = check_key_exists(state, key)

      if has_key == false do
        IO.puts("key '#{key}' does not exist")
        state
      else
        Map.delete(state, key)
      end
    end)
  end

  def check_key_exists(shopping_list, key) do
    keys = Map.keys(shopping_list)

    has_key =
      Enum.any?(keys, fn item ->
        item == key
      end)

    has_key
  end

  def seed do
    todo_list = new_todo_list()
    add_todo(todo_list, 1, "bread")
    add_todo(todo_list, 2, "cheese")
    todo_list
  end
end
