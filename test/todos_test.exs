defmodule TODOSTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO
  doctest TODOS

  test "adds an item to a list" do
    shopping = TODOS.new_todo_list()
    assert is_pid(shopping) == true
    bread = TODOS.add_todo(shopping, 1, "bread")
    assert is_pid(bread) == true
    assert bread == shopping
  end

  test "prints a list of items" do
    shopping = TODOS.new_todo_list()
    TODOS.add_todo(shopping, 1, "bread")
    TODOS.add_todo(shopping, 2, "water")

    assert TODOS.print_todos(shopping) == :ok
  end

  test "deletes an item from the list by the key" do
    shopping = TODOS.new_todo_list()
    TODOS.add_todo(shopping, 1, "bread")

    empty_map = TODOS.delete_todo(shopping, 5)
    assert empty_map == %{}
  end
end
