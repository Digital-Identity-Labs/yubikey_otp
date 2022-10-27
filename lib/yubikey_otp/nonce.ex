defmodule YubikeyOTP.Nonce do
  @moduledoc false

  use Puid, chars: :alphanum

  ## All the work is done by the Puid library - it provides a .generate() method
  @spec generate() :: binary()
  
end
