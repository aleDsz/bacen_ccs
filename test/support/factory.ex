defmodule Bacen.CCS.TestRepo do
  @moduledoc false
end

defmodule Bacen.CCS.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Bacen.CCS.TestRepo

  def accs001_factory do
    %Bacen.CCS.ACCS001{
      daily_update: build(:daily_update)
    }
  end

  def daily_update_factory do
    %Bacen.CCS.ACCS001.DailyUpdate{
      movement_date: "2021-05-07",
      quantity: 1,
      persons: build(:accs001_persons)
    }
  end

  def accs001_persons_factory do
    cnpj =
      Brcpfcnpj.cnpj_generate()
      |> String.slice(0..7)

    %Bacen.CCS.ACCS001.DailyUpdate.Persons{
      cnpj: cnpj,
      person: build_list(1, :accs001_person)
    }
  end

  def accs001_person_factory do
    %Bacen.CCS.ACCS001.DailyUpdate.Persons.Person{
      cpf_cnpj: Brcpfcnpj.cpf_generate(),
      start_date: "2021-05-07",
      operation_qualifier: "C",
      type: "F",
      operation_type: "I"
    }
  end

  def accs002_factory do
    %Bacen.CCS.ACCS002{
      response: build(:response)
    }
  end

  def response_factory do
    %Bacen.CCS.ACCS002.Response{
      last_file_id: "000000000000",
      status: "A",
      error: nil,
      reference_date: "2021-05-07 05:04:00Z",
      movement_date: "2021-05-07"
    }
  end

  def accs003_factory do
    %Bacen.CCS.ACCS003{
      daily_update_validation: build(:daily_update_validation)
    }
  end

  def daily_update_validation_factory do
    %Bacen.CCS.ACCS003.DailyUpdateValidation{
      reference_date: "2021-05-07 05:04:00Z",
      movement_date: "2021-05-07",
      error_quantity: 0,
      accepted_quantity: 1,
      persons: build(:accs003_persons)
    }
  end

  def accs003_persons_factory do
    cnpj =
      Brcpfcnpj.cnpj_generate()
      |> String.slice(0..7)

    %Bacen.CCS.ACCS003.DailyUpdateValidation.Persons{
      cnpj: cnpj,
      person: build_list(1, :accs003_person)
    }
  end

  def accs003_person_factory do
    %Bacen.CCS.ACCS003.DailyUpdateValidation.Persons.Person{
      cpf_cnpj: Brcpfcnpj.cpf_generate(),
      start_date: "2021-05-07",
      operation_qualifier: "C",
      end_date: nil,
      type: "F",
      operation_type: "I",
      error: nil
    }
  end

  def accs004_factory do
    %Bacen.CCS.ACCS004{
      registration_position: build(:registration_position)
    }
  end

  def registration_position_factory do
    %Bacen.CCS.ACCS004.RegistrationPosition{
      conglomerate: build(:conglomerate),
      persons: build(:accs004_persons),
      movement_date: "2021-05-07"
    }
  end

  def conglomerate_factory do
    %Bacen.CCS.ACCS004.RegistrationPosition.Conglomerate{
      participant: build_list(1, :participant)
    }
  end

  def participant_factory do
    cnpj =
      Brcpfcnpj.cnpj_generate()
      |> String.slice(0..7)

    %Bacen.CCS.ACCS004.RegistrationPosition.Conglomerate.Participant{
      cnpj: cnpj
    }
  end

  def accs004_persons_factory do
    cnpj =
      Brcpfcnpj.cnpj_generate()
      |> String.slice(0..7)

    %Bacen.CCS.ACCS004.RegistrationPosition.Persons{
      cnpj: cnpj,
      person: build(:accs004_person)
    }
  end

  def accs004_person_factory do
    %Bacen.CCS.ACCS004.RegistrationPosition.Persons.Person{
      cpf_cnpj: Brcpfcnpj.cpf_generate(),
      start_date: "2021-05-07",
      end_date: nil,
      type: "F"
    }
  end
end
