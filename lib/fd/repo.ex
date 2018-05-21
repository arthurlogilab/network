defmodule Fd.Repo do
  use Ecto.Repo, otp_app: :fd

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  defmodule Instrumenter do
    use Prometheus.EctoInstrumenter
  end
end
