#! /usr/bin/lua
-- Rules in .XCompose files are hard to read so I made this script to convert
-- a more readable notation to the official notation

local keysyms = require 'xcomposer.keysyms'

local argparse = require 'argparse'
local utf8     = require 'dromozoa.utf8'

--
-- Util
--

local function exit_with_error(error_msgs)
  io.stderr:write("xcomposer encountered an error:\n")
  io.stderr:write("\n")
  for _, msg in ipairs(error_msgs) do
    io.stderr:write(msg, "\n")
  end
  os.exit(10)
end

--
-- Read the input file
--

local function parse_keysequence(keystr)

  local codepoints = {}
  for c in keystr:gmatch(utf8.charpattern) do
    table.insert(codepoints, c)
  end

  local evts = {}

  -- Lexer state machine:
  local i = 1
  local next_char, escaped, add_char, done

  next_char = function()
    if i > #codepoints then return done() end

    local c = codepoints[i]; i = i + 1
    if     c == '\\' then
      return escaped()
    elseif c == '_'  then
      return add_char(' ')
    else
      return add_char(c)
    end
  end

  escaped = function()
    if i > #codepoints then return false, 'backslash at end of string' end

    local c = codepoints[i]; i = i + 1
    return add_char(c)
  end

  add_char = function(c)
     local sym = keysyms[c]
     if sym then
       table.insert(evts, sym)
       return next_char()
     else
       return false, string.format("Unrecognized character %s (%04X)",
                                   c, utf8.codepoint(c, 1))
    end
  end

  done = function()
    return evts
  end

  return next_char()
end



local function syntax_error(lineno, msg)
  exit_with_error({
      string.format("Syntax error in Line %d: %s",
                    lineno, msg)
  })
end

local function parse_file(infile)
  local the_rules = {}

  local lineno = 0
  while true do
    line = infile:read('*l')
    if not line then break end
    lineno = lineno + 1

    line = line:match("([^#]*)#?.*")
    if line:match("^%s*$") then goto continue end

    local code, output, keystr = line:match("^%s*U(%x+)%s+(%S+)%s+(%S+)")
    if not code then syntax_error(lineno, "bad rule") end

    local keys, err = parse_keysequence(keystr)
    if not keys then syntax_error(lineno, err) end

    table.insert(the_rules, {
      codepoint = tonumber(code, 16),
      keys = keys,
      output = output,
      keystr = keystr,
      lineno = lineno,
    })
    ::continue::
  end

  return the_rules
end

--
-- Check for errors
--

local function is_prefix_or_suffix(evts1, evts2)
  for i = 1, math.min(#evts1, #evts2) do
    if evts1[i] ~= evts2[i] then return false end
  end
  return true
end

local function check_for_errors(the_rules)
  local error_msgs = {}

  for rulei, rule in ipairs(the_rules) do

    -- check that is a single codepoint
    if utf8.len(rule.output) ~= 1 then
      table.insert(error_msgs, (string.format(
                     "Line %d: Rule does not output a single utf8 codepoint",
                     rule.lineno)))
    end

    -- check that codepoint is correct
    local point = utf8.codepoint(rule.output, 1)
    if rule.codepoint ~= point then
      table.insert(error_msgs, (string.format(
                                  "Line %d: Wrong character. Expected '%s' (U%04X), got '%s' (U%04X)",
                                  rule.lineno, utf8.char(rule.codepoint), rule.codepoint, rule.output, point)))
    end

    -- check that is not a prefix or suffix of existing rule
    for rulej = 1, rulei-1 do
      local other_rule = the_rules[rulej]
      if is_prefix_or_suffix(other_rule.keys, rule.keys) then
        table.insert(error_msgs, (string.format(
                       "Incompatible rules:\n  Line %d: %s\n  Line %d: %s",
                       other_rule.lineno, other_rule.keystr,
                       rule.lineno, rule.keystr)))
      end
    end

  end

  if #error_msgs > 0 then
    exit_with_error(error_msgs)
  end

end

--
-- Output
--

-- {{a,A},{b,B}} --> ({a,b}, {a,B}, {A,b}, {A,B})
local function combinations(xss)
  return coroutine.wrap(function()
    local buf = {}
    function go(i)
      if i > #xss then
         coroutine.yield(buf)
      else
        for _, x in ipairs(xss[i]) do
          buf[i] = x
          go(i+1)
        end
      end
    end
    go(1)
  end)
end

local function escape_xcompose_string(str)
  return str:gsub('["\\]', {
    ['\"'] = '\\\"',
    ['\\'] = '\\\\',
  })
end

local function print_rule(rule, outfile)

  local possibilities = { {"<Multi_key>"} }

  for _, sym in ipairs(rule.keys) do
    -- We use numbers because keysyms after 0xFF capitalize incorrectly
    local xs = {}
    if sym.code then table.insert(xs, string.format("<U%04X>", sym.code)) end
    if sym.dead then table.insert(xs, string.format("<%s>", sym.dead)) end
    table.insert(possibilities, xs)
  end

  for evts in combinations(possibilities) do
    outfile:write(string.format('%s : "%s"\n',
      table.concat(evts, " "),
      escape_xcompose_string(rule.output)
    ))
  end
end


--
-- Main
--

local function xcomposer(infile, outfile)
  local the_rules = parse_file(infile)
  check_for_errors(the_rules)

  outfile:write("# THIS FILE WAS AUTOMATICALLY GENERATED BY xcomposer\n")
  outfile:write("# DO NOT MODIFY IT BY HAND\n")
  outfile:write("\n")
  outfile:write("include \"%L\"\n")
  outfile:write("\n")
  for _, rule in ipairs(the_rules) do
    --outfile:write("# ",rule.keystr,'\n')
    print_rule(rule, outfile)
  end
end

--
-- Reading command line parameters
--

local homedir = os.getenv('HOME')
if not homedir then
  io.stderr:write("Could not read $HOME environment variable")
  io.exit(1)
end

for _, envvar in ipairs({"GTK_IM_MODULE", "QT_IM_MODULE"}) do
  local value = os.getenv(envvar)
  if not value then
    io.stderr:write("Composition sequences may not work because the ")
    io.stderr:write(envvar," environment\n")
    io.stderr:write("variable is not set.")
    io.stderr:write(" Consider adding the following to your .xsessionrc:\n")
    io.stderr:write("    export ", envvar, "=\"xim\"\n")
    io.stderr:write("\n")
  end
  if value == "ibus" then
    io.stderr:write("Environment variable ",envvar," is set to \"ibus\" ")
    io.stderr:write("but ibus ignores .XCompose\n")
    io.stderr:write("files. ")
    io.stderr:write("Consider using \"xim\" or another input module")
    io.stderr:write(" that supports .XCompose\n")
    io.stderr:write("\n")
  end
end

local function arg_input(filename)
  if filename == '-' then
    io.stderr:write("Reading from standard input...\n")
    return io.stdin
  else
    return io.open(filename, 'r')
  end
end

local function arg_output(filename)
  if filename == '-' then
    return io.stdout
  else
    return io.open(filename, 'w')
  end
end

local pp = argparse({
    name = "xcomposer",
    description = "A tool for writing readable XCompose rules",
    epilog = "For more info see https://github.com/hugomg/xcomposer",
})
pp:argument({
    name = "input",
    description = "Input file",
    args = 1,
    convert = arg_input,
})
pp:option({
    name = "-o --output",
    description = "Output file",
    args = 1,
    default = homedir..'/.XCompose',
    convert = arg_output,
})


local args = pp:parse()
xcomposer(args.input, args.output)
