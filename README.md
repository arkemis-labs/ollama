# Ollama

This is a simple Elixir wrapper around the Ollama API.

# Usage

Initialize the client.

```elixir
client = Ollama.init()
```

## Generate

```elixir
Ollama.generate(client, [
  model: "llama3.2",
  prompt: "Who is Luke Skywalker?"
])
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
