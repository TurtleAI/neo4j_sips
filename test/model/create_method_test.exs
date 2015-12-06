defmodule Model.CreateMethodTest do
  use ExUnit.Case
  import Mock

  test "parses responses to successful save requests" do
    enable_mock do
      query = """
      CREATE (n:Test:Person { properties }) RETURN id(n), n
      """

      query_params = %{
               email: "john.doe@example.com",
                name: "John DOE",
          created_at: "2015-11-02 17:17:17 +0000",
          updated_at: "2015-11-02 17:17:17 +0000"
      }

      expected_response = [
        %{
          "id(n)" => 81776,
            "n" => %{"name" => "John DOE","email" => "john.doe@example.com",
            "created_at" => "2015-11-02 17:17:17 +0000",
            "updated_at" => "2015-11-02 17:17:17 +0000"}
        }
      ]

      cypher_returns { :ok, expected_response },
        for_query: query,
        with_params: query_params

      {:ok, person} = Person.create(name: "John DOE", email: "john.doe@example.com", age: 10)

      assert person.id == 81776
      assert person.name == "John DOE"
      assert person.email == "john.doe@example.com"
      assert person.created_at == "2015-11-02 17:17:17 +0000"
      assert person.updated_at == "2015-11-02 17:17:17 +0000"
    end
  end

  test "parses responses to failed save requests" do
    enable_mock do
      query = """
      CREATE (n:Test:Person { properties })
      RETURN id(n), n
      """

      query_params = %{
          :email      => "john.doe@example.com",
          :name       => "John DOE",
          :created_at => "2015-11-02 17:17:17 +0000",
          :updated_at => "2015-11-02 17:17:17 +0000"
      }

      expected_response = [
        %{
          code: "Neo.ClientError.Statement.InvalidSyntax",
          message: "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
        }
      ]

      cypher_returns { :error, expected_response },
        for_query: query,
        with_params: query_params

      {:nok, [resp], _person} = Person.create(name: "John DOE", email: "john.doe@example.com", enable_validations: false)

      assert resp.code == "Neo.ClientError.Statement.InvalidSyntax"
      assert resp.message == "Invalid input 'T': expected <init> (line 1, column 1)\n\"This is not a valid Cypher Statement.\"\n ^"
    end
  end
end
