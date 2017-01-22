local v3 = {}
v3.__index = v3
setmetatable(v3, v3)

function v3:__call(x, y, z)
	local o = setmetatable({}, self)
	if type(x) == "table" then
		o.x = x.x
		o.y = x.y
		o.z = x.z
	else
		o.x = x
		o.y = y
		o.z = z
	end
	return o
end

function length( a )
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function v3:normalize()
	magnitude = length(self)
	self.x = self.x / magnitude
	self.y = self.y / magnitude
	self.z = self.z / magnitude
end

-- pro tip - don't use : for arithmetic metamethods or else a gets replaced with self (nil)
function v3.__add(a, b)
	return v3(a.x + b.x, a.y + b.y, a.z + b.z)
end

function v3.__sub(a, b)
	return v3(a.x - b.x, a.y - b.y, a.z - b.z)
end

function v3.__mul(a, b)
	if (type(a) == "number") then
		return v3(a * b.x, a * b.y, a * b.z)
	elseif (type(b) == "number") then
		return v3(b * a.x, b * a.y, b * a.z)
	end

	return a.x * b.x + a.y * b.y + a.z * b.z
end

function v3.__div(a, b)
	return v3(a.x / b, a.y / b, a.z / b)
end

function v3:normalized()
	magnitude = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	return v3(self.x / magnitude, self.y / magnitude, self.z / magnitude)
end

return v3