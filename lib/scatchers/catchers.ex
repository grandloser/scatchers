defmodule Scatchers.Catchers do
  use GenServer

  require Logger

  alias Scatchers.{APICaller, MisterSendo}

  @interval 5_000
  @size_limit 150

  def start_link do
    IO.puts "started!@!!!!!!!!!!!!!!!!!!!!"
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(:init)
    IO.puts "init"

    {:ok, state}
  end

  defp schedule_work(type) do
    IO.puts "schedule_work #{inspect type}"
    Process.send_after(self(), {type, :scrape}, @interval)
  end

  def handle_info({flag, :scrape}, state) do

    IO.puts "scrape starats"
    state =
      APICaller.pull_search_result
      |> update_result(flag, state)

    schedule_work(:after)
    {:noreply, state}
  end

  def update_result(result, flag, state) do
    state = result
    |> Enum.filter( fn x ->
      href = x |> Floki.attribute("href")

      !in_cache?(href)
    end)
    |> Enum.each(fn x ->
      IO.puts "new one detected #{inspect Floki.attribute(x, "href")}"
      if(flag != :init) do
        notification_sendo(x)
      else
        Logger.info "init completed"
      end
      Cachex.set(:cache,Floki.attribute(x, "href"), x)
    end)
    %{}
  end

  def in_cache?(href) do
    case Cachex.get(:cache, href) do
      {:missing, _} -> false
      _ -> true
    end
  end

  def notification_sendo(x) do
    IO.puts "notification sent for #{inspect x}"
    MisterSendo.send_email(x)
  end
end
