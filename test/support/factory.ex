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
end
