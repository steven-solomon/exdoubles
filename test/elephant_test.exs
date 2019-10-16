defmodule ElephantTest do
  use ExUnit.Case

  test "raises error when zero arg function is NEVER called" do
    {:ok, {pid, _}} = Elephant.mock(0)

    assert_raise RuntimeError, "expected 1 times but was 0", fn ->
      Elephant.verify(pid, Elephant.once())
    end
  end

  test "returns truthy when zero arg function is called" do
    {:ok, {pid, zero_arg_fn}} = Elephant.mock(0)

    zero_arg_fn.()

    assert Elephant.verify(pid, Elephant.once())
  end
end
