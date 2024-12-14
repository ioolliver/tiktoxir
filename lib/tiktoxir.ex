defmodule Tiktoxir do

  defp normalize(username) do
    username
    |> String.replace("@", "")
    |> String.replace("https://www.tiktok.com/", "")
    |> String.replace("/live", "")
  end

  defp default_headers() do
    [
      {"Connection", "keep-alive"},
      {"Cache-Control", "max-age=0"},
      {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"},
      {"Accept", "text/html,application/json,application/protobuf"},
      {"Referer", "https://www.tiktok.com/"},
      {"Origin", "https://www.tiktok.com"},
      {"Accept-Language", "en-US,en;q=0.9"},
      {"Accept-Encoding", "gzip, deflate"}
    ]
  end

  defp read_live_status(2), do: true
  defp read_live_status(_), do: false

  defp is_streamer(nil), do: {:error, :notstreamer}
  defp is_streamer(data) do
    user = data["liveRoomUserInfo"]["user"]
    live = data["liveRoomUserInfo"]["liveRoom"]
    follow_state = data["liveRoomUserInfo"]["stats"]
    {:ok, %{
      room_id: Map.get(user, "roomId"),
      nickname: Map.get(user, "nickname"),
      is_verified: Map.get(user, "verified"),
      unique_id: Map.get(user, "uniqueId"),
      bio: Map.get(user, "signature"),
      title: Map.get(live, "title"),
      followers: Map.get(follow_state, "followerCount"),
      following: Map.get(follow_state, "followingCount"),
      is_live_online: Map.get(user, "status") |> read_live_status,
    }}
  end

  defp filter_info(data) do
    data["LiveRoom"]
    |> is_streamer()
  end

  defp get_stream_info(content) do
      Floki.parse_document!(content)
      |> Floki.find("#SIGI_STATE")
      |> List.first()
      |> elem(2)
      |> Jason.decode!()
      |> filter_info()
  end

  defp get_info(username) do
    request = Req.get!("https://www.tiktok.com/@#{username}/live", headers: default_headers())
    request.body
    |> get_stream_info()
  end

  def connect(username) do
    username
    |> normalize()
    |> get_info()
  end
end
