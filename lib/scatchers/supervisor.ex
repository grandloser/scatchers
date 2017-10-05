defmodule Scatchers.Supervisor do
  use Supervisor

   def start_link do
     Supervisor.start_link(__MODULE__, :ok)
   end

   def init(:ok) do

    children = Enum.reduce(1.. 15, [], fn num, acc -> 
      acc ++ [worker(Scatchers.Catchers, [num], [restart: :transient, id: num])]
    end)

    Supervisor.init(children, strategy: :one_for_one)
   end
end
