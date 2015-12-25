-- Shallow copy a Lua array
local function copy_array(xs)
  local ys = {}
  for i,x in ipairs(xs) do ys[i] = x end
  return ys
end


-- Receives an array with a set of possible values for each position
-- Returns an iterator over arrays of values.
--
-- example: {{a,A},{b,B}} --> (ab, aB, Ab, AB)
local function combinations(xss)
  return coroutine.wrap(function()
    local buf = {}
    function go(i)
      if i > #xss then 
         coroutine.yield( copy_array(buf) )
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

-- Given a pair of lists, determines if one is a prefix of the other
--
-- examples:
--  is_prefix_or_suffix({1,2}, {1,2,3}) --> true
--  is_prefix_or_suffix({1,2,3}, {1,2}) --> true
--  is_prefix_or_suffix({1,2}, {4,5,6}) --> false
local function is_prefix_or_suffix(xs, ys)
  for i = 1, math.min(#xs, #ys) do
    if xs[i] ~= ys[i] then return false end
  end
  return true
end


--
--
local function supercurry(argspec, the_function)

  return function(...)

    -- param_name -> param_value
    local received = {}

    local function get_unused_positional_arg()
      for _, arg in ipairs(argspec) do
        if received[arg.name] == nil then
          return arg
        end
      end
      return nil, "Too many arguments"
    end

    local function get_unused_named_arg(name)

      for _, arg in ipairs(argspec) do
        if arg.name == name then
          if received[arg.name] == nil then
            return arg
          else
            return nil, "Duplicate argument "..name
          end
        end
      end
      return nil, "Unknown argument "..name
    end

    local function received_args_plus_defaults()
      local final_args = {}
      for i, arg in ipairs(argspec) do
        local value = received[arg.name]
        if value ~= nil then
          final_args[i] = value
        elseif arg.optional then
          final_args[i] = arg.default
        else
          return nil, "Missing arguments"
        end
      end
      return final_args
    end

    local function supercurried(...)
      for _, x in ipairs({...}) do
        if type(x) == 'table' then
          for name, value in pairs(x) do
            local arg = assert( get_unused_named_arg(name) )
            received[arg.name] = value
          end
        else
          local arg = assert( get_unused_positional_arg() )
          received[arg.name] = x
        end
      end

      -- Am I done reading arguments?
      local final_args = received_args_plus_defaults()
      if final_args then
        return the_function(table.unpack(final_args))
      else
        return supercurried
      end
    end

    return supercurried(...)
  end
end



return {
  copy_array = copy_array,
  is_prefix_or_suffix = is_prefix_or_suffix,
  combinations = combinations,
  supercurry = supercurry,
}
