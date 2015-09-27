local keysyms = require 'xcomposer.keysyms'
local utf8    = require 'dromozoa.utf8'

-- Check utf8-representations
for _, t in ipairs(keysyms) do
  assert(utf8.char(t.code) == t.str)
end

-- Check correcness of keysyms
-- Pipe this output to xdotool:
--   lua test/check_keysyms.lua | xdotool -
io.stderr:write("Typing to screen in 3 seconds...\n")
io.write("sleep 3\n")
for _, t in ipairs(keysyms) do
  io.write("key ", string.format("U%04X", t.code), "\n")
  --io.write("key ", t.live, "\n")
  io.write("key space\n")
  for x in t.live:gmatch('.') do
    io.write("key ",x,"\n")
  end
  io.write("key Return\n")
end
