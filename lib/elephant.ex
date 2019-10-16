defmodule Elephant do
  alias Elephant.State

  def mock(_name, arg_count) do
    listener_fn = ListenerFactory.make_listener(arg_count, fn ->
      State.increment()
    end)

    {:ok, _pid} = State.start_link()

    {:ok, listener_fn}
  end

  def once() do
    %{times: 1}
  end

  def verify(_name, %{times: n}) do
    count = call_count()

    case call_count() == n do
      true ->
        true

      false ->
        State.stop()
        raise "expected #{n} times but was #{count}"
    end
  end

  defp call_count() do
    State.call_count()
  end
end
