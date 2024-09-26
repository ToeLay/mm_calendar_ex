defmodule Date.MoonPhase do
  @moon_phases [:waxing, :full_moon, :waning, :new_moon]

  def to_moon_phase_name(index) when index >= 0 and index <= 3 do
    Enum.at(@moon_phases, index)
  end

  def to_moon_phase_name(_) do
    :invalid_index
  end

  def to_moon_phase_index(:waxing) do
    0
  end

  def to_moon_phase_index(:full_moon) do
    1
  end

  def to_moon_phase_index(:waning) do
    2
  end

  def to_moon_phase_index(:new_moon) do
    3
  end

  def to_moon_phase_index(_) do
    -1
  end
end
