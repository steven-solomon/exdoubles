defmodule ExDoubles.State do
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

  def increment(name, args) do
    GenServer.cast(__MODULE__, {:increment, name, args})
  end

  def add_mock(%{name: _, arity: _} = mock) do
    start_process()
    GenServer.cast(__MODULE__, {:add_mock, mock})
  end

  def get_mock(name) do
    GenServer.call(__MODULE__, {:get_mock, name})
  end

  def stop() do
    GenServer.stop(__MODULE__, :normal)
  end

  def handle_call({:call_count, name}, _from, state) do
    %{calls: calls} = Map.get(state, name)

    call_count =
      calls
      |> Enum.count()

    {:reply, call_count, state}
  end

  def handle_call({:get_mock, name}, _from, state) do
    mock = Map.get(state, name)
    {:reply, Map.put(mock, :name, name), state}
  end

  def handle_cast({:increment, name, args}, state) do
    new_state = Map.update!(state, name, fn %{calls: calls} = mock ->
      %{mock | calls: [args | calls]}
    end)
    {:noreply, new_state}
  end

  def handle_cast({:add_mock, %{name: name, arity: arity}}, state) do
    {:noreply, Map.put(state, name, %{arity: arity, calls: []})}
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
