defmodule MmDate do
  @doc """
  Module for Myanmar Date.
  """

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

  @type t :: %__MODULE__{
          year: integer(),
          year_type: 0..2,
          year_length: pos_integer(),
          month: 0..14,
          month_length: pos_integer(),
          day: 1..30,
          fornight_day: 1..15,
          moon_phase: 0..3,
          week_day: 0..6,
          hour: 0..23,
          minute: 0..59,
          second: 0..59
        }

  alias Watat.WatatStrategy
  alias Date.{MmMonth, YearType}

  @doc """
  Get Myanmar date for today.
  """
  @spec today() :: %__MODULE__{}
  def today() do
    date_time = NaiveDateTime.local_now()
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  @doc """
  Get Myanmar date for given `date_time`.
  """
  @spec for(%NaiveDateTime{}) :: %__MODULE__{}
  def for(%NaiveDateTime{} = date_time) do
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  @doc """
  Get Myanmar date for given `year`, `month`, `day`.
  """
  @spec for(non_neg_integer, 1..12, 1..31) :: %__MODULE__{}
  def for(year, month, day) do
    date_time = NaiveDateTime.new(year, month, day, 0, 0, 0)
    jdn = get_jdn(date_time)
    calculate_date(jdn)
  end

  @doc """
  Get Myanmar date for given julian date number.
  """
  @spec from_jdn(float) :: %__MODULE__{}
  def from_jdn(jdn) do
    calculate_date(jdn)
  end

  @spec calculate_date(%NaiveDateTime{}) :: %__MODULE__{}
  defp calculate_date(%NaiveDateTime{} = date_time) do
    # calculate Myanmar date for given date_time
    jdn = get_jdn(date_time)

    date = calculate_date(jdn)
    %{date | hour: date_time.hour, minute: date_time.minute, second: date_time.second}
  end

  @spec calculate_date(float) :: %__MODULE__{}
  defp calculate_date(jdn) do
    # calculate Myanmar date from julian day number

    jf = trunc(jdn + 0.5)
    time_fraction = jdn + 0.5 - jf
    %{hour: hour, minute: minute, second: second} = get_time(time_fraction)

    year = get_year(jdn)
    year_type = get_year_type(year)
    year_length = year_type |> YearType.name() |> get_year_length()
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

  @spec get_time(float) :: %{hour: 0..23, minute: 0..59, second: 0..59}
  defp get_time(jf) do
    # Calculate hour, minute, second from julian time fraction

    jf = jf * 24
    hour = trunc(jf)

    jf = (jf - hour) * 60
    minute = trunc(jf)

    jf = (jf - minute) * 60
    second = trunc(jf)

    %{hour: hour, minute: minute, second: second}
  end

  @doc """
  Get julian day number for given `date_time`.

  `calendar_type` can be `:british`, `:julian` or `:gregorian`. Defaults to `:british`.
  """
  @spec get_jdn(Calendar.naive_datetime(), :british | :julian | :gregorian) :: float()
  def get_jdn(
        %NaiveDateTime{} = date_time,
        calendar_type \\ :british
      ) do
    %NaiveDateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: second} =
      date_time

    julian_day = get_julian_day(year, month, day, calendar_type)
    time_fraction = day_to_time_fraction(hour, minute, second)

    julian_day + time_fraction
  end

  @spec get_year(float) :: integer()
  defp get_year(jdn) do
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

    jdn
    |> round()
    |> Kernel.-(Constants.zero_year_jdn())
    |> Kernel.-(0.5)
    |> Kernel./(Constants.solar_year())
    |> trunc()
  end

  @spec get_year_type(integer) :: 0..2
  # [0 = common, 1 = litte watat, 2 = big watat]
  defp get_year_type(year) do
    # မြန်မာနှစ်တနှစ် မှာ လထပ်ရင် ဝါထပ်နှစ်လို့ခေါ်ပြီး၊ ဝါထပ်နှစ်မှာပဲ ရက်ထပ်လို့ရပါတယ်။
    # ရက်မထပ်တဲ့ ဝါထပ်နှစ်ကို ဝါငယ်ထပ်နှစ်လို့ခေါ်ပြီး ဝါဆိုလရဲ့ ရှေ့မှာ ရက် ၃၀ ရှိတဲ့ ပထမဝါဆိုလ ထပ်ပေါင်းထားပါတယ်။
    # ဝါထပ်နှစ်မှာ ရက်ပါထပ်ရင် ဝါကြီးထပ်နှစ်လို့ ခေါ်ပြီး
    # ဝါဆိုလရဲ့ ရှေ့မှာ ၃၁ ရက် (ပထမ ဝါဆိုလ မှာ ရက် ၃၀ နဲ့ အဲဒီရှေ့ကပ်ရပ် နယုန်လ အကုန်မှာ ၁ ရက်) ထပ်ပေါင်းပါတယ်။
    # ဒါကြောင့် သာမန်နှစ်တွေကို ရက်ထပ်မထပ် စစ်ဖို့ မလိုပါဘူး။
    # နှစ်တနှစ်က ဝါထပ်ခဲ့ရင်တော့ ရက်ထပ်မထပ်စစ်ဖို့ သူ့ရဲ့ ဒုတိယ ဝါဆိုလပြည့်ရက် ကို ရှာပါမယ်။
    # နောက်တစ်ခါ အဲဒီနှစ် မတိုင်ခင် အနီးဆုံး ဝါထပ်နှစ်ရဲ့ ဒုတိယ ဝါဆိုလပြည့်ကိုလည်း ရှာပါမယ်။
    # အဲဒီလပြည့်ရက် နှစ်ရက်ရဲ့ ခြားနားတဲ့ ရက်အရေအတွက်ကို သာမန်နှစ်တနှစ်မှာရှိတဲ့ ရက်အရေအတွက် ၃၅၄ ရက် နဲ့ စားပါမယ်။
    # ရတဲ့ အကြွင်းက ၃၀ ဆိုရင် ပထမဝါဆိုလ တစ်လပဲ ပေါင်းဖို့လိုတာမို့ အဲဒီနှစ်က ဝါငယ်ထပ်နှစ်ဖြစ်ပြီး
    # အကြွင်းက ၃၁ ဆိုရင်တော့ ပထမဝါဆိုအပြင်၊ နယုန်လကိုပါ တစ်ရက်ထပ်ပေါင်းဖို့ လိုတာကြောင့် အဲဒီနှစ်က ဝါကြီးထပ်နှစ်ဖြစ်ပါတယ်။

    watat_info = WatatStrategy.get_watat_info(year)
    nearest_watat_info = get_nearnest_watat_info(year)

    unless watat_info.is_watat do
      0
    else
      (watat_info.second_waso_full_moon_day - nearest_watat_info.second_waso_full_moon_day)
      |> Kernel.rem(354)
      |> div(31)
      |> trunc()
      |> Kernel.+(1)
    end
  end

  @spec get_year_length(:common) :: 354
  defp get_year_length(:common) do
    # ရိုးရိုးနှစ်၊ ဝါငယ်ထပ်နှစ် နဲ့ ဝါကြီးထပ်နှစ်တွေအတွက် စုစုပေါင်း ရက်အရေအတွက် က ၃၅၄၊ ၃၈၄ နှင့် ၃၈၅ အသီးသီးဖြစ်ပါတယ်။
    354
  end

  @spec get_year_length(:litte_watat) :: 384
  defp get_year_length(:little_watat) do
    # (354 (common length) + 30 (watat = leap year))
    384
  end

  @spec get_year_length(:big_watat) :: 385
  defp get_year_length(:big_watat) do
    # (354 (common length) + 30 (watat = leap year) + 1 (yat ngyin = ရက်င်))
    385
  end

  @spec get_month(float) :: 0..14
  defp get_month(jdn) do
    month = get_raw_month(jdn)
    e = trunc((month + 12) / 16)
    f = trunc((month + 11) / 16)

    month = month + f * 3 - e * 4

    year = get_year(jdn)
    total_days = trunc(jdn - get_first_day_of_tagu(year) + 1)

    year_length =
      year
      |> get_year_type()
      |> YearType.name()
      |> get_year_length()

    if total_days > year_length, do: month + 12, else: month
  end

  @spec get_day(float) :: 0..30
  defp get_day(jdn) do
    # မြန်မာလကို ရတဲ့အခါ ရက်အရေအတွက်ထဲက အဲဒီလ မစခင် အရင်လတွေရဲ့ ရက်အရေအတွက် စုစုပေါင်းကို ပြန်နုတ်ပေးလိုက်ရင် မြန်မာရက်ကို ရပါတယ်။
    # ရက်မစုံတဲ့လဆိုရင် အများဆုံး ၂၉ ရက်ဖြစ်နိုင်ပြီး ရက်စုံတဲ့လဆိုရင်တော့ အများဆုံး ရက် ၃၀ ဖြစ်နိုင်ပါတယ်။

    month = get_raw_month(jdn)
    e = trunc((month + 12) / 16)
    f = trunc((month + 11) / 16)

    total_days = get_days_from_new_year(jdn)
    day = total_days - trunc(29.544 * month - 29.26)

    year_type = get_year(jdn) |> get_year_type() |> YearType.name()
    day = day - if year_type == :big_watat, do: e, else: 0
    day + if year_type == :common, do: f * 30, else: 0
  end

  @spec get_month_length(float) :: 29 | 30
  defp get_month_length(jdn) do
    # မကိန်းနံပါတ် လတွေဟာ ရက်မစုံ ၂၉ ရက်ပဲရှိပြီးတော့ စုံကိန်းနံပါတ် လတွေဟာတော့ ရက်စုံ ၃၀ ရှိတဲ့လတွေဖြစ်ပါတယ်။
    # ဒါကြောင့် လနံပါတ်ကို ၂ နဲ့စား အကြွင်းကို ၃၀ ထဲကနှုတ်လိုက်ရင် လရဲ့ ရက်အရေအတွက်ရပါပြီ

    month = get_month(jdn)
    month_length = 30 - rem(month, 2)

    year_type =
      jdn
      |> get_year()
      |> get_year_type()
      |> YearType.name()

    # ဝါကြီးထပ်နှစ် ရဲ့ နယုန်လ ဖြစ်ရင်တော့ ၁ ရက် ပေါင်းပေးဖို့ လိုပါတယ်။
    if MmMonth.name(month) == :nayon and year_type == :big_watat,
      do: month_length + 1,
      else: month_length
  end

  @spec get_moon_phase(float) :: 0..3
  defp get_moon_phase(jdn) do
    # လတစ်လ မှာ ၁ ရက်ကနေ ၁၄ ရက်ထိကို လဆန်းရက်တွေ လို့ခေါ်ပြီး ၁၅ ရက် ဆိုပါက လပြည့်နေ့ ဖြစ်ပါတယ်။
    # ၁၅ ရက်ကျော်ရင် ၁၅ ပြန်နုတ်ပေးပြီး လဆုတ် ဒါမှမဟုတ် လပြည့်ကျော် လို့ခေါ်ပါတယ်။
    # ဥပမာ ၁၆ ရက်ဆိုပါက လဆုတ် ၁ ရက်ဖြစ်ပါတယ်။ လတစ်လ ရဲ့နောက်ဆုံးရက်ကို လကွယ် ရက်လို့ခေါ်ပါတယ်။

    day = get_day(jdn)

    trunc((day + 1) / 16) + trunc(day / 16) + trunc(day / get_month_length(jdn))
  end

  @spec get_fornight_day(float) :: 1..15
  defp get_fornight_day(jdn) do
    day = get_day(jdn)
    trunc(day - 15 * trunc(day / 16))
  end

  @spec get_week_day(float) :: 0..6
  defp get_week_day(jdn) do
    (trunc(jdn) + 2) |> rem(7)
  end

  @spec get_julian_day(non_neg_integer, 1..12, 1..31, :gregorian) :: float()
  defp get_julian_day(year, month, day, :gregorian) do
    a = ((14 - month) / 12) |> trunc()
    year = year + 4800 - a
    month = month + 12 * a - 3

    julian_day = calculate_julian_day(year, month, day)
    julian_day - trunc(year / 100) + trunc(year / 400) - 32045
  end

  @spec get_julian_day(non_neg_integer, 1..12, 1..31, :julian) :: float()
  defp get_julian_day(year, month, day, :julian) do
    a = ((14 - month) / 12) |> trunc()
    year = year + 4800 - a
    month = month + 12 * a - 3

    julian_day = calculate_julian_day(year, month, day)
    julian_day - 32083
  end

  @spec get_julian_day(non_neg_integer, 1..12, 1..31, atom) :: float()
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

  @spec calculate_julian_day(non_neg_integer, 1..12, 1..31) :: non_neg_integer()
  defp calculate_julian_day(year, month, day) do
    ((153 * month + 2) / 5)
    |> trunc()
    |> Kernel.+(day)
    |> Kernel.+(365 * year)
    |> Kernel.+(trunc(year / 4))
  end

  @spec day_to_time_fraction(0..23, 0..59, 0..59) :: float()
  defp day_to_time_fraction(hour, minute, second) do
    (hour - 12) / 24 + minute / 1440 + second / 86400
  end

  @spec get_nearnest_watat_info(non_neg_integer, pos_integer) :: struct()
  defp get_nearnest_watat_info(year, year_count \\ 1) do
    # search nearest watat year

    watat_info = WatatStrategy.get_watat_info(year - year_count)

    if watat_info.is_watat != true and year_count < 3 do
      get_nearnest_watat_info(year, year_count + 1)
    else
      watat_info
    end
  end

  @spec get_raw_month(float) :: non_neg_integer()
  defp get_raw_month(jdn) do
    # ရက်အရေအတွက် ကနေ လ ကိုရှာရတာ လွယ်ကူပါတယ်။
    # ဥပမာ နှစ်စကနေ ၆၂ ရက်မြောက်နေ့လို့ ရက်အရေအတွက်သိရင်
    # တန်ခူးလ အတွက် ၂၉ ရက်နုတ်၊ နောက်တစ်ခါ ကဆုန်လအတွက် ၃၀ ရက် ထပ်နုတ်ပြီးတဲ့အခါ
    # ၃ ရက်ပဲကျန်တဲ့အတွက် အဲဒီရက်က နယုန်လ ထဲမှာ ဖြစ်တယ်လို့ သိနိုင်ပါတယ်။
    # ကွန်ပျူတာ ပရိုဂရမ်အတွက် ဆိုရင် အဲဒီလို စစ်လိုက်၊ ပြန်နုတ်လိုက် ထပ်ကာထပ်ကာ လုပ်တာက မထိရောက်ဘူး ထင်တာနဲ့ ညီမျှခြင်းနဲ့ ဖော်ပြဖို့ ကြိုးစားထားပါတယ်။
    # From https://coolemerald.blogspot.com/2013/06/algorithm-program-and-calculation-of.html

    total_days = get_days_from_new_year(jdn)
    day_threshold = trunc((total_days + 423) / 512)

    year_type =
      jdn
      |> get_year()
      |> get_year_type()
      |> YearType.name()

    total_days = total_days - if year_type == :big_watat, do: day_threshold, else: 0
    total_days = total_days + if year_type == :common, do: day_threshold * 30, else: 0

    trunc((total_days + 29.26) / 29.544)
  end

  @spec get_days_from_new_year(float) :: pos_integer()
  defp get_days_from_new_year(jdn) do
    # နှစ်စကနေ လက်ရှိရက်ထိ စုစုပေါင်း ရက်အရေအတွက်ကိုလိုချင်ရင်
    # ရှာလိုတဲ့ရက်ရဲ့ ဂျူလီယန်ရက်နံပါတ်ကနေ နှစ်ဦးမှာ ရှိတဲ့ တန်ခူးလဆန်း ၁ ရက်ကို နုတ်၊ တစ်ပေါင်းပေးပြီး ရှာနိုင်ပါတယ်။

    jdn = round(jdn)
    year = get_year(jdn)

    total_days = jdn - get_first_day_of_tagu(year) + 1

    year_length =
      year
      |> get_year_type()
      |> YearType.name()
      |> get_year_length()

    # တကယ်လို့ နှောင်းလ ဖြစ်ခဲ့ရင် အဲဒီနှစ်အမျိုးအစားရဲ့ ရက်အရေအတွက်ကို ပြန်နုတ်ပေးဖို့ လိုပါတယ်။
    if total_days > year_length, do: total_days - year_length, else: total_days
  end

  @spec get_first_day_of_tagu(non_neg_integer) :: pos_integer()
  defp get_first_day_of_tagu(year) do
    # မြန်မာနှစ်တနှစ်မှာ နှစ်ဦးမှာရှိတဲ့ တန်ခူးလရဲ့ လဆန်းတစ်ရက်နေ့ ရယ်၊ နှစ်အမျိုးအစား ( သာမန်လား၊ ဝါငယ်လား၊ ဝါကြီးလား) ဆိုတာသိရင်
    # အဲဒီနှစ်ရဲ့ ကျန်တဲ့ရက်တွေအားလုံးကို သိနိုင်ပါတယ်။
    # ဦးအုန်းကြိုင်က ရက်ပိုကို တွက်ပြီး နှစ်ဆန်းချိန်ထဲက ရက်ပိုကို နုတ်ပြီး တန်ခူးလ ဆန်း ၁ ရက် ရှာတာကို တွေ့ရှိမှတ်သားဘူးပါတယ်။
    # စဉ်းစားကြည့်ပြီး ချတွက်ကြည့်ပြီးတဲ့ အခါ အဲဒီနည်းက အမြဲမမှန်ပဲ နှစ်တော်တော်များများမှာ မှားတာကို တွေ့ရပါတယ်။
    # ဘာကြောင့်လဲဆိုရင် မြန်မာ ပြက္ခဒိန်မှာ ရက်ကို မှန်အောင် ပြန်ချိန်ညှိပေးတဲ့ ယန္တရား (mechanism) က
    # ဝါထပ်နှစ်မှာပဲ ဒုတိယ ဝါဆိုလ မတိုင်ခင် လထပ်၊ ရက်ထပ်တာကပဲ တစ်ခုတည်းသော နည်းဖြစ်ပါတယ်။
    # ကျန်တဲ့ လတွေနဲ့ ဝါမထပ်တဲ့ နှစ်တွေမှာ လွဲတဲ့ရက် ပေါ်လာရင် ဘာမှလုပ်လို့ မရပါဘူး။
    # နောက်တစ်ကြိမ် ဝါထပ်တဲ့ အခါမှပဲ ပြန်တည့်မတ်သွားမှာ ဖြစ်ပါတယ်။
    # ဒါ့ကြောင့် မြန်မာ ပြက္ခဒိန်မှာ ဒုတိယ ဝါဆိုလပြည့်နေ့က ပုံမှန် အဖြစ်ဆုံးလို့ဆိုတာပါ။
    # မြန်မာနှစ်တနှစ်ရဲ့ နှစ်ဦးမှာရှိတဲ့ တန်ခူးလရဲ့ လဆန်း ၁ ရက်နေ့ကို ရှာရင်လည်း ရှာမယ့် နှစ်မတိုင်ခင် အနီးဆုံး ဝါထပ်နှစ်ရဲ့ ဝါဆိုလပြည့်နေ့ ကို ကိုးကားရှာဖွေမှပဲ မှန်တဲ့နေ့ကိုရနိုင်ပါတယ်။
    # နှစ်တစ်နှစ်ရဲ့ အစပိုင်း တန်ခူးလဆန်း ၁ ရက်ကို အဲဒီနှစ်မတိုင်ခင် အနီးဆုံး ဝါထပ်နှစ်ရဲ့ ဝါဆိုလပြည့်ရက်ရယ်
    # အဲဒီနှစ်နဲ့ အနီးဆုံးဝါထပ်နှစ်အကြားမှာ ရှိတဲ့ သာမန်နှစ်အရေအတွက်ကို ၃၅၄ နဲ့ မြှောက်ထားတဲ့ မြှောက်လဒ် ရယ်ပေါင်းပြီး
    # အဲဒီရလဒ်ထဲက ၁၀၂ ရက်ကိုပြန်နုတ် ပေးပြီးရှာနိုင်ပါတယ်။

    nearest_watat_info = get_nearnest_watat_info(year)
    year_count = year - nearest_watat_info.year
    nearest_watat_info.second_waso_full_moon_day + 354 * year_count - 102
  end
end
