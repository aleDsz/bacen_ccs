defmodule Bacen.CCS.Serializer.SchemaConverter do
  @moduledoc """
  The Bacen's CCS schema converter.

  It reads all `Ecto.Schema` defined on `Message`
  schema and generates a tuple-formatted XML, allowing
  the application to serialize it properly and convert
  to String.
  """

  alias Bacen.CCS.Message
  alias Bacen.CCS.{ACCS001, ACCS002, ACCS003, ACCS004}

  @typep attrs :: {atom(), charlist()}
  @typep xml :: {:CCSDOC, list(attrs()), nonempty_maybe_improper_list()}

  @accs_modules [ACCS001, ACCS002, ACCS003, ACCS004]

  @doc """
  Convert an `t:Ecto.Schema` into a tuple-formatted XML.

  ## Examples

      iex> message = %Bacen.CCS.Message{
      iex>   message: %Bacen.CCS.Message.BaseMessage{
      iex>     body: %Bacen.CCS.ACCS002{
      iex>       response: %Bacen.CCS.ACCS002.Response{
      iex>         error: nil,
      iex>         last_file_id: "000000000000",
      iex>         movement_date: ~D[2021-05-07],
      iex>         reference_date: ~U[2021-05-07 05:04:00Z],
      iex>         status: "A"
      iex>       }
      iex>     },
      iex>     header: %Bacen.CCS.Message.BaseMessage.Header{
      iex>       file_id: "000000000000",
      iex>       file_name: "ACCS001",
      iex>       issuer_id: "69930846",
      iex>       recipient_id: "25992990"
      iex>     }
      iex>   }
      iex> }
      iex> Bacen.CCS.Serializer.SchemaConverter.to_xml(message, 'foo')
      {:ok, {:CCSDOC, [xmlns: 'foo'],
        [
          BCARQ: [
            {:IdentdEmissor, ['69930846']},
            {:IdentdDestinatario, ['25992990']},
            {:NomArq, ['ACCS001']},
            {:NumRemessaArq, ['000000000000']}
          ],
          SISARQ: [
            CCSArqAtlzDiariaRespArq: [
              {:SitArq, ['A']},
              {:UltNumRemessaArq, ['000000000000']},
              {:DtHrBC, ['2021-05-07T05:04:00']},
              {:DtMovto, ['2021-05-07']}
            ]
          ]
        ]
      }}

  """
  @spec to_xml(Message.t(), charlist()) :: {:ok, xml()} | {:error, any()}
  def to_xml(message = %Message{}, xmlns) when is_list(xmlns) do
    {element, attrs, content} =
      message
      |> build_xml_map()
      |> build_xml(xmlns)

    xml = {element, attrs, order_fields(content, [:BCARQ, :SISARQ])}

    {:ok, xml}
  end

  defp build_xml_map(data = [%{__struct__: _} | _]), do: Enum.map(data, &build_xml_map/1)

  defp build_xml_map(data = %{__struct__: module}) do
    fields = get_fields(module)

    Enum.reduce(fields, %{}, fn field, acc ->
      source = get_source(module, field)

      if source == field do
        data
        |> Map.get(field)
        |> build_xml_map()
      else
        value = get_value(data, field, source)

        Map.put_new(acc, source, value)
      end
    end)
  end

  defp get_fields(module) when is_atom(module), do: module.__schema__(:fields)

  defp get_source(module, field) when is_atom(module) and is_atom(field),
    do: module.__schema__(:field_source, field)

  defp get_value(data, field, _source) do
    do_get_value(Map.get(data, field))
  end

  defp do_get_value(date_time = %DateTime{}),
    do: Timex.format!(date_time, "{YYYY}-{0M}-{0D}T{h24}:{0m}:{0s}")

  defp do_get_value(date = %Date{}), do: Date.to_string(date)

  defp do_get_value(list_of_structs) when is_list(list_of_structs),
    do: Enum.map(list_of_structs, &do_get_value/1)

  defp do_get_value(struct) when is_struct(struct), do: build_xml_map(struct)
  defp do_get_value(value), do: value

  defp build_xml(data_struct, xmlns) when is_map(data_struct) and is_list(xmlns) do
    childrens = build_child_xml(data_struct)
    build_root_xml(xmlns, childrens)
  end

  defp build_root_xml(xmlns, childrens = [_ | _]) do
    {:CCSDOC, [{:xmlns, xmlns}], childrens}
  end

  defp build_child_xml(%{CCSDOC: ccs_doc}) when is_map(ccs_doc) do
    build_child_xml(ccs_doc)
  end

  defp build_child_xml(map) when is_map(map) do
    Enum.reduce(map, [], fn
      {key, value}, acc when is_map(value) ->
        value = build_child_xml(value)
        fields_sequence = sequence(key, value)
        ordered_value = order_fields(value, fields_sequence)

        Keyword.put_new(acc, key, ordered_value)

      {key, value}, acc when is_binary(value) ->
        Keyword.put_new(acc, key, [to_charlist(value)])

      {_key, nil}, acc ->
        acc

      {key, values}, acc when is_list(values) ->
        values = Enum.map(values, &build_child_xml/1)
        Keyword.put_new(acc, key, values)

      {key, value}, acc ->
        value =
          value
          |> to_string()
          |> to_charlist()

        Keyword.put_new(acc, key, value)
    end)
  end

  defp order_fields(content, fields) do
    index = fn list, item -> Enum.find_index(list, &Kernel.==(&1, item)) end

    Enum.sort_by(content, fn {key, _} -> index.(fields, key) end)
  end

  defp sequence(:BCARQ, _), do: Message.sequence(:BCARQ)
  defp sequence(:SISARQ, content), do: Keyword.keys(content)

  defp sequence(element_name, _content) do
    Enum.reduce_while(@accs_modules, [], fn module, acc ->
      if data = maybe_get_sequence(module, element_name) do
        {:halt, data}
      else
        {:cont, acc}
      end
    end)
  end

  defp maybe_get_sequence(module, element_name) do
    module.sequence(element_name)
  rescue
    _ -> nil
  end
end
