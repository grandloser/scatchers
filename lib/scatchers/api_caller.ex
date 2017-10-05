defmodule Scatchers.APICaller do

  def pull_search_result do
    IO.puts "#{DateTime.utc_now()} :: API call start"
    url = "https://www.mercari.com/jp/search/?keyword=%E3%83%99%E3%82%A2%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF"
    {:ok, resp} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])
    res = Floki.find(resp.body, ".items-box")
    |> Enum.map(fn x -> Floki.find(x, "a") end)
    # IO.puts "API call end #{inspect resp}"
    res
  end

  def translate_to_korean(txt) do
    url = "https://translation.googleapis.com/language/translate/v2?key=#{key(:google_api)}"
    post_body = %{
      "source" => "ja",
      "target" => "ko",
      "q" => txt
    }
    |> Poison.encode!
    {:ok, resp} = HTTPoison.post(url, post_body, %{"Content-Type" => "application/json"})

    resp.body
    |> Poison.decode!
    |> extract_translated_text
  end

  def extract_translated_text(%{"data" => %{"translations" => list}}) do
    list |> List.first |> Map.get("translatedText")
  end

  def key(:google_api), do: Application.get_env(:scatchers, __MODULE__)[:google_api_key]

end
