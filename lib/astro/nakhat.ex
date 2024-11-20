defmodule MmCalendar.Astro.Nakhat do
  alias MmCalendar.Language
  alias MmCalendar.Language.{NameTranslations, Translator}

  @nakhat [:ogre, :elf, :human]

  defstruct [
    :index,
    :name,
    :translations
  ]

  def new(index) when is_integer(index) and index >= 0 and index <= 2 do
    name = Enum.at(@nakhat, index)
    create(index, name)
  end

  def new(name) when is_atom(name) and name in @nakhat do
    index = Enum.find_index(@nakhat, fn el_name -> el_name == name end)
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
