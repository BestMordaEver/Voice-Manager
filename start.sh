#!/bin/sh
# Start Voice Manager. Run this from a terminal.
cd "$(dirname "$0")"
"$(dirname "$0")/../luvit" bot.lua
