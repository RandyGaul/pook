-- all hotswapped dependencies go here
if not firstLoadComplete or KeyPressed("r") then
	ObjLoader = dofile("src/util/parser.lua")
	dofile("src/core/tick.lua")
	dofile("src/util/input.lua")
	dofile("src/util/cam.lua")
	dofile("src/util/graphics.lua")
	dofile("src/util/pooler.lua")
	dofile("src/entities/cow.lua")
	firstLoadComplete = true
end