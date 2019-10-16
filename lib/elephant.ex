defmodule Elephant do
  def mock(_arg_count) do
    pid = spawn_link(&wait/0)

    {:ok, {pid, fn -> listen(pid) end}}
  end

  defp listen(pid) do
    send(pid, :call)
  end

  defp wait(count \\ 0)
  defp wait(count) do
    receive do
      :call ->
        wait(count + 1)
      {:count, pid} ->
        send(pid, {:count, count})
        wait(count)
    end
  end

  def once() do
    %{times: 1}
  end

  def verify(pid, %{times: n}) do
    count = call_count(pid)
    case call_count(pid) == n do
      true ->
        true
      false ->
        raise "expected #{n} times but was #{count}"
    end
  end

  defp call_count(pid) do
    send(pid, {:count, self()})
    receive do
      {:count, count} -> count
    end
  end
end
