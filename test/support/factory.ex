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
      movement_date: ~D[2021-05-07],
      quantity: 1,
      persons: build(:persons)
    }
  end

  def persons_factory do
    %Bacen.CCS.ACCS001.DailyUpdate.Persons{
      person: build_list(1, :person)
    }
  end

  def person_factory do
    %Bacen.CCS.ACCS001.DailyUpdate.Persons.Person{
      cpf_cnpj: Brcpfcnpj.cpf_generate(),
      start_date: ~D[2021-05-07],
      operation_qualifier: "C",
      type: "F",
      operation_type: "I"
    }
  end
end
