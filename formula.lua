require"util"

-- Represent formulas in Conjunctive Normal Form -- product of sums
local function New()
	return {
	-- Clauses stores a list of clauses for this formula, where each clause
	-- is a map from literal to truth state:
	-- { ["1"] = true, ["2"] = false}
	-- for a ^ ~b
		Clauses = {},
	-- Literals holds a map from literal id eg, "123" to the list of clause
	-- indices containing that ltieral. eg "123" = {4,67,123}
	-- TODO(andrew): consider whether this should just directly hold references
	-- to the clauses, so that we would have to do less "pointer arithmetic"
	-- when updating formulas to eliminate clauses
		Literals = {},
	-- internal counter for generating clause indices
		count = 0

	}
end

-- In functional style, return a new formula that contains an additional clause
local function AddClause(f, clause)
	local res = table_copy(f)

	id = 
	res.Clauses[f.count] = clause


	for k,v in pairs(clause) do
		if res.Literals[k] == nil then
			res.Literals[k] = {}
		end
		res.Literals[k][#(res.Literals[k]) + 1] = #res.Clauses + 1
	end
	return res
end

local function getOneKey(table)
	for k,_ in pairs(table) do
		return k
	end
end

-- Although as this is largely mixed functionalish crapstyle, several of the
-- following functions are pretty simply re-expressed with map(), filter(), etc.
local function getUnitClauseLiterals()
	local ret = {}
	for _,v in pairs(f.Clauses) do
		if table_length(v) == 1 then
			local k = getOneKey(v)
			ret[k] = v[k]
		end
	end
	return ret
end

local function ConsistentUnitClausesOnly()
	local check = {}
	for _,v in pairs(f.Clauses) do
		if table_length(v) ~= 1 then
			return false
		end
		local l = getOneKey(v)
		if check[l] ~= nil and check[l] ~= value then
			-- This formula is unsatisfiable, actually.
			return false
		end
		check[l] = value
	end
end

local function ContainsEmptyClauses()
	for _,v in pairs(f.Clauses) do
		if table_length(v) == 0 then
			return true
		end
	end
	return false
end

-- Greedily perform all available unit-propagation
-- TODO(Andrew) consider writing this recursively
local function UnitPropagate(f)
	local ret = table_copy(f)
	local lits = getUnitClauseLiterals(ret)
	local old_length = -1
	-- We're going to propogate unit clauses through the formula to reduce clause
	-- complexity. As this may generate new 
	while(table_length(lits) > 0 and old_length ~= table_length(lits)) do
		for literal, value in pairs(lits) do
			ret = UnitPropagateSingle(ret, literal)
		end

		old_length = table_length(lits)
		lits = getUnitClauseLiterals(ret)
	end
	return ret
end

local function UnitPropagateSingle(f, literal)
	local ret = table_copy(f)

	local saw_unit = false
	for i, clause_index in ipairs(ret.Literals[literal]) do
		local clause = ret.Clauses[clause_index]

		-- If the reference inside clause has the same polarity as the unit
		-- refrence
		if clause[literal] == value then
			if ~saw_unit and table_length(clause) == 1 then
				saw_unit = true
			else
				-- remove the clause; we don't need to keep multiple
				-- duplicate unit clauses around
				ret.Clauses[clause_index] = nil
				-- remove the reference to that clause from the literal
				table.remove(ret.Literals[literal], i)
			end
		else
			-- IT's the opposite, so we can just eliminate this literal from the
			-- clause, replacing the existing clause with a new clause
			-- containing all the original clauses literals except for the
			-- literal in question.
			ret.Clauses[clause_index] = {}
			for k, v in pairs(clause) do
				if k ~= literal then
					ret.Clauses[clause_index][k] = v
				end
			end
		end
	end
	return ret
end

local function ChooseLiteral(f)
	if table_length(f.Literals) == 0 then
		error "No literals to choose from."
	end
	-- Whee, randomish?
	for k,v in range(f.Literals) do
		return k
	end
end



return {
	New = New,
	AddClause = AddClause,
	UnitPropagateSingle = UnitPropagateSingle,
	UnitPropagate = UnitPropagate
}