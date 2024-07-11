# Discuss

To start your Phoenix server:

  * Run `mix deps.get` to install dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000/topics`](http://localhost:4000) from your browser.

## Learn more

  * Course: https://www.udemy.com/course/the-complete-elixir-and-phoenix-bootcamp-and-tutorial/
  * Repo I've used to see implementation using latest Phoenix version: https://github.com/tfnielson-se/elixir-phoenix-udemy
  * Official website: https://www.phoenixframework.org/

## [Initial Commit:](https://github.com/dcampogiani/discuss/commit/265d06c1e0931a814110b29fb9c8076b74d3be6b)
- This is mainly done running `mix phoenix.new discuss`
- It will scaffold the project, creating a basic [configuration](config) for things like username and password for the database
- It will also create a basic web UI, and a sample page controller with associated view

## [Topic CRUD and web UI:](https://github.com/dcampogiani/discuss/commit/cb0dffe1c85ab6111f8443d37110b4f72580be35)

### Setup
- You need to run `mix ecto.create`: it will create the database using the parameters inside [config](config) folder. [Ecto](https://github.com/elixir-ecto/ecto)  is a toolkit for data mapping and language integrated query for Elixir. You can see it as a wrapper for the database
- Then with `mix ecto.gen.migration add_topics` you will create the [first migration](priv/repo/migrations/20240307142659_add_topics.exs). A migration file is used to define changes to the database schema, such as creating or altering tables, adding or removing columns, and other modifications
- Running `mix ecto.migrate` will actually mutate the database structure

### Create Topic Model
- Create [`Topic Model`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/models/topics.ex#L1) file. We just need a title String, the `changeset` fun is _"boilerplate"_ to validate data before inserting into database, we receive a basic struct and we validate it

### Index (List of Topics)
- In the router define the entry [`get "/", TopicController, :index`.](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L20) This will invoke the fun `index` of `TopicController` everytime you receive a GET request at `/` path
- Create the [`TopicController`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L1). For the [`index`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L7) fun the controller gets all the Topics using Repo (from Ecto) and passes them to a view. `render` is the function to render a given view, with parameters. Here the view is `:index`, so it will load [`lib/discuss_web/controllers/topic_html/index.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/index.html.heex#L1) and we pass all the topics
- The view will use some special markup provided by phoenix to render a header, an action and a table. Using `~p"/topics/...` urls are validated at compile time to avoid errors

### New (Create a new Topic)
- In the router define the controller and the method get similar to what you already did [`"get /topics/new", TopicController, :new`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L21)
- The controller creates an empty changeset and passes to the new view [`lib/discuss_web/controllers/topic_html/new.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/new.html.heex#L1). Inside this view you'll use `<.topic_form />` markup. In [`lib/discuss_web/controllers/topic_html.ex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html.ex#L1) there is the definition, it will require an Ecto ChangeSet and an action. In [`lib/discuss_web/controllers/topic_html/topic_form.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/topic_form.html.heex#L1) there is the implementation using special Phoenix markup for forms
- Back to [`lib/discuss_web/controllers/topic_html/new.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/new.html.heex#L1) you'll pass the changesed you got from the controller, and specify `~p"/topics"` as action. This will be mapped into a post request to `/topics`. You'll map this new route as always, specifying [`post "/topics", TopicController, :create`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L22) into the router. Inside `TopicController` [`create`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L18) you build a ChangeSet based on the data in the body of the HTTP post request,extracted with pattern matching , then use Ecto Repo to insert in the database. If this is successful the user will be redirected to the index, otherwise the page will be reloaded, passing the changeset with errors, so the user can see them

### Edit (Update a Topic)
- In the router define the controller and the method [`get "/topics/:id/edit", TopicController, :edit`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L23). In the [controller](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L30) load the given Topic, extracting the id with pattern matching, and create a changeset to pass to the view. In the view [`lib/discuss_web/controllers/topic_html/edit.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/edit.html.heex#L1) you reuse the `<.topic_form />` passing both the changeset and the action. This action will be mapped into a put request to `"/topics/:id"`
- Map this request in the router with [`put "/topics/:id", TopicController, :update`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L24). In the controller, inside [update](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L36) method you extract both the topic_id and the data submitted by the form thanks to pattern matching and create a changed merging old and new data, saving the result to the database.

### Delete (Remove a Topic)
- Back to [`lib/discuss_web/controllers/topic_html/index.html.heex`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_html/index.html.heex#L19) you added a link `href={~p"/topics/#{topic}"} method="delete"`. In this case instead of mapping a new individual route in the router you use [`resources "/", TopicController`](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/router.ex#L25), this will follow REST conventions and maps all the previous routes plus the `DELETE` one.
- The controller will [delete](https://github.com/dcampogiani/discuss/blob/cb0dffe1c85ab6111f8443d37110b4f72580be35/lib/discuss_web/controllers/topic_controller.ex#L50) the desired topic, extracting the id from the request

## [User Authentication:](https://github.com/dcampogiani/discuss/commit/c447f726951eb5ce16ca5a46d4f2400d1d802df2)

### Models
- `mix ecto.gen.migration add_users` terminal command will create [`priv/repo/migrations/20240329152151_add_users.exs`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/priv/repo/migrations/20240329152151_add_users.exs#L1) where you define the database data. `timestamps()` adds utilities such as last update.
- `mix ecto.gen.migration add_user_id_to_topics` creates [`priv/repo/migrations/20240405124213_add_user_id_to_topics.exs`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/priv/repo/migrations/20240405124213_add_user_id_to_topics.exs#L1) where you link each topic to a user
- `mix ecto.migrate` runs the migration and actually mutates the database structure
- As last step create and update our models: [`lib/discuss_web/models/user.ex`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/models/user.ex#L1) and [`lib/discuss_web/models/topics.ex`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/models/topics.ex#L7) using `has_many` and `belongs_to`. They are used by Ecto for relationship mapping

### Controller
- Add https://github.com/ueberauth/ueberauth to [`mix.exs`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/mix.exs#L63) dependencies, both `ueberauth` and `ueberauth_github`, and its configuration `config :ueberauth` in [`config.exs`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/config/config.exs#L77) (you need to create a GitHub application to get `client_id` and `client_secret`)
- Add sign-in and logout links to the header in [`lib/discuss_web/components/layouts/app.html.heex`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/components/layouts/app.html.heex#L19) (ignore `@conn.assigns[:user]` at the moment).
- Update the router to handle [`get "/signout"`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/router.ex#L32), [`get "/:provider"`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/router.ex#L33) and [`get "/:provider/callback"`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/router.ex#L34) delegating to [`AuthController`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/auth_controller.ex#L1)
- In the new AuthController, you are going to use [`plug Ueberauth`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/auth_controller.ex#L3) to delegate some part of the implementation to the library. Indeed, you do not have to implement `request` method, Ueberauth is doing it for you. [`signout`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/auth_controller.ex#L49) instead is pretty basic, just clear the session. In [`callback`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/auth_controller.ex#L8) you extract the result auth value using pattern matching, and create a User to save or update values in the database. The key is that you also update the session with the current user: `put_session(:user_id, user.id)`

### Plugs
- A plug is like an interceptor, executed for every request
- Let's start with [`DiscussWeb.Plugs.SetUser`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/plugs/set_user.ex#L1). You look for `:user_id` in the session, and you add the associated user to the `conn` object, so you always have the current logged user available. To "enable" this plug, set it up [in the `router`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/router.ex#L11)
- Define another plug, [`DiscussWeb.Plugs.RequireAuth`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/plugs/require_auth.ex#L1) that will redirect the user to the index, if not logged and use inside [`TopicController`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/topic_controller.ex#L8)
- Create another plug, this time directly inside [`TopicController`](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/topic_controller.ex#L9C9-L9C26) because it is the only user: `check_topic_owner`. This one will check if the requested topic was created by the logged user

### Final changes
- Now that a topic has an associated user, [when creating it](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/topic_controller.ex#L23) we must associate the current logged user with `build_assoc`. This is used by Ecto to manage relationships
- Now you can update some links ([1](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/components/layouts/app.html.heex#L18), [2](https://github.com/dcampogiani/discuss/blob/c447f726951eb5ce16ca5a46d4f2400d1d802df2/lib/discuss_web/controllers/topic_html/index.html.heex#L18)) checking the user in the session








