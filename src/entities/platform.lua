local function GenerateMesh(self)
	if GeneratedMeshes["platform"] ~= nil then
		return
	end

	local A, B, C, D, E, F, G, H =
		{-1, 1, 1}, 	--A
		{1, 1, 1},  	--B
		{1, -1, 1}, 	--C
		{-1, -1, 1},	--D
		{-1, 1, -1},	--E
		{1, 1, -1}, 	--F
		{-1, -1, -1},	--G
		{1, -1, -1}		--H

	PushMeshLua({C,B,A,C,A,D,H,C,D,H,D,G,H,G,F,G,E,F,B,F,
		E,B,E,A,D,A,E,D,E,G,F,B,C,H,F,C}, "cube")
	GeneratedMeshes["platform"] = true
end

local function Render(self)
	PushInstance("simple", "cube", self.p.x, self.p.y, self.p.z, self.s.x, self.s.y, self.s.z)
end

local function Update()
--
end

function GeneratePlatform()
	local platform = {}

	platform.p = v3(math.random(0, 5), math.random(-3, 3), math.random(-10, 0))
	platform.s = v3(math.random(2, 4), math.random(3, 5), math.random(2, 4))

	platform.GenerateMesh = GenerateMesh
	platform.Render = Render
	platform.Update = Update

	return platform
end