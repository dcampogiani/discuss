defmodule DiscussWeb.CommentsChannelTest do
  use DiscussWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      DiscussWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(DiscussWeb.CommentsChannel, "comments:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to comments:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
