defmodule Ollama do
  defstruct [:req]

  @default_http_options [
    base_url: "http://localhost:11434/api",
    receive_timeout: 60_000
  ]

  @type response() :: {:ok, map()} | {:error, term()}
  @type http_response() :: {:ok, Req.Response.t()} | {:error, term()}

  @type http_client() :: %__MODULE__{req: Req.Request.t()}

  @spec init(Req.url() | keyword()) :: http_client()
  def init(opts \\ [])

  def init(url) when is_binary(url), do: struct(__MODULE__, req: init_req(base_url: url))
  def init(opts) when is_list(opts), do: struct(__MODULE__, req: init_req(opts))

  @spec init_req(keyword()) :: Req.Request.t()
  defp init_req(opts) do
    @default_http_options
    |> Keyword.merge(opts)
    |> Req.new()
  end

  @spec chat(http_client(), keyword()) :: response()

  @chat_message_schema [
    role: [
      type: {:in, ["user", "assistant", "system", "tool"]},
      required: true,
      doc: "The role of the message."
    ],
    content: [
      type: :string,
      required: true,
      doc: "The content of the message."
    ]
  ]

  @chat_schema [
    model: [
      type: :string,
      required: true,
      doc: "The ollama model to use for the chat."
    ],
    messages: [
      type: {:list, {:map, @chat_message_schema}},
      required: true,
      doc: "The messages of the chat, this can be used to keep a chat memory."
    ],
    format: [
      type: {:or, [:string, :map]},
      doc: "The format to return a response in. Format can be json or a JSON schema."
    ],
    stream: [
      type: :boolean,
      default: false,
      doc: "Wether to stream the response or not."
    ],
    keep_alive: [
      type: {:or, [:string, :integer]},
      doc: "Controls how long the model will stay loaded into memory following the request."
    ],
    options: [
      type: :map,
      doc: "Additional model parameters."
    ]
  ]

  def chat(%__MODULE__{} = client, opts) when is_list(opts) do
    # todo: implement images
    # todo: implement tools
    with {:ok, opts} <- NimbleOptions.validate(opts, @chat_schema) do
      client
      |> make_request(:post, "/chat", Enum.into(opts, %{}))
      |> handle_response()
    end
  end

  @spec make_request(http_client(), atom(), Req.url(), keyword()) :: response()
  defp make_request(%__MODULE__{req: req}, method, url, opts) do
    Req.request(req, method: method, url: url, json: Enum.into(opts, %{}))
  end

  @spec handle_response(http_response()) :: response()
  # todo: handle streaming
  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299,
    do: {:ok, body}

  defp handle_response({:ok, %{status: status}}), do: {:error, status}
  defp handle_response({:error, reason}), do: {:error, reason}
end
