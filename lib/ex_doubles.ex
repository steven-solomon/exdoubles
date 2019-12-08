defmodule ExDoubles do
  alias ExDoubles.{ErrorMessages, State, ListenerFactory}

  @spec mock(atom, integer) :: {:ok, function}
  def mock(name, arity) do
    listener_fn = ListenerFactory.make_listener(arity, fn args ->
      State.invoke_function(name, args)
    end)

    :ok = State.add_mock(%{name: name, arity: arity})

    {:ok, listener_fn}
  end

  @doc """
    Allows the definition of stubbed values for a mocked function.

    ## Example
    test "returns stubbed value from a mock" do
      {:ok, mock_fn} = mock(:mock_label, 0)

      when_called(:mock_label, :stub_value)

      assert :stub_value == mock_fn.()
    end

    It is possible to defined multiple stub values. These are values are returned by the function in the order defined in the test.

    ## Example
    test "returns stubbed values in the order they were passed to `when_called`" do
      {:ok, mock_fn} = mock(:mock_label, 0)

      when_called(:mock_label, :stub_value_1)
      when_called(:mock_label, :stub_value_2)
      when_called(:mock_label, :stub_value_3)

      assert :stub_value_1 == mock_fn.()
      assert :stub_value_2 == mock_fn.()
      assert :stub_value_3 == mock_fn.()
    end
  """
  @spec mock(atom, any) :: :ok
  def when_called(name, stub_value) do
    :ok = State.add_stub(name, stub_value)
  end

  @type call_count_matcher :: %{times: integer}
  @type argument_matcher :: %{called_with: list(any())}

  @spec verify(atom(), call_count_matcher) :: bool
  def verify(name, %{called_with: args}) do
    %{arity: arity, calls: calls} = State.get_mock(name)
    case arity do
      0 -> raise ErrorMessages.unsupported_call()
      _ ->
        case matches?(calls, args) do
          true ->
            true
          false ->
            raise ErrorMessages.not_called_error(name, args, calls)
        end
    end
  end

  @spec verify(atom(), argument_matcher) :: bool
  def verify(name, %{times: n}) do
    call_count = State.call_count(name)

    case call_count == n do
      true ->
        true

      false ->
        State.stop()
        raise ErrorMessages.call_count_incorrect(n, call_count)
    end
  end

  defp matches?(calls, args) do
    calls
    |> Enum.find_index(fn c -> c == args end)
    |> is_integer()
  end

  @spec once :: call_count_matcher
  def once() do
    %{times: 1}
  end

  @spec twice :: call_count_matcher
  def twice() do
    %{times: 2}
  end

  @spec thrice :: call_count_matcher
  def thrice() do
    %{times: 3}
  end

  @spec times(integer) :: call_count_matcher
  def times(n) do
    %{times: n}
  end

  @spec called_with(list(any)) :: argument_matcher
  def called_with(args) do
    %{called_with: args}
  end
end
