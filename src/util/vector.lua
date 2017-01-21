local v3 = {}
v3.__index = v3
setmetatable(v3, v3)

-- overkill unless i add more functionality to v3
function v3:__call(x, y, z)
	local o = setmetatable({}, self)
	o.x = x
	o.y = y
	o.z = z
	return o
end

function v3:normalize()
	magnitude = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	self.x = self.x / magnitude
	self.y = self.y / magnitude
	self.z = self.z / magnitude
end

return v3