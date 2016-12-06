defmodule Eular12 do
  @doc """
  iex> Eular12.calTri 1
  1
  iex> Eular12.calTri 3
  2
  iex> Eular12.calTri 6
  4
  iex> Eular12.calTri 21
  4
  iex> Eular12.calTri 28
  6
  iex> Eular12.solve(500)
  76576500
  iex> Eular12.solve_concurrent(500)
  76576500
  """

  @thread 5

  def calTri(num) when num <= 1, do: num

  def calTri(num) do

    Stream.iterate(1, & &1+1)
    |> Stream.map(fn x -> case rem(num, x) do
                          0 -> {x, true}
                          _ -> {x, false} end end)
    |> Stream.take_while(fn {i, _} -> i*i < num end)
    |> Stream.filter_map(fn {_, v} -> v end, fn _ -> 1 end)
    |> Enum.reduce(fn (u, v) -> u+v end)
    |> (&(2*&1)).()
  end

  defp start_cal(val, max) do

    main=self()

    spawn(fn ->
      send(main, {Eular12.calTri(val)>=max, val})
    end)
  end

  def solve(x) do

    Stream.iterate(0, & &1+1)
    |> Stream.map(& trunc((&1*(&1+1))/2))
    |> Stream.map(fn n -> {n, Eular12.calTri(n)} end)
    |> Stream.filter(fn {_ ,val} -> val >= x end)
    |> Stream.map(fn {val, _} -> val end)
    |> Enum.at(0)
  end

  def solve_concurrent(x) do
    loop(0, 1, x)
  end

  defp loop(pnum, current, thre) do

    if pnum < @thread do
      start_cal(trunc((current*(current+1))/2), thre)
      loop(pnum+1, current+1, thre)
    else
      receive do
        {false, _} -> loop(pnum-1, current, thre)
        {true, num} -> collect(pnum-1, num)
      end
    end
  end

  defp collect(0, num), do: num

  defp collect(pnum, num) do

    receive do
      {true, val} -> collect(pnum-1, min(num, val))
      _ -> collect(pnum-1, num)
    end
  end

end
