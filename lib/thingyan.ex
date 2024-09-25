defmodule Thingyan do
  defstruct [:akyo, :akya, :akyat, :atat, :new_year]

  def for_en_year(year) do
    # Thingyan likely falls in April
    # so check two months ahead
    {:ok, date_time} = NaiveDateTime.new(year, 6, 1, 0, 0, 0)

    %MmDate{year: year} = MmDate.for(date_time)
    calculate_thingyan(year)
  end

  def for(%MmDate{year: year}) do
    calculate_thingyan(year)
  end

  def for(year) do
    calculate_thingyan(year)
  end

  defp calculate_thingyan(year) do
    thingyan_atat_date_time = Constants.solar_year() * year + Constants.zero_year_jdn()

    akya_day_offset = if year >= Constants.third_era_start(), do: 2.169918982, else: 2.1675
    thingyan_akya_date_time = thingyan_atat_date_time - akya_day_offset

    thingyan_atat_day = round(thingyan_atat_date_time)
    thingyan_akya_day = round(thingyan_akya_date_time)
    thingyan_akyo_day = thingyan_akya_day - 1
    mm_new_year_day = thingyan_atat_day + 1

    akyat_day_count = thingyan_atat_day - thingyan_akya_day - 1

    thingyan_akyat_days =
      Enum.reduce(akyat_day_count..1//-1, [], fn index, acc ->
        [thingyan_akya_day + index | acc]
      end)

    akyo_date_time = MmCalendar.julian_date_to_western(thingyan_akyo_day)
    akya_date_time = MmCalendar.julian_date_to_western(thingyan_akya_date_time)
    akyat_date_times = Enum.map(thingyan_akyat_days, &MmCalendar.julian_date_to_western(&1))
    atat_date_time = MmCalendar.julian_date_to_western(thingyan_atat_date_time)
    new_year_date_time = MmCalendar.julian_date_to_western(mm_new_year_day)

    %Thingyan{
      akyo: akyo_date_time,
      akya: akya_date_time,
      akyat: akyat_date_times,
      atat: atat_date_time,
      new_year: new_year_date_time
    }
  end
end
