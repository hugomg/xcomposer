local cosmo = require 'cosmo'
local utf8 = require 'dromozoa.utf8'

local util    = require 'xcomposer.util'
local keysyms = require 'xcomposer.keysyms'

local ComposeFile = {}
ComposeFile.__index = ComposeFile

ComposeFile.new = function()
  local self = {}
  self.config = {}
  self.config.use_system_compose_file = true
  self.rules = {}
  setmetatable(self, ComposeFile)
  return self
end


local function parse_input(use_compose_key, input)

  local function evt_keysym(s)    return string.format("<%s>", s) end
  local function evt_codepoint(u) return string.format("<U%04X>", u) end

  local possibilities = {}

  if use_compose_key then
    table.insert(possibilities, { evt_keysym('Multi_key') })
  end

  if type(input) == 'string' then
    for c in input:gmatch(utf8.charpattern) do
      local xs = {}
      local k = keysyms[c]
      if k.code then table.insert(xs, evt_codepoint(k.code)) end
      if k.dead then table.insert(xs, evt_keysym(k.dead)) end
      table.insert(possibilities, xs)
    end
  elseif type(input) == 'table' then
    for _, x in ipairs(input) do
      if type(x) == 'number' then
        table.insert(possibilities, {evt_codepoint(x)})
      elseif type(x) == 'string' then
        table.insert(possibilities, {evt_keysym(x)})
      else
        assert(false)
      end
    end
  else
    assert(false)
  end

  return util.combinations(possibilities)
end


-- Rule format:
--   input  = string | list of (codepoint | keysym)
--   output = string
--   compose_key = bool (should the rule start with the compose key?)
function ComposeFile:add_rule(rule)

  for evts in parse_input(rule.compose_key, rule.input) do  
    for _, other_rule in ipairs(self.rules) do
      if util.is_prefix_or_suffix(evts, other_rule.input) then
        error("Rule is prefix or suffix of another rule")
      end
    end

    if type(rule.output) ~= 'string' then
      error("Bad output type")
    end

    table.insert(self.rules, {input = evts, output = rule.output })
  end
end


local generated_header = cosmo.f [[
# THIS FILE WAS AUTOMATICALLY GENERATED BY $(progname)
# DO NOT MODIFY IT BY HAND


]]

local function quote_xcompose_rule_output(str)
  local escaped = str:gsub('[\"\\]', {
    [ '\"' ] = '\\\"',
    [ '\\' ] = '\\\\',
  })
  return '"'..escaped..'"'
end

function ComposeFile:save_to_file(outfile)
  if self.config.use_system_compose_file then
    outfile:write( 'include "%L"\n' )
  end
  for _, rule in ipairs(self.rules) do
    outfile:write(string.format("%s : %s\n",
      table.concat(rule.input, " "),
      quote_xcompose_rule_output(rule.output)))
  end
end

return ComposeFile
