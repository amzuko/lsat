require("util")
local parse = require("parse")
local formula = require("formula")

local assert_count = 0
function assert_eq(actual, expected, message)
	assert_count = assert_count + 1
	if not table_eq(expected, actual) then
		error (message or ("Expected " .. table_tostring(expected) ..
							" got " .. table_tostring(actual)),
				2)
	end
end

-- This asserts that the two formula's clauses are the same, assuming that
-- each clause is ordered the same.
function assert_formula_similar(actual, expected, message)
	for k, v in pairs(actual.Clauses) do

	end
end


local TestSat = {}



-- File based test cases.
function runSat(filename)
	local file = io.open("tests/"..filename)
	local formula = parse.parse(file:read("*a"))
	file:close()
	if file == nil then
		error("Parse error in "..filename)
	end
end

local file_cases = {
	"quinn.cnf",
	"simple_v3_c2.cnf"
}

for _,file in ipairs(file_cases) do
	TestSat[file] = function()
		runSat(file)
	end
end

-- End file based test cases

TestSat.testUnitClausePropagation = function()
	-- example from wikipedia's page on unit propagation
	local f = parse.Parse(
[[p cnf 4 4
1 2 0
-1 3 0
-3 4 0
1 0]])

	local result = formula.UnitPropagation(f)
	assert_eq(result, )
end


local lpeg = require "lpeg"

TestSat.testParsePrimitives = function()
	assert_eq(lpeg.match(parse.term, "-123"), {false, "123"})
	assert_eq(lpeg.match(parse.term, "123"), {true, "123"})

	assert_eq(lpeg.match(parse.comment, "c hello world"), 14)

	assert_eq(lpeg.match(parse.problem, "p cnf 123 345"), {123, 345})

	assert_eq(lpeg.match(parse.whitespace, " 	"), 3)
	assert_eq(lpeg.match(parse.whitespace, "  "), 3)
	assert_eq(lpeg.match(parse.whitespace, " "), 2)

	assert_eq(lpeg.match(parse.clause, "123 -456 0"), {["123"] = true, ["456"] = false})

	assert_eq(lpeg.match(parse.pattern,
[[c I am a comment
p cnf 3 2
1 2 0
-2 -3 0
]]), {{3, 2}, {["1"]= true, ["2"]=true}, {["2"]= false, ["3"]= false}})
end

function main()
	local failures = {}
	for k,v in pairs(TestSat) do
		print("starting "..k.."...")
		local status, err = pcall(v)
		if not status then
			failures[k] = err
		end
		print("      ...finished "..k..".")
	end

	local n_failures = table_length(failures)
	print(table_length(TestSat).." total tests, "..assert_count.." assertions made.")
	print(table_length(TestSat) - n_failures .." Successes.")

	if n_failures == 0 then
		return 0
	else
		print(n_failures .. " Failures:")
		for k,v in pairs(failures) do
			print(k .. " : ", v)
		end
		return 1
	end
end

main()