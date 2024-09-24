defmodule MmMonth do
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

  # @months [
  #   first_waso: 0,
  #   tagu: 1,
  #   kason: 2,
  #   nayon: 3,
  #   waso: 4,
  #   wagung: 5,
  #   tawthalin: 6,
  #   thadingyut: 7,
  #   tazaungmon: 8,
  #   nadaw: 9,
  #   pyatho: 10,
  #   tabodwe: 11,
  #   tabaung: 12,
  #   late_tagu: 13,
  #   late_kason: 14
  # ]

  def to_month_name(month_index) when month_index < 15 do
    Enum.at(@months_names, month_index)
  end

  def to_month_name(_) do
    :invalid_index
  end

  def to_month_index(:first_waso) do
    0
  end

  def to_month_index(:tagu) do
    1
  end

  def to_month_index(:kason) do
    2
  end

  def to_month_index(:nayon) do
    3
  end

  def to_month_index(:waso) do
    4
  end

  def to_month_index(:wagung) do
    5
  end

  def to_month_index(:tawthalin) do
    6
  end

  def to_month_index(:thadingyut) do
    7
  end

  def to_month_index(:tazaungmon) do
    8
  end

  def to_month_index(:nadaw) do
    9
  end

  def to_month_index(:pyatho) do
    10
  end

  def to_month_index(:tabodwe) do
    11
  end

  def to_month_index(:tabaung) do
    12
  end

  def to_month_index(:late_tagu) do
    13
  end

  def to_month_index(:late_kason) do
    14
  end

  def to_month_index(_) do
    -1
  end
end
