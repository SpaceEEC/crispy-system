FOR %%A IN (bot_rest bot_gateway bot_cache bot_lavalink bot_handler) DO docker run -e APP_NAME=%%A -v %~dp0:/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build

PAUSE

