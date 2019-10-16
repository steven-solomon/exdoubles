defmodule Elephant.State do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{call_count: 0}}
  end

  def call_count() do
    GenServer.call(__MODULE__, :call_count)
  end

  def increment() do
    GenServer.cast(__MODULE__, :increment)
  end

  def stop() do
    GenServer.stop(__MODULE__, :normal)
  end

  def handle_call(:call_count, _from, %{call_count: call_count} = state) do
    {:reply, call_count, state}
  end

  def handle_cast(:increment, %{call_count: call_count}) do
    {:noreply, %{call_count: call_count + 1}}
  end
end
