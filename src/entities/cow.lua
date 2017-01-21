COIN_SPIN_SPEED = math.pi * 2

function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/coin.obj")
	cow.pos = v3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	cow.spinAngle = 0
	cow.tempTriangleVerts = {}
	cow.tempQuadVerts = {}

	for i = 1, #cow.verts.triangleVerts do cow.tempTriangleVerts[i] = {0, 0, 0} end
	for i = 1, #cow.verts.quadVerts do cow.tempQuadVerts[i] = {0, 0, 0} end

	cow.GenerateMesh = function(self)
		if GeneratedMeshes["cow"] ~= nil then
			return
		end

		PushMeshLua(self.verts.triangleVerts, "triangle")
		PushMeshLua(self.verts.quadVerts, "quad")

		GeneratedMeshes["cow"] = true
	end

	cow.Render = function(self)
		local angle = self.spinAngle
		local rx = 0
		local ry = 1
		local rz = 0
		PushInstance( "simple", "triangle", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5, rx, ry, rz, angle)
		PushInstance( "quads", "quad", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5, rx, ry, rz, angle)
	end

	cow.Update = function(self)
		self.spinAngle = self.spinAngle + COIN_SPIN_SPEED * dt
	end

	return cow
end
