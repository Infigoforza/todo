defmodule Todo.OverviewFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todo.Overview` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~U[2023-10-30 18:58:00Z],
        state: "some state",
        title: "some title"
      })
      |> Todo.Overview.create_task()

    task
  end
end
