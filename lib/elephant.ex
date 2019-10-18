defmodule Elephant do
  alias Elephant.State

  @spec mock(atom, integer) :: {:ok, function}
  def mock(name, arity, stub_value \\ nil)

  @spec mock(atom, integer, any) :: {:ok, function}
  def mock(name, arity, stub_value) do
    listener_fn = ListenerFactory.make_listener(arity, fn args ->
      State.increment(name, args)
      stub_value
    end)

    :ok = State.add_mock(%{name: name, arity: arity})

    {:ok, listener_fn}
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
