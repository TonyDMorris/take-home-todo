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
end
