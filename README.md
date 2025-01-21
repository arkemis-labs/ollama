# Ollama

This is a simple Elixir wrapper around the Ollama API.

# Usage

Initialize the client.

```elixir
client = Ollama.init()
```

## Chat

```elixir
Ollama.chat(client, [
  model: "llama3.2",
  messages: [
    %{role: "system", content: "You are a helpful assistant."},
    %{role: "user", content: "Who is Luke Skywalker?"},
  ]
])
```


# License

MIT
