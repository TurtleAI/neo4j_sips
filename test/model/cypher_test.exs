defmodule CypherTest do
  use ExUnit.Case
  use Neo4j.Sips.Cypher

  import Mock

  test "execute a query without arguments" do
    enable_mock do
      query = "match (n) return n"

      expected_response = """
      {
        "errors": [],
        "results": [
          {
            "columns": ["n"],
            "data": [
              {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]}
            ]
          }
        ]
      }
      """

      http_client_returns expected_response,
        for_query: query,
        with_params: %{}

      {:ok, results} = run(query)
      assert Enum.count(results) == 1

      item = results |> List.first |> Map.get("n")
      assert item["name"] == "John Doe"
      assert item["email"] == "john@doe.dummy"
      assert item["type"] == "customer"
    end
  end

  test "execute a query with arguments" do
    enable_mock do
      query = "match (n {props}) return n"
      params = %{props: %{name: "John Doe"}}

      expected_response = """
      {
        "errors": [],
        "results": [
          {
            "columns": ["n"],
            "data": [
              {"row": [{"name":"John Doe","email":"john@doe.dummy","type":"customer"}]}
            ]
          }
        ]
      }
      """

      http_client_returns expected_response,
        for_query: query,
        with_params: params

      {:ok, results} = run(query, params)
      assert Enum.count(results) == 1

      item = results |> List.first |> Map.get("n")
      assert item["name"] == "John Doe"
      assert item["email"] == "john@doe.dummy"
      assert item["type"] == "customer"
    end
  end

end
