SHARK_BASE_Y = -40
SHARK_SPEED = 60

function PlaceShark(self)
	self.p.x = math.random(levelMinX, levelMaxX)
	self.p.y = SHARK_BASE_Y
	self.p.z = math.random(levelMinZ, levelMaxZ)
end

function GetJumpTarget()
	return math.random(40, 60)
end

function GenerateShark()
	local shark = {}
	shark.PlaceShark = PlaceShark
	shark.verts = ObjLoader.getVerts("assets/models/shark.obj")
	shark.p = v3(0, 0, 0)
	shark:PlaceShark()
	shark.s = v3(.25, .25, .25)
	shark.jumpTarget = GetJumpTarget()
	shark.velocity = SHARK_SPEED
	shark.falling = false
	shark.nextJumpTime = os.time() + math.random(0, 4)

	shark.GenerateMesh = function(self)
		if GeneratedMeshes["shark"] ~= nil then
			return
		end

		PushMeshLua(self.verts, "shark", {.5, .5, .5})

		GeneratedMeshes["shark"] = true
	end

	shark.Render = function(self)
		PushInstance("simple", "shark", self.p.x, self.p.y, self.p.z, self.s.x, self.s.y, self.s.z, 1, 0, 0, 1.57)
	end

	shark.Update = function(self)
		if (not self.falling) and os.time() < self.nextJumpTime then return end

		self.p.y = self.p.y + self.velocity * dt
		if self.p.y > self.jumpTarget and not self.falling then
			self.velocity = -SHARK_SPEED
			self.falling = true
		elseif self.p.y < SHARK_BASE_Y and self.falling then
			self.velocity = SHARK_SPEED
			shark:PlaceShark()
			self.falling = false
			self.jumpTarget = GetJumpTarget()
			self.nextJumpTime = os.time() + math.random(3, 6)
		end
	end

	return shark
end