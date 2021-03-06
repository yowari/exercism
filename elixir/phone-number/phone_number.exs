defmodule Phone do

  @regex_phone_number_pieces ~r/^(?<area_code>\d{3})(?<exchange_code>\d{3})(?<line_code>\d{4})$/

  @doc """
  Remove formatting from a phone number.

  Returns "0000000000" if phone number is not valid
  (10 digits or "1" followed by 10 digits)

  ## Examples

  iex> Phone.number("123-456-7890")
  "1234567890"

  iex> Phone.number("+1 (303) 555-1212")
  "3035551212"

  iex> Phone.number("867.5309")
  "0000000000"
  """
  @spec number(String.t) :: String.t
  def number(raw) do
    raw
    |> cleanup
    |> normalize_to_zeroes
  end

  @doc """
  Extract the area code from a phone number

  Returns the first three digits from a phone number,
  ignoring long distance indicator

  ## Examples

  iex> Phone.area_code("123-456-7890")
  "123"

  iex> Phone.area_code("+1 (303) 555-1212")
  "303"

  iex> Phone.area_code("867.5309")
  "000"
  """
  @spec area_code(String.t) :: String.t
  def area_code(raw) do
    {area_code, _, _} =
      raw
      |> cleanup
      |> extract_phone_number_pieces
    area_code
  end

  @doc """
  Pretty print a phone number

  Wraps the area code in parentheses and separates
  exchange and subscriber number with a dash.

  ## Examples

  iex> Phone.pretty("123-456-7890")
  "(123) 456-7890"

  iex> Phone.pretty("+1 (303) 555-1212")
  "(303) 555-1212"

  iex> Phone.pretty("867.5309")
  "(000) 000-0000"
  """
  @spec pretty(String.t) :: String.t
  def pretty(raw) do
    {area_code, exchange_code, line_code} =
      raw
      |> cleanup
      |> extract_phone_number_pieces
    "(#{area_code}) #{exchange_code}-#{line_code}"
  end

  @spec cleanup(String.t) :: String.t
  defp cleanup(raw_phone_number) do
    raw_phone_number
    |> sanitize_number
    |> trim_extra_leading_one
  end

  @spec extract_phone_number_pieces(String.t) :: {String.t, String.t, String.t}
  defp extract_phone_number_pieces(phone_number) do
    pieces = Regex.named_captures(@regex_phone_number_pieces, phone_number)
    { pieces["area_code"], pieces["exchange_code"], pieces["line_code"] }
  end

  @spec has_extra_leading_one?(String.t) :: boolean
  defp has_extra_leading_one?(numerical_string) do
    String.length(numerical_string) == 11 &&
    String.starts_with?(numerical_string, "1")
  end

  @spec normalize_to_zeroes(String.t) :: String.t
  defp normalize_to_zeroes(numerical_string) do
    if String.length(numerical_string) == 10 do
      numerical_string
    else
      "0000000000"
    end
  end

  @spec sanitize_number(String.t) :: String.t
  defp sanitize_number(numerical_input) do
    numerical_input
    |> String.replace(~r{\D}, "")
  end

  @spec trim_extra_leading_one(String.t) :: String.t
  defp trim_extra_leading_one(numerical_string) do
    if has_extra_leading_one?(numerical_string) do
      Regex.named_captures(~r/^1(?<remainder>\d{10}+)$/, numerical_string)["remainder"]
    else
      numerical_string
    end
  end

end
