defmodule MmAstro do
  def is_sabbath_eve?(%MmDate{day: day, month_length: month_length}) do
    day in [7, 14, 22] or day == month_length - 1
  end

  def is_sabbath?(%MmDate{day: day, month_length: month_length}) do
    day in [8, 15, 23] or day == month_length
  end

  def is_yatyaza?(%MmDate{month: month, week_day: week_day}) do
    m1 =
      month
      |> MmMonth.to_month_index()
      |> rem(4)

    wd1 = trunc(m1 / 2) + 4
    wd2 = (1 - trunc(m1 / 2) + rem(m1, 2)) * (1 + 2 * rem(m1, 2))
    MmWeekDay.to_day_index(week_day) in [wd1, wd2]
  end

  def is_pyathada?(%MmDate{month: month, week_day: week_day}) do
    m1 = month |> MmMonth.to_month_index() |> rem(4)

    # if m1 == 0 and week_day == 4:
    #     return True # afternoon pyathada

    wda = [1, 3, 3, 0, 2, 1, 2]

    week_index = week_day |> MmWeekDay.to_day_index()
    m1 == Enum.at(wda, week_index)
  end
end
