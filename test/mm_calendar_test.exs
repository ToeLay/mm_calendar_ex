defmodule MmCalendarTest do
  use ExUnit.Case
  doctest MmCalendar

  setup_all do
    base_file_path = "priv/mmdate/"

    file_list =
      Enum.reduce(2023..1923//-1, [], fn index, acc ->
        file_path = base_file_path <> "#{index}.txt"
        content = File.read!(file_path)

        lines =
          content
          |> String.trim()
          |> String.split("\n")
          |> Enum.map(&String.split(&1, "|"))

        [lines | acc]
      end)

    astro_file_path = "priv/astro/astro-2023.txt"

    astro_lines =
      File.read!(astro_file_path)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))

    [file_list: file_list, astro_lines: astro_lines]
  end

  test "julian date checks" do
    assert MmDate.get_jdn(~N[2024-09-23 15:30:28]) == 2_460_577.146157407

    assert MmDate.get_jdn(~N[2023-09-23 15:30:28]) == 2_460_211.146157407

    assert MmDate.get_jdn(~N[1000-09-23 15:30:30]) == 2_086_574.1461805555
  end

  test "julian date checks for julian calendar" do
    assert MmDate.get_jdn(~N[2024-09-23 15:30:28], :julian) == 2_460_590.146157407

    assert MmDate.get_jdn(~N[2023-09-23 15:30:28], :julian) == 2_460_224.146157407

    assert MmDate.get_jdn(~N[1000-09-23 15:30:30], :julian) == 2_086_574.1461805555
  end

  test "julian date checks for gregorian calendar" do
    assert MmDate.get_jdn(~N[2018-09-23 15:30:28], :gregorian) == 2_458_385.146157407

    assert MmDate.get_jdn(~N[2015-09-23 15:30:28], :gregorian) == 2_457_289.146157407

    assert MmDate.get_jdn(~N[1000-09-23 15:30:30], :gregorian) == 2_086_568.1461805555
  end

  test "check dates from 1923 to 2023", %{file_list: file_list} do
    Enum.each(file_list, fn line ->
      Enum.each(line, fn row ->
        [jd, year_type, year, month, day] = row |> Enum.map(&String.to_integer/1)

        %MmDate{
          year: calculated_year,
          year_type: calculated_year_type,
          month: calculated_month,
          day: calculated_day
        } = MmDate.from_jdn(jd)

        assert calculated_year == year

        assert YearType.to_year_type_index(calculated_year_type) == year_type

        assert MmMonth.to_month_index(calculated_month) == month

        assert calculated_day == day
      end)
    end)
  end

  test "thingyan one akyat day test" do
    thingyan = Thingyan.for(1379)

    assert thingyan.akya == ~N[2017-04-14 04:56:29]
    assert thingyan.atat == ~N[2017-04-16 09:01:10]
  end

  test "thingyan two akyat day test" do
    thingyan = Thingyan.for(1382)

    # has one second difference
    assert abs(NaiveDateTime.diff(thingyan.akya, ~N[2020-04-13 23:34:19], :second)) <= 1
    assert abs(NaiveDateTime.diff(thingyan.atat, ~N[2020-04-16 03:38:59], :second)) <= 1

    # assert akyat days
    [~N[2020-04-14 12:00:00], ~N[2020-04-15 12:00:00]]
  end

  test "check days for 2023", %{astro_lines: astro_lines} do
    Enum.each(astro_lines, fn line ->
      [
        jd,
        sabbath,
        yatyaza,
        pyathada,
        thamanyo,
        amyeittasote,
        warameittugyi,
        warameittunge,
        yatpote,
        thamaphyu,
        nagapor,
        yatyotema,
        mahayatkyan,
        shanyat,
        nagahle,
        mahabote,
        nakhat,
        yearName
      ] = line |> Enum.map(&String.to_integer/1)

      date = MmDate.from_jdn(jd)
      is_sabbath_eve = MmAstro.is_sabbath_eve?(date)
      assert is_sabbath_eve == (sabbath == 2)

      is_sabbath = MmAstro.is_sabbath?(date)
      assert is_sabbath == (sabbath == 1)

      is_yatyaza = MmAstro.is_yatyaza?(date)
      assert is_yatyaza == to_bool(yatyaza)

      is_pyathada = MmAstro.is_pyathada?(date)
      assert is_pyathada == (pyathada == 1)
    end)
  end

  defp to_bool(number) when is_integer(number) do
    number != 0
  end
end
