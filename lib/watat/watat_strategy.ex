defmodule MmCalendar.Watat.WatatStrategy do
  alias MmCalendar.Watat.{
    ThirdEraWatatInfo,
    SecondEraWatatInfo,
    FirstEraWatatInfo,
    FirstEraMakranata1WatatInfo,
    FirstEraMakranata2WatatInfo
  }

  def get_watat_info(year) do
    cond do
      year >= 1312 -> ThirdEraWatatInfo.new(year)
      year >= 1217 -> SecondEraWatatInfo.new(year)
      year >= 1100 -> FirstEraWatatInfo.new(year)
      year >= 798 -> FirstEraMakranata2WatatInfo.new(year)
      true -> FirstEraMakranata1WatatInfo.new(year)
    end
  end
end
