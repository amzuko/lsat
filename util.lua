function table_eq(table1, table2)
   local avoid_loops = {}
   function recurse(t1, t2)
      -- compare value types
      if type(t1) ~= type(t2) then return false end
      -- Base case: compare simple values
      if type(t1) ~= "table" then return t1 == t2 end
      -- Now, on to tables.
      -- First, let's avoid looping forever.
      if avoid_loops[t1] then return avoid_loops[t1] == t2 end
      avoid_loops[t1] = t2
      -- Copy keys from t2
      local t2keys = {}
      local t2tablekeys = {}
      for k, _ in pairs(t2) do
         if type(k) == "table" then table.insert(t2tablekeys, k) end
         t2keys[k] = true
      end
      -- Let's iterate keys from t1
      for k1, v1 in pairs(t1) do
         local v2 = t2[k1]
         if type(k1) == "table" then
            -- if key is a table, we need to find an equivalent one.
            local ok = false
            for i, tk in ipairs(t2tablekeys) do
               if table_eq(k1, tk) and recurse(v1, t2[tk]) then
                  table.remove(t2tablekeys, i)
                  t2keys[tk] = nil
                  ok = true
                  break
               end
            end
            if not ok then return false end
         else
            -- t1 has a key which t2 doesn't have, fail.
            if v2 == nil then return false end
            t2keys[k1] = nil
            if not recurse(v1, v2) then return false end
         end
      end
      -- if t2 has a key which t1 doesn't have, fail.
      if next(t2keys) then return false end
      return true
   end
   return recurse(table1, table2)
end

function table_copy (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = table_copy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function table_length( t1 )
   local count = 0
   for k,v in pairs(t1) do
      count = count + 1
   end
   return count
end

function table_tostring(t1)
   if type(t1) ~= 'table' then
      return tostring(t1)
   end
   local s = "{"
   for k,v in pairs(t1) do
      s = s .." "..table_tostring(k).."="..table_tostring(v)..","
   end
   return s.."}"
end

-- returns true if t1 and t2 have the same keys
-- returns false if there exists a key in t1 that does not exist in t2,
-- or vice-versa.
function check_keys(t1, t2)
   for k,_ in pairs(t1) do
      if t2[k] == nil then
         return false
      end
   end
   for k,_ in pairs(t2) do
      if t1[k] == nil then
         return false
      end
   end
   return true
end