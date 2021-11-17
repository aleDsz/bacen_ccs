defmodule Bacen.CCS do
  @moduledoc """
  # Cadastro de Clientes do Sistema Financeiro Nacional

  The CCS context.

  It interacts to Bacen's CCS system.
  """

  alias Bacen.CCS.{
    ACCS001,
    ACCS002,
    ACCS003,
    ACCS004,
    ACCS005,
    ACCS006,
    ACCS009,
    ACCS010,
    ACCS011,
    ACCS012,
    CCS0001,
    CCS0002,
    CCS0003,
    CCS0004
  }

  @typedoc """
  The CCS message types
  """
  @type schemas ::
          ACCS001
          | ACCS002
          | ACCS003
          | ACCS004
          | ACCS005
          | ACCS006
          | ACCS009
          | ACCS010
          | ACCS011
          | ACCS012
          | CCS0001
          | CCS0002
          | CCS0003
          | CCS0004

  @doc """
  Gets the schema module from given name

  ## Examples

      iex> Bacen.CCS.name_to_schema("ACCS001")
      Bacen.CCS.ACCS001

      iex> Bacen.CCS.name_to_schema("foobar")
      ** (FunctionClauseError) no function clause matching in Bacen.CCS.name_to_schema/1

  """
  @spec name_to_schema(String.t()) :: schemas()
  def name_to_schema(name)

  def name_to_schema("ACCS001"), do: ACCS001
  def name_to_schema("ACCS002"), do: ACCS002
  def name_to_schema("ACCS003"), do: ACCS003
  def name_to_schema("ACCS004"), do: ACCS004
  def name_to_schema("ACCS005"), do: ACCS005
  def name_to_schema("ACCS006"), do: ACCS006
  def name_to_schema("ACCS009"), do: ACCS009
  def name_to_schema("ACCS010"), do: ACCS010
  def name_to_schema("ACCS011"), do: ACCS011
  def name_to_schema("ACCS012"), do: ACCS012
  def name_to_schema("CCS0001"), do: CCS0001
  def name_to_schema("CCS0002"), do: CCS0002
  def name_to_schema("CCS0003"), do: CCS0003
  def name_to_schema("CCS0004"), do: CCS0004
end
