defmodule Neo4j.Sips.Http do
  @moduledoc """

  module responsible with prepping the headers and delegating any requests to
  HTTPoison
  """
  use HTTPoison.Base

  @base_headers [
    "Accept": "application/json; charset=UTF-8",
    "Content-Type": "application/json; charset=UTF-8",
    "User-Agent": "Neo4j.Sips client",
    "X-Stream": "true"
  ]

  @doc false
  @spec process_request_headers(map) :: map
  def process_request_headers(header) do
    headers ++ header
  end

  defp headers do
    @base_headers ++ ["Authorization": "Basic #{token_auth}"]
  end

  defp token_auth do
    basic_auth = Neo4j.Sips.config[:basic_auth]
    token_auth = Neo4j.Sips.config[:token_auth]

    cond do
      token_auth != nil ->
        token_auth

      basic_auth != nil ->
        username = basic_auth[:username]
        password = basic_auth[:password]
        Base.encode64("#{username}:#{password}")
    end
  end

end
