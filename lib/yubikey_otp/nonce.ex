defmodule YubikeyOTP.Nonce do
  @moduledoc false

  ## All the work is done by the Puid library - it provides a .generate() method
  use Puid, charset: :alphanum

end
