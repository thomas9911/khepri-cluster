defmodule KherpiLibcluster do
  @moduledoc """
  Documentation for `KherpiLibcluster`.
  """

  defdelegate get(x), to: :khepri
  defdelegate put(x, y), to: :khepri
  defdelegate delete(x), to: :khepri
end
