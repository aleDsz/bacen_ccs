defmodule Bacen.CCS.ACCS004 do
  @moduledoc """
  The ACCS004 message.

  This message reports the actual persons
  registered on Bacen's system for given CNPJ company.

  It has the following XML example:

  ```xml
  <CCSArqPosCad>
    <Repet_ACCS004_Congl>
      <CNPJBasePart>12345678</CNPJBasePart>
    </Repet_ACCS004_Congl>
    <Repet_ACCS004_Pessoa>
      <Grupo_ACCS004_Pessoa>
        <TpPessoa>F</TpPessoa>
        <CNPJ_CPFPessoa>12345678901</CNPJ_CPFPessoa>
        <DtIni>2002-01-01</DtIni>
        <DtFim>2002-01-03</DtFim>
      </Grupo_ACCS004_Pessoa>
    </Repet_ACCS004_Pessoa>
    <DtMovto>2004-10-10</DtMovto>
  </CCSArqPosCad>
  ```

  """
  use Ecto.Schema

  import Brcpfcnpj.Changeset
  import Ecto.Changeset

  @typedoc """
  The ACCS004 message type
  """
  @type t :: %__MODULE__{}

  @registration_position_opts [source: :CCSArqPosCad, primary_key: false]
  @registration_position_fields ~w(movement_date)a
  @registration_position_fields_source_sequence ~w(Repet_ACCS004_Congl Repet_ACCS004_Pessoa QtdOpCCS DtHrBC DtMovto)a

  @participant_fields ~w(cnpj)a
  @participant_fields_source_sequence ~w(CNPJBasePart)a

  @persons_fields ~w(cnpj)a
  @persons_fields_source_sequence ~w(CNPJBasePart Grupo_ACCS004_Pessoa)a

  @person_fields ~w(type cpf_cnpj start_date end_date)a
  @person_required_fields ~w(type cpf_cnpj start_date)a
  @person_fields_source_sequence ~w(TpPessoa CNPJ_CPFPessoa DtIni DtFim)a

  @allowed_person_types ~w(F J)

  @primary_key false
  embedded_schema do
    embeds_one :registration_position, RegistrationPosition, @registration_position_opts do
      embeds_one :conglomerate, Conglomerate, source: :Repet_ACCS004_Congl, primary_key: false do
        embeds_many :participant, Participant, primary_key: false do
          field :cnpj, :string, source: :CNPJBasePart
        end
      end

      embeds_one :persons, Persons, source: :Repet_ACCS004_Pessoa, primary_key: false do
        embeds_many :person, Person, source: :Grupo_ACCS004_Pessoa, primary_key: false do
          field :type, :string, source: :TpPessoa
          field :cpf_cnpj, :string, source: :CNPJ_CPFPessoa
          field :start_date, :date, source: :DtIni
          field :end_date, :date, source: :DtFim
        end

        field :cnpj, :string, source: :CNPJBasePart
      end

      field :movement_date, :date, source: :DtMovto
    end
  end

  @doc """
  Creates a new ACCS004 message from given attributes.
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
    |> cast_embed(:registration_position, with: &registration_position_changeset/2, required: true)
  end

  @doc false
  def registration_position_changeset(registration_position, attrs) when is_map(attrs) do
    registration_position
    |> cast(attrs, @registration_position_fields)
    |> validate_required(@registration_position_fields)
    |> cast_embed(:conglomerate, with: &conglomerate_changeset/2, required: true)
    |> cast_embed(:persons, with: &persons_changeset/2, required: true)
  end

  @doc false
  def conglomerate_changeset(conglomerate, attrs) when is_map(attrs) do
    conglomerate
    |> cast(attrs, [])
    |> cast_embed(:participant, with: &participant_changeset/2, required: true)
  end

  @doc false
  def participant_changeset(participant, attrs) when is_map(attrs) do
    participant
    |> cast(attrs, @participant_fields)
    |> validate_required(@participant_fields)
    |> validate_length(:cnpj, is: 8)
    |> validate_format(:cnpj, ~r/[0-9]{8}/)
  end

  @doc false
  def persons_changeset(persons, attrs) when is_map(attrs) do
    persons
    |> cast(attrs, @persons_fields)
    |> validate_required(@persons_fields)
    |> validate_length(:cnpj, is: 8)
    |> validate_format(:cnpj, ~r/[0-9]{8}/)
    |> cast_embed(:person, with: &person_changeset/2, required: true)
  end

  @doc false
  def person_changeset(person, attrs) when is_map(attrs) do
    person
    |> cast(attrs, @person_fields)
    |> validate_required(@person_required_fields)
    |> validate_inclusion(:type, @allowed_person_types)
    |> validate_length(:type, is: 1)
    |> validate_by_type()
  end

  defp validate_by_type(changeset) do
    case get_field(changeset, :type) do
      "F" -> validate_cpf(changeset, :cpf_cnpj, message: "invalid CPF format")
      "J" -> validate_cnpj(changeset, :cpf_cnpj, message: "invalid CNPJ format")
      _ -> changeset
    end
  end

  @doc """
  Returns the field sequence for given root xml element

  ## Examples

      iex> Bacen.CCS.ACCS004.sequence(:CCSArqPosCad)
      [:Repet_ACCS004_Congl, :Repet_ACCS004_Pessoa, :QtdOpCCS, :DtHrBC, :DtMovto]

      iex> Bacen.CCS.ACCS004.sequence(:Repet_ACCS004_Congl)
      [:CNPJBasePart]

      iex> Bacen.CCS.ACCS004.sequence(:Repet_ACCS004_Pessoa)
      [:CNPJBasePart, :Grupo_ACCS004_Pessoa]

      iex> Bacen.CCS.ACCS004.sequence(:Grupo_ACCS004_Pessoa)
      [:TpPessoa, :CNPJ_CPFPessoa, :DtIni, :DtFim]

  """
  @spec sequence(
          :CCSArqPosCad
          | :Repet_ACCS004_Congl
          | :Repet_ACCS004_Pessoa
          | :Grupo_ACCS004_Pessoa
        ) ::
          list(atom())
  def sequence(element)

  def sequence(:CCSArqPosCad), do: @registration_position_fields_source_sequence
  def sequence(:Repet_ACCS004_Congl), do: @participant_fields_source_sequence
  def sequence(:Repet_ACCS004_Pessoa), do: @persons_fields_source_sequence
  def sequence(:Grupo_ACCS004_Pessoa), do: @person_fields_source_sequence
end
