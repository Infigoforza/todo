defmodule Todo.Overview.Task do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :state, Ecto.Enum, values: [:open, :in_progress, :on_hold, :done]
    field :description, :string
    field :title, :string
    field :due_date, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :state, :due_date])
    |> validate_required([:title, :description, :state])
  end
end
