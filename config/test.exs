use Mix.Config

config :neo4j_sips, Neo4j,
  url: "http://localhost:7373",
  pool_size: 15,
  max_overflow: 5
