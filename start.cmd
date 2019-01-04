FOR %%A IN (bot_rest bot_gateway bot_cache bot_lavalink bot_handler) DO cd apps/%%A && start cmd.exe /k iex --name %%A@127.0.0.1 -S mix && cd ../.. && timeout 5

PAUSE