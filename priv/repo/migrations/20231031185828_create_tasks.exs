defmodule Todo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :state, :string
      add :due_date, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
