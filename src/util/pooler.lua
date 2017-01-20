ObjectPooler = {}
ObjectPooler.__index = ObjectPooler
setmetatable(ObjectPooler, ObjectPooler)

function ObjectPooler:__call(...)
	local o = setmetatable({}, self) --setmetatable returns the original table
	o:new(...)
	return o
end

function ObjectPooler:new(initialSize, maxSize, growthAmount, constructor, ...)
	self.stackPool = {}
	self.initialSize = initialSize
	self.currentSize = initialSize
	self.maxSize = maxSize
	self.growthAmount = growthAmount
	self.constructor = constructor
	self.initialArgs = {...}
	for i = 1, initialSize do
		table.insert(self.stackPool, constructor(...))
	end
end

function ObjectPooler:get(...)
	if #self.stackPool == 0 then
		local numToAdd = math.min(self.growthAmount, self.maxSize - self.currentSize)
		for i = 1, numToAdd do
			table.insert(self.stackPool, self.constructor(unpack(self.initialArgs)))
		end
		self.currentSize = self.currentSize + numToAdd
	end

	return table.remove(self.stackPool)
end

function ObjectPooler:recycle(obj)
	table.insert(self.stackPool, obj)
end