defmodule Astro.Mahabote do
  @mahabote [:binga, :ahtun, :yaza, :adipidi, :marana, :thike, :puti]

  def name(index) do
    Enum.at(@mahabote, index)
  end

  def index(:binga) do
    0
  end

  def index(:ahtun) do
    1
  end

  def index(:yaza) do
    2
  end

  def index(:adipidi) do
    3
  end

  def index(:marana) do
    4
  end

  def index(:thike) do
    5
  end

  def index(:puti) do
    6
  end
end
