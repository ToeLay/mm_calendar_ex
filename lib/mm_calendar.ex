defmodule MmCalendar do
  alias MmCalendar.MmDate
  alias MmCalendar.Date.MmMonth
  alias MmCalendar.Language.NameTranslations

  @gregorian_start_jdn 2_361_222

  def julian_date_to_western(jd, calendar_type \\ :british)

  def julian_date_to_western(jd, :julian) do
    get_western_date_for_julian_calendar(jd)
  end

  def julian_date_to_western(jd, :british) when jd < @gregorian_start_jdn do
    get_western_date_for_julian_calendar(jd)
  end

  def julian_date_to_western(jd, calendar_type)
      when calendar_type == :british or calendar_type == :gregorian do
    get_western_date(jd)
  end

  def julian_date_to_western(_, _) do
    :invalid
  end

  @doc """
  Get list of days in English year, month.
  """
  @spec get_days_for_en_month(pos_integer(), 1..12) :: term()
  def get_days_for_en_month(year, month) do
    month_length = Calendar.ISO.days_in_month(year, month)

    1..month_length
    |> Enum.map(fn index -> MmDate.for(year, month, index) end)
  end

  @doc """
  Get Myanmar month range for English year, month.
  E.g (Tagu - Kason) for January.
  """
  def get_month_range(year, month) do
    month_length = Calendar.ISO.days_in_month(year, month)

    first_date = MmDate.for(year, month, 1)
    last_date = MmDate.for(year, month, month_length)

    {first_date.month, last_date.month}
  end

  def get_month_range_str(year, month, language \\ :english) do
    get_month_range(year, month) |> month_range_str(language)
  end

  defp month_range_str({%MmMonth{} = first_month, %MmMonth{} = last_month}, language)
       when first_month.index != last_month.index do
    first_month_str = first_month.translations |> NameTranslations.get_translation(language)
    last_month_str = last_month.translations |> NameTranslations.get_translation(language)

    first_month_str <> " - " <> last_month_str
  end

  defp month_range_str({first_month, last_month}, language)
       when first_month.index == last_month.index do
    # if first month and last month are the same, then we only need one month to show
    first_month.translations |> NameTranslations.get_translation(language)
  end

  defp get_western_date_for_julian_calendar(jd) do
    j = trunc(jd + 0.5)
    jf = jd + 0.5 - j
    b = j + 1524
    c = trunc((b - 122.1) / 365.25)
    f = trunc(365.25 * c)
    e = trunc((b - f) / 30.6001)

    month = if e > 13, do: e - 13, else: e - 1
    day = b - f - trunc(30.6001 * e)
    year = if month < 3, do: c - 4715, else: c - 4716

    %{hour: hour, minute: minute, second: second} = MmDate.get_time(jf)

    {:ok, date_time} = NaiveDateTime.new(year, month, day, hour, minute, second)
    date_time
  end

  defp get_western_date(jd) do
    jdn = trunc(jd + 0.5)
    jf = jd + 0.5 - jdn
    jdn = jdn - 1_721_119
    year = trunc((4 * jdn - 1) / 146_097)
    jdn = 4 * jdn - 1 - 146_097 * year
    day = trunc(jdn / 4)
    jdn = trunc((4 * day + 3) / 1461)
    day = 4 * day + 3 - 1461 * jdn
    day = trunc((day + 4) / 4)
    month = trunc((5 * day - 3) / 153)
    day = 5 * day - 3 - 153 * month
    day = trunc((day + 5) / 5)
    year = 100 * year + jdn

    [month, year] =
      if month < 10 do
        [month + 3, year]
      else
        [month - 9, year + 1]
      end

    %{hour: hour, minute: minute, second: second} = MmDate.get_time(jf)

    {:ok, date_time} = NaiveDateTime.new(year, month, day, hour, minute, second)
    date_time
  end
end
