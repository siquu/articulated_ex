defmodule Articulated.Engine do
  @moduledoc ~S"""
  Specification to manage & manipulate IdLists
  """

  alias Articulated.ElementId

  @typedoc "Bias for indexing deleted-but-known elements"
  @type bias :: :none | :left | :right

  @opaque id_list :: Articulated.IdList.t()

  @callback new() :: id_list()

  @callback from_ids(list :: list(ElementId.t())) :: id_list()

  @callback insert_after(
              list :: id_list(),
              anchor_id :: ElementId.t() | nil,
              new_id :: ElementId.t(),
              count :: non_neg_integer()
            ) :: {:ok, id_list()} | {:error, any()}

  @callback insert_before(
              list :: id_list(),
              anchor_id :: ElementId.t() | nil,
              new_id :: ElementId.t(),
              count :: non_neg_integer()
            ) :: {:ok, id_list()} | {:error, any()}

  @callback delete(list :: id_list(), id :: ElementId.t(), count :: non_neg_integer()) ::
              {:ok, id_list()} | {:error, any()}

  @callback undelete(list :: id_list(), id :: ElementId.t(), count :: non_neg_integer()) ::
              {:ok, id_list()} | {:error, any()}

  @callback delete_range(list :: id_list(), from :: non_neg_integer(), to :: non_neg_integer()) ::
              {:ok, id_list()} | {:error, any()}

  @callback uninsert(list :: id_list(), id :: ElementId.t(), count :: non_neg_integer()) ::
              {:ok, id_list()} | {:error, any()}

  @callback at(list :: id_list(), index :: non_neg_integer()) ::
              {:ok, ElementId.t()} | {:error, any()}

  @callback index_of(list :: id_list(), id :: ElementId.t(), bias :: bias()) ::
              {:ok, integer()} | {:error, any()}

  @callback length(list :: id_list()) :: non_neg_integer()

  @callback has?(list :: id_list(), ElementId.t()) :: boolean()

  @callback known?(list :: id_list(), id :: ElementId.t()) :: boolean()

  @callback to_list(list :: id_list()) :: list(ElementId.t())
end
