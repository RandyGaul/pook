local ObjLoader = {}

local function loadVerts(filename)
	local verts = {}
	io.input(filename)
	for line in io.lines() do
		local prefix = string.match(line, "%l*")
		if prefix == "v" then
			local vert = {}
			local vertForLine = string.gmatch(string.sub(line, #prefix + 1), "%S+")
			for point in vertForLine do
				table.insert(vert, tonumber(point))
			end
			table.insert(verts, vert)
		end
	end
	return verts
end

local function appendToTable(t1, t2)
	for i = 1, #t2 do table.insert(t1, t2[i]) end
end

local function createLists(filename, verts)
	local triangleVerts = {}
	local quadVerts = {}
	io.input(filename)
	for line in io.lines() do
		local prefix = string.match(line, "%l*")
		if prefix == "f" then
			local vertIndices = string.gmatch(string.sub(line, #prefix + 1), "%S+")
			local vertList = {}
			for vertIndex in vertIndices do
				table.insert(vertList, verts[tonumber(string.match(vertIndex, "%d*"))])
			end
			if #vertList == 3 then
				appendToTable(triangleVerts, vertList)
			elseif #vertList == 4 then
			    appendToTable(quadVerts, vertList)
			end
		end
	end
	return triangleVerts, quadVerts
end

function ObjLoader.getVerts(filename)
	local triangleVerts, quads = createLists(filename, loadVerts(filename))
	return {triangleVerts = triangleVerts, quadVerts = quadVerts}
end

return ObjLoader