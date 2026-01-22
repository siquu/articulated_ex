defmodule Articulated.IdListTest do
  use ExUnit.Case, async: true
  alias Articulated.{IdList, ElementId}

  defp equals_id?(%ElementId{bunch_id: b1, counter: c1}, %ElementId{bunch_id: b2, counter: c2}) do
    b1 == b2 and c1 == c2
  end

  describe "constructor and factory functions" do
    test "creates an empty list with new/0" do
      list = IdList.new()
      assert IdList.length(list) == 0
    end

    test "creates a list with present elements using from_ids/1" do
      ids = [
        %ElementId{bunch_id: "abc", counter: 1},
        %ElementId{bunch_id: "abc", counter: 2},
        %ElementId{bunch_id: "def", counter: 1}
      ]

      id_list = IdList.from_ids(ids)
      assert IdList.length(id_list) == 3
      counters = Enum.map(IdList.to_list(id_list), & &1.counter)
      assert counters == [1, 2, 1]

      bunch_ids = Enum.map(IdList.to_list(id_list), & &1.bunch_id)
      assert bunch_ids == ["abc", "abc", "def"]
    end
  end

  describe "insert operations" do
    test "inserts at the beginning with insert_after(nil)" do
      id_list = IdList.new()
      id = %ElementId{bunch_id: "abc", counter: 1}

      id_list = IdList.insert_after(id_list, nil, id)

      assert IdList.length(id_list) == 1
      assert equals_id?(IdList.at(id_list, 0), id)
    end

    test "inserts after a specific element" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      list = IdList.insert_after(list, nil, id1)
      list = IdList.insert_after(list, id1, id2)

      assert IdList.length(list) == 2
      assert equals_id?(IdList.at(list, 0), id1)
      assert equals_id?(IdList.at(list, 1), id2)
    end

    test "inserts at the end with insert_before(nil)" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      list = IdList.insert_after(list, nil, id1)
      list = IdList.insert_before(list, nil, id2)

      assert IdList.length(list) == 2
      assert equals_id?(IdList.at(list, 0), id1)
      assert equals_id?(IdList.at(list, 1), id2)
    end

    test "inserts before a specific element" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      list = IdList.insert_after(list, nil, id1)
      list = IdList.insert_before(list, id1, id2)

      assert IdList.length(list) == 2
      assert equals_id?(IdList.at(list, 0), id2)
      assert equals_id?(IdList.at(list, 1), id1)
    end

    test "inserts before the end" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      # Bulk insert before nil when list is empty
      list = IdList.insert_before(list, nil, id1, 3)
      assert IdList.length(list) == 3
      assert equals_id?(IdList.at(list, 0), id1)

      # Insert before nil when list has ids
      list = IdList.insert_before(list, nil, id2)
      assert IdList.length(list) == 4
      assert equals_id?(IdList.at(list, 3), id2)
      assert equals_id?(IdList.at(list, 0), id1)
    end

    test "bulk inserts multiple elements" do
      list = IdList.new()
      start_id = %ElementId{bunch_id: "abc", counter: 1}

      list = IdList.insert_after(list, nil, start_id, 3)

      assert IdList.length(list) == 3
      assert equals_id?(IdList.at(list, 0), %ElementId{bunch_id: "abc", counter: 1})
      assert equals_id?(IdList.at(list, 1), %ElementId{bunch_id: "abc", counter: 2})
      assert equals_id?(IdList.at(list, 2), %ElementId{bunch_id: "abc", counter: 3})
    end

    test "raises when inserting an ID that is already known" do
      list = IdList.new()
      id = %ElementId{bunch_id: "abc", counter: 1}

      list = IdList.insert_after(list, nil, id)

      assert_raise ArgumentError, fn ->
        IdList.insert_after(list, nil, id)
      end

      assert_raise ArgumentError, fn ->
        IdList.insert_before(list, nil, id)
      end
    end

    test "raises when inserting after an unknown ID" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      assert_raise ArgumentError, fn ->
        IdList.insert_after(list, id1, id2)
      end
    end

    test "raises when inserting before an unknown ID" do
      list = IdList.new()
      id1 = %ElementId{bunch_id: "abc", counter: 1}
      id2 = %ElementId{bunch_id: "def", counter: 1}

      assert_raise ArgumentError, fn ->
        IdList.insert_before(list, id1, id2)
      end
    end

    test "raises on bulk insert_after with invalid count" do
      list = IdList.new()
      id = %ElementId{bunch_id: "abc", counter: 1}

      for invalid_count <- [-7, 3.5, :nan] do
        assert_raise ArgumentError, fn ->
          IdList.insert_after(list, nil, id, invalid_count)
        end
      end

      # bulk insert 0 is okay (no-op)
      new_list = IdList.insert_after(list, nil, id, 0)
      assert new_list == list
    end

    test "raises on bulk insert_before with invalid count" do
      list = IdList.new()
      id = %ElementId{bunch_id: "abc", counter: 1}

      for invalid_count <- [-7, 3.5, :nan] do
        assert_raise ArgumentError, fn ->
          IdList.insert_before(list, nil, id, invalid_count)
        end
      end

      # bulk insert 0 is okay (no-op)
      new_list = IdList.insert_before(list, nil, id, 0)
      assert new_list == list
    end
  end
end
