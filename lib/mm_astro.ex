defmodule MmAstro do
  @moduledoc """
  Get astrological information for Myanmar date.
  """

  alias Date.MmWeekDay
  alias Astro.{DragonHeadDirection, Mahabote, Nakhat}

  @spec is_sabbath_eve?(%MmDate{}) :: boolean()
  def is_sabbath_eve?(%MmDate{day: day, month_length: month_length}) do
    # မြန်မာ ပြက္ခဒိန်မှာ လပြည့်၊ လကွယ် နဲ့ လဆန်း၊ လဆုတ် ၈ ရက်နေ့တွေက ဥပုသ် နေ့ဖြစ်ပြီး၊ အဲဒီမတိုင်ခင်ရက်က အဖိတ်နေ့ ဖြစ်ပါတယ်။
    day in [7, 14, 22] or day == month_length - 1
  end

  @spec is_sabbath?(%MmDate{}) :: boolean()
  def is_sabbath?(%MmDate{day: day, month_length: month_length}) do
    # မြန်မာ ပြက္ခဒိန်မှာ လပြည့်၊ လကွယ် နဲ့ လဆန်း၊ လဆုတ် ၈ ရက်နေ့တွေက ဥပုသ် နေ့ဖြစ်ပြီး၊ အဲဒီမတိုင်ခင်ရက်က အဖိတ်နေ့ ဖြစ်ပါတယ်။
    day in [8, 15, 23] or day == month_length
  end

  @spec is_yatyaza?(%MmDate{}) :: boolean()
  def is_yatyaza?(%MmDate{month: month, week_day: week_day}) do
    # လနဲ့ နေ့ အပေါ်မှာ မူတည်တဲ့ ရက်ရာဇာ နေ့တွေကို အောက်က ဇယားမှာ ပြထားပါတယ်။
    # ===========================================
    # လ	                   | နေ့
    # ===========================================
    # တန်ခူး၊ ဝါခေါင်၊ နတ်တော်       | ဗုဒ္ဓဟူး၊ သောကြာ
    # ကဆုန်၊ တော်သလင်း၊ ပြာသို     |	ကြာသပတေး၊ စနေ
    # နယုန်၊ သီတင်းကျွတ်၊ တပို့တွဲ     |	အင်္ဂါ၊ ကြာသပတေး
    # ဝါဆို၊ တန်ဆောင်မုန်း၊ တပေါင်း   |	တနင်္ဂနွေ၊ ဗုဒ္ဓဟူး
    # ============================================

    m1 = rem(month, 4)

    wd1 = trunc(m1 / 2) + 4
    wd2 = (1 - trunc(m1 / 2) + rem(m1, 2)) * (1 + 2 * rem(m1, 2))
    week_day in [wd1, wd2]
  end

  @spec is_pyathada?(%MmDate{}) :: boolean()
  def is_pyathada?(%MmDate{month: month, week_day: week_day}) do
    # ===============================================
    # လ                        |နေ့
    # ===============================================
    # တန်ခူး၊ ဝါခေါင်၊ နတ်တော်       |ကြာသပတေး၊ စနေ
    # ကဆုန်၊ တော်သလင်း၊ ပြာသို     |ဗုဒ္ဓဟူး၊ သောကြာ
    # နယုန်၊ သီတင်းကျွတ်၊ တပို့တွဲ     |တနင်္ဂနွေ၊ တနင်္လာ
    # ဝါဆို၊ တန်ဆောင်မုန်း၊ တပေါင်း   |အင်္ဂါ၊ ဗုဒ္ဓဟူး မွန်းလွဲ
    # ===============================================

    m1 = rem(month, 4)

    # if m1 == 0 and week_day == 4:
    #     return True # afternoon pyathada

    wda = [1, 3, 3, 0, 2, 1, 2]

    m1 == Enum.at(wda, week_day)
  end

  @spec get_dragon_head_direction(%MmDate{}) :: :west | :noth | :east | :south
  def get_dragon_head_direction(%MmDate{month: month}) do
    # first waso is considered as waso
    month = if month == 0, do: 4, else: month

    month
    |> rem(12)
    |> div(3)
    |> trunc()
    |> DragonHeadDirection.name()
  end

  @spec get_mahabote(%MmDate{}) :: :binga | :ahtun | :yaza | :adipidi | :marana | :thike | :puti
  def get_mahabote(%MmDate{year: year, week_day: week_day}) do
    year
    |> Kernel.-(week_day)
    |> rem(7)
    |> Mahabote.name()
  end

  @spec get_nakhat(%MmDate{}) :: :ogre | :elf | :human
  def get_nakhat(%MmDate{year: year}) do
    year
    |> rem(3)
    |> Nakhat.name()
  end

  @spec is_thama_nyo?(%MmDate{}) :: boolean()
  def is_thama_nyo?(%MmDate{month: month, week_day: week_day}) do
    month_type = trunc(month / 13)
    # to 1-12 with month type
    month = rem(month, 13) + month_type

    # first waso is considered waso
    month = if month <= 0, do: 4, else: month

    m1 = month - 1 - trunc(month / 9)

    wd1 =
      (m1 * 2)
      |> Kernel.-(trunc(m1 / 8))
      |> rem(7)

    wd2 =
      week_day
      |> Kernel.+(7)
      |> Kernel.-(wd1)
      |> rem(7)

    wd2 <= 1
  end

  @spec is_thama_phyu?(%MmDate{}) :: boolean()
  def is_thama_phyu?(%MmDate{fornight_day: fornight_day, week_day: week_day}) do
    wda = [[1, 0], [2, 1], [6, 0], [6, 0], [5, 0], [6, 3], [7, 3]]

    if fornight_day in Enum.at(wda, week_day) do
      true
    else
      fornight_day == 4 and week_day |> MmWeekDay.name() == :thursday
    end
  end

  @spec is_amyeittasote?(%MmDate{}) :: boolean()
  def is_amyeittasote?(%MmDate{fornight_day: fornight_day, week_day: week_day}) do
    wda = [5, 8, 3, 7, 2, 4, 1]

    fornight_day == Enum.at(wda, week_day)
  end

  @spec is_warameittu_gyi?(%MmDate{}) :: boolean()
  def is_warameittu_gyi?(%MmDate{fornight_day: fornight_day, week_day: week_day}) do
    wda = [7, 1, 4, 8, 9, 6, 3]

    fornight_day == Enum.at(wda, week_day)
  end

  @spec is_warameittu_nge?(%MmDate{}) :: boolean()
  def is_warameittu_nge?(%MmDate{fornight_day: fornight_day, week_day: week_day}) do
    index =
      week_day
      |> Kernel.+(6)
      |> rem(7)

    index == 12 - fornight_day
  end

  @spec is_yat_pote?(%MmDate{}) :: boolean()
  def is_yat_pote?(%MmDate{fornight_day: fornight_day, week_day: week_day}) do
    wda = [8, 1, 4, 6, 9, 8, 7]

    fornight_day == Enum.at(wda, week_day)
  end

  @spec is_naga_por?(%MmDate{}) :: boolean()
  def is_naga_por?(%MmDate{day: day, week_day: week_day}) do
    wda = [[26, 17], [21, 19], [2, 1], [10, 0], [18, 9], [2, 0], [21, 0]]

    if day in Enum.at(wda, week_day) do
      true
    else
      week_day_name = MmWeekDay.name(week_day)

      (day == 2 and week_day_name == :sunday) or (day in [12, 4, 18] and week_day_name == :monday)
    end
  end

  @spec is_yat_yotema?(%MmDate{}) :: boolean()
  def is_yat_yotema?(%MmDate{month: month, fornight_day: fornight_day}) do
    month_type = trunc(month / 13)
    # to 1-12 with month type
    month = rem(month, 13) + month_type

    month = if month <= 0, do: 4, else: month

    m1 = if rem(month, 2) == 0, do: rem(month + 9, 12), else: month
    m1 = rem(m1 + 4, 12) + 1

    fornight_day == m1
  end

  @spec is_maha_yat_kyan?(%MmDate{}) :: boolean()
  def is_maha_yat_kyan?(%MmDate{month: month, fornight_day: fornight_day}) do
    month = if month == 0, do: 4, else: month

    m1 = trunc(rem(month, 12) / 2) + 4
    m1 = rem(m1, 6) + 1

    fornight_day == m1
  end

  @spec is_shan_yat?(%MmDate{}) :: boolean()
  def is_shan_yat?(%MmDate{month: month, fornight_day: fornight_day}) do
    month_type = trunc(month / 13)
    # to 1-12 with month type
    month = rem(month, 13) + month_type

    month = if month <= 0, do: 4, else: month

    sya = [8, 8, 2, 2, 9, 3, 3, 5, 1, 4, 7, 4]

    fornight_day == Enum.at(sya, month - 1)
  end
end
