defmodule MmDate do
  defstruct [
    :year,
    :year_type,
    :year_length,
    :month,
    :month_length,
    :day,
    :fornight_day,
    :moon_phase,
    :week_day,
    :hour,
    :minute,
    :second
  ]

  alias Watat.WatatStrategy
  alias Date.{MmMonth, MoonPhase, MmWeekDay, YearType}

  def today() do
    date_time = NaiveDateTime.local_now()
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  def for(%NaiveDateTime{} = date_time) do
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  def for(year, month, day) do
    date_time = NaiveDateTime.new(year, month, day, 0, 0, 0)
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  def from_jdn(jdn) do
    calculate_date(jdn)
  end

  defp calculate_date(%NaiveDateTime{} = date_time) do
    jdn = get_jdn(date_time)

    date = calculate_date(jdn)
    %{date | hour: date_time.hour, minute: date_time.minute, second: date_time.second}
  end

  defp calculate_date(jdn) do
    jf = trunc(jdn + 0.5)
    time_fraction = jdn + 0.5 - jf
    %{hour: hour, minute: minute, second: second} = get_time(time_fraction)

    year = get_year(jdn)
    year_type = get_year_type(year)
    year_length = get_year_length(year_type)
    month = get_month(jdn)
    day = get_day(jdn)
    month_length = get_month_length(jdn)
    moon_phase = get_moon_phase(jdn)
    fornight_day = get_fornight_day(jdn)
    week_day = get_week_day(jdn)

    %MmDate{
      year: year,
      year_type: year_type,
      year_length: year_length,
      month: month,
      month_length: month_length,
      day: day,
      fornight_day: fornight_day,
      moon_phase: moon_phase,
      week_day: week_day,
      hour: hour,
      minute: minute,
      second: second
    }
  end

  defp get_time(jf) do
    jf = jf * 24
    hour = trunc(jf)

    jf = (jf - hour) * 60
    minute = trunc(jf)

    jf = (jf - minute) * 60
    second = trunc(jf)

    %{hour: hour, minute: minute, second: second}
  end

  @spec get_jdn(Calendar.naive_datetime(), atom()) :: float()
  def get_jdn(
        %NaiveDateTime{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second
        },
        calendar_type \\ :british
      ) do
    julian_day = get_julian_day(year, month, day, calendar_type)
    time_fraction = day_to_time_fraction(hour, minute, second)

    julian_day + time_fraction
  end

  def get_year(jdn) do
    # မြန်မာပြက္ခဒိန်မှာ နှစ်တစ်နှစ်ရဲ့ကြာချိန် ကို ၁၅၇၇၉၁၇၈၂၈/၄၃၂၀၀၀၀ (၃၆၅.၂၅၈၇၅၆၅) ရက် လို့သတ်မှတ်ထားပါတယ်။
    # နှစ်တစ်နှစ်ရဲ့အစချိန် (အတာတက်ချိန်)ကို နှစ်တစ်နှစ်ရဲ့ကြာချိန် ထည့်ပေါင်းလိုက်ရင် နောက်တစ်နှစ်ရဲ့ နှစ်အစချိန်ကို ရနိုင်တယ်။
    # ကြိုက်တဲ့ မြန်မာနှစ်တစ်နှစ်ရဲ့ နှစ်ဆန်းချိန်ကို ဂျူလီယန်ရက်စွဲတန်််ဖိုးနဲ့ လိုချင်ရင်အောက်က ပုံသေနည်းနဲ့ ရှာနိုင်ပါတယ်။
    # မြန်မာနှစ်ဆန်းချိန်(ဂျူလီယန်ရက်စွဲ) = နှစ်တစ်နှစ်ရဲ့ကြာချိန် x ရှာလိုသောနှစ် + မြန်မာနှစ် သုညနှစ်ရဲ့ အစကိန်းသေ(ဂျူလီယန်ရက်စွဲ)
    # ဒီပုံသေနည်းကို သုံးပြီးတော့ ဂျူလီယန်ရက်ကနေ မြန်မာနှစ်ကို အောက်ကပုံသေနည်းနဲ့ ရှာနိုင်ပါတယ်။
    # မြန်မာနှစ် = (မြန်မာနှစ်ဆန်းချိန်(ဂျူလီယန်ရက်စွဲ) - မြန်မာနှစ် သုညနှစ်ရဲ့ အစကိန်းသေ(ဂျူလီယန်ရက်စွဲ)) / နှစ်တစ်နှစ်ရဲ့ကြာချိန်
    # ဒါပေမယ့် မြန်မာပြက္ခဒိန်အရ နှစ်တစ်နှစ်ပြောင်းတာက နှစ်ဆန်းတစ်ရက်နေ့မှ ပြောင်းတာဖြစ်ပြီး
    # လက်ရှိပုံသေနည်းအရ နှစ်ဆန်းချိန်ဆိုတာက အတာတက်ချိန်(အတက်နေ့)သာဖြစ်နေတာကြောင့် ၁ ရက်နှုတ်ပေးဖို့လိုပါတယ်။
    # ဒါပေမယ့် ဂျူလီယန်ရက်ဆိုတာ နေမွန်းတည့်ချိန်က စတွက်တာဖြစ်လို့ ၁ ရက်မနှုတ်ဘဲ နေ့တစ်ဝက်စာ နှုတ်ပေးဖို့လိုပါတယ်။
    # ဒါကြောင့် ပုံသေနည်းအမှန်ကတော့ အောက်ပါအတိုင်းဖြစ်ပါတယ်။
    # မြန်မာနှစ် = (မြန်မာနှစ်ဆန်းချိန်(ဂျူလီယန်ရက်စွဲ) - မြန်မာနှစ် သုညနှစ်ရဲ့ အစကိန်းသေ(ဂျူလီယန်ရက်စွဲ) - ၀.၅) / နှစ်တစ်နှစ်ရဲ့ကြာချိန်

    days_from_zero_year =
      jdn
      |> round()
      |> Kernel.-(Constants.zero_year_jdn())
      |> Kernel.-(0.5)

    (days_from_zero_year / Constants.solar_year())
    |> trunc()
  end

  def get_year_type(year) do
    watat_info = WatatStrategy.get_watat_info(year)
    nearest_watat_info = get_nearnest_watat_info(year)

    unless watat_info.is_watat do
      :common
    else
      (watat_info.second_waso_full_moon_day - nearest_watat_info.second_waso_full_moon_day)
      |> Kernel.rem(354)
      |> div(31)
      |> trunc()
      |> Kernel.+(1)
      |> YearType.to_year_type_name()
    end
  end

  def get_year_length(:common) do
    354
  end

  def get_year_length(:little_watat) do
    # (354 (common length) + 30 (watat = leap year))
    384
  end

  def get_year_length(:big_watat) do
    # (354 (common length) + 30 (watat = leap year) + 1 (yat ngyin = ရက်င်))
    385
  end

  def get_month(jdn) do
    month = get_raw_month(jdn)
    e = trunc((month + 12) / 16)
    f = trunc((month + 11) / 16)

    month = month + f * 3 - e * 4

    year = get_year(jdn)
    total_days = trunc(jdn - get_first_day_of_tagu(year) + 1)
    year_type = get_year_type(year)
    year_length = get_year_length(year_type)

    month = if total_days > year_length, do: month + 12, else: month

    MmMonth.to_month_name(month)
  end

  def get_day(jdn) do
    month = get_raw_month(jdn)
    e = trunc((month + 12) / 16)
    f = trunc((month + 11) / 16)

    total_days = get_days_from_new_year(jdn)
    day = total_days - trunc(29.544 * month - 29.26)

    year = get_year(jdn)
    year_type = get_year_type(year)
    day = day - if year_type == :big_watat, do: e, else: 0
    day + if year_type == :common, do: f * 30, else: 0
  end

  def get_month_length(jdn) do
    month = get_month(jdn)
    month_length = 30 - rem(MmMonth.to_month_index(month), 2)

    if month == :nayon and get_year_type(get_year(jdn)) == :big_watat,
      do: month_length + 1,
      else: month_length
  end

  def get_moon_phase(jdn) do
    day = get_day(jdn)

    (trunc((day + 1) / 16) + trunc(day / 16) + trunc(day / get_month_length(jdn)))
    |> MoonPhase.to_moon_phase_name()
  end

  def get_fornight_day(jdn) do
    day = get_day(jdn)
    trunc(day - 15 * trunc(day / 16))
  end

  def get_week_day(jdn) do
    (trunc(jdn) + 2) |> rem(7) |> MmWeekDay.to_day_name()
  end

  defp get_julian_day(year, month, day, :gregorian) do
    a = ((14 - month) / 12) |> trunc()
    year = year + 4800 - a
    month = month + 12 * a - 3

    julian_day = calculate_julian_day(year, month, day)
    julian_day - trunc(year / 100) + trunc(year / 400) - 32045
  end

  defp get_julian_day(year, month, day, :julian) do
    a = ((14 - month) / 12) |> trunc()
    year = year + 4800 - a
    month = month + 12 * a - 3

    julian_day = calculate_julian_day(year, month, day)
    julian_day - 32083
  end

  defp get_julian_day(year, month, day, _calendary_type) do
    a = ((14 - month) / 12) |> trunc()
    year = year + 4800 - a
    month = month + 12 * a - 3

    julian_day = calculate_julian_day(year, month, day)

    julian_day = julian_day - trunc(year / 100) + trunc(year / 400) - 32045

    if julian_day < Constants.gregorian_start_jdn() do
      julian_day =
        ((153 * month + 2) / 5)
        |> Kernel.+(day)
        |> Kernel.+(365 * year)
        |> Kernel.+(trunc(year / 4))
        |> Kernel.-(32083)

      if julian_day > Constants.gregorian_start_jdn(),
        do: Constants.gregorian_start_jdn(),
        else: julian_day
    else
      julian_day
    end
  end

  defp calculate_julian_day(year, month, day) do
    ((153 * month + 2) / 5)
    |> trunc()
    |> Kernel.+(day)
    |> Kernel.+(365 * year)
    |> Kernel.+(trunc(year / 4))
  end

  defp day_to_time_fraction(hour, minute, second) do
    (hour - 12) / 24 + minute / 1440 + second / 86400
  end

  def get_nearnest_watat_info(year, year_count \\ 1) do
    watat_info = WatatStrategy.get_watat_info(year - year_count)

    if watat_info.is_watat != true and year_count < 3 do
      get_nearnest_watat_info(year, year_count + 1)
    else
      watat_info
    end
  end

  defp get_raw_month(jdn) do
    year = get_year(jdn)

    total_days = get_days_from_new_year(jdn)
    day_threshold = trunc((total_days + 423) / 512)

    year_type = get_year_type(year)
    total_days = total_days - if year_type == :big_watat, do: day_threshold, else: 0
    total_days = total_days + if year_type == :common, do: day_threshold * 30, else: 0

    trunc((total_days + 29.26) / 29.544)
  end

  defp get_days_from_new_year(jdn) do
    jdn = round(jdn)
    year = get_year(jdn)

    total_days = jdn - get_first_day_of_tagu(year) + 1
    year_type = get_year_type(year)
    year_length = get_year_length(year_type)

    if total_days > year_length, do: total_days - year_length, else: total_days
  end

  defp get_first_day_of_tagu(year) do
    nearest_watat_info = get_nearnest_watat_info(year)
    year_count = year - nearest_watat_info.year
    nearest_watat_info.second_waso_full_moon_day + 354 * year_count - 102
  end
end
