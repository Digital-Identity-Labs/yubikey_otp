defmodule YubikeyOTP.Nonce do
  @moduledoc false

  use Puid, charset: :alphanum

  ## All the work is done by the Puid library - it provides a .generate() method
  @spec generate() :: binary()
  
end
