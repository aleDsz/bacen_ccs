defmodule Bacen.CCS.ACCS003Test do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.ACCS003

  import Bacen.CCS.ACCS003
  alias Bacen.CCS.ACCS003

  describe "new/1" do
    test "builds a new ACCS003" do
      attrs =
        params_for(:accs003,
          daily_update_validation:
            build(:daily_update_validation,
              persons:
                build(:accs003_persons,
                  cnpj: "36935289",
                  person: build_list(1, :accs003_person, cpf_cnpj: "96709797228")
                )
            )
        )

      assert {:ok,
              %ACCS003{
                daily_update_validation: %ACCS003.DailyUpdateValidation{
                  error_quantity: 0,
                  accepted_quantity: 1,
                  movement_date: ~D[2021-05-07],
                  reference_date: ~U[2021-05-07 05:04:00Z],
                  persons: %ACCS003.DailyUpdateValidation.Persons{
                    cnpj: "36935289",
                    person: [
                      %ACCS003.DailyUpdateValidation.Persons.Person{
                        cpf_cnpj: "96709797228",
                        end_date: nil,
                        operation_qualifier: "C",
                        operation_type: "I",
                        start_date: ~D[2021-05-07],
                        type: "F",
                        error: nil
                      }
                    ]
                  }
                }
              }} == new(attrs)
    end
  end

  describe "ACCS003" do
    test "validates the existence of daily_update_validation field" do
      changeset = refute_valid_changeset changeset(%ACCS003{}, %{})
      assert "can't be blank" in errors_on(changeset).daily_update_validation
    end
  end

  describe "DailyUpdateValidation" do
    alias ACCS003.DailyUpdateValidation

    test "validates the existence of fields" do
      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, %{})

      assert errors_on(changeset) == %{
               accepted_quantity: ["can't be blank"],
               error_quantity: ["can't be blank"],
               movement_date: ["can't be blank"],
               persons: ["can't be blank", "can't be blank"],
               reference_date: ["can't be blank"]
             }
    end

    test "validates the existence of persons field" do
      attrs = params_for(:daily_update_validation, persons: nil)

      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, attrs)

      assert "can't be blank" in errors_on(changeset).persons
    end

    test "validates the number from error_quantity field" do
      attrs =
        params_for(:daily_update_validation,
          error_quantity: -1,
          persons: nil
        )

      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, attrs)

      assert "must be greater than or equal to 0" in errors_on(changeset).error_quantity
    end

    test "validates the digits from error_quantity field" do
      attrs =
        params_for(:daily_update_validation,
          error_quantity: 1_000_000_000,
          persons: nil
        )

      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, attrs)

      assert "number should be minor than 9 digits" in errors_on(changeset).error_quantity
    end

    test "validates the number from accepted_quantity field" do
      attrs =
        params_for(:daily_update_validation,
          error_quantity: -1,
          persons: nil
        )

      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, attrs)

      assert "must be greater than or equal to 0" in errors_on(changeset).error_quantity
    end

    test "validates the digits from accepted_quantity field" do
      attrs =
        params_for(:daily_update_validation,
          error_quantity: 1_000_000_000,
          persons: nil
        )

      changeset =
        refute_valid_changeset daily_update_validation_changeset(%DailyUpdateValidation{}, attrs)

      assert "number should be minor than 9 digits" in errors_on(changeset).error_quantity
    end
  end

  describe "Persons" do
    alias ACCS003.DailyUpdateValidation.Persons

    test "validates the existence of person field" do
      changeset = refute_valid_changeset persons_changeset(%Persons{}, %{})

      assert errors_on(changeset) == %{
               cnpj: ["can't be blank"],
               person: ["can't be blank"]
             }
    end

    test "validates the length from cnpj field" do
      attrs = params_for(:accs003_persons, cnpj: "123456789")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).cnpj
    end

    test "validates the format from cnpj field" do
      attrs = params_for(:accs003_persons, cnpj: "1234567A")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "has invalid format" in errors_on(changeset).cnpj
    end
  end

  describe "Person" do
    alias ACCS003.DailyUpdateValidation.Persons.Person

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
      attrs = params_for(:accs003_person, operation_type: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).operation_type
      assert "should be 1 character(s)" in errors_on(changeset).operation_type
    end

    test "validates the operation_qualifier field" do
      attrs = params_for(:accs003_person, operation_qualifier: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).operation_qualifier
      assert "should be 1 character(s)" in errors_on(changeset).operation_qualifier
    end

    test "validates the type field" do
      attrs = params_for(:accs003_person, type: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).type
      assert "should be 1 character(s)" in errors_on(changeset).type
    end

    test "validates the existence of end_date field" do
      attrs = params_for(:accs003_person, operation_type: "A")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "can't be blank" in errors_on(changeset).end_date
    end

    test "validates the CPF from cpf_cnpj field" do
      attrs = params_for(:accs003_person, type: "F", cpf_cnpj: Brcpfcnpj.cnpj_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CPF format" in errors_on(changeset).cpf_cnpj
    end

    test "validates the CNPJ from cpf_cnpj field" do
      attrs = params_for(:accs003_person, type: "J", cpf_cnpj: Brcpfcnpj.cpf_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CNPJ format" in errors_on(changeset).cpf_cnpj
    end

    test "validates the format from error field" do
      attrs = params_for(:accs003_person, error: "E1RO12A4")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "has invalid format" in errors_on(changeset).error
    end

    test "validates the length from error field" do
      attrs = params_for(:accs003_person, error: "ERRO12345")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).error
    end
  end
end
