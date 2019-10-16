defmodule ElephantTest do
  use ExUnit.Case

  test "raises error when zero arg function is NEVER called" do
    {:ok, _} = Elephant.mock(:zero_arg_name, 0)

    assert_raise RuntimeError, "expected 1 times but was 0", fn ->
      Elephant.verify(:zero_arg_name, Elephant.once())
    end

    assert_process_stopped()
  end

  describe "arity" do
    test "returns truthy when zero arg function is called" do
      {:ok, zero_arg_fn} = Elephant.mock(:zero_arg_name, 0)

      zero_arg_fn.()

      assert Elephant.verify(:zero_arg_name, Elephant.once())
    end

    test "returns truthy when one arg function is called" do
      {:ok, one_arg_fn} = Elephant.mock(:one_arg_name, 1)

      one_arg_fn.("hello")

      assert Elephant.verify(:one_arg_name, Elephant.once())
    end

    test "returns truthy when two arg function is called" do
      {:ok, two_arg_fn} = Elephant.mock(:two_arg_name, 2)

      two_arg_fn.("hello", "world")

      assert Elephant.verify(:two_arg_name, Elephant.once())
    end

    test "returns truthy when three arg function is called" do
      {:ok, three_arg_fn} = Elephant.mock(:three_arg_name, 3)

      three_arg_fn.("hello", "world", "people")

      assert Elephant.verify(:three_arg_name, Elephant.once())
    end

    test "returns truthy when four arg function is called" do
      {:ok, four_arg_fn} = Elephant.mock(:four_arg_name, 4)

      four_arg_fn.("hello", "world", "people", "hello")

      assert Elephant.verify(:four_arg_name, Elephant.once())
    end

    test "returns truthy when five arg function is called" do
      {:ok, five_arg_fn} = Elephant.mock(:five_arg_name, 5)

      five_arg_fn.("hello", "world", "people", "hello", "world")

      assert Elephant.verify(:five_arg_name, Elephant.once())
    end

    test "returns truthy when six arg function is called" do
      {:ok, five_arg_fn} = Elephant.mock(:six_arg_name, 6)

      five_arg_fn.("hello", "world", "people", "hello", "world", "people")

      assert Elephant.verify(:six_arg_name, Elephant.once())
    end

    test "raises error when > 6 arg function passed to mock" do
      assert_raise RuntimeError, "Arity greater than 6 is not supported.", fn ->
        Elephant.mock(:name, 7)
      end

      assert_process_stopped()
    end
  end

  test "tracks multiple mocks" do
    {:ok, one_fn} = Elephant.mock(:one, 0)
    {:ok, another_fn} = Elephant.mock(:another, 0)

    one_fn.()
    another_fn.()

    Elephant.verify(:one, Elephant.once())
    Elephant.verify(:another, Elephant.once())
  end

  describe "process book keeping" do
    test "there is a process registered " do
      _ = Elephant.mock(:name, 0)

      assert is_integer(Enum.find_index(Process.registered(), fn name -> name == Elephant.State end))
      assert_process_running()
    end
  end

  defp assert_process_stopped() do
    assert is_nil(Enum.find_index(Process.registered(), fn name -> name == Elephant.State end))
  end

  defp assert_process_running() do
    assert is_integer(Enum.find_index(Process.registered(), fn name -> name == Elephant.State end))
  end
end
