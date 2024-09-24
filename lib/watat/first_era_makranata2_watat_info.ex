defmodule Watat.FirstEraMakranata2WatatInfo do
  defstruct [:is_watat, :second_waso_full_moon_day, :year]

  @type t :: %Watat.FirstEraMakranata2WatatInfo{
          is_watat: boolean(),
          second_waso_full_moon_day: integer(),
          year: integer()
        }

  # not based on months
  @to_check_months -1
  @excess_days_per_month Constants.solar_year() / 12 - Constants.lunar_month()
  @watat_offset -1.1
  # key is year and value is whether watat or not
  @watat_exceptions %{}
  # key is year and value is offset
  @offset_exceptions %{
    "813" => -2.1,
    "849" => -2.1,
    "851" => -2.1,
    "854" => -2.1,
    "927" => -2.1,
    "933" => -2.1,
    "936" => -2.1,
    "938" => -2.1,
    "949" => -2.1,
    "952" => -2.1,
    "963" => -2.1,
    "968" => -2.1,
    "1039" => -2.1
  }

  def new(year) do
    %Watat.FirstEraMakranata2WatatInfo{
      is_watat: is_watat?(year),
      second_waso_full_moon_day: get_second_waso_full_moon_day(year),
      year: year
    }
  end

  defp is_watat?(year) do
    key = Integer.to_string(year)

    if Map.has_key?(@watat_exceptions, key) do
      Map.get(@watat_exceptions, key)
    else
      watat = (year * 7 + 2) |> rem(19)

      watat = watat + if watat < 0, do: 19, else: 0

      round(watat / 12) != 0
    end
  end

  defp get_second_waso_full_moon_day(year) do
    excess_days = get_excess_days(year)
    watat_offset = Map.get(@offset_exceptions, Integer.to_string(year), @watat_offset)

    (year * Constants.solar_year())
    |> Kernel.+(Constants.zero_year_jdn())
    |> Kernel.-(excess_days)
    |> Kernel.+(4.5 * Constants.lunar_month())
    |> Kernel.+(watat_offset)
    |> round()
  end

  defp get_excess_days(year) do
    excess_days =
      Constants.solar_year()
      |> Kernel.*(year + 3739)
      |> :math.fmod(Constants.lunar_month())

    to_check_excess_days = (12 - @to_check_months) * @excess_days_per_month

    # if excess days is less than 4 months excess days
    # then this must be watat and need to adjust
    excess_days + if excess_days < to_check_excess_days, do: Constants.lunar_month(), else: 0
  end
end
