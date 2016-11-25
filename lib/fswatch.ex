defmodule FsWatch do

  use GenServer
  require Logger

  @flags ["NoOp", "PlatformSpecific", "Created", "Updated", "Removed", "Renamed",
  "OwnerModified", "AttributeModified", "MovedFrom", "MovedTo", "IsFile", "IsDir",
  "IsSymLink", "Link", "Overflow"]

  def start_link(args, options \\ []) do
    GenServer.start_link(__MODULE__, args, [name: args[:name]] ++ options)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  ### GenServer callbacks ###

  def init(args) do
    start_watcher(args)
    {:ok, %{folder: args[:folder], callback: args[:callback]}}
  end

  def handle_info({_pid, :data, :out, raw}, config) do
    raw
      |> String.replace_trailing("\n", "")
      |> String.split("\n")
      |> Enum.map(&extract_events(&1))
      |> Enum.each(fn(data) ->
        IO.puts(":: watcher :: #{inspect data}")
        config.callback.(data)
      end)
    {:noreply, config}
  end

  # The catch-all clause, that discards any unknown message
  def handle_info(_msg, config) do
    {:noreply, config}
  end

  ### Helpers ###

  @spec start_watcher(list) :: none
  defp start_watcher(args) do
    folder = args[:folder]
    Porcelain.spawn_shell "fswatch -xr #{folder}", out: {:send, self}
    Logger.info ~s(Started watching "#{folder}" folder for changes.)
  end

  @spec extract_events(charlist) :: tuple
  defp extract_events(line) do
    line = line
      |> String.split(" ")
      |> Enum.reverse()
    extract_events line, []
  end

  @spec extract_events(list, list) :: tuple
  defp extract_events([head | tail], events) do
    if head in @flags do
      event = head
        |> Macro.underscore
        |> String.to_atom
        |> List.wrap
      extract_events tail, event ++ events
    else
      path = [head] ++ tail
        |> Enum.reverse
        |> Enum.join(" ")
      { path, events }
    end
  end

end
