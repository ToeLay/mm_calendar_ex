defmodule Date.MmMonth do
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

  def name(month_index) when month_index < 15 do
    Enum.at(@months_names, month_index)
  end

  def name(_) do
    :invalid_index
  end

  def index(:first_waso) do
    0
  end

  def index(:tagu) do
    1
  end

  def index(:kason) do
    2
  end

  def index(:nayon) do
    3
  end

  def index(:waso) do
    4
  end

  def index(:wagung) do
    5
  end

  def index(:tawthalin) do
    6
  end

  def index(:thadingyut) do
    7
  end

  def index(:tazaungmon) do
    8
  end

  def index(:nadaw) do
    9
  end

  def index(:pyatho) do
    10
  end

  def index(:tabodwe) do
    11
  end

  def index(:tabaung) do
    12
  end

  def index(:late_tagu) do
    13
  end

  def index(:late_kason) do
    14
  end

  def index(_) do
    -1
  end
end
