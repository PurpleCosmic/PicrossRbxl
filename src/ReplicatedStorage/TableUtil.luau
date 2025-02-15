--!strict
local function deepEqual(tbl1: {}, tbl2: any)
	if typeof(tbl1) ~= typeof(tbl2) then return false end
	for k, v in pairs(tbl1) do
		local eq;
		if typeof(v) == "table" then
			eq = deepEqual(v, tbl2[k])
		else
			eq = v == tbl2[k]
		end
		if eq == false then
			return false
		end
	end
	return true
end

local function tblToString(tbl: any)
	if typeof(tbl) ~= "table" then return tostring(tbl) end
	local str = "{"
	for k, v in tbl do
		if typeof(k) == "number" then
			str ..=  `{tblToString(v)}, `
		else
			str ..= `[{tblToString(k)}] = {tblToString(v)},`
		end
	end
	if str:len() > 1 then str = str:sub(1, -3)	end
	return str.."}"	
end

local function assertEq(expected: {}, actual: any)
	assert(deepEqual(expected, actual), `Expected: {tblToString(expected)}\nActual: {tblToString(actual)}`)
end


local module = {
	toString = tblToString,
	deepEqual = deepEqual,
	assertEq = assertEq
}

return module
