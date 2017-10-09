defmodule Scatchers.Catchers do
  use GenServer

  require Logger

  alias Scatchers.{APICaller, MisterSendo}

  @interval 0
  @size_limit 150

  def start_link(num) do
    IO.puts "#{num} :: started!@!!!!!!!!!!!!!!!!!!!!"
    GenServer.start_link(__MODULE__, %{name: num})
  end

  def init(state) do
    schedule_work(:init)
    IO.puts "init"

    {:ok, state}
  end

  defp schedule_work(type) do
    # IO.puts "#{DateTime.utc_now()} :: #{inspect self()} :: schedule_work #{inspect type}"
    Process.send_after(self(), {type, :scrape}, @interval)
  end

  def handle_info({flag, :scrape}, %{name: num} = state) do

    start_dt = DateTime.utc_now()
    schedule_work(:after)
    # IO.puts "#{DateTime.utc_now()} :: scrape starats"
    APICaller.pull_search_result
    |> update_result(flag, state)

    # IO.puts "#{DateTime.utc_now()} :: scrape ended"
    end_dt = DateTime.utc_now()
    IO.puts "#{DateTime.utc_now()} :: SCV ##{num} :: #{DateTime.diff(end_dt, start_dt)} - time elapsed for API call"

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
      
    end)
    %{}
  end

  def in_cache?(href) do
    case Cachex.get(:cache, href) do
      {:missing, _} -> 
        Cachex.set(:cache, href, true)
        false
      _ -> true
    end
    false
  end

  def notification_sendo(x) do
    IO.puts "notification sent for #{inspect x}"
    MisterSendo.send_email(x)
  end
end
