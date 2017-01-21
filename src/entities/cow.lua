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
		PushInstance( "simple", "triangle", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5)
		PushInstance( "quads", "quad", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5)
	end

	cow.Update = function(self)
		self:Spin()
	end

	cow.Spin = function(self)
		self.spinAngle = self.spinAngle + COIN_SPIN_SPEED * dt

		local function spinFunc(verts, tempVerts, mesh)
			for i, v in pairs(verts) do
				local rotatedX = v[1] * math.cos(self.spinAngle) - v[3] * math.sin(self.spinAngle)
				local rotatedZ = v[1] * math.sin(self.spinAngle) + v[3] * math.cos(self.spinAngle)
				tempVerts[i][1] = rotatedX
				tempVerts[i][2] = v[2]
				tempVerts[i][3] = rotatedZ
			end
			PushMeshLua(tempVerts, mesh)
		end

		spinFunc(self.verts.triangleVerts, self.tempTriangleVerts, "triangle")
		spinFunc(self.verts.quadVerts, self.tempQuadVerts, "quad")
	end

	return cow
end