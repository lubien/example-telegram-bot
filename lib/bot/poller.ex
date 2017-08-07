defmodule Bot.Poller do
  require Logger
  use GenServer

  def start_link do
    GenServer.start_link(Bot.Poller, [], name: Bot.Poller)
  end

  def init(_) do
    {:ok, 0, 100}
  end

  def handle_info(:timeout, state) do
    new_state =
      Nadia.get_updates([offset: state])
      |> process_updates
    {:noreply, new_state, 100}
  end

  def process_updates({:ok, []}), do: 0
  def process_updates({:ok, updates}) do
    for update <- updates do
      Task.start fn ->
        process_update(update)
      end
    end

    List.last(updates).update_id + 1
  end
  def process_updates({:error, error}) do
    Logger.warn (inspect error)
    0
  end

  def process_update(update) do
    #chat_id = update.message.chat.id
    chat_id = 56732328
    msg = update.message.text
    Nadia.send_message(chat_id, msg)
  end
end
