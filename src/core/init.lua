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

cowPool = ObjectPooler(15, 50, 2, GenerateCow)
platformPool = ObjectPooler(15, 50, 2, GeneratePlatform)
player = GeneratePlayer()

--skybox = GenerateSkybox()
GenerateLevel(30)

-- add init stuff below
