# Start the consumer
{:ok, _pid} =
  ElixirRabbit.Consumer.start_link(
    queue: "demo.queue",
    handler: fn payload ->
      IO.inspect(payload, label: "received")
      :ack
    end
  )

# Publish something (default exchange "" routes to the queue by name)
ElixirRabbit.Publisher.publish("", "demo.queue", "hello from publisher")

