defmodule Bacen.CCS.ACCS003 do
  @moduledoc """
  The ACCS003 message.

  This message is a response from Bacen's system
  about the validation of given ACCS001 message.

  Also, this message reports all success and failures
  from a ACCS001 message.

  It has the following XML example:

  ```xml
  <CCSArqValidcAtlzDiaria>
    <Repet_ACCS003_Pessoa>
      <Grupo_ACCS003_Pessoa>
        <TpOpCCS>I</TpOpCCS>
        <QualifdrOpCCS>N</QualifdrOpCCS>
        <TpPessoa>F</TpPessoa>
        <CNPJ_CPFPessoa>12345678901</CNPJ_CPFPessoa>
        <DtIni>2002-01-01</DtIni>
        <DtFim>2002-01-03</DtFim>
        <ErroCCS>ECCS0023</ErroCCS>
      </Grupo_ACCS003_Pessoa>
    </Repet_ACCS003_Pessoa>
    <QtdErro>1</QtdErro>
    <QtdOpCCSActo>0</QtdOpCCSActo>
    <DtHrBC>2004-06-16T05:04:00</DtHrBC>
    <DtMovto>2004-10-10</DtMovto>
  </CCSArqValidcAtlzDiaria>
  ```

  """
  use Ecto.Schema

  import Brcpfcnpj.Changeset
  import Ecto.Changeset

  @typedoc """
  The ACCS003 message type
  """
  @type t :: %__MODULE__{}

  @daily_update_validation_fields ~w(error_quantity accepted_quantity reference_date movement_date)a
  @daily_update_validation_opts [source: :CCSArqValidcAtlzDiaria, primary_key: false]
  @daily_update_validation_fields_source_sequence ~w(Repet_ACCS003_Pessoa QtdErro QtdOpCCSActo DtHrBC DtMovto)a

  @quantity_fields ~w(error_quantity accepted_quantity)a

  @persons_fields ~w(cnpj)a
  @persons_fields_source_sequence ~w(CNPJBasePart Grupo_ACCS003_Pessoa)a

  @person_fields ~w(
    operation_type operation_qualifier type
    cpf_cnpj start_date end_date error
  )a

  @person_required_fields ~w(
    operation_type operation_qualifier type
    cpf_cnpj start_date
  )a

  @person_fields_source_sequence ~w(TpOpCCS QualifdrOpCCS TpPessoa CNPJ_CPFPessoa DtIni DtFim ErroCCS)a

  @allowed_operation_types ~w(E A I)
  @allowed_operation_qualifiers ~w(N P C L H E)
  @allowed_person_types ~w(F J)

  @primary_key false
  embedded_schema do
    embeds_one :daily_update_validation, DailyUpdateValidation, @daily_update_validation_opts do
      embeds_one :persons, Persons, source: :Repet_ACCS003_Pessoa, primary_key: false do
        embeds_many :person, Person, source: :Grupo_ACCS003_Pessoa, primary_key: false do
          field :operation_type, :string, source: :TpOpCCS
          field :operation_qualifier, :string, source: :QualifdrOpCCS
          field :type, :string, source: :TpPessoa
          field :cpf_cnpj, :string, source: :CNPJ_CPFPessoa
          field :start_date, :date, source: :DtIni
          field :end_date, :date, source: :DtFim
          field :error, :string, source: :ErroCCS
        end

        field :cnpj, :string, source: :CNPJBasePart
      end

      field :error_quantity, :integer, source: :QtdErro
      field :accepted_quantity, :integer, source: :QtdOpCCSActo
      field :reference_date, :utc_datetime, source: :DtHrBC
      field :movement_date, :date, source: :DtMovto
    end
  end

  @doc """
  Creates a new ACCS003 message from given attributes.
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
    |> cast_embed(:daily_update_validation,
      with: &daily_update_validation_changeset/2,
      required: true
    )
  end

  @doc false
  def daily_update_validation_changeset(daily_update_validation, attrs) when is_map(attrs) do
    daily_update_validation
    |> cast(attrs, @daily_update_validation_fields)
    |> validate_required(@daily_update_validation_fields)
    |> validate_number(:error_quantity, greater_than_or_equal_to: 0)
    |> validate_number(:accepted_quantity, greater_than_or_equal_to: 0)
    |> cast_embed(:persons, with: &persons_changeset/2)
    |> validate_by_quantity()
    |> validate_quantity_digit()
  end

  defp validate_by_quantity(changeset) do
    Enum.reduce(@quantity_fields, changeset, fn field, acc ->
      quantity = get_field(changeset, field, 0)
      validate_cast_embed_by_quantity(acc, quantity)
    end)
  end

  defp validate_cast_embed_by_quantity(changeset, quantity) do
    if quantity > 0 do
      cast_embed(changeset, :persons, with: &persons_changeset/2, required: true)
    else
      changeset
    end
  end

  defp validate_quantity_digit(changeset) do
    Enum.reduce(@quantity_fields, changeset, fn field, acc ->
      quantity =
        changeset
        |> get_field(field, 0)
        |> to_string()

      check_quantity_digit(acc, field, quantity)
    end)
  end

  defp check_quantity_digit(changeset, field, quantity) do
    if String.length(quantity) > 9 do
      add_error(changeset, field, "number should be minor than 9 digits")
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
    |> validate_error()
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

  defp validate_error(changeset) do
    case get_field(changeset, :error) do
      nil ->
        changeset

      _ ->
        changeset
        |> validate_required([:error])
        |> validate_length(:error, is: 8)
        |> validate_format(:error, ~r/E[A-Z]{3}[0-9]{4}/)
    end
  end

  @doc """
  Returns the field sequence for given root xml element

  ## Examples

      iex> Bacen.CCS.ACCS003.sequence(:CCSArqValidcAtlzDiaria)
      [:Repet_ACCS003_Pessoa, :QtdErro, :QtdOpCCSActo, :DtHrBC, :DtMovto]

      iex> Bacen.CCS.ACCS003.sequence(:Repet_ACCS003_Pessoa)
      [:CNPJBasePart, :Grupo_ACCS003_Pessoa]

      iex> Bacen.CCS.ACCS003.sequence(:Grupo_ACCS003_Pessoa)
      [:TpOpCCS, :QualifdrOpCCS, :TpPessoa, :CNPJ_CPFPessoa, :DtIni, :DtFim, :ErroCCS]

  """
  @spec sequence(:CCSArqValidcAtlzDiaria | :Repet_ACCS003_Pessoa | :Grupo_ACCS003_Pessoa) ::
          list(atom())
  def sequence(element)

  def sequence(:CCSArqValidcAtlzDiaria), do: @daily_update_validation_fields_source_sequence
  def sequence(:Repet_ACCS003_Pessoa), do: @persons_fields_source_sequence
  def sequence(:Grupo_ACCS003_Pessoa), do: @person_fields_source_sequence
end
