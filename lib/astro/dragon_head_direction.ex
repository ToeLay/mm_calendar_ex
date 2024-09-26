defmodule Astro.DragonHeadDirection do
  @direction [:west, :north, :east, :south]

  def name(direction) do
    Enum.at(@direction, direction)
  end

  def index(:west) do
    0
  end

  def index(:north) do
    1
  end

  def index(:east) do
    2
  end

  def index(:south) do
    3
  end
end
