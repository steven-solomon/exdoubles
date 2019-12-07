defmodule ExDoubles.ErrorMessages do
  def not_called_error(name, args, []) do
    "#{inspect name} was never called with #{inspect args}"
  end
  def not_called_error(name, args, calls) do
    """
    #{inspect name} was never called with #{inspect args}
    but was called with:
    #{format_calls(calls)}
    """
  end

  def arity_not_supported do
    "Arity greater than 6 is not supported."
  end

  def unsupported_call() do
    "called_with cannot have more arguments than the mocked function."
  end

  def call_count_incorrect(expected, actual) do
    "expected #{expected} times but was #{actual}"
  end

  defp format_calls(calls) do
    calls
    |> Enum.map(fn call -> "#{inspect call}" end)
    |> Enum.join("\n")
  end
end
