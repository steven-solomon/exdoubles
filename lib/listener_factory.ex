defmodule ListenerFactory do
  def make_listener(pid, 0) do
    fn -> listen(pid) end
  end

  def make_listener(pid, 1) do
    fn _ -> listen(pid) end
  end

  def make_listener(pid, 2) do
    fn _, _ -> listen(pid) end
  end

  def make_listener(pid, 3) do
    fn _, _, _ -> listen(pid) end
  end

  def make_listener(pid, 4) do
    fn _, _, _, _ -> listen(pid) end
  end

  def make_listener(pid, 5) do
    fn _, _, _, _, _ -> listen(pid) end
  end

  def listen(pid) do
    send(pid, :call)
  end
end
