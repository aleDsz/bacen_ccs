defmodule Bacen.CCS.ACCS002Test do
  use Bacen.CCS.EctoCase
  doctest Bacen.CCS.ACCS002

  import Bacen.CCS.ACCS002
  alias Bacen.CCS.ACCS002

  describe "new/1" do
    test "builds a new ACCS002" do
      attrs = params_for(:accs002)

      assert {:ok,
              %ACCS002{
                response: %ACCS002.Response{
                  error: nil,
                  last_file_id: "000000000000",
                  movement_date: ~D[2021-05-07],
                  reference_date: ~U[2021-05-07 05:04:00Z],
                  status: "A"
                }
              }} == new(attrs)
    end
  end

  describe "ACCS002" do
    test "validates the existence of response field" do
      changeset = refute_valid_changeset changeset(%ACCS002{}, %{})
      assert "can't be blank" in errors_on(changeset).response
    end
  end

  describe "Response" do
    alias Bacen.CCS.ACCS002.Response

    test "validates the existence of fields" do
      changeset = refute_valid_changeset response_changeset(%Response{}, %{})

      assert errors_on(changeset) == %{
               last_file_id: ["can't be blank"],
               movement_date: ["can't be blank"],
               reference_date: ["can't be blank"],
               status: ["can't be blank"]
             }
    end

    test "validates the status field" do
      attrs = params_for(:response, status: "foo")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "is invalid" in errors_on(changeset).status
      assert "should be 1 character(s)" in errors_on(changeset).status
    end

    test "validates the existence of error field" do
      attrs = params_for(:response, status: "R")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "can't be blank" in errors_on(changeset).error
    end

    test "validates the length from last_file_id field" do
      attrs = params_for(:response, last_file_id: "0000000000000")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "should be 12 character(s)" in errors_on(changeset).last_file_id
    end

    test "validates the length from error field" do
      attrs = params_for(:response, status: "R", error: "ERRO12345")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "should be 8 character(s)" in errors_on(changeset).error
    end

    test "validates the format from last_file_id field" do
      attrs = params_for(:response, last_file_id: "00000A000000")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "has invalid format" in errors_on(changeset).last_file_id
    end

    test "validates the format from error field" do
      attrs = params_for(:response, status: "R", error: "E1RO12A4")
      changeset = refute_valid_changeset response_changeset(%Response{}, attrs)

      assert "has invalid format" in errors_on(changeset).error
    end
  end
end
