defmodule YubikeyOTP.ModHex do
  @moduledoc """
  Implementation of ModHex encoding and decoding.
  """
  require Integer

  @hex_digits to_charlist("0123456789abcdef")
  @modhex_digits to_charlist("cbdefghijklnrtuv")
  @hex_to_modhex_map Enum.zip(@hex_digits, @modhex_digits) |> Enum.into(%{})
  @modhex_to_hex_map Enum.zip(@modhex_digits, @hex_digits) |> Enum.into(%{})

  @doc "The digits in modhex"
  defmacro modhex_digits, do: @modhex_digits

  @doc """
  Determines whether the given string is modhex.

  ## Examples

      iex> YubikeyOTP.ModHex.modhex?("jjnkec")
      true

      iex> YubikeyOTP.ModHex.modhex?("nope")
      false
  """
  @spec modhex?(string :: binary()) :: boolean()
  def modhex?(string) when is_binary(string) and rem(byte_size(string), 2) == 0 do
    string
      |> to_charlist
      |> Enum.all?(&Enum.member?(@modhex_digits, &1))
  end

  def modhex?(string) when is_binary(string) do
    false
  end

  @doc """
  Determines whether the given string is hexadecimal.

  ## Examples

      iex> YubikeyOTP.ModHex.hex?("666f6F626172")
      true

      iex> YubikeyOTP.ModHex.hex?("nope")
      false
  """
  @spec hex?(string :: binary()) :: boolean()
  def hex?(string) do
    case Base.decode16(string, case: :mixed) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc """
  Converts the given modhex string to hexadecimal.

  An `ArgumentError` exception is raised if the value is not modhex.

  ## Examples

      iex> YubikeyOTP.ModHex.to_hex!("jjnkec")
      "88b930"
  """
  @spec to_hex!(string :: binary()) :: binary()
  def to_hex!(string) do
    if modhex?(string) do
      string
        |> to_charlist
        |> Enum.map(fn i -> @modhex_to_hex_map[i] end)
        |> to_string
    else
      raise ArgumentError, "invalid modhex: #{string}"
    end
  end

  @doc """
  Decodes the given modhex into a binary string.

  An `ArgumentError` exception is raised if the value is not modhex.

  ## Examples

      iex> YubikeyOTP.ModHex.decode!("jjnkec")
      <<0x88, 0xb9, 0x30>>
  """
  @spec decode!(string :: binary()) :: binary()
  def decode!(string) do
    string
      |> to_hex!
      |> Base.decode16!(case: :mixed)
  end

    @doc """
  Decodes the given modhex into a binary string.

  An `ArgumentError` exception is raised if the value is not modhex.

  ## Examples

      iex> YubikeyOTP.ModHex.decode("jjnkec")
      {:ok, <<0x88, 0xb9, 0x30>>}

      iex> YubikeyOTP.ModHex.decode("nope")
      :error
  """
  @spec decode(string :: binary()) :: {:ok, binary()} | :error
  def decode(string) do
    {:ok, decode!(string)}
  rescue
    ArgumentError -> :error
  end

  @doc """
  Converts the given hexadecimal string to modhex.

  An `ArgumentError` exception is raised if the value is not hex.

  ## Examples

      iex> YubikeyOTP.ModHex.hex_to_modhex!("88b930")
      "jjnkec"

      iex> YubikeyOTP.ModHex.hex_to_modhex!("88B930")
      "jjnkec"

  """
  @spec hex_to_modhex!(string :: binary()) :: binary()
  def hex_to_modhex!(string) do
    if hex?(string) do
      string
        |> String.downcase
        |> to_charlist
        |> Enum.map(fn i -> @hex_to_modhex_map[i] end)
        |> to_string
    else
      raise ArgumentError, "invalid hex: #{string}"
    end
  end

  @doc """
  Encodes the binary string to modhex.

  ## Examples

      iex> YubikeyOTP.ModHex.encode(<<0x88, 0xb9, 0x30>>)
      "jjnkec"
  """
  @spec encode(string :: binary()) :: binary()
  def encode(string) do
    string
      |> Base.encode16(case: :lower)
      |> hex_to_modhex!
  end
end
