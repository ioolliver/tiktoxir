defmodule TiktoxirTest do
  use ExUnit.Case
  doctest Tiktoxir

  test "normalize tiktok username" do
    username = "greettiktoker"
    assert Tiktoxir.connect(username) == "greettiktoker"
    username = "@greettiktoker"
    assert Tiktoxir.connect(username) == "greettiktoker"
    username = "https://www.tiktok.com/@greettiktoker/live"
    assert Tiktoxir.connect(username) == "greettiktoker"
    username = "https://www.tiktok.com/@greettiktoker"
    assert Tiktoxir.connect(username) == "greettiktoker"
  end
end
