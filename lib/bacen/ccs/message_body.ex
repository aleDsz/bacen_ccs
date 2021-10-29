defmodule Bacen.CCS.MessageBody do
  @moduledoc """
  The CCS base message body type.

  This custom Ecto Type creates an
  abstraction around the ACCS/CCS messages
  to generate a full XML to serialize a
  CCS message XML to communicate with Bacen's system.

  This also makes a easy way to read the
  received message from Bacen's system to parse
  the given XML into a 't:MessageBody' schema
  from given file name (ACCS*/CCS*).
  """
  use Ecto.Type

  alias Bacen.CCS.{ACCS001, ACCS002, ACCS003, ACCS004}

  @accs_modules [ACCS001, ACCS002, ACCS003, ACCS004]
  defguardp is_accs(module) when module in @accs_modules

  def type, do: :map

  def cast(data = %module{}) when is_accs(module) do
    {:ok, data}
  end

  def cast(_), do: :error

  def dump(data) do
    data
  end

  def load(data) do
    {:ok, data}
  end
end
