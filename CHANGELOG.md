### Change Log

### 0.1.21 (2015-12-05)

Finally made peace with the [meck](https://github.com/eproxus/meck) framework and decided to keep it around, at least for the legacy tests. Meck is ok, as long as you pay attention to the race conditions. 

This neo4_sips version is stable and can be used for simple yet serious tasks :) Model documentation and some works on the model relationships are still work in progress.


### 0.1.20 (2015-12-06)

Introducing the [Model](https://github.com/florinpatrascu/neo4j_sips/tree/model_intro), one of the few steps remaining before integrating the `neo4j_sips` into a new `Ecto` driver for Neo4j.

Using the Model, you can easily define your own Elixir modules like this:

```elixir
defmodule Person do
  use Neo4j.Sips.Model

  field :name, required: true
  field :email, required: true, unique: true, format: ~r/\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/
  field :age, type: :integer
  field :doe_family, type: :boolean, default: false # used for testing
  field :neo4j_sips, type: :boolean, default: true

  validate_with :check_age

  relationship :FRIEND_OF, Person
  relationship :MARRIED_TO, Person

  def check_age(model) do
    if model.age == nil || model.age <= 0 do
      {:age, "model.validation.invalid_age"}
    end
  end
end

```

and use in various scenarios. Example from various tests file:

```elixir
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

...

# model find
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

...

# serialization
Person.to_json(jane)  

# support for relationships
relationship_names = Person.metadata.relationships |> Enum.map(&(&1.name))
relationship_related_models = Person.metadata.relationships |> Enum.map(&(&1.related_model))
assert relationship_names == [:FRIEND_OF, :MARRIED_TO]
assert relationship_related_models == [Person, Person]

...

#support for validation
test "invalid mail format" do
  {:nok, nil, person} = Person.create(name: "John Doe", email: "johndoe.example.com", age: 30)
  assert Enum.find(person.errors[:email], &(&1 == "model.validation.invalid")) != nil
end

test "invalid age value" do
  {:nok, nil, person} = Person.create(name: "John Doe", email: "john.doe@example.com", age: -30)
  assert Enum.find(person.errors[:age], &(&1 == "model.validation.invalid_age")) != nil
end


## and more
```


This is still work in progress. Imported, refactored and optimized the Model implementation from https://github.com/raw1z/ex_neo4j, big thanks to Rawane Zossou. Work started to refactor the majority of tests. Two bugs, so far, are blocking this code before master merge: incomplete model relationship update support (in development) and a weird tests-related behavior. The tests are passing if executed one by one, but they fail when executed as a whole. The core test suite, under the `basic` folder is fine, example: `mix test test/basic`. However, `mix test` and `mix test test/model` fail randomly, very annoying, sorry. 

Please use this branch with care, and not in production, unless you know what you're doing :)
