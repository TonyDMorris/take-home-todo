defmodule Todos do
  use Agent
  import Helpers

  # returns the pid of the current todo_list
  @spec new_todo_list :: pid
  def new_todo_list() do
    {_, pid} = Agent.start_link(fn -> %{} end)
    pid
  end

  # adds a todo and converts the date to a date struct for later use
  @spec add_todo(atom | pid | {atom, any} | {:via, atom, any}, any, any, binary) ::
          atom | pid | {atom, any} | {:via, atom, any}
  def add_todo(todo_list, todo_number, todo_item, date_string) do
    date = normalize_date(date_string)
    todo = %{"name" => todo_item, "complete_by" => date}

    Agent.update(todo_list, fn list ->
      Map.put(list, todo_number, todo)
    end)

    todo_list
  end

  # uses IO to print the list items or a msg
  @spec print_todos(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def print_todos(todo_list) do
    list = Agent.get(todo_list, fn state -> state end)

    if Map.size(list) == 0 do
      IO.puts("the list is empty")
    end

    keys =
      Enum.sort(
        Map.keys(list),
        fn a, b ->
          Date.compare(list[a]["complete_by"], list[b]["complete_by"]) == :lt
        end
      )

    Enum.each(keys, fn key ->
      IO.puts("#{list[key]["complete_by"]}\n#{key}. #{list[key]["name"]}")
    end)
  end

  # deletes a todo and rearanges the keys to replace the missing value
  @spec delete_todo(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def delete_todo(todo_list, key) do
    Agent.cast(todo_list, fn state ->
      has_key = check_key_exists(state, key)

      if has_key == false do
        IO.puts("key '#{key}' does not exist")
        state
      else
        new_todo_map = Map.delete(state, key)
        re_order_map(new_todo_map)
      end
    end)
  end

  # saves the given todo list to a named file
  @spec save_todos(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def save_todos(todo_list, file_name) do
    list = Agent.get(todo_list, fn state -> state end)

    keys =
      Enum.sort(
        Map.keys(list),
        fn a, b ->
          Date.compare(list[a]["complete_by"], list[b]["complete_by"]) == :lt
        end
      )

    file =
      Enum.reduce(keys, "", fn key, acc ->
        acc <> "#{list[key]["complete_by"]}\n#{key} #{list[key]["name"]}\n"
      end)

    File.write(file_name, file)
  end

  # loads todos from the specified file and converts the string keys to integers and the date lists back to date structs
  @spec load_todos(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | char,
              binary | []
            )
        ) :: pid
  def load_todos(file_name) do
    new_list = new_todo_list()
    {_, file} = File.read(file_name)

    [_ | split_string] = Enum.reverse(String.split(file, ~r/\s/))
    prepared_list = Enum.chunk_every(split_string, 3)

    new_state =
      Enum.reduce(prepared_list, %{}, fn chunk, acc ->
        [name | key_and_date] = chunk
        [key | date_string] = key_and_date
        date = normalize_date(un_normalize_date(date_string))

        todo = %{"name" => name, "complete_by" => date}

        Map.put(acc, String.to_integer(key), todo)
      end)

    Agent.cast(new_list, fn _ -> new_state end)
    new_list
  end

  # seed function that produces a list and adds 4 items
  @spec seed :: pid
  def seed do
    todo_list = new_todo_list()
    add_todo(todo_list, 1, "beer", "01/01/2020")
    add_todo(todo_list, 2, "bread", "01/02/2020")
    add_todo(todo_list, 3, "cheese", "03/01/2021")
    add_todo(todo_list, 4, "doritos", "05/01/2021")
    save_todos(todo_list, "date.txt")
    delete_todo(todo_list, 3)
    new_todos = load_todos("date.txt")
    print_todos(new_todos)
    new_todos
  end
end
