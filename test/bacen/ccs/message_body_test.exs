defmodule Bacen.CCS.MessageBodyTest do
  use Bacen.CCS.EctoCase

  alias Bacen.CCS.MessageBody

  test "type/0 returns map type" do
    assert MessageBody.type() == :map
  end

  describe "cast/1" do
    test "casts successfully an ACCS message type" do
      message = build(:accs001)
      assert {:ok, message} == MessageBody.cast(message)
    end
  end

  describe "load/1" do
    test "loads successfully an ACCS message type" do
      data = string_params_for(:accs001)
      assert {:ok, data} == MessageBody.load(data)
    end
  end

  describe "dump/1" do
    test "dumps successfully an ACCS message type" do
      data = string_params_for(:accs001)
      assert MessageBody.dump(data) == data
    end
  end
end
