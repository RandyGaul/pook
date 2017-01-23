-- find a better way of preventing the constant reloading of the file from resetting all state
if not camInitialized then
	prevX, prevY = nil, nil
	accumulatedYaw, accumulatedPitch = 0, 0
end
camInitialized = true

sensitivity = .3
maxAbsDeg = 360
camDist = 8.5
camOffsetY = 2
up = {x = 0, y = 1, z = 0}

local function clampDeg(deg)
	if deg < -maxAbsDeg then
		return -maxAbsDeg
	elseif deg > maxAbsDeg then
		return maxAbsDeg
	end

	return deg
end

local function deg2Rad(deg)
	return deg * math.pi / 180
end

function handleMouseMovement(x, y)
	if not player or (prevX == x and prevY == y) then return end

	if prevX == nil then
		dx, dy = 0, 0
	else
		dx, dy = x - 600, prevY - 600
	end

	accumulatedYaw = accumulatedYaw + dx * sensitivity
	accumulatedPitch = accumulatedPitch + dy * sensitivity
	yawRad, pitchRad = deg2Rad(accumulatedYaw), deg2Rad(accumulatedPitch)

	vx = math.cos(yawRad) * math.cos(pitchRad)
	vy = math.sin(pitchRad)
	vz = math.sin(yawRad) * math.cos(pitchRad)

	front = v3(vx, vy, vz)
	front:normalize()
	right = v3(vz, 0, -vx)

	prevX, prevY = x, y

	UpdateCamLua()
end

function UpdateCamLua()
	local eye = player.p - front * camDist
	UpdateCam(eye.x, eye.y + camOffsetY, eye.z, front.x, front.y, front.z)
end
