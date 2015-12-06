defmodule Model.FindMethodTest do
  use ExUnit.Case

  setup_all do
    Neo4j.Sips.query(Neo4j.Sips.conn, "MATCH (n {doe_family: true}) OPTIONAL MATCH (n)-[r]-() DELETE n,r")
    assert {:ok, john} = Person.create(name: "John DOE", email: "john.doe@example.com",
                                       age: 30, doe_family: true,
                                       enable_validations: true)
    assert john != nil
    assert {:ok, jane} = Person.create(name: "Jane DOE", email: "jane.doe@example.com",
                                       age: 25, enable_validations: true, doe_family: true,
                                       married_to: john)
    on_exit({john, jane}, fn ->
        assert :ok = Person.delete(john)
        assert :ok = Person.delete(jane)
      end)
    :ok
  end

  test "find the two Doe family members with results" do
    {:ok, people} = Person.find(doe_family: true)
    assert Enum.count(people) == 2
  end

  test "find Jane DOE" do
    persons = Person.find!(name: "Jane DOE")
    assert length(persons) == 1

    person = List.first(persons)
    assert person.name == "Jane DOE"
    assert person.email == "jane.doe@example.com"
    assert person.age == 25
  end

  test "find John DOE" do
    persons = Person.find!(name: "John DOE")
    assert length(persons) == 1

    person = List.first(persons)
    assert person.name == "John DOE"
    assert person.email == "john.doe@example.com"
    assert person.age == 30
  end

  test "John is married to Jane" do
    jane = Person.find!(name: "Jane DOE") |> List.first
    assert jane.name == "Jane DOE"
    john = Person.find!(name: "John DOE") |> List.first
    assert john.name == "John DOE"

    johns_spouse = john.married_to |> List.first
    assert johns_spouse.name == jane.name
  end

end
