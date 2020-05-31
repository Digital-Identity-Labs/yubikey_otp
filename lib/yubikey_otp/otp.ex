defmodule YubikeyOTP.OTP do
  @moduledoc """
  ## OTP Format
  The format of the OTP is documented in:

  https://developers.yubico.com/OTP/OTPs_Explained.html
  """

  alias YubikeyOTP.CRC
  alias YubikeyOTP.ModHex
  alias YubikeyOTP.OTP

  @type t :: %__MODULE__{
    public_id: binary(),
    prefix: nil | binary(),
    serial: nil | integer(),
    encrypted_otp: binary(),
    private_id: nil | binary(),
    use_counter: nil | binary(),
    timestamp: integer(),
    session_counter: nil | binary(),
    random: nil | binary(),
    checksum: nil | binary()
  }

  @otp_length 44
  @key_format_error "Error parsing key. Key should be 128-bits stored as a 16 byte binary (preferred) or 32 character hex string"

  defmacrop is_otp(string) do
    quote do
      is_binary(unquote(string)) and byte_size(unquote(string)) == @otp_length
    end
  end

  defstruct [
    :public_id,
    :prefix,
    :serial,
    :encrypted_otp,
    :private_id,
    :use_counter,
    :timestamp,
    :session_counter,
    :random,
    :checksum
  ]

  @spec device_id(otp :: binary()) :: {:ok, binary()} | {:error, :otp_invalid}
  def device_id(otp) do
    with {:ok, parsed} <- parse(otp) do
      {:ok, parsed.public_id}
    else
      _ -> {:error, :otp_invalid}
    end
  end

  @spec validate(otp :: binary()) :: {:ok, binary()} | {:error, :otp_invalid}
  def validate(otp, opts \\ [])

  def validate(otp, opts) when is_otp(otp) do
    with {:ok, _} <- parse(otp, opts) do
      {:ok, otp}
    else
      _ -> {:error, :otp_invalid}
    end
  end

  def validate(_otp, _opts), do: {:error, :otp_invalid}

  @doc """
  Parses an OTP into an OTP struct.

  Without the encryption key, only the `public_id`, 'prefix`, `serial` and
  `encrypted_otp` fields are hydrated.

  ## Options
    * `:key` - provides the 128 bit AES key to decrypt the OTP and load the
      remaining fields. As part of decryption, the OTP checksum is verified.
    * `:skip_checksum` - whether to skip verifying the checksum after decrypting
      the OTP with the provided `key`.

  ## Examples

      iex> YubikeyOTP.OTP.parse("ccccccclulvjbbhccnndrietjjnkeclcvjgrnhcivtgd")
      {:ok,
        %YubikeyOTP.OTP{
          public_id: "ccccccclulvj",
          prefix: "cccccc",
          serial: 715512,
          encrypted_otp: "bbhccnndrietjjnkeclcvjgrnhcivtgd"
        }
      }

      iex> YubikeyOTP.OTP.parse("nope")
      :error
  """
  @spec parse(otp :: binary()) :: {:ok, YubikeyOTP.OTP.t()} | :error
  def parse(otp, opts \\ []) do
    {:ok, parse!(otp, opts)}
  rescue
    _ -> :error
  end

  @doc """
  Like `parse`, but returns the OTP struct directly, and throws exceptions when
  errors are encountered (to permit specific handling, if desired).

  ## Exceptions
    * `OTP.ParseError` - raised when the OTP cannot be successfully parsed with
      the given options.
    * `OTP.InvalidChecksumError` - raised when the checksum of the OTP does not
      validate.

  ## Examples

  Without specifying a decryption key, only the public information can be hydrated.

    iex> YubikeyOTP.OTP.parse!("ccccccclulvjbbhccnndrietjjnkeclcvjgrnhcivtgd")
    %YubikeyOTP.OTP{
      public_id: "ccccccclulvj",
      prefix: "cccccc",
      serial: 715512,
      encrypted_otp: "bbhccnndrietjjnkeclcvjgrnhcivtgd"
    }

  Specifying a decryption key, but skipping the checksum verification will
  hydrate the data even with a "bad" decryption.

    iex> YubikeyOTP.OTP.parse!("ccccccclulvjbbhccnndrietjjnkeclcvjgrnhcivtgd", key: "1111111111111111", skip_checksum: true)
    %YubikeyOTP.OTP{
      public_id: "ccccccclulvj",
      prefix: "cccccc",
      serial: 715512,
      encrypted_otp: "bbhccnndrietjjnkeclcvjgrnhcivtgd",
      private_id: <<68, 48, 254, 248, 123, 61>>,
      use_counter: 49442,
      timestamp: 4703963,
      session_counter: 150,
      random: "Xn",
      checksum: <<1, 15>>
    }

    Decrypting the token successfully will hydrate all fields.

    iex> YubikeyOTP.OTP.parse!("ccccccclulvjhnblleegivrcjlvvtvujejbclrdjdgvk", key: "1111111111111111")
    %YubikeyOTP.OTP{
      public_id: "ccccccclulvj",
      prefix: "cccccc",
      serial: 715512,
      encrypted_otp: "hnblleegivrcjlvvtvujejbclrdjdgvk",
      private_id: "111111",
      use_counter: 0,
      timestamp: 8002816,
      session_counter: 0,
      random: <<64, 22>>,
      checksum: <<44, 51>>
    }

    Errors will be thrown when the checksum is invalid, an invalid key is
    provided, or an invalid token is provided.

    iex> YubikeyOTP.OTP.parse!("ccccccclulvjbbhccnndrietjjnkeclcvjgrnhcivtgd", key: "1111111111111111")
    ** (YubikeyOTP.OTP.InvalidChecksumError) OTP checksum is invalid

    iex> YubikeyOTP.OTP.parse!("nope")
    ** (YubikeyOTP.OTP.ParseError) OTP parsing failed
  """
  @spec parse!(otp :: binary(), opts :: keyword()) :: YubikeyOTP.OTP.t()
  def parse!(otp, opts \\ [])
  def parse!(<<
    prefix :: binary-size(6),
    serial:: binary-size(6),
    encrypted_otp :: binary-size(32)
    >>,  opts) when is_otp(prefix <> serial <> encrypted_otp)
  do
    decoded_serial = ModHex.decode!(serial)
    otp = %OTP{
      public_id: prefix <> serial,
      prefix: prefix,
      serial: decoded_serial |> :binary.decode_unsigned,
      encrypted_otp: encrypted_otp
    }
    if Keyword.get(opts, :key), do: do_parse!(otp, opts), else: otp
  end
  def parse!(_otp, _opts), do: raise OTP.ParseError

  defp do_parse!(otp, opts) do
    with decoded_otp <- ModHex.decode!(otp.encrypted_otp),
         key <- Keyword.fetch!(opts, :key),
         key <- format_key(key),
         <<
           private_id :: binary-size(6),
           use_counter :: binary-size(2),
           timestamp :: binary-size(3),
           session_counter :: binary-size(1),
           random :: binary-size(2),
           checksum :: binary-size(2)
         >> <- :crypto.crypto_one_time(:aes_128_ecb, key, decoded_otp, false)
    do
      unless Keyword.get(opts, :skip_checksum) do
        decrypted_otp = private_id <> use_counter <> timestamp <> session_counter <> random <> checksum
        unless CRC.verify_crc16(decrypted_otp), do: raise OTP.InvalidChecksumError
      end
      %{otp |
        private_id: private_id,
        use_counter: use_counter |> :binary.decode_unsigned,
        timestamp: timestamp |> :binary.decode_unsigned,
        session_counter: session_counter |> :binary.decode_unsigned,
        random: random,
        checksum: checksum
      }
    else
      result -> raise OTP.ParseError, "Error parsing OTP: #{result}"
    end
  rescue
    e in ErlangError -> reraise OTP.ParseError, ErlangError.message(e), __STACKTRACE__
  end


  defp format_key(key) when is_binary(key) and byte_size(key) == 32 do
    case Base.decode16(String.downcase(key), case: :lower) do
      {:ok, key} -> key
      _ -> raise raise OTP.ParseError, @key_format_error
    end
  end

  defp format_key(key)
       when is_binary(key) and byte_size(key) == 16 do
    key
  end

  defp format_key(_) do
    raise raise OTP.ParseError, @key_format_error
  end

end
