-- all hotswapped dependencies go here
function loadfiles()
	ObjLoader = dofile("src/util/parser.lua")
	dofile("src/core/tick.lua")
	dofile("src/util/input.lua")
	dofile("src/util/cam.lua")
	dofile("src/util/graphics.lua")
end