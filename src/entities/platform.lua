platforms = {}

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
		E,B,E,A,D,A,E,D,E,G,F,B,C,H,F,C}, "cube", {0, 1, 0})
	GeneratedMeshes["platform"] = true
end

local function Render(self)
	PushInstance("simple", "cube", self.p.x, self.p.y, self.p.z, self.s.x, self.s.y, self.s.z)
end

local function Update(self)
	do return end
	self.yDisplacement = math.sin(self.platformFrequencyMult * t + self.platformWaveOffset)
		* self.yMoveDistance
	self.p.y = self.originalY + self.yDisplacement
	if not self.coin == nil then
		self.coin.y = self.p.y + self.s.y
	end

	AddCubeCollider(self.s.x, self.s.y, self.s.z, self.p.x, self.p.y, self.p.z)
end

function GeneratePlatform()
	local platform = {}

	platform.p = v3(0, 0, 0)
	platform.s = v3(0, 0, 0)

	platform.GenerateMesh = GenerateMesh
	platform.Render = Render
	platform.Update = Update

	-- function platform.init() end
	platform.Init = function(self, x, y, z, sx, sy, sz)
		-- print("x:"..x)
		-- print("y:"..y)
		-- print("z:"..z)
		-- print("x: "..x..", y:"..y..", z:"..z..", sx:"..sx..", sy:"..sy..", sz:"..sz)

		self.p.x = x
		self.p.y = y
		self.p.z = z
		self.s.x = sx
		self.s.y = sy
		self.s.z = sz

		self.yMoveDistance = math.random(2, 4)
		self.yDisplacement = 0
		self.originalY = y
		self.platformFrequencyMult = math.random(1, 3)
		self.platformWaveOffset = math.random(0, 3)

		if math.random(1, 3) > 1 then
			local coin = cowPool:get()
			coin.p.x = x
			coin.p.z = z
			coin.p.y = y + self.s.y
			self.coin = coin
		end

		local p = self.p
		local s = self.s
		AddCubeCollider( s.x, s.y, s.z, p.x, p.y, p.z )

		table.insert(platforms, self) -- clean this up if we switch levels.
	end

	return platform
end
