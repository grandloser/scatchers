defmodule Scatchers.APICaller do

  def pull_search_result do
    url = "https://www.mercari.com/jp/search/?keyword=%E3%83%99%E3%82%A2%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF"
    {:ok, resp} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])
    res = Floki.find(resp.body, ".items-box")
    |> Enum.map(fn x -> Floki.find(x, "a") end)
    res
  end

end
