defmodule ElixirRabbit.Consumer do
  @moduledoc """
    Minimal single queue consumer.
  """

  use GenServer
  require Logger
  alias AMQP.{Connection, Channel, Basic, Queue}

  @type opts :: [
          {:url, String.t()},
          {:queue, String.t()},
          {:handler, (binary -> :ack | {:nack, boolean})},
          {:prefetch, pos_integer}
        ]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def init(opts) do
    url = Keyword.get(opts, :url, "amqp://guest:guest@localhost")
    queue = Keyword.fetch!(opts, :queue)
    handler = Keyword.fetch!(opts, :handler)
    prefetch = Keyword.get(opts, :prefetch, 10)

    {:ok, conn} = Connection.open(url)
    {:ok, chan} = Channel.open(conn)
    :ok = Basic.qos(chan, prefect_count: prefetch)

    {:ok, _} =
      Queue.declare(chan, queue,
        durable: true,
        arguments: [
          {"x-queue-type", :longstr, "quorum"}
        ]
      )

    {:ok, _tag} = Basic.consume(chan, queue, nil, no_ack: false)
    state = %{conn: conn, chan: chan, queue: queue, handler: handler}
    {:ok, state}
  end

  @impl true
  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag}},
        %{chan: chan, handler: handler} = state
      ) do
    result =
      try do
        handler.(payload)
      rescue
        e ->
          Logger.error("Handler crashed: #{Exception.message(e)}")
          {:nack, false}
      end

    case result do
      :ok ->
        Basic.ack(chan, tag)

      {:nack, reenqueue?} ->
        Basic.reject(chan, tag, reenqueue: reenqueue?)

      :ack ->
        :ack

      other ->
        Logger.warn("Handler returned unexpected #{inspect(other)} - rejecting without reenqueu")
        Basic.reject(chan, tag, reenqueue: false)
    end

    {:noreply, state}
  end

  def handle_info({:basic_cancel, _}, state), do: {:stop, :cancelled, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}
  def handle_info({:basic_consume_ok, _}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, %{chan: chan, conn: conn}) do
    if Process.alive?(self()) do
      :ok = Channel.close(chan)
      :ok = Connection.close(conn)
    end

    :ok
  end
end
