defmodule ElephantTest do
  use ExUnit.Case
  use Elephant

  test "raises error when zero arg function is NEVER called" do
    {:ok, _} = mock(:zero_arg_name, 0)

    assert_raise RuntimeError, "expected 1 times but was 0", fn ->
      verify(:zero_arg_name, once())
    end

    assert_process_stopped()
  end

  describe "arity" do
    test "returns truthy when zero arg function is called" do
      {:ok, zero_arg_fn} = mock(:zero_arg_name, 0)

      zero_arg_fn.()

      assert verify(:zero_arg_name, once())
    end

    test "returns truthy when one arg function is called" do
      {:ok, one_arg_fn} = mock(:one_arg_name, 1)

      one_arg_fn.("hello")

      assert verify(:one_arg_name, once())
    end

    test "returns truthy when two arg function is called" do
      {:ok, two_arg_fn} = mock(:two_arg_name, 2)

      two_arg_fn.("hello", "world")

      assert verify(:two_arg_name, once())
    end

    test "returns truthy when three arg function is called" do
      {:ok, three_arg_fn} = mock(:three_arg_name, 3)

      three_arg_fn.("hello", "world", "people")

      assert verify(:three_arg_name, once())
    end

    test "returns truthy when four arg function is called" do
      {:ok, four_arg_fn} = mock(:four_arg_name, 4)

      four_arg_fn.("hello", "world", "people", "hello")

      assert verify(:four_arg_name, once())
    end

    test "returns truthy when five arg function is called" do
      {:ok, five_arg_fn} = mock(:five_arg_name, 5)

      five_arg_fn.("hello", "world", "people", "hello", "world")

      assert verify(:five_arg_name, once())
    end

    test "returns truthy when six arg function is called" do
      {:ok, five_arg_fn} = mock(:six_arg_name, 6)

      five_arg_fn.("hello", "world", "people", "hello", "world", "people")

      assert verify(:six_arg_name, once())
    end

    test "raises error when > 6 arg function passed to mock" do
      assert_raise RuntimeError, "Arity greater than 6 is not supported.", fn ->
        mock(:name, 7)
      end

      assert_process_stopped()
    end
  end

  test "tracks multiple mocks" do
    {:ok, one_fn} = mock(:one, 0)
    {:ok, another_fn} = mock(:another, 0)

    one_fn.()
    another_fn.()

    verify(:one, once())
    verify(:another, once())
  end

  describe "matchers" do
    test "call count matchers" do
      {:ok, zero_arg_fn} = mock(:zero_arg, 0)
      zero_arg_fn.()
      zero_arg_fn.()

      verify(:zero_arg, twice())

      zero_arg_fn.()
      verify(:zero_arg, thrice())

      zero_arg_fn.()
      verify(:zero_arg, times(4))
    end

    test "called_with matcher throws error when used with zero arg mock" do
      {:ok, _} = mock(:zero_arg, 0)

      assert_raise RuntimeError, "called_with cannot have more arguments than the mocked function.", fn ->
        verify(:zero_arg, called_with(:foo))
      end
    end

    test "called_with raises an error when function is never invoked" do
      {:ok, _} = mock(:one_arg, 1)

      assert_raise RuntimeError, ":one_arg was never called with [:foo]", fn ->
        verify(:one_arg, called_with([:foo]))
      end
    end

    test "called_with gives more detail when argument does not match" do
      {:ok, one_arg_fn} = mock(:one_arg, 1)

      one_arg_fn.(:bar)
      one_arg_fn.(:baz)

      message = """
      :one_arg was never called with [:foo]
      but was called with:
      [:baz]
      [:bar]
      """

      assert_raise RuntimeError, message, fn ->
        verify(:one_arg, called_with([:foo]))
      end
    end

    test "called_with matches one arg function" do
      {:ok, one_arg_fn} = mock(:one_arg, 1)

      one_arg_fn.(:foo)

      verify(:one_arg, called_with([:foo]))
    end

    test "called_with matches two arg function" do
      {:ok, two_arg_fn} = mock(:two_arg, 2)

      two_arg_fn.("hello", "world")

      verify(:two_arg, called_with(["hello", "world"]))
    end

    test "called_with matches three arg function" do
      {:ok, three_arg_fn} = mock(:three_arg, 3)

      three_arg_fn.("hello", "world", "people")

      verify(:three_arg, called_with(["hello", "world", "people"]))
    end

    test "called_with matches four arg function" do
      {:ok, four_arg_fn} = mock(:four_arg, 4)

      four_arg_fn.("hello", "world", "people", "hello")

      verify(:four_arg, called_with(["hello", "world", "people", "hello"]))
    end
  end

  describe "process book keeping" do
    test "there is a process registered " do
      _ = mock(:name, 0)

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
