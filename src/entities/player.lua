playerSpeed = 10
initialJumpVelocity = 35
downwardVelocity = -30
initialY = 0

function SetPlayerPositionFromC( x, y, z )
	if not player then return end
	player.p.x = x
	player.p.y = y
	player.p.z = z
end

function SetPlayerVelocityFromC( x, y, z )
	if not player then return end
	player.v.x = x
	player.v.y = y
	player.v.z = z
end

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

	self.v.x = 0
	self.v.z = 0

	if KeyDown("w") then
		self.v.z = scaledFront.z
		self.v.x = scaledFront.x
	end
	if KeyDown("a") then
		self.v.z = scaledRight.z
		self.v.x = scaledRight.x
	end
	if KeyDown("s") then
		self.v.z = -scaledFront.z
		self.v.x = -scaledFront.x
	end
	if KeyDown("d") then
		self.v.z = -scaledRight.z
		self.v.x = -scaledRight.x
	end
	if KeyPressed(KEY_SPACE) and self:TouchingGround() then
		self.v.y = JumpHeight( 10 )
	end

	grav = v3( 0, -GRAVITY, 0 )
	self.v = self.v + grav * dt
	self.p = self.p + self.v * dt

	-- ghetto ground collision
	if self.p.y < 0 then
		self.p.y = 0
		self.v.y = 0
	end

	UpdateCamLua()
	SetPlayerPosition( self.p.x, self.p.y, self.p.z )
	SetPlayerVelocity( self.v.x, self.v.y, self.v.z )
end

function GeneratePlayer()
	local player = {}

	player.verts = ObjLoader.getVerts("assets/models/cow.obj")
	player.p = v3(0, 0, 0)
	player.v = v3(0, 0, 0)

	player.jumping = false

	player.GenerateMesh = function(self)
		PushMeshLua(self.verts, "playerTriangles")
	end

	player.Render = function(self)
		PushInstance("simple", "playerTriangles", self.p.x, self.p.y, self.p.z, .5, .5, .5)
	end

	-- clean this up later with some metatables
	player.Update = Update
	player.TouchingGround = TouchingGround
	player.InitJump = InitJump
	player.UpdateJump = UpdateJump

	table.insert(world, player)
	return player
end
