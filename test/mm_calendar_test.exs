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

    [file_list: file_list]
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
end
