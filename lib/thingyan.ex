defmodule Thingyan do
  @doc """
  Myanmar thingyan calculation.
  """

  defstruct [:akyo, :akya, :akyat, :atat, :new_year]

  @type t :: %__MODULE__{
          akyo: Calendar.naive_datetime(),
          akya: Calendar.naive_datetime(),
          atat: [Calendar.naive_datetime()],
          new_year: Calendar.naive_datetime()
        }

  @doc """
  Get thingyan based on English year.
  """
  @spec for_en_year(pos_integer) :: %__MODULE__{}
  def for_en_year(year) do
    # Thingyan likely falls in April
    # so check two months ahead
    {:ok, date_time} = NaiveDateTime.new(year, 5, 1, 0, 0, 0)

    %MmDate{year: year} = MmDate.for(date_time)
    calculate_thingyan(year)
  end

  @doc """
  Get thingyan for given Myanmar date.
  """
  @spec for(%MmDate{}) :: %__MODULE__{}
  def for(%MmDate{year: year}) do
    calculate_thingyan(year)
  end

  @spec for(pos_integer) :: %__MODULE__{}
  def for(year) do
    calculate_thingyan(year)
  end

  @spec calculate_thingyan(pos_integer) :: %__MODULE__{}
  defp calculate_thingyan(year) do
    # နှစ်တစ်နှစ်ရဲ့ နှစ်ကူးချိန် (အတက်ချိန်) ကိုလိုချင်ရင် နှစ်တစ်နှစ်မှာရှိတဲ့ ဂျူလီယန်ရက်အရေအတွက်နဲ့
    # ရှာလိုတဲ့နှစ်နဲ့မြှောက်ပြီး မြန်မာနှစ် ၀ နှစ်မှာရှိတဲ့ ဂျူလီယန်ရက်နဲ့ပေါင်းလိုက်ရင် ရပါပြီ။
    thingyan_atat_date_time = Constants.solar_year() * year + Constants.zero_year_jdn()

    # ယခုလက်ရှိ မြန်မာပြက္ခဒိန် အကြံပေးအဖွဲ့က အသိအမှတ်ပြုတဲ့ သင်္ကြန်ကာလက
    # ၂.၁၆၉၉၁၈၉၈၂ ရက် (၂ ရက်၊ ၄ နာရီ၊ ၄ မိနစ်၊ ၄၁ စက္ကန့်) ဖြစ်ပြီး
    # ရှေးမြန်မာမင်းများ လက်ထက်ကတော့ ၂.၁၆၇၅ ရက် (၂ ရက်၊ ၄ နာရီ၊ ၁ မိနစ်၊ ၁၂ စက္ကန့်) ကိုသုံးခဲ့ပါတယ်။
    # ဒါကြောင့် သင်္ကြန်ကျချိန်ကို ရှာချင်ရင် သင်္ကြန်တက်ချိန်ထဲက ၂.၁၆၉၉၁၈၉၈၂ ရက်ကို နုတ်ပေးလိုက်ရင် ရပါတယ်။
    # မူသစ် မစတင်မီ (မြန်မာ သက္ကရာဇ် ၁၃၁၂ ခုနှစ် ၊ ခရစ်နှစ် ၁၉၅၀ မတိုင်မီ ) ဆိုရင်တော့
    # သင်္ကြန်ကျချိန်ကို ရဖို့အတွက် သင်္ကြန်တက်ချိန်ထဲက ၂.၁၆၇၅ ရက်နုတ်ပေးရမှာ ဖြစ်ပါတယ်။
    akya_day_offset = if year >= Constants.third_era_start(), do: 2.169918982, else: 2.1675
    thingyan_akya_date_time = thingyan_atat_date_time - akya_day_offset

    thingyan_atat_day = round(thingyan_atat_date_time)
    thingyan_akya_day = round(thingyan_akya_date_time)
    thingyan_akyo_day = thingyan_akya_day - 1
    mm_new_year_day = thingyan_atat_day + 1

    # သင်္ကြန်ကျချိန်နှင့် တက်ချိန် ကြားမှာရှိတဲ့ အချိန်ကွာခြားချက်က ၂ ရက်ကျော်ကျော် ဖြစ်တဲ့အတွက်
    # အကျရက်၊ အတက်ရက်တွေ ကျရောက်တာကို မူတည်ပြီး
    # တခါတလေ အကြတ်နေ့ တစ်ရက်ရှိပြီး၊ တခါတလေ အကြတ်နေ့ နှစ်ရက်ရှိနိုင်ပါတယ်။
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
