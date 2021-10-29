defmodule Bacen.CCS.Message do
  @moduledoc """
  The base message from CCS messages.

  This part of a XML is required to any message,
  requested or received from Bacen's system.

  This message has the following XML example:

  ```xml
  <?xml version="1.0"?>
  <CCSDOC>
    <BCARQ>
      <IdentdEmissor>12345678</IdentdEmissor>
      <IdentdDestinatario>87654321</IdentdDestinatario>
      <NomArq>ACCS001</NomArq>
      <NumRemessaArq>000000000000</NumRemessaArq>
    </BCARQ>
    <SISARQ>
      <!-- Any ACCS/CCS messsage here -->
    </SISARQ>
  </CCSDOC>
  ```

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Bacen.CCS.MessageBody

  @typedoc """
  The base message from CCS
  """
  @type t :: %__MODULE__{}

  @message_fields ~w(body)a

  @header_fields ~w(issuer_id recipient_id file_name file_id)a
  @header_fields_source_sequence ~w(IdentdEmissor IdentdDestinatario NomArq NumRemessaArq)a

  @primary_key false
  embedded_schema do
    embeds_one :message, BaseMessage, source: :CCSDOC, primary_key: false do
      embeds_one :header, Header, source: :BCARQ, primary_key: false do
        field :issuer_id, :string, source: :IdentdEmissor
        field :recipient_id, :string, source: :IdentdDestinatario
        field :file_name, :string, source: :NomArq
        field :file_id, :string, source: :NumRemessaArq
      end

      field :body, MessageBody, source: :SISARQ
    end
  end

  @doc """
  Creates a new CCS message from given attributes.
  """
  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    attrs
    |> changeset()
    |> apply_action(:insert)
  end

  @doc false
  def changeset(schema \\ %__MODULE__{}, attrs) when is_map(attrs) do
    schema
    |> cast(attrs, [])
    |> cast_embed(:message, with: &message_changeset/2, required: true)
  end

  @doc false
  def message_changeset(message, attrs) when is_map(attrs) do
    message
    |> cast(attrs, @message_fields)
    |> cast_embed(:header, with: &header_changeset/2, required: true)
    |> validate_required(@message_fields)
  end

  @doc false
  def header_changeset(header, attrs) when is_map(attrs) do
    header
    |> cast(attrs, @header_fields)
    |> validate_required(@header_fields)
    |> validate_length(:issuer_id, is: 8)
    |> validate_format(:issuer_id, ~r/[0-9]{8}/)
    |> validate_length(:recipient_id, is: 8)
    |> validate_format(:recipient_id, ~r/[0-9]{8}/)
    |> validate_length(:file_id, is: 12)
    |> validate_format(:file_id, ~r/[0-9]{12}/)
    |> validate_length(:file_name, max: 80)
  end

  @doc """
  Returns the field sequence for given root xml element

  ## Examples

      iex> Bacen.CCS.Message.sequence(:BCARQ)
      [:IdentdEmissor, :IdentdDestinatario, :NomArq, :NumRemessaArq]

  """
  @spec sequence(:BCARQ) :: list(atom())
  def sequence(:BCARQ), do: @header_fields_source_sequence

  @doc """
  Returns the module name from `BaseMessage` body

  ## Examples

      iex> alias Bacen.CCS.Message
      iex> alias Bacen.CCS.ACCS002
      iex> message = %Message{message: %Message.BaseMessage{body: %ACCS002{}}}
      iex> Message.get_schema_from_body(message)
      Bacen.CCS.ACCS002

  """
  @spec get_schema_from_body(t()) :: Bacen.CCS.schemas()
  def get_schema_from_body(%__MODULE__{message: %__MODULE__.BaseMessage{body: %module{}}}),
    do: module
end
