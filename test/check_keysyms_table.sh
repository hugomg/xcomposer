#! /bin/sh
currdir=$(dirname "$0")
cd "$currdir/../src"
lua "../test/check_keysyms_table.lua" | xdotool -
