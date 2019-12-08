defmodule LongRunningTest do
  use ExUnit.Case
  import ExDoubles

  test "that this slow test doesn't affect other instances of ExDoubles" do
    {:ok, zero_arg_fn} = mock(:zero_arg, 0)

    1..4
    |> Enum.each(fn _ ->
      :timer.sleep(200)
      zero_arg_fn.()
    end)

    verify(:zero_arg, times(4))
  end
end
