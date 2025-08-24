# ElixirRabbit WORK IN PROGRESS

A __Work In Progress__ elixir implementation of https://github.com/CoinifySoftware/node-rabbitmq while learning elixir.
Will not be usable until we are at version 1.0.0

## Progress
- [x] Basic publisher/consumer
- [ ] Multiple  consumers
- [ ] JSON payload
- [ ] Long lived publisher connection
- [ ] multiple exchanges
- [ ] retries, and failed

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_rabbit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_rabbit, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_rabbit>
