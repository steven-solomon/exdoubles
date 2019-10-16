defmodule Elephant do
  alias Elephant.State

  def mock(name, arity) do
    listener_fn = ListenerFactory.make_listener(arity, fn args ->
      State.increment(name, args)
    end)

    :ok = State.add_mock(%{name: name, arity: arity})

    {:ok, listener_fn}
  end

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

  defmacro __using__(_options) do
    quote do
      def mock(name, arity) do
        Elephant.mock(name, arity)
      end

      def verify(name, matcher) do
        Elephant.verify(name, matcher)
      end

      def once() do
        %{times: 1}
      end

      def twice() do
        %{times: 2}
      end

      def thrice() do
        %{times: 3}
      end

      def times(n) do
        %{times: n}
      end

      def called_with(args) do
        %{called_with: args}
      end
    end
  end
end
