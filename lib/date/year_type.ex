defmodule Date.YearType do
  @year_types [:common, :little_watat, :big_watat]

  def name(index) when is_integer(index) and index >= 0 and index <= 2 do
    Enum.at(@year_types, index)
  end

  def name(_) do
    :invalid_index
  end

  def index(:common) do
    0
  end

  def index(:little_watat) do
    1
  end

  def index(:big_watat) do
    2
  end

  def index(_) do
    -1
  end
end
