defmodule Bacen.CCS.ACCS001Test do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.ACCS001

  import Bacen.CCS.ACCS001
  alias Bacen.CCS.ACCS001

  describe "new/1" do
    test "builds a new ACCS001 message" do
      attrs =
        params_for(:accs001,
          daily_update:
            build(:daily_update,
              persons:
                build(:accs001_persons,
                  cnpj: "36935289",
                  person: build_list(1, :accs001_person, cpf_cnpj: "96709797228")
                )
            )
        )

      assert {:ok,
              %ACCS001{
                daily_update: %ACCS001.DailyUpdate{
                  movement_date: ~D[2021-05-07],
                  persons: %ACCS001.DailyUpdate.Persons{
                    cnpj: "36935289",
                    person: [
                      %ACCS001.DailyUpdate.Persons.Person{
                        cpf_cnpj: "96709797228",
                        end_date: nil,
                        operation_qualifier: "C",
                        operation_type: "I",
                        start_date: ~D[2021-05-07],
                        type: "F"
                      }
                    ]
                  },
                  quantity: 1
                }
              }} == new(attrs)
    end
  end

  describe "ACCS001" do
    test "validates the existence of daily_update field" do
      changeset = refute_valid_changeset changeset(%ACCS001{}, %{})
      assert "can't be blank" in errors_on(changeset).daily_update
    end
  end

  describe "DailyUpdate" do
    alias ACCS001.DailyUpdate

    test "validates the existence of movement_date field" do
      changeset = refute_valid_changeset daily_update_changeset(%DailyUpdate{}, %{})
      assert "can't be blank" in errors_on(changeset).movement_date
    end

    test "validates the existence of persons field" do
      attrs = params_for(:daily_update, quantity: 1, movement_date: ~D[2021-05-07], persons: nil)

      changeset = refute_valid_changeset daily_update_changeset(%DailyUpdate{}, attrs)
      assert "can't be blank" in errors_on(changeset).persons
    end

    test "validates the number from quantity field" do
      attrs = params_for(:daily_update, quantity: -1, movement_date: ~D[2021-05-07], persons: nil)

      changeset = refute_valid_changeset daily_update_changeset(%DailyUpdate{}, attrs)
      assert "must be greater than or equal to 0" in errors_on(changeset).quantity
    end

    test "validates the digits from quantity field" do
      attrs =
        params_for(:daily_update,
          quantity: 1_000_000_000,
          movement_date: ~D[2021-05-07],
          persons: nil
        )

      changeset = refute_valid_changeset daily_update_changeset(%DailyUpdate{}, attrs)
      assert "number should be minor than 9 digits" in errors_on(changeset).quantity
    end
  end

  describe "Persons" do
    alias ACCS001.DailyUpdate.Persons

    test "validates the existence of fields" do
      changeset = refute_valid_changeset persons_changeset(%Persons{}, %{})

      assert errors_on(changeset) == %{
               cnpj: ["can't be blank"],
               person: ["can't be blank"]
             }
    end

    test "validates the length from cnpj field" do
      attrs = params_for(:accs001_persons, cnpj: "123456789")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).cnpj
    end

    test "validates the format from cnpj field" do
      attrs = params_for(:accs001_persons, cnpj: "1234567A")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "has invalid format" in errors_on(changeset).cnpj
    end
  end

  describe "Person" do
    alias ACCS001.DailyUpdate.Persons.Person

    test "validates the existence of fields" do
      changeset = refute_valid_changeset person_changeset(%Person{}, %{})

      assert errors_on(changeset) == %{
               cpf_cnpj: ["can't be blank"],
               operation_qualifier: ["can't be blank"],
               operation_type: ["can't be blank"],
               start_date: ["can't be blank"],
               type: ["can't be blank"]
             }
    end

    test "validates the operation_type field" do
      attrs = params_for(:accs001_person, operation_type: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).operation_type
      assert "should be 1 character(s)" in errors_on(changeset).operation_type
    end

    test "validates the operation_qualifier field" do
      attrs = params_for(:accs001_person, operation_qualifier: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).operation_qualifier
      assert "should be 1 character(s)" in errors_on(changeset).operation_qualifier
    end

    test "validates the type field" do
      attrs = params_for(:accs001_person, type: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).type
      assert "should be 1 character(s)" in errors_on(changeset).type
    end

    test "validates the existence of end_date field" do
      attrs = params_for(:accs001_person, operation_type: "A")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "can't be blank" in errors_on(changeset).end_date
    end

    test "validates the CPF from cpf_cnpj field" do
      attrs = params_for(:accs001_person, type: "F", cpf_cnpj: Brcpfcnpj.cnpj_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CPF format" in errors_on(changeset).cpf_cnpj
    end

    test "validates the CNPJ from cpf_cnpj field" do
      attrs = params_for(:accs001_person, type: "J", cpf_cnpj: Brcpfcnpj.cpf_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CNPJ format" in errors_on(changeset).cpf_cnpj
    end
  end
end
