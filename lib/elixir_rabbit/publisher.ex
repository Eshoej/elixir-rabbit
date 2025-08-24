defmodule(ElixirRabbit.Publisher) do
  @moduledoc """
  Minimal publisher for learning. Open a publisher per call"
  """

  alias AMQP.{Connection, Channel, Basic}

  @type url :: String.t()
  @type exchange :: String.t()
  @type routing_key :: String.t()
  @type payload :: iodata()

  @doc """
  Publish `payload` to `exchange` using `routing_key`.

  For the *default exchange* ("") the routing key shoud be the queue name.
  """
  @spec publish(exchange, routing_key, payload, keyword) :: :ok | {:error, term()}
  def publish(exchange, routing_key, payload, opts \\ []) do
    url = Keyword.get(opts, :url, "amqp://guest:guest@localhost")

    with {:ok, conn} <- Connection.open(url),
         {:ok, chan} <- Channel.open(conn),
         :ok <- Basic.publish(chan, exchange, routing_key, payload, persistent: true) do
      Channel.close(chan)
      Connection.close(conn)
      :ok
    else
      # {:error, reason} -> err ->
      {:error, _} = err ->
        err
    end
  end
end
