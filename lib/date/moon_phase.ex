defmodule Date.MoonPhase do
  @moon_phases [:waxing, :full_moon, :waning, :new_moon]

  def name(index) when index >= 0 and index <= 3 do
    Enum.at(@moon_phases, index)
  end

  def name(_) do
    :invalid_index
  end

  def index(:waxing) do
    0
  end

  def index(:full_moon) do
    1
  end

  def index(:waning) do
    2
  end

  def index(:new_moon) do
    3
  end

  def index(_) do
    -1
  end
end
