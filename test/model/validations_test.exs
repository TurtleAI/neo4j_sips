defmodule Model.ValidationsTests do
  use ExUnit.Case
  import Mock

  test "missing required model field" do
    {:nok, nil, person} = Person.create(name: "John Doe", age: 30)
    assert Enum.find(person.errors[:email], &(&1 == "model.validation.required")) != nil
  end

  test "validates uniqueness" do
    assert {:ok, person} = Person.create(name: "John Doe", doe_family: true, email: "john.doe@example.com", age: 30)

    enable_mock do
      cypher = """
        MATCH (n) where ID(n) == #{person.id}
        RETURN id(n), n
      """

      expected_response = [
        %{"id(n)" => person.id,
            "n" => %{"name" => "John DOE","email" => "john.doe@example.com", "neo4j_sips" => true,
            "age" => 30, "created_at" => "2015-11-02 17:17:17 +0000",
            "updated_at" => "2015-11-02 17:17:17 +0000"}}]

      cypher_returns { :ok, expected_response }, for_query: cypher

      {:nok, nil, p} = Person.create(name: "John Doe", email: "john.doe@example.com", age: 30) |> IO.inspect

      assert Enum.find(p.errors[:email], &(&1 == "model.validation.unique")) != nil
      # IO.puts("deleting person: #{inspect(person)}")
      assert :ok = Person.delete(person), "cannot delete a model"
    end

  end

  test "invalid mail format" do
    {:nok, nil, person} = Person.create(name: "John Doe", email: "johndoe.example.com", age: 30)
    assert Enum.find(person.errors[:email], &(&1 == "model.validation.invalid")) != nil
  end

  test "invalid age value" do
    {:nok, nil, person} = Person.create(name: "John Doe", email: "john.doe@example.com", age: -30)
    assert Enum.find(person.errors[:age], &(&1 == "model.validation.invalid_age")) != nil
  end
end
