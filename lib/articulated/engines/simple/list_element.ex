defmodule Articulated.Engines.Simple.ListElement do
  @moduledoc false
  alias Articulated.ElementId

  @enforce_keys [:id]
  @derive {JSON.Encoder, only: [:id, :is_deleted]}
  defstruct [:id, is_deleted: false]

  @type t :: %__MODULE__{
          id: ElementId.t(),
          is_deleted: boolean()
        }

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{id: id, is_deleted: deleted}, opts) do
      to_doc(%{bunch_id: id.bunch_id, counter: id.counter, is_deleted: deleted}, opts)
    end
  end
end
