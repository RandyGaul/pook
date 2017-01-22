playerSpeed = 40
playerRadius = 7
WORLD_BOTTOM = -1000
JUMP_HEIGHT = 20

function SetPlayerPositionFromC( x, y, z )
	if not player then return end
	player.p.y = math.max(player.p.y, y)
	do return end

	player.p.x = x
	player.p.z = z
end

function SetPlayerVelocityFromC( x, y, z )
	if not player then return end
	player.v.x = 0
	player.v.y = 0
	player.v.z = 0
end

function SetPlayerTouchingGround( val )
	player.touching_ground = val
end

-- this is COMPLETE shit, will replace once randy gets collision stuff working
local function TouchingGround(self)
	if ( self.p.y <= WORLD_BOTTOM ) then
		self.touching_ground = true
		return true
	end

	for i, v in pairs(platforms) do
		local groundCheckOffset = playerRadius + 5
		if self.p.x > (v.p.x - v.s.x) and self.p.x < (v.p.x + v.s.x) and self.p.z > (v.p.z - v.s.z) and self.p.z < (v.p.z + v.s.z)
			and (self.p.y - groundCheckOffset) > (v.p.y - v.s.y) and (self.p.y - groundCheckOffset) < (v.p.y + v.s.y) then
			self.touching_ground = true
			return true
		end
	end

	self.touching_ground = false
	return false
end

local function InitJump(self)
	if self.jumping then return end

	self.jumping = true
	self.jumpStartTime = t
	self.jumpInitialHeight = 0
end

local function Update(self)
	front = front or v3(0, 0, 1); right = right or v3(0, -1, 0)
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
	if KeyPressed(KEY_SPACE) and math.abs(self.v.y) < .01 then
		self.v.y = JumpHeight( JUMP_HEIGHT )
		self.touching_ground = false
	end

	if not self:TouchingGround() then
		grav = v3( 0, -GRAVITY, 0 )
	else
		grav = v3(0, 0, 0)
	end

	self.v = self.v + grav * dt
	self.p = self.p + self.v * dt

	-- ghetto ground collision
	if self.p.y < WORLD_BOTTOM then
		self.p.y = WORLD_BOTTOM
		self.v.y = 0
	end

	SetPlayerPosition( self.p.x, self.p.y, self.p.z )
	SetPlayerVelocity( self.v.x, self.v.y, self.v.z )
	UpdateCamLua()

	-- collide with coins and remove them
	for k, v in pairs( THE_COINS ) do
		local dist = length(v.p - player.p)
		if dist < (playerRadius + 2) then
			v.alive = false
			THE_COINS[ k ] = nil
			AdjustGameTime(-10)
		end
	end
end

function GeneratePlayer()
	local player = {}

	-- player.verts = ObjLoader.getVerts("assets/models/cow.obj")
	player.verts = GenerateSphereMesh(3)

	player.p = v3(0, 0, 0)
	player.v = v3(0, 0, 0)

	player.jumping = false
	player.touching_ground = true;

	player.GenerateMesh = function(self)
		PushMeshLua(self.verts, "playerTriangles", nil, true)
	end

	player.Render = function(self)
		PushInstance("simple", "playerTriangles", self.p.x, self.p.y, self.p.z, .5, .5, .5)
	end

	-- clean this up later with some metatables
	player.Update = Update
	player.TouchingGround = TouchingGround

	table.insert(world, player)
	return player
end
