defmodule KherpiTestingTest do
  use ExUnit.Case
  doctest KherpiTesting

  test "greets the world" do
    assert KherpiTesting.hello() == :world
  end
end
