local function Subdivide(points, r)
	local j = 1
	local out = {}
	for i = 1, #points, 3 do
		local a = v3(points[i])
		local b = v3(points[i + 1])
		local c = v3(points[i + 2])

		local ab = (a + b) / 2
		local bc = (b + c) / 2
		local ca = (c + a) / 2

		for ii, vv in pairs({b, bc, ab, c, ca, bc, a, ab, ca, ab, bc, ca}) do
			out[j] = vv:normalized() * r
			j = j + 1
		end
	end

	for i, v in ipairs(out) do
		points[i] = v
	end

	points = {table.unpack(points, 1, j - 1)}
end

function GenerateSphereMesh(radius)
	local octohedron = {
		v3(1, 0, 0), v3(0, -1, 0), v3(-1, 0, 0), v3(0, 1, 0), v3(0, 0, 1), v3(0, 0, -1)
	}

	local points = {
		octohedron[2], octohedron[1], octohedron[5],
		octohedron[3], octohedron[2], octohedron[5],
		octohedron[4], octohedron[3], octohedron[5],
		octohedron[1], octohedron[4], octohedron[5],
		octohedron[1], octohedron[2], octohedron[6],
		octohedron[2], octohedron[3], octohedron[6],
		octohedron[3], octohedron[4], octohedron[6],
		octohedron[4], octohedron[1], octohedron[6]
	}

	Subdivide(points, radius)

	return points
end