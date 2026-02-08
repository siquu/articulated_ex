defmodule Articulated.IdList do
  @moduledoc """
  Functions to work on IdLists, which track ElementIds in order, supporting insertions,
  deletions, undos, and queries.
  """

  alias Articulated.{ElementId, IdList}

  @engine_module Application.compile_env(
                   :articulated,
                   :id_list_engine,
                   Articulated.Engines.Simple
                 )

  @type element_id :: ElementId.t()
  @type bias :: :none | :left | :right

  @opaque t :: %IdList{engine: module(), state: any()}
  defstruct engine: nil, state: nil

  defimpl JSON.Encoder do
    def encode(id_list, encoder) do
      encoder.(id_list.state, encoder)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Articulated.IdList{state: state}, opts) do
      {doc, %{limit: limit}} = to_doc_with_opts(state, %{opts | charlists: :as_lists})

      {concat(["IdList.new(", doc, ")"]), %{opts | limit: limit}}
    end
  end

  @doc """
  Create a new IdList.

  Optionally pass an engine module. Defaults to `Articulated.Engines.Simple`.
  """
  def new(engine_module \\ @engine_module) do
    %IdList{engine: engine_module, state: engine_module.new()}
  end

  @doc "Create an IdList from a list of ElementId structs."
  @spec from_ids([element_id()]) :: t()
  def from_ids(ids, engine_module \\ @engine_module) do
    %IdList{engine: engine_module, state: engine_module.from_ids(ids)}
  end

  def to_list(%IdList{engine: engine, state: state}) do
    engine.to_list(state)
  end

  @doc """
  Insert `new_id` after the given element `left_of`.

  Returns a new IdList.
  """
  def insert_after(%IdList{engine: engine, state: state} = list, anchor_id, new_id, count \\ 1) do
    new_state = engine.insert_after(state, anchor_id, new_id, count)
    %{list | state: new_state}
  end

  @doc """
  Insert `new_id` before the given element `right_of`.

  Returns a new IdList.
  """
  def insert_before(%IdList{engine: engine, state: state} = list, anchor_id, new_id, count \\ 1) do
    new_state = engine.insert_before(state, anchor_id, new_id, count)
    %{list | state: new_state}
  end

  @doc """
  Delete an element by its ElementId.
  """
  def delete(%IdList{engine: engine, state: state} = list, id, count \\ 1) do
    new_state = engine.delete(state, id, count)
    %{list | state: new_state}
  end

  @doc """
  Restore a deleted ElementId.
  """
  def undelete(%IdList{engine: engine, state: state} = list, id, count \\ 1) do
    new_state = engine.undelete(state, id, count)
    %{list | state: new_state}
  end

  @doc """
  Deletes all ids with indexes in the range [from, to).
  """
  def delete_range(%IdList{engine: engine, state: state} = list, to, from) do
    new_state = engine.delete_range(state, to, from)
    %{list | state: new_state}
  end

  @doc """
  Undo an insertion of an ElementId.
  """
  def uninsert(%IdList{engine: engine, state: state} = list, id, count \\ 1) do
    new_state = engine.uninsert(state, id, count)
    %{list | state: new_state}
  end

  @doc """
  Returns the ElementId at a specific index.
  """
  def at(%IdList{engine: engine, state: state}, index) do
    engine.at(state, index)
  end

  @doc """
  Returns the index of an ElementId, optionally biased for deleted-but-known elements.

  If `id` is known but deleted, the bias specifies what to return:
      * - "none": -1.
      * - "left": The index immediately to the left of `id`, possibly -1.
      * - "right": The index immediately to the right of `id`, possibly `this.length`.
      * Equivalently, the index where `id` would be if present.
  """
  def index_of(%IdList{engine: engine, state: state}, id, bias \\ :none) do
    engine.index_of(state, id, bias)
  end

  @doc """
  Returns the number of present (non-deleted) elements.
  """
  def length(%IdList{engine: engine, state: state}) do
    engine.length(state)
  end

  @doc """
  Checks whether an ElementId is present (known and not deleted).
  """
  def has?(%IdList{engine: engine, state: state}, id) do
    engine.has?(state, id)
  end

  @doc """
  Checks whether an ElementId is known (even if deleted).
  """
  def known?(%IdList{engine: engine, state: state}, id) do
    engine.known?(state, id)
  end

  @doc """
  Returns the maximum counter across all known ElementIds with the given bunch_id,
  or undefined if no such ElementIds are known.

  This method is useful when creating ElementIds.
  """
  def max_counter(%IdList{engine: engine, state: state}, bunch_id) do
    engine.max_counter(state, bunch_id)
  end
end
