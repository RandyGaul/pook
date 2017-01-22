local ObjLoader = {}

if VertCache == nil then
	VertCache = {}
end

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
				vertList[6] = vertList[4]
				vertList[4] = vertList[1]
				vertList[5] = vertList[3]
			    appendToTable(triangleVerts, vertList)
			end
		end
	end
	return triangleVerts
end

function ObjLoader.getVerts(filename)
	if VertCache[filename] ~= nil then
		return VertCache[filename]
	end

	print("getting verts for "..filename)

	local triangleVerts, quadVerts = createLists(filename, loadVerts(filename))
	local result = triangleVerts

	VertCache[filename] = result

	return result
end

return ObjLoader