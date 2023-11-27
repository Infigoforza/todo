defmodule TodoWeb.TaskLive.Index do
  alias TodoWeb.Endpoint

  use TodoWeb, :live_view

  alias Todo.Overview
  alias Todo.Overview.Task

  @topic "tasks:all"
  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: Endpoint.subscribe(@topic)

    updates_socket =
      socket
      |> assign(search: params["search"] || "", per_page: 20, page: 1)
      |> paginate_tasks(1)

    {:ok, updates_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, Overview.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_info({TodoWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    Endpoint.broadcast(@topic, "new_task", %{task: task})
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: @topic, payload: %{task: task}}, socket) do
    {:noreply, stream_insert(socket, :tasks, task)}
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:noreply,
     socket
     |> assign(:search, search)
     |> paginate_tasks(1, true)
     |> push_patch(to: ~p"/tasks?#{[search: search]}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Overview.get_task!(id)
    {:ok, _} = Overview.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  def handle_event("next-page", _, socket) do
    {:noreply, paginate_tasks(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_tasks(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_tasks(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  defp paginate_tasks(socket, new_page, reset \\ false) when new_page >= 1 do
    %{per_page: per_page, page: cur_page, search: search} = socket.assigns

    tasks =
      Overview.list_tasks(offset: (new_page - 1) * per_page, limit: per_page, search: search)

    {tasks, at, limit} =
      if new_page >= cur_page do
        {tasks, -1, per_page * 3 * -1}
      else
        {Enum.reverse(tasks), 0, per_page * 3}
      end

    case tasks do
      [] ->
        assign(socket, end_of_table?: at == -1)
        |> stream(:tasks, [], reset: true)

      [_ | _] = tasks ->
        socket
        |> assign(end_of_table?: false, page: new_page)
        |> stream(:tasks, tasks, at: at, limit: limit, reset: reset)
    end
  end
end
