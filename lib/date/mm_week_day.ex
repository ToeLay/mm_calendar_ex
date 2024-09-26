defmodule Date.MmWeekDay do
  @week_days [:saturday, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday]

  def name(index) when index >= 0 and index <= 6 do
    Enum.at(@week_days, index)
  end

  def name(_) do
    :invalid_index
  end

  def index(:saturday) do
    0
  end

  def index(:sunday) do
    1
  end

  def index(:monday) do
    2
  end

  def index(:tuesday) do
    3
  end

  def index(:wednesday) do
    4
  end

  def index(:thursday) do
    5
  end

  def index(:friday) do
    6
  end

  def index(_) do
    -1
  end
end
