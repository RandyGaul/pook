dofile("src/util/fileloader.lua")

for i, v in pairs(world) do
	ClearCubes();
	v:Update()
	v:Render()
end

-- Flush( "simple" )
-- Flush( "quads" )
