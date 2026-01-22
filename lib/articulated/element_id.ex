defmodule Articulated.ElementId do
  @moduledoc """
  Represents a unique ElementId, analogous to `ElementId` in articulated JS.
  """

  @enforce_keys [:bunch_id, :counter]
  defstruct [:bunch_id, :counter]

  @type t :: %__MODULE__{
          bunch_id: String.t(),
          counter: non_neg_integer()
        }
end
