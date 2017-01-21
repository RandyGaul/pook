dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
math.randomseed(os.time())
GRAVITY = 100

function JumpHeight( height )
    return math.sqrt( 2 * GRAVITY * height )
end

player = GeneratePlayer()
cowPool = ObjectPooler(15, 20, 2, GenerateCow)
platformPool = ObjectPooler(15, 5, 2, GeneratePlatform)
--skybox = GenerateSkybox()
GenerateLevel(5)

-- add init stuff below
