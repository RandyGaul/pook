local function GenerateMesh(self)
	local e = v3(math.random(3, 6) / 2, math.random(10, 20) / 2, math.random(3, 6) / 2)
	local p = self.p

	-- TODO: clean this up and move the scaling logic into main.c instead of doing all this weirdness
	self.verts = {
		{p.x + e.x, p.y - e.y, p.z + e.z}, --C
		{p.x + e.x, p.y + e.y, p.z + e.z}, --B
		{p.x - e.x, p.y + e.y, p.z + e.z}, --A
		
		{p.x + e.x, p.y - e.y, p.z + e.z}, --C
		{p.x - e.x, p.y + e.y, p.z + e.z}, --A
		{p.x - e.x, p.y - e.y, p.z + e.z}, --D

		{p.x + e.x, p.y - e.y, p.z - e.z}, --H
		{p.x + e.x, p.y - e.y, p.z + e.z}, --C
		{p.x - e.x, p.y - e.y, p.z + e.z}, --D

		{p.x + e.x, p.y - e.y, p.z - e.z}, --H
		{p.x + e.x, p.y - e.y, p.z + e.z}, --D
		{p.x - e.x, p.y - e.y, p.z - e.z}, --G

		{p.x + e.x, p.y - e.y, p.z - e.z}, --H
		{p.x - e.x, p.y - e.y, p.z - e.z}, --G
		{p.x + e.x, p.y + e.y, p.z - e.z}, --F

		{p.x - e.x, p.y - e.y, p.z - e.z}, --G
		{p.x - e.x, p.y + e.y, p.z - e.z}, --E
		{p.x + e.x, p.y + e.y, p.z - e.z}, --F

		{p.x + e.x, p.y + e.y, p.z + e.z}, --B
		{p.x + e.x, p.y + e.y, p.z - e.z}, --F
		{p.x - e.x, p.y + e.y, p.z - e.z}, --E

		{p.x + e.x, p.y + e.y, p.z + e.z}, --B
		{p.x - e.x, p.y + e.y, p.z - e.z}, --E
		{p.x - e.x, p.y + e.y, p.z + e.z}, --A
		
		{p.x + e.x, p.y - e.y, p.z + e.z}, --D
		{p.x - e.x, p.y + e.y, p.z + e.z}, --A
		{p.x - e.x, p.y + e.y, p.z - e.z}, --E
		
		{p.x + e.x, p.y - e.y, p.z + e.z}, --D
		{p.x - e.x, p.y + e.y, p.z - e.z}, --E
		{p.x - e.x, p.y - e.y, p.z - e.z}, --G
		
		{p.x + e.x, p.y + e.y, p.z - e.z}, --F
		{p.x + e.x, p.y + e.y, p.z + e.z}, --B
		{p.x + e.x, p.y - e.y, p.z + e.z}, --C
		
		{p.x + e.x, p.y - e.y, p.z - e.z}, --H
		{p.x + e.x, p.y + e.y, p.z - e.z}, --F
		{p.x + e.x, p.y - e.y, p.z + e.z} --C
	}

	PushMeshLua(self.verts, "cube")
end

local function Render(self)
	PushInstance("simple", "cube", self.p.x, self.p.y, self.p.z)
end

local function Update()
--
end

function GeneratePlatform()
	local platform = {}

	platform.p = v3(math.random(0, 5), math.random(-3, 3), math.random(-10, 0))

	platform.GenerateMesh = GenerateMesh
	platform.Render = Render
	platform.Update = Update

	return platform
end