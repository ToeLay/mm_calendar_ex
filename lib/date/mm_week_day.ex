defmodule Date.MmWeekDay do
  @week_days [:saturday, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday]

  def to_day_name(index) when index >= 0 and index <= 6 do
    Enum.at(@week_days, index)
  end

  def to_day_name(_) do
    :invalid_index
  end

  def to_day_index(:saturday) do
    0
  end

  def to_day_index(:sunday) do
    1
  end

  def to_day_index(:monday) do
    2
  end

  def to_day_index(:tuesday) do
    3
  end

  def to_day_index(:wednesday) do
    4
  end

  def to_day_index(:thursday) do
    5
  end

  def to_day_index(:friday) do
    6
  end

  def to_day_index(_) do
    -1
  end
end
