defmodule Date.YearType do
  @year_types [:common, :little_watat, :big_watat]

  def to_year_type_name(index) when is_integer(index) and index >= 0 and index <= 2 do
    Enum.at(@year_types, index)
  end

  def to_year_type_name(_) do
    :invalid_index
  end

  def to_year_type_index(:common) do
    0
  end

  def to_year_type_index(:little_watat) do
    1
  end

  def to_year_type_index(:big_watat) do
    2
  end

  def to_year_type_index(_) do
    -1
  end
end
