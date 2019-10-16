defmodule ListenerFactory do
  def make_listener(0, listener_fn) do
    fn -> listener_fn.([]) end
  end

  def make_listener(1, listener_fn) do
    fn arg ->
      listener_fn.([arg])
    end
  end

  def make_listener(2, listener_fn) do
    fn a, b -> listener_fn.([a, b]) end
  end

  def make_listener(3, listener_fn) do
    fn a, b, c -> listener_fn.([a, b, c]) end
  end

  def make_listener(4, listener_fn) do
    fn _, _, _, _ -> listener_fn.([]) end
  end

  def make_listener(5, listener_fn) do
    fn _, _, _, _, _ -> listener_fn.([]) end
  end

  def make_listener(6, listener_fn) do
    fn _, _, _, _, _, _ -> listener_fn.([]) end
  end

  def make_listener(_, _) do
    raise "Arity greater than 6 is not supported."
  end
end
