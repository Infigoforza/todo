defmodule Todo.OverviewTest do
  use Todo.DataCase

  alias Todo.Overview

  describe "tasks" do
    alias Todo.Overview.Task

    import Todo.OverviewFixtures

    @invalid_attrs %{state: nil, description: nil, title: nil, due_date: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Overview.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Overview.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{state: "some state", description: "some description", title: "some title", due_date: ~U[2023-10-30 18:58:00Z]}

      assert {:ok, %Task{} = task} = Overview.create_task(valid_attrs)
      assert task.state == "some state"
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.due_date == ~U[2023-10-30 18:58:00Z]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Overview.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{state: "some updated state", description: "some updated description", title: "some updated title", due_date: ~U[2023-10-31 18:58:00Z]}

      assert {:ok, %Task{} = task} = Overview.update_task(task, update_attrs)
      assert task.state == "some updated state"
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.due_date == ~U[2023-10-31 18:58:00Z]
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Overview.update_task(task, @invalid_attrs)
      assert task == Overview.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Overview.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Overview.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Overview.change_task(task)
    end
  end
end
