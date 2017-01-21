playerSpeed = 5

local function Update(self)
	if KeyDown("w") then
		self.p.z = self.p.z - playerSpeed * dt
	elseif KeyDown("a") then
		self.p.x = self.p.x - playerSpeed * dt
	elseif KeyDown("s") then
		self.p.z = self.p.z + playerSpeed * dt
	elseif KeyDown("d") then
		self.p.x = self.p.x + playerSpeed * dt
	end

	if self:Moved() then
		self.lastPos.x = self.p.x
		self.lastPos.y = self.p.y
		self.lastPos.z = self.p.z
		UpdateCam(self.p.x, self.p.y, self.p.z + 4, front.x, front.y, front.z)
	end
end

local function Moved(self)
	return self.p.x ~= self.lastPos.x or self.p.y ~= self.lastPos.y
		or self.p.z ~= self.lastPos.z
end

function GeneratePlayer()
	local player = {}

	player.verts = ObjLoader.getVerts("assets/models/cow.obj")
	player.p = v3(0, 0, 0)
	player.lastPos = v3(0, 0, 0)

	player.GenerateMesh = function(self)
		PushMeshLua(self.verts.triangleVerts, "playerTriangles")
		PushMeshLua(self.verts.quadVerts, "playerQuads")
	end

	player.Render = function(self)
		PushInstance("simple", "playerTriangles", self.p.x, self.p.y, self.p.z, .5, .5, .5)
		PushInstance("quads", "playerQuads", self.p.x, self.p.y, self.p.z, .5, .5, .5)
	end

	player.Update = Update
	player.Moved = Moved

	table.insert(world, player)
	return player
end