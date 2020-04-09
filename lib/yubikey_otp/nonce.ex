defmodule YubikeyOTP.Nonce do
  @moduledoc false

  use Puid, charset: :alphanum
end
