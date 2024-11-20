defmodule MmCalendar.Constants do
  @doc """
    Beginning of Gregorian calendar in JDN (1752/Sep/14)
  """
  def gregorian_start_jdn() do
    2_361_222
  end

  @doc """
    Length of solar year
  """
  def solar_year() do
    1_577_917_828.0 / 4_320_000.0
  end

  @doc """
  Length of lunar month
  """
  def lunar_month() do
    1_577_917_828.0 / 53_433_336.0
  end

  @doc """
   Myanmar zero year in jdn
  """
  def zero_year_jdn() do
    1_954_168.050623
  end

  @doc """
  Beginning of thingyan in Myanmar year
  """
  def beginning_of_thingyan() do
    1100
  end

  @doc """
  Start of third era in Myanmar year
  """
  def third_era_start() do
    1312
  end
end
