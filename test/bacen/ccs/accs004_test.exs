defmodule Bacen.CCS.ACCS004Test do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.ACCS004

  import Bacen.CCS.ACCS004
  alias Bacen.CCS.ACCS004

  describe "new/1" do
    test "builds a new ACCS004" do
      attrs =
        params_for(:accs004,
          registration_position:
            build(:registration_position,
              conglomerate:
                build(:conglomerate, participant: build_list(1, :participant, cnpj: "44843979")),
              persons:
                build(:accs004_persons,
                  cnpj: "36935289",
                  person: build_list(1, :accs004_person, cpf_cnpj: "96709797228")
                )
            )
        )

      assert {:ok,
              %ACCS004{
                registration_position: %ACCS004.RegistrationPosition{
                  conglomerate: %Bacen.CCS.ACCS004.RegistrationPosition.Conglomerate{
                    participant: [
                      %Bacen.CCS.ACCS004.RegistrationPosition.Conglomerate.Participant{
                        cnpj: "44843979"
                      }
                    ]
                  },
                  movement_date: ~D[2021-05-07],
                  persons: %ACCS004.RegistrationPosition.Persons{
                    cnpj: "36935289",
                    person: [
                      %ACCS004.RegistrationPosition.Persons.Person{
                        cpf_cnpj: "96709797228",
                        end_date: nil,
                        start_date: ~D[2021-05-07],
                        type: "F"
                      }
                    ]
                  }
                }
              }} == new(attrs)
    end
  end

  describe "ACCS004" do
    test "validates the existence of registration_position field" do
      changeset = refute_valid_changeset changeset(%ACCS004{}, %{})
      assert "can't be blank" in errors_on(changeset).registration_position
    end
  end

  describe "RegistrationPosition" do
    alias ACCS004.RegistrationPosition

    test "validates the existence of fields" do
      changeset =
        refute_valid_changeset registration_position_changeset(%RegistrationPosition{}, %{})

      assert errors_on(changeset) == %{
               persons: ["can't be blank"],
               conglomerate: ["can't be blank"],
               movement_date: ["can't be blank"]
             }
    end
  end

  describe "Conglomerate" do
    alias ACCS004.RegistrationPosition.Conglomerate

    test "validates the existence of participant field" do
      changeset = refute_valid_changeset conglomerate_changeset(%Conglomerate{}, %{})

      assert "can't be blank" in errors_on(changeset).participant
    end
  end

  describe "Participant" do
    alias ACCS004.RegistrationPosition.Conglomerate.Participant

    test "validates the existence of cnpj field" do
      changeset = refute_valid_changeset participant_changeset(%Participant{}, %{})

      assert "can't be blank" in errors_on(changeset).cnpj
    end

    test "validates the length from cnpj field" do
      attrs = params_for(:participant, cnpj: "123456789")
      changeset = refute_valid_changeset participant_changeset(%Participant{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).cnpj
    end

    test "validates the format from cnpj field" do
      attrs = params_for(:participant, cnpj: "1234567A")
      changeset = refute_valid_changeset participant_changeset(%Participant{}, attrs)

      assert "has invalid format" in errors_on(changeset).cnpj
    end
  end

  describe "Persons" do
    alias ACCS004.RegistrationPosition.Persons

    test "validates the existence of person field" do
      changeset = refute_valid_changeset persons_changeset(%Persons{}, %{})

      assert errors_on(changeset) == %{
               cnpj: ["can't be blank"],
               person: ["can't be blank"]
             }
    end

    test "validates the length from cnpj field" do
      attrs = params_for(:accs004_persons, cnpj: "123456789")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).cnpj
    end

    test "validates the format from cnpj field" do
      attrs = params_for(:accs004_persons, cnpj: "1234567A")
      changeset = refute_valid_changeset persons_changeset(%Persons{}, attrs)

      assert "has invalid format" in errors_on(changeset).cnpj
    end
  end

  describe "Person" do
    alias ACCS004.RegistrationPosition.Persons.Person

    test "validates the existence of fields" do
      changeset = refute_valid_changeset person_changeset(%Person{}, %{})

      assert errors_on(changeset) == %{
               cpf_cnpj: ["can't be blank"],
               start_date: ["can't be blank"],
               type: ["can't be blank"]
             }
    end

    test "validates the type field" do
      attrs = params_for(:accs004_person, type: "test")
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "is invalid" in errors_on(changeset).type
      assert "should be 1 character(s)" in errors_on(changeset).type
    end

    test "validates the CPF from cpf_cnpj field" do
      attrs = params_for(:accs004_person, type: "F", cpf_cnpj: Brcpfcnpj.cnpj_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CPF format" in errors_on(changeset).cpf_cnpj
    end

    test "validates the CNPJ from cpf_cnpj field" do
      attrs = params_for(:accs004_person, type: "J", cpf_cnpj: Brcpfcnpj.cpf_generate())
      changeset = refute_valid_changeset person_changeset(%Person{}, attrs)

      assert "invalid CNPJ format" in errors_on(changeset).cpf_cnpj
    end
  end
end
