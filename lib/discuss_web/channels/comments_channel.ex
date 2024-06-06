defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel

  import Ecto
  alias Discuss.Repo
  alias DiscussWeb.Topic
  alias DiscussWeb.Comment



  def join("comments:" <> topic_id, _message, socket) do

    topic_id = String.to_integer(topic_id)
    topic = Topic
            |> Repo.get(topic_id)
            |> Repo.preload(comments: [:user])

    #assign is used to propagate the topic, so handle_in can use it
    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}

  end

  def handle_in(_name, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset = topic
                |> build_assoc(:comments, user_id: user_id)
                |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        # Preload the user association
        comment = Repo.preload(comment, :user)
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

end
