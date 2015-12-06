defmodule Neo4j.Sips.Model.ParseNodeMethod do
  def generate(_metadata) do
    quote do
      def parse_node(node_data) do
        Neo4j.Sips.Model.NodeParser.parse(__MODULE__, node_data)
      end
    end
  end
end
