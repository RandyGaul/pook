local function CheckPlatformCollision(platform1, platform2)
	--

end

function GenerateLevel(numPlatforms)
	--
	local prevPlatform = platformPool:get()
	prevPlatform:Init(math.random(0, 10), math.random(-3, 3), math.random(-10, 0),
			math.random(2, 4), math.random(3, 6), math.random(2, 4))

	for i = 1, numPlatforms - 1 do
		prevPlatform = platformPool:get()
		prevPlatform:Init(math.random(0, 10), math.random(-3, 3), math.random(-10, 0),
			math.random(2, 4), math.random(3, 6), math.random(2, 4))
	end
end