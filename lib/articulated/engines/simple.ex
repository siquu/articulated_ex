defmodule Articulated.Engines.Simple do
  @behaviour Articulated.Engine

  alias Articulated.Engines.Simple.ListElement
  alias Articulated.Engines.Simple
  alias Articulated.ElementId

  @type t :: [ListElement.t()]

  @spec new() :: t()
  @impl true
  def new(), do: []

  @spec from_ids([ElementId.t()]) :: t()
  @impl true
  def from_ids(element_ids), do: Enum.map(element_ids, &%ListElement{id: &1})

  @spec to_list(t()) :: [ElementId.t()]
  @impl true
  def to_list(list_els) do
    Enum.flat_map(list_els, &if(&1.is_deleted, do: [], else: [&1.id]))
  end

  @impl true
  def insert_after(_list_els, _anchor_id, _new_id, count)
      when not (is_integer(count) and count >= 0) do
    raise ArgumentError, "count must be a non-negative integer, got: #{inspect(count)}"
  end

  def insert_after(list_els, _anchor_id, _new_id, 0), do: list_els

  def insert_after(list_els, anchor_id, new_id, count) do
    validate_insert!(list_els, anchor_id, new_id)

    new_elements =
      for i <- 0..(count - 1), do: %ListElement{id: %{new_id | counter: new_id.counter + i}}

    if anchor_id do
      Enum.flat_map(list_els, fn
        %ListElement{id: ^anchor_id} = el -> [el | new_elements]
        other -> [other]
      end)
    else
      new_elements ++ list_els
    end
  end

  @impl true
  def insert_before(_list_els, _anchor_id, _new_id, count)
      when not (is_integer(count) and count >= 0) do
    raise ArgumentError, "count must be a non-negative integer, got: #{inspect(count)}"
  end

  def insert_before(list_els, _anchor_id, _new_id, 0), do: list_els

  def insert_before(list_els, anchor_id, new_id, count) do
    validate_insert!(list_els, anchor_id, new_id)

    new_elements =
      for i <- 0..(count - 1), do: %ListElement{id: %{new_id | counter: new_id.counter + i}}

    if anchor_id do
      Enum.flat_map(list_els, fn
        %ListElement{id: ^anchor_id} = el -> new_elements ++ [el]
        other -> [other]
      end)
    else
      list_els ++ new_elements
    end
  end

  @impl true
  def delete(_list_els, _id, count)
      when not (is_integer(count) and count >= 0) do
    raise ArgumentError, "count must be a non-negative integer, got: #{inspect(count)}"
  end

  def delete(list_els, _id, 0), do: list_els

  def delete(list_els, id, count) do
    to_delete = for i <- 0..(count - 1), do: %{id | counter: id.counter + i}
    Enum.map(list_els, fn e -> if e.id in to_delete, do: %{e | is_deleted: true}, else: e end)
  end

  @impl true
  def undelete(_list_els, _id, count)
      when not (is_integer(count) and count >= 0) do
    raise ArgumentError, "count must be a non-negative integer, got: #{inspect(count)}"
  end

  def undelete(list_els, _id, 0), do: list_els

  def undelete(list_els, id, count) do
    to_undelete = for i <- 0..(count - 1), do: %{id | counter: id.counter + i}
    Enum.map(list_els, fn e -> if e.id in to_undelete, do: %{e | is_deleted: false}, else: e end)
  end

  @impl true
  def uninsert(_list_els, _id, count)
      when not (is_integer(count) and count >= 0) do
    raise ArgumentError, "count must be a non-negative integer, got: #{inspect(count)}"
  end

  def uninsert(list_els, _id, 0), do: list_els

  def uninsert(list_els, id, count) do
    to_uninsert = for i <- 0..(count - 1), do: %{id | counter: id.counter + i}
    Enum.reject(list_els, fn e -> e.id in to_uninsert end)
  end

  @impl true
  def at(list_els, index) when is_integer(index) and index >= 0 do
    list_els
    |> Enum.reduce_while(0, fn
      %{is_deleted: true}, visible_index ->
        {:cont, visible_index}

      %{id: id}, visible_index ->
        if visible_index == index do
          {:halt, id}
        else
          {:cont, visible_index + 1}
        end
    end)
  end

  @impl true
  def delete_range(list_els, from, to) do
    els = for i <- from..(to - 1), do: Simple.at(list_els, i)

    for el <- els, reduce: list_els do
      acc -> delete(acc, el, 1)
    end
  end

  @impl true
  def index_of(list_els, id, _bias), do: Enum.find_index(list_els, fn e -> e.id == id end)

  @impl true
  def length(list_els) do
    for %{is_deleted: false} <- list_els, reduce: 0 do
      acc -> acc + 1
    end
  end

  @impl true
  def has?(list, element_id) do
    Enum.any?(list, fn el ->
      el.id == element_id and not el.is_deleted
    end)
  end

  @impl true
  def known?(list_els, element_id) do
    Enum.any?(list_els, fn list_el ->
      list_el.id == element_id
    end)
  end

  defp validate_insert!(list_els, anchor_id, new_id) do
    {anchor_found, new_id_found} =
      Enum.reduce_while(list_els, {false, false}, fn
        %ListElement{id: ^anchor_id}, {_anchor_found, new_id_found} ->
          {:cont, {true, new_id_found}}

        %ListElement{id: ^new_id}, {anchor_found, _new_id_found} ->
          # stop early, we found the new_id already
          {:halt, {anchor_found, true}}

        _, acc ->
          {:cont, acc}
      end)

    if new_id_found do
      raise ArgumentError, "ElementId already exists in IdList"
    end

    if anchor_id && !anchor_found do
      raise ArgumentError, "Anchor #{inspect(anchor_id)} not found"
    end
  end
end
