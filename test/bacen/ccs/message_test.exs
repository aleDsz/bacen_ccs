defmodule Bacen.CCS.MessageTest do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.Message

  alias Bacen.CCS.Message
  import Bacen.CCS.Message

  describe "new/1" do
    test "builds a new CCS message" do
      body =
        build(:accs001,
          daily_update:
            build(:daily_update,
              persons:
                build(:accs001_persons,
                  cnpj: "65490167",
                  person: build_list(1, :accs001_person, cpf_cnpj: "96709797228")
                )
            )
        )

      attrs =
        params_for(:message,
          message:
            build(:base_message,
              body: body,
              header: build(:header, issuer_id: "69930846", recipient_id: "25992990")
            )
        )

      assert {:ok,
              %Message{
                message: %Bacen.CCS.Message.BaseMessage{
                  body: %Bacen.CCS.ACCS001{
                    daily_update: %Bacen.CCS.ACCS001.DailyUpdate{
                      movement_date: "2021-05-07",
                      persons: %Bacen.CCS.ACCS001.DailyUpdate.Persons{
                        cnpj: "65490167",
                        person: [
                          %Bacen.CCS.ACCS001.DailyUpdate.Persons.Person{
                            cpf_cnpj: "96709797228",
                            end_date: nil,
                            operation_qualifier: "C",
                            operation_type: "I",
                            start_date: "2021-05-07",
                            type: "F"
                          }
                        ]
                      },
                      quantity: 1
                    }
                  },
                  header: %Bacen.CCS.Message.BaseMessage.Header{
                    file_id: "000000000000",
                    file_name: "ACCS001",
                    issuer_id: "69930846",
                    recipient_id: "25992990"
                  }
                }
              }} == new(attrs)
    end
  end

  describe "Message" do
    test "validates the existence of message field" do
      changeset = refute_valid_changeset changeset(%Message{}, %{})
      assert "can't be blank" in errors_on(changeset).message
    end
  end

  describe "BaseMessage" do
    alias Message.BaseMessage

    test "validates the existence of fields" do
      changeset = refute_valid_changeset message_changeset(%BaseMessage{}, %{})

      assert errors_on(changeset) == %{
               header: ["can't be blank"],
               body: ["can't be blank"]
             }
    end

    test "validates the ACCS message type on body field" do
      body = params_for(:message)
      attrs = params_for(:base_message, body: body)

      changeset = refute_valid_changeset message_changeset(%BaseMessage{}, attrs)
      assert "is invalid" in errors_on(changeset).body
    end
  end

  describe "Header" do
    alias Message.BaseMessage.Header

    test "validates the existence of fields" do
      changeset = refute_valid_changeset header_changeset(%Header{}, %{})

      assert errors_on(changeset) == %{
               issuer_id: ["can't be blank"],
               recipient_id: ["can't be blank"],
               file_name: ["can't be blank"],
               file_id: ["can't be blank"]
             }
    end

    test "validates the length from issuer_id field" do
      attrs = params_for(:header, issuer_id: "123456789")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).issuer_id
    end

    test "validates the format from issuer_id field" do
      attrs = params_for(:header, issuer_id: "1234567A")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "has invalid format" in errors_on(changeset).issuer_id
    end

    test "validates the length from recipient_id field" do
      attrs = params_for(:header, recipient_id: "123456789")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).recipient_id
    end

    test "validates the format from recipient_id field" do
      attrs = params_for(:header, recipient_id: "1234567A")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "has invalid format" in errors_on(changeset).recipient_id
    end

    test "validates the file_name field" do
      file_name = for _ <- 1..81, into: "", do: "A"
      attrs = params_for(:header, file_name: file_name)
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "should be at most 80 character(s)" in errors_on(changeset).file_name
    end

    test "validates the length from file_id field" do
      attrs = params_for(:header, file_id: "0000000000000")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "should be 12 character(s)" in errors_on(changeset).file_id
    end

    test "validates the format from file_id field" do
      attrs = params_for(:header, file_id: "00000A000000")
      changeset = refute_valid_changeset header_changeset(%Header{}, attrs)

      assert "has invalid format" in errors_on(changeset).file_id
    end
  end
end
