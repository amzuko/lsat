-- Parser for cnf file formats
-- See http://people.sc.fsu.edu/~jburkardt/data/cnf/cnf.html for information

-- We're going to use the (excellent) lpeg library
local lpeg = require "lpeg"
local formula = require "formula"

local C = lpeg.C
local Ct = lpeg.Ct
local R = lpeg.R
local P = lpeg.P

local endline = P'\n'
local whitespace = lpeg.S(' \t')^0

local number = C(R("09")^1)/function(a) return tonumber(a) end


local term = Ct(C(P('-')^-1)/function(a) return a ~= '-' end * C(R("09")^1 - P("0")))

local assembleClause = function(items)
	local res = {}
	for _,v in ipairs(items) do
		if res[v[2]] then
			error("Literal " .. v[2] .." included twice in clause.")
		end
		res[v[2]] = v[1]
	end
	return res
end


local comment = P('c') * (1 - P'\n')^0
local problem = Ct(P'p cnf ' * number * P' ' * number)
local clause = Ct((term * whitespace)^1) * P('0') / assembleClause

local pattern = Ct(
	(whitespace * comment * endline) ^ 0 *
	whitespace * problem * endline *
	(whitespace * (clause + comment) * endline) ^ 0
)


local parse = function(str)
	local result = lpeg.match(pattern, str)
	if result == nil then
		error "Parse error."
	end
	local f = formula.New()
	-- The first item in result contains the program specification
	for i=2,#result do
		f = formula.AddClause(f, result[i])
	end
	if table_length(f.Literals) ~= result[1][1] then
		error("Missing literals: expected "..result[1][1].." got "..table_length(f.Literals))
	end

	if #f.Clauses ~= result[1][2] then
		error("Missing clauses: expected "..result[1][2].." got "..#f.Clauses)
	end

	return f
end


return {
	whitespace = whitespace,

	term = term,
	comment = comment,
	problem = problem,
	clause = clause,

	pattern = pattern,

	parse = parse
}