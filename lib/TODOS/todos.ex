defmodule TODOS do
  use Agent

  # returns the pid of the current todo_list
  def new_todo_list() do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    pid
  end

  def add_todo(todo_list, todo_number, todo_item, date_string) do
    day_month_year = String.split(date_string, ~r/\//)
    {day, _} = List.pop_at(day_month_year, 0)
    {month, _} = List.pop_at(day_month_year, 1)
    {year, _} = List.pop_at(day_month_year, 2)

    {_, date} =
      Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

    Agent.update(todo_list, fn list ->
      todo = %{"name" => todo_item, "complete_by" => date}
      Map.put(list, todo_number, todo)
    end)

    todo_list
  end

  # uses IO to print the list items or a msg
  @spec print_todos(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def print_todos(todo_list) do
    Agent.get(todo_list, fn state ->
      if Map.size(state) == 0 do
        IO.puts("the list is empty")
      end

      keys =
        Enum.sort(
          Map.keys(state),
          fn a, b ->
            Date.compare(state[a]["complete_by"], state[b]["complete_by"]) == :lt
          end
        )

      Enum.each(keys, fn key ->
        IO.puts("#{state[key]["complete_by"]}\n#{key}. #{state[key]["name"]}")
      end)
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
      keys =
        Enum.sort(
          Map.keys(state),
          fn a, b ->
            Date.compare(state[a]["complete_by"], state[b]["complete_by"]) == :lt
          end
        )

      IO.puts("#{keys}")

      file =
        Enum.reduce(keys, "", fn key, acc ->
          acc <> "#{state[key]["complete_by"]}\n#{key}. #{state[key]["name"]}\n"
        end)

      File.write(file_name, file)
    end)
  end

  def load_todos(file_name) do
    new_list = new_todo_list()
    {_, file} = File.read(file_name)
    split_string = String.split(file, ~r/\n/)

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

  # seed function that produces a list and adds 4 items
  @spec seed :: pid
  def seed do
    todo_list = new_todo_list()
    add_todo(todo_list, 1, "beer", "01/02/2020")
    add_todo(todo_list, 2, "bread", "01/01/2020")
    add_todo(todo_list, 3, "cheese", "03/01/2021")
    add_todo(todo_list, 4, "doritos", "05/01/2021")
    save_todo_list(todo_list, "date.txt")
    todo_list
  end
end
