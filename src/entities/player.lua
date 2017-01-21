playerSpeed = 10
initialJumpVelocity = 35
downwardVelocity = -30
initialY = 0

-- this is shit, will replace once randy gets collision stuff working
local function TouchingGround(self)
	return self.p.y <= initialY
end

local function InitJump(self)
	if self.jumping then return end

	self.jumping = true
	self.jumpStartTime = t
	self.jumpInitialHeight = 0
end

local function UpdateJump(self)
	local deltaJumpTime = t - self.jumpStartTime
	self.p.y = self.jumpInitialHeight + downwardVelocity * deltaJumpTime * deltaJumpTime
		+ initialJumpVelocity * deltaJumpTime
	if self:TouchingGround() and deltaJumpTime > 0 then
		self.jumping = false
	end
end

local function Update(self)
	local scaledFront = front * playerSpeed
	local scaledRight = right * playerSpeed

	if KeyDown("w") then
		self.p.z = self.p.z + scaledFront.z * dt
		self.p.x = self.p.x + scaledFront.x * dt
	end
	if KeyDown("a") then
		self.p.z = self.p.z + scaledRight.z * dt
		self.p.x = self.p.x + scaledRight.x * dt
	end
	if KeyDown("s") then
		self.p.z = self.p.z - scaledFront.z * dt
		self.p.x = self.p.x - scaledFront.x * dt 
	end
	if KeyDown("d") then
		self.p.z = self.p.z - scaledRight.z * dt
		self.p.x = self.p.x - scaledRight.x * dt
	end
	if KeyPressed(KEY_SPACE) and self:TouchingGround() then
		self:InitJump()
	end

	if self.jumping then
		self:UpdateJump()
	end

	if self:Moved() then
		self.lastPos.x = self.p.x
		self.lastPos.y = self.p.y
		self.lastPos.z = self.p.z
		UpdateCamLua()
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

	player.jumpStartTime = 0
	player.jumping = false

	player.GenerateMesh = function(self)
		PushMeshLua(self.verts, "playerTriangles")
	end

	player.Render = function(self)
		PushInstance("simple", "playerTriangles", self.p.x, self.p.y, self.p.z, .5, .5, .5)
	end

	-- clean this up later with some metatables
	player.Update = Update
	player.Moved = Moved
	player.TouchingGround = TouchingGround
	player.InitJump = InitJump
	player.UpdateJump = UpdateJump

	table.insert(world, player)
	return player
end