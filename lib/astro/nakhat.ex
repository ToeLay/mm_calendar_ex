defmodule Astro.Nakhat do
  @nakhat [:ogre, :elf, :human]

  def name(index) do
    Enum.at(@nakhat, index)
  end

  def index(:ogre) do
    0
  end

  def index(:elf) do
    1
  end

  def index(:human) do
    2
  end
end
