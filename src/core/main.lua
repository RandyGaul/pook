dofile("src/util/fileloader.lua")

for i, v in pairs(world) do
	v:Render()
	v:Update()
end

-- Flush( "simple" )
-- Flush( "quads" )
