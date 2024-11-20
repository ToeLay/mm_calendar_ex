defmodule MmCalendar.Language.NameTranslations do
  @languages MmCalendar.Language.get_supported_languages()
  @lang_count Enum.count(@languages)

  defstruct [:english, :myanmar, :mon, :tai, :karen]

  @type t :: %__MODULE__{
          english: String.t(),
          myanmar: String.t(),
          mon: String.t(),
          tai: String.t(),
          karen: String.t()
        }

  def get_translation(%__MODULE__{} = translations, language)
      when is_integer(language) and language >= 0 and language <= @lang_count do
    lang_name = Enum.at(@languages, language)

    Map.get(translations, lang_name)
  end

  def get_translation(%__MODULE__{} = translations, language)
      when is_atom(language) and language in @languages do
    Map.get(translations, language)
  end
end
