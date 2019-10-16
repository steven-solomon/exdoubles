defmodule Elephant.State do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{}}
  end

  def call_count(name) do
    GenServer.call(__MODULE__, {:call_count, name})
  end

  def increment(name) do
    GenServer.cast(__MODULE__, {:increment, name})
  end

  def add_mock(name) do
    start_process()
    GenServer.cast(__MODULE__, {:add_mock, name})
  end

  def stop() do
    GenServer.stop(__MODULE__, :normal)
  end

  def handle_call({:call_count, name}, _from, state) do
    call_count = Map.get(state, name)
    {:reply, call_count, state}
  end

  def handle_cast({:increment, name}, state) do
    new_state = Map.update!(state, name, fn value -> value + 1 end)
    {:noreply, new_state}
  end

  def handle_cast({:add_mock, name}, state) do
    {:noreply, Map.put(state, name, 0)}
  end

  defp start_process() do
    case started?() do
      true -> :ok
      false ->
        {:ok, _pid} = start_link()
    end
  end

  defp started?() do
    Process.registered()
    |> Enum.find_index(fn name -> name == __MODULE__ end)
    |> is_integer()
  end
end
