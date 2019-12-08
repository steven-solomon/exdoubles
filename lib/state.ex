defmodule ExDoubles.State do
  use GenServer

  @default_stub_value []

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{}}
  end

  def call_count(name) do
    GenServer.call(__MODULE__, {:call_count, name})
  end

  def invoke_function(name, args) do
    GenServer.call(__MODULE__, {:invoke_function, name, args})
  end

  def add_stub(name, stub) do
    GenServer.cast(__MODULE__, {:add_stub, name, stub})
  end

  def add_mock(%{name: _, arity: _} = mock) do
    start_process()
    mock_with_default_stub = Map.put(mock, :stubs, @default_stub_value)
    GenServer.cast(__MODULE__, {:add_mock, mock_with_default_stub})
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

  def handle_call({:invoke_function, name, args}, _from, state) do
    stubs = Map.get(state, name) |> Map.get(:stubs)

    {return_value, rest} = List.pop_at(stubs, 0)

    new_state = Map.update!(
      state,
      name,
      fn %{calls: calls} = mock ->
        %{mock | calls: [args | calls], stubs: rest}
      end
    )
    {
      :reply,
      return_value,
      new_state
    }
  end

  def handle_cast({:add_mock, %{name: name, arity: arity, stubs: stubs}}, state) do
    {:noreply, Map.put(state, name, %{arity: arity, calls: [], stubs: stubs})}
  end

  def handle_cast({:add_stub, name, stub_value}, state) do
    mock = Map.get(state, name)

    updated_mock =
      Map.update!(
        mock,
        :stubs,
        fn stubs ->
          stubs ++ [stub_value]
        end
      )
    updated_state = Map.put(state, name, updated_mock)

    {:noreply, updated_state}
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
