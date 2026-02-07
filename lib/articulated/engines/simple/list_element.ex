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
end
