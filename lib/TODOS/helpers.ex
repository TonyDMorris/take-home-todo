defmodule HELPERS do
  # helper function to check if a key exists within a map
  def check_key_exists(shopping_list, key) do
    keys = Map.keys(shopping_list)

    has_key =
      Enum.any?(keys, fn item ->
        item == key
      end)

    has_key
  end

  def normalize_date(date_string) do
    day_month_year = String.split(date_string, ~r/\//)
    {day, _} = List.pop_at(day_month_year, 0)
    {month, _} = List.pop_at(day_month_year, 1)
    {year, _} = List.pop_at(day_month_year, 2)

    {_, date} =
      Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

    date
  end

  def un_normalize_date(date_obj) do
    [date_string | _] = date_obj
    [year | month_and_day] = String.split(date_string, ~r/\-/)
    [month | day] = month_and_day
    non_standard_date = "#{day}/#{month}/#{year}"
    non_standard_date
  end

  def is_date?(date) do
    case Date.from_iso8601(date) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def re_order_map(todo_map) do
    length = Map.size(todo_map)
    keys = Enum.to_list(1..length)
    values = Map.values(todo_map)
    re_order_keys(%{}, keys, values)
  end

  def re_order_keys(map, keys, values) do
    if keys == [] do
      map
    else
      [val | left_overs] = values
      [key | other_keys] = keys
      list = Map.put(map, key, val)
      re_order_keys(list, other_keys, left_overs)
    end
  end
end
