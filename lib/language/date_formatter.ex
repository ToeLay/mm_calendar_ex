defmodule MmCalendar.Language.DateFormatter do
  alias MmCalendar.MmDate
  alias MmCalendar.Astro
  alias MmCalendar.Language.{Translator, NameTranslations}

  def get_date_string(%MmDate{} = date, format, language) do
    patterns = [
      "&yyyy",
      "&y",
      "&YYYY",
      "&mm",
      "&M",
      "&m",
      "&P",
      "&dd",
      "&d",
      "&ff",
      "&f",
      "&W",
      "&w",
      "&A",
      "&D"
    ]

    year_str = pad_number(date.year, 4) |> translate_num_string(language)

    year_str_short = pad_number(date.year) |> translate_num_string(language)

    sasana_year_str = pad_number(date.sasana_year, 4) |> translate_num_string(language)

    month = date.month
    month_num_str = pad_number(month.index) |> translate_num_string(language)

    month_str = NameTranslations.get_translation(month.translations, language)

    month_str =
      if month == :waso and date.year_type != :common,
        do: Translator.translate(:second, language) <> "-" <> month_str,
        else: month_str

    month_num_str_short =
      month.index
      |> Integer.to_string()
      |> translate_num_string(language)

    moon_phase_str =
      date.moon_phase.translations
      |> NameTranslations.get_translation(language)

    day_str = pad_number(date.day) |> translate_num_string(language)

    day_str_short =
      date.day
      |> Integer.to_string()
      |> translate_num_string(language)

    fortnight_day_str = pad_number(date.fornight_day) |> translate_num_string(language)

    fornight_day_str_short =
      date.fornight_day
      |> Integer.to_string()
      |> translate_num_string(language)

    week_day_str =
      date.week_day.translations
      |> NameTranslations.get_translation(language)

    week_day_no =
      date.week_day.index
      |> Integer.to_string()
      |> translate_num_string(language)

    astro_days =
      Astro.get_astro_days(date)
      |> Enum.map(fn astro_day -> Translator.translate(astro_day, language) end)
      |> Enum.join(Translator.translate(:separator, language))

    direction = Astro.get_dragon_head_direction(date)

    direction_str =
      direction.translations
      |> NameTranslations.get_translation(language)

    String.replace(format, patterns, fn
      "&yyyy" -> year_str
      "&y" -> year_str_short
      "&YYYY" -> sasana_year_str
      "&mm" -> month_num_str
      "&M" -> month_str
      "&m" -> month_num_str_short
      "&P" -> moon_phase_str
      "&dd" -> day_str
      "&d" -> day_str_short
      "&ff" -> fortnight_day_str
      "&f" -> fornight_day_str_short
      "&W" -> week_day_str
      "&w" -> week_day_no
      "&A" -> astro_days
      "&D" -> direction_str
    end)
  end

  defp pad_number(number, padding \\ 2) do
    output_str =
      0
      |> List.duplicate(padding)
      |> Enum.concat([number])
      |> Enum.join()

    start_index = String.length(output_str) - padding

    String.slice(output_str, start_index..-1//1)
  end

  defp translate_num_string(num_string, language) do
    num_string
    |> String.split("", trim: true)
    |> Enum.map(fn str -> Translator.translate(str, language) end)
    |> Enum.join()
  end
end
