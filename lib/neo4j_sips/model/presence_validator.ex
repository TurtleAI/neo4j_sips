defmodule Neo4j.Sips.Model.PresenceValidator do
  import Neo4j.Sips.Model.Validator

  def validate(model, field) when is_atom(field) do
    field_value = Map.get model, field
    if field_value == nil || field_value == "" do
      model = add_error model, field, "model.validation.required"
    end

    model
  end
end
