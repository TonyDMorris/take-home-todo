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

  # uses IO to print the list items or a msg
  def print_todos(todo_list) do
    Agent.get(todo_list, fn list ->
      if Map.size(list) == 0 do
        IO.puts("the list is empty")
      end

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

  # helper function to check if a key exists within a map
  def check_key_exists(shopping_list, key) do
    keys = Map.keys(shopping_list)

    has_key =
      Enum.any?(keys, fn item ->
        item == key
      end)

    has_key
  end

  # saves the given todo list to a named file
  def save_todo_list(todo_list, file_name) do
    Agent.get(todo_list, fn state ->
      keys = Map.keys(state)

      file =
        Enum.reduce(keys, "", fn key, acc ->
          acc <> "#{key} #{state[key]}\n"
        end)

      File.write(file_name, file)
    end)
  end

  def load_todos(file_name) do
    {_, file} = File.read(file_name)
    split_string = String.split(file, ~r/\n/)
    new_list = new_todo_list()

    new_state =
      Enum.reduce(split_string, %{}, fn item, acc ->
        [key | value] = String.split(item, ~r/\s/)

        if key == "" do
          acc
        else
          IO.puts("#{key} #{value}")
          Map.put(acc, key, value)
        end
      end)

    Agent.cast(new_list, fn _ -> new_state end)
    new_list
  end

  # seed function that produces a list and adds 2 items
  def seed do
    todo_list = new_todo_list()
    add_todo(todo_list, 1, "bread")
    add_todo(todo_list, 2, "cheese")
    todo_list
  end
end
