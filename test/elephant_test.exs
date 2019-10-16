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

  test "returns truthy when one arg function is called" do
    {:ok, {pid, one_arg_fn}} = Elephant.mock(1)

    one_arg_fn.("hello")

    assert Elephant.verify(pid, Elephant.once())
  end

  test "returns truthy when two arg function is called" do
    {:ok, {pid, two_arg_fn}} = Elephant.mock(2)

    two_arg_fn.("hello", "world")

    assert Elephant.verify(pid, Elephant.once())
  end

  test "returns truthy when three arg function is called" do
    {:ok, {pid, three_arg_fn}} = Elephant.mock(3)

    three_arg_fn.("hello", "world", "people")

    assert Elephant.verify(pid, Elephant.once())
  end

  test "returns truthy when four arg function is called" do
    {:ok, {pid, four_arg_fn}} = Elephant.mock(4)

    four_arg_fn.("hello", "world", "people", "hello")

    assert Elephant.verify(pid, Elephant.once())
  end

  test "returns truthy when five arg function is called" do
    {:ok, {pid, five_arg_fn}} = Elephant.mock(5)

    five_arg_fn.("hello", "world", "people", "hello", "world")

    assert Elephant.verify(pid, Elephant.once())
  end
end
