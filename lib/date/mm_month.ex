defmodule MmCalendar.Date.MmMonth do
  alias MmCalendar.Language
  alias MmCalendar.Language.{NameTranslations, Translator}

  @months_names [
    :first_waso,
    :tagu,
    :kason,
    :nayon,
    :waso,
    :wagung,
    :tawthalin,
    :thadingyut,
    :tazaungmon,
    :nadaw,
    :pyatho,
    :tabodwe,
    :tabaung,
    :late_tagu,
    :late_kason
  ]

  defstruct [
    :index,
    :name,
    :translations
  ]

  @type t :: %__MODULE__{
          index: 0..14,
          name: atom(),
          translations: %NameTranslations{}
        }

  def new(index) when is_integer(index) and index >= 0 and index <= 14 do
    name = Enum.at(@months_names, index)
    create(index, name)
  end

  def new(name) when is_atom(name) and name in @months_names do
    index = Enum.find_index(@months_names, fn el_name -> el_name == name end)
    create(index, name)
  end

  defp create(index, name) do
    %__MODULE__{
      index: index,
      name: name,
      translations: %NameTranslations{
        english: Translator.translate(name, Language.english()),
        myanmar: Translator.translate(name, Language.myanmar()),
        mon: Translator.translate(name, Language.mon()),
        tai: Translator.translate(name, Language.tai()),
        karen: Translator.translate(name, Language.karen())
      }
    }
  end
end
