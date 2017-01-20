-- find a better way of preventing the constant reloading of the file from resetting all state
if not camInitialized then
	prevX, prevY = nil, nil
	accumulatedYaw, accumulatedPitch = 0, 0
end
camInitialized = true

sensitivity = .3
maxAbsDeg = 180
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
	if prevX == x and prevY == y then return end

	if prevX == nil then
		dx, dy = 0, 0
	else
		dx, dy = x - prevX, prevY - y
	end

	accumulatedYaw = accumulatedYaw + dx * sensitivity
	accumulatedPitch = accumulatedPitch + dy * sensitivity
	yawRad, pitchRad = deg2Rad(clampDeg(accumulatedYaw)), deg2Rad(clampDeg(accumulatedPitch))

	vx = math.cos(yawRad) * math.cos(pitchRad)
	vy = math.sin(pitchRad)
	vz = math.sin(yawRad) * math.cos(pitchRad)

	-- create a vector helper later
	magnitude = math.sqrt(vx * vx + vy * vy + vz * vz)
	front = {x = vx / magnitude, y = vy / magnitude, z = vz / magnitude}

	prevX, prevY = x, y

	-- print("front is {x: "..front.x..", y: "..front.y..", z: "..front.z.."}")
	UpdateCam(front.x, front.y, front.z)
end