defmodule Elephant do
  alias Elephant.State

  def mock(name, arg_count) do
    listener_fn = ListenerFactory.make_listener(arg_count, fn ->
      State.increment(name)
    end)

    :ok = State.add_mock(name)

    {:ok, listener_fn}
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

  def verify(name, %{times: n}) do
    count = State.call_count(name)

    case count == n do
      true ->
        true

      false ->
        State.stop()
        raise "expected #{n} times but was #{count}"
    end
  end
end
