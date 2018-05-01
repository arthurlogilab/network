defmodule Fd.ReleaseTasks do
  require Logger
  def migrate do
    {:ok, _} = Application.ensure_all_started(:fd)
    path = Application.app_dir(:fd, "priv/repo/migrations")
    Logger.warn "ReleaseTasks: running migrations"
    Ecto.Migrator.run(Fd.Repo, path, :up, all: true)
    Logger.warn "ReleaseTasks: migrations done."
  end
end
