defmodule KherpiTesting do
  @moduledoc """
  Documentation for `KherpiTesting`.
  """

  defdelegate get(x), to: :khepri
  defdelegate put(x, y), to: :khepri
  defdelegate delete(x), to: :khepri
end
