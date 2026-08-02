#!/bin/sh
# Install or update Voice Manager's slash commands.
# Run this file, then pick an option from the menu.
cd "$(dirname "$0")"
"$(dirname "$0")/../luvit" initSlash.lua
