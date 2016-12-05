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
  iex> Eular12.solve(6)
  28
  iex> Eular12.solve(500)
  76576500
  """

  @thread 10

  def calTri(num) when num <= 2 do
    num
  end

  def calTri(num) do
    calTrip(num, trunc(:math.sqrt(num)), 0)
  end

  defp calTrip(num, 0, total) do
    2*total
  end

  defp calTrip(num, div, total)do

    case rem(num,div) do
      0 -> calTrip(num, div-1, total+1)
      _ -> calTrip(num, div-1, total)
    end
  end

  defp start_cal(val, max) do

    main=self()

    spawn(fn ->
      send(main, {Eular12.calTri(val)>=max, val}) end)
  end

  def solve(x) do
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
