defmodule Bacen.CCS.ACCS002 do
  @moduledoc """
  The ACCS002 message.

  This message is a response from ACCS001 message.

  It has the following XML example:

  ```xml
  <CCSArqAtlzDiariaRespArq>
    <SitArq>R</SitArq>
    <ErroCCS>ECCS0023</ErroCCS>
    <UltNumRemessaArq>000000000000</UltNumRemessaArq>
    <DtHrBC>2004-06-16T05:04:00</DtHrBC>
    <DtMovto>2004-06-16</DtMovto>
  </CCSArqAtlzDiariaRespArq>
  ```

  """
  use Ecto.Schema

  import Ecto.Changeset

  @typedoc """
  The ACCS002 message type
  """
  @type t :: %__MODULE__{}

  @response_fields ~w(last_file_id status error reference_date movement_date)a
  @response_required_fields ~w(last_file_id status reference_date movement_date)a
  @response_fields_source_sequence ~w(SitArq ErroCCS UltNumRemessaArq DtHrBC DtMovto)a

  @allowed_status ~w(R A)

  @primary_key false
  embedded_schema do
    embeds_one :response, Response, source: :CCSArqAtlzDiariaRespArq, primary_key: false do
      field :last_file_id, :string, source: :UltNumRemessaArq
      field :status, :string, source: :SitArq
      field :error, :string, source: :ErroCCS
      field :reference_date, :utc_datetime, source: :DtHrBC
      field :movement_date, :date, source: :DtMovto
    end
  end

  @doc """
  Creates a new ACCS002 message from given attributes.
  """
  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    attrs
    |> changeset()
    |> apply_action(:insert)
  end

  @doc false
  def changeset(accs002 \\ %__MODULE__{}, attrs) when is_map(attrs) do
    accs002
    |> cast(attrs, [])
    |> cast_embed(:response, with: &response_changeset/2, required: true)
  end

  @doc false
  def response_changeset(response, attrs) when is_map(attrs) do
    response
    |> cast(attrs, @response_fields)
    |> validate_required(@response_required_fields)
    |> validate_inclusion(:status, @allowed_status)
    |> validate_length(:status, is: 1)
    |> validate_length(:last_file_id, is: 12)
    |> validate_format(:last_file_id, ~r/[0-9]{12}/)
    |> validate_by_status()
  end

  defp validate_by_status(changeset) do
    case get_field(changeset, :status) do
      "R" ->
        changeset
        |> validate_required([:error])
        |> validate_length(:error, is: 8)
        |> validate_format(:error, ~r/E[A-Z]{3}[0-9]{4}/)

      _ ->
        changeset
    end
  end

  @doc """
  Returns the field sequence for given root xml element

  ## Examples

      iex> Bacen.CCS.ACCS002.sequence(:CCSArqAtlzDiariaRespArq)
      [:SitArq, :ErroCCS, :UltNumRemessaArq, :DtHrBC, :DtMovto]

  """
  @spec sequence(:CCSArqAtlzDiariaRespArq) :: list(atom())
  def sequence(:CCSArqAtlzDiariaRespArq), do: @response_fields_source_sequence
end
