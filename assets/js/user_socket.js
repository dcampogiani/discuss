import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

const createSocket = (topicId) => {
	let channel = socket.channel(`comments:${topicId}`, {});

	channel
		.join()
		.receive("ok", (resp) => {
            renderListOfComments(resp.comments)
		})
		.receive("error", (resp) => {
			console.log("Error while joining channel", resp);
		});

	channel.on(`comments:${topicId}:new`, renderComment)

	const button = document.querySelector("button#click-btn");
	button.addEventListener("click", () => {
	    const content = document.querySelector("textarea").value;
	    channel.push("comment:add", { content: content });
	    });
};

const renderListOfComments = (comments) => {
  const renderedComments = comments.map(comment => {
    return commentTemplate(comment)
  });
  document.querySelector('.collection').innerHTML = renderedComments.join("")
}

const renderComment = (event) => {
  const renderedComment = commentTemplate(event.comment)
  document.querySelector('.collection').innerHTML += renderedComment;
}

const commentTemplate = (comment) => {
  let email = 'Anonymous'
  if (comment.user) {
    email = comment.user.email
  }
  return `
  <li class="collection-item">
  ${comment.content}
  <div class="secondary-content">
  ${email}
  </div>
  </li>
  `;
}

window.createSocket = createSocket;

export default socket
