defmodule MmCalendar.Language do
  @languages [:english, :myanmar, :mon, :tai, :karen]

  def english() do
    0
  end

  def myanmar() do
    1
  end

  def mon() do
    2
  end

  def tai() do
    3
  end

  def karen() do
    4
  end

  def get_supported_languages() do
    @languages
  end
end
