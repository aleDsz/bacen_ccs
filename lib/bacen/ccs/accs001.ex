defmodule Bacen.CCS.ACCS001 do
  @moduledoc """
  The ACCS001 message.

  This message is responsible to register or deregister
  persons from CCS system.

  It has the following XML example:

  ```xml
  <CCSArqAtlzDiaria>
    <Repet_ACCS001_Pessoa>
      <Grupo_ACCS001_Pessoa>
        <TpOpCCS>I</TpOpCCS>
        <QualifdrOpCCS>N</QualifdrOpCCS>
        <TpPessoa>F</TpPessoa>
        <CNPJ_CPFPessoa>12345678901</CNPJ_CPFPessoa>
        <DtIni>2002-01-01</DtIni>
        <DtFim>2002-01-03</DtFim>
      </Grupo_ACCS001_Pessoa>
      <Grupo_ACCS001_Pessoa>
        <TpOpCCS>I</TpOpCCS>
        <QualifdrOpCCS>N</QualifdrOpCCS>
        <TpPessoa>F</TpPessoa>
        <CNPJ_CPFPessoa>98765432102</CNPJ_CPFPessoa>
        <DtIni>2002-02-01</DtIni>
      </Grupo_ACCS001_Pessoa>
    </Repet_ACCS001_Pessoa>
    <QtdOpCCS>2</QtdOpCCS>
    <DtMovto>2004-10-10</DtMovto>
  </CCSArqAtlzDiaria>
  ```

  """
  use Ecto.Schema

  import Brcpfcnpj.Changeset
  import Ecto.Changeset

  @typedoc """
  The ACCS001 type
  """
  @type t :: %__MODULE__{}

  @daily_update_fields ~w(quantity movement_date)a
  @daily_update_fields_source_sequence ~w(Repet_ACCS001_Pessoa QtdOpCCS DtMovto)a

  @persons_fields ~w(cnpj)a
  @persons_fields_source_sequence ~w(CNPJBasePart Grupo_ACCS001_Pessoa)a

  @person_fields ~w(
    operation_type operation_qualifier type
    cpf_cnpj start_date end_date
  )a

  @person_required_fields ~w(
    operation_type operation_qualifier type
    cpf_cnpj start_date
  )a

  @person_fields_source_sequence ~w(TpOpCCS QualifdrOpCCS TpPessoa CNPJ_CPFPessoa DtIni DtFim)a

  @allowed_operation_types ~w(E A I)
  @allowed_operation_qualifiers ~w(N P C L H E)
  @allowed_person_types ~w(F J)

  @primary_key false
  embedded_schema do
    embeds_one :daily_update, DailyUpdate, source: :CCSArqAtlzDiaria, primary_key: false do
      embeds_one :persons, Persons, source: :Repet_ACCS001_Pessoa, primary_key: false do
        embeds_many :person, Person, source: :Grupo_ACCS001_Pessoa, primary_key: false do
          field :operation_type, :string, source: :TpOpCCS
          field :operation_qualifier, :string, source: :QualifdrOpCCS
          field :type, :string, source: :TpPessoa
          field :cpf_cnpj, :string, source: :CNPJ_CPFPessoa
          field :start_date, :date, source: :DtIni
          field :end_date, :date, source: :DtFim
        end

        field :cnpj, :string, source: :CNPJBasePart
      end

      field :quantity, :integer, default: 0, source: :QtdOpCCS
      field :movement_date, :date, source: :DtMovto
    end
  end

  @doc """
  Creates a new ACCS001 message from given attributes.
  """
  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    attrs
    |> changeset()
    |> apply_action(:insert)
  end

  @doc false
  def changeset(accs001 \\ %__MODULE__{}, attrs) when is_map(attrs) do
    accs001
    |> cast(attrs, [])
    |> cast_embed(:daily_update, with: &daily_update_changeset/2, required: true)
  end

  @doc false
  def daily_update_changeset(daily_update, attrs) when is_map(attrs) do
    daily_update
    |> cast(attrs, @daily_update_fields)
    |> validate_required(@daily_update_fields)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> cast_embed(:persons, with: &persons_changeset/2)
    |> validate_by_quantity()
    |> validate_quantity_digit()
  end

  defp validate_by_quantity(changeset) do
    quantity = get_field(changeset, :quantity, 0)

    if quantity > 0 do
      cast_embed(changeset, :persons, with: &persons_changeset/2, required: true)
    else
      changeset
    end
  end

  defp validate_quantity_digit(changeset) do
    quantity =
      changeset
      |> get_field(:quantity, 0)
      |> to_string()

    if String.length(quantity) > 9 do
      add_error(changeset, :quantity, "number should be minor than 9 digits")
    else
      changeset
    end
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
    |> validate_inclusion(:operation_type, @allowed_operation_types)
    |> validate_inclusion(:operation_qualifier, @allowed_operation_qualifiers)
    |> validate_inclusion(:type, @allowed_person_types)
    |> validate_length(:operation_type, is: 1)
    |> validate_length(:operation_qualifier, is: 1)
    |> validate_length(:type, is: 1)
    |> validate_by_operation_type()
    |> validate_by_type()
  end

  defp validate_by_operation_type(changeset) do
    case get_field(changeset, :operation_type) do
      "A" -> validate_required(changeset, [:end_date])
      _ -> changeset
    end
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

      iex> Bacen.CCS.ACCS001.sequence(:CCSArqAtlzDiaria)
      [:Repet_ACCS001_Pessoa, :QtdOpCCS, :DtMovto]

      iex> Bacen.CCS.ACCS001.sequence(:Repet_ACCS001_Pessoa)
      [:CNPJBasePart, :Grupo_ACCS001_Pessoa]

      iex> Bacen.CCS.ACCS001.sequence(:Grupo_ACCS001_Pessoa)
      [:TpOpCCS, :QualifdrOpCCS, :TpPessoa, :CNPJ_CPFPessoa, :DtIni, :DtFim]

  """
  @spec sequence(:CCSArqAtlzDiaria | :Repet_ACCS001_Pessoa | :Grupo_ACCS001_Pessoa) ::
          list(atom())
  def sequence(element)

  def sequence(:CCSArqAtlzDiaria), do: @daily_update_fields_source_sequence
  def sequence(:Repet_ACCS001_Pessoa), do: @persons_fields_source_sequence
  def sequence(:Grupo_ACCS001_Pessoa), do: @person_fields_source_sequence
end
