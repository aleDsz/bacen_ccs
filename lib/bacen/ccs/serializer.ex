defmodule Bacen.CCS.Serializer do
  @moduledoc """
  The CCS message serializer.
  """

  alias Bacen.CCS
  alias Bacen.CCS.Message
  alias Bacen.CCS.Serializer.SchemaConverter

  @bacen_ccs_xsd_path Application.app_dir(:bacen_ccs, "priv/xsd")

  @doc """
  Serializes an `t:Ecto.Schema` into a tuple-formatted XML and
  validates it's XML with his XSD.

  ## Examples

      iex> header = %{
      iex>   file_id: "000000000000",
      iex>   file_name: "ACCS002",
      iex>   issuer_id: "69930846",
      iex>   recipient_id: "25992990"
      iex> }
      iex> body = %{
      iex>   response: %{
      iex>     last_file_id: "000000000000",
      iex>     movement_date: ~D[2021-05-07],
      iex>     reference_date: ~U[2021-05-07 05:04:00Z],
      iex>     status: "A"
      iex>   }
      iex> }
      iex> Bacen.CCS.Serializer.serialize(header, body)
      {:ok, ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)}

      iex> header = %{
      iex>   "file_id" => "000000000000",
      iex>   "file_name" => "ACCS002",
      iex>   "issuer_id" => "69930846",
      iex>   "recipient_id" => "25992990"
      iex> }
      iex> body = %{
      iex>   response: %{
      iex>     "last_file_id" => "000000000000",
      iex>     "movement_date" => ~D[2021-05-07],
      iex>     "reference_date" => ~U[2021-05-07 05:04:00Z],
      iex>     "status" => "A"
      iex>   }
      iex> }
      iex> Bacen.CCS.Serializer.serialize(header, body)
      {:ok, ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)}

  The example above, generated the following an XML with UTF-16 encoding, making it
  not human-readable, but if we convert it back to UTF-8, it generates the following
  human-readable XML:

  ```xml
  <?xml version="1.0"?>
  <CCSDOC xmlns="http://www.bcb.gov.br/ccs/ACCS002.xsd">
    <BCARQ>
      <IdentdEmissor>69930846</IdentdEmissor>
      <IdentdDestinatario>25992990</IdentdDestinatario>
      <NomArq>ACCS002</NomArq>
      <NumRemessaArq>000000000000</NumRemessaArq>
    </BCARQ>
    <SISARQ>
      <CCSArqAtlzDiariaRespArq>
        <SitArq>A</SitArq>
        <UltNumRemessaArq>000000000000</UltNumRemessaArq>
        <DtHrBC>2021-05-07T05:04:00</DtHrBC>
        <DtMovto>2021-05-07</DtMovto>
      </CCSArqAtlzDiariaRespArq>
    </SISARQ>
  </CCSDOC>
  ```

  """
  @spec serialize(map(), map()) :: {:ok, String.t()} | {:error, any()}
  def serialize(header_attrs, body_attrs) when is_map(header_attrs) and is_map(body_attrs) do
    with {:ok, header = %{file_name: file_name}} <- parse_header(header_attrs),
         schema <- CCS.name_to_schema(file_name),
         {:ok, body} <- schema.new(body_attrs),
         {:ok, message} <- build_message(header, body),
         {:ok, xml_element} <- build_xml(message, file_name),
         {:ok, valid_xml_element} <- validate_xsd(xml_element, file_name) do
      xml =
        valid_xml_element
        |> List.wrap()
        |> :xmerl.export_simple(:xmerl_xml)
        |> List.flatten()
        |> to_charlist()
        |> :unicode.characters_to_binary(:utf8, :utf16)

      {:ok, xml}
    end
  end

  defp parse_header(header = %{file_name: _, file_id: _, issuer_id: _, recipient_id: _}) do
    {:ok, header}
  end

  defp parse_header(
         header = %{"file_name" => _, "file_id" => _, "issuer_id" => _, "recipient_id" => _}
       ) do
    parsed_header =
      Enum.reduce(header, %{}, fn {key, value}, acc ->
        Map.put_new(acc, String.to_atom(key), value)
      end)

    {:ok, parsed_header}
  end

  defp build_message(header, body) do
    Message.new(%{message: %{header: header, body: body}})
  end

  defp build_xml(message = %Message{}, file_name) do
    xmlns = to_charlist("http://www.bcb.gov.br/ccs/#{file_name}.xsd")

    with {:ok, xml} <- SchemaConverter.to_xml(message, xmlns),
         {:ok, parsed_xml} <- parse_xml_into_xmerl_xml(xml),
         {xml_element, _} <- :xmerl_scan.string(parsed_xml) do
      {:ok, xml_element}
    end
  end

  defp parse_xml_into_xmerl_xml(xml) do
    parsed_xml =
      xml
      |> List.wrap()
      |> :xmerl.export_simple(:xmerl_xml)
      |> List.flatten()

    {:ok, parsed_xml}
  end

  # coveralls-ignore-start
  defp validate_xsd(xml_element, file_name) do
    path = to_charlist("#{@bacen_ccs_xsd_path}/#{file_name}.xsd")

    with {:ok, schema} <- :xmerl_xsd.process_schema(path) do
      case :xmerl_xsd.validate(xml_element, schema) do
        error = {:error, _} -> error
        {valid_xml_element, _global_state} -> {:ok, valid_xml_element}
      end
    end
  end

  # coveralls-ignore-stop
end
