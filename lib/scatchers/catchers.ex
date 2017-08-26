defmodule Scatchers.Catchers do
  use GenServer

  require Logger

  alias Scatchers.{APICaller, MisterSendo}

  @interval 5_000

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

      !Map.has_key?(state, href)
    end)
    |> Enum.reduce(state, fn x, state ->
      IO.puts "new one detected #{inspect Floki.attribute(x, "href")}"
      if(flag == :init) do
        notification_sendo(x)
      else
        Logger.info "init completed"
      end

      Map.put(state, Floki.attribute(x, "href"), x)
    end)
    state
  end

  def notification_sendo(x) do
    IO.puts "notification sent for #{inspect x}"
    MisterSendo.send_email(x)
  end
end
