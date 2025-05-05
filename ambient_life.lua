GnatClouds = {}
GnatCloudGlobalData = {
    spawnDensity = 0.000000008, radius = ToPixels(.5),
    gnatCount = { min = 6, max = 20, }
}

Flutters = {}
FlutterGlobalData = {
    spawnDensity = 0.0000002,
    radius = { min = 4, max = 8 },
    speed = { min = 2, max = 3 },
    color = {1,1,1,.4},
    floatHeight = 70,
}



function StartAmbientLifeUpdateThread()
    AmbientLifeUpdateThread = love.thread.newThread([[

Flutters, Player = ...

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

while true do
    local dataBack = love.thread.getChannel("flutters to thread"):demand()
    Player = love.thread.getChannel("player"):demand()

    Flutters = dataBack

    for _, turret in ipairs(Flutters) do
        if Distance(Player.centerX, Player.centerY, turret.x, turret.y) <= Player.renderDistance then
            turret.render = true
        end
    end

    love.thread.getChannel("flutters"):supply(Flutters)
end

    ]])

    AmbientLifeUpdateThread:start(Flutters, Player)
end

function DrawAmbientLife()
    DrawGnatClouds()
    DrawFlutters()
end

function SpawnGnatClouds()
    GnatClouds = {}

    for _ = 1, Boundary.width * Boundary.height * GnatCloudGlobalData.spawnDensity do
        NewGnatCloud(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
    end
end
function NewGnatCloud(x, y)
    table.insert(GnatClouds, {
        x = x, y = y,
        radius = GnatCloudGlobalData.radius,
        gnatCount = math.random(GnatCloudGlobalData.gnatCount.min, GnatCloudGlobalData.gnatCount.max),
    })
end
function DrawGnatClouds()
    for _, self in ipairs(GnatClouds) do
        for _ = 1, self.gnatCount do
            local angle = math.rad(math.random(360))
            local displacement = math.random(0, self.radius)
            local x, y = self.x + math.sin(angle) * displacement, self.y + math.cos(angle) * displacement

            love.graphics.setColor(1,1,1,math.random()/4)
            love.graphics.circle(lume.randomchoice({"fill","line"}), x, y, math.random()*2+2)
        end

        -- love.graphics.setColor(1,0,0)
        -- love.graphics.setLineWidth(5)
        -- love.graphics.circle("line", self.x, self.y, ToPixels(2))
    end
end

function SpawnFlutters()
    for _ = 1, Boundary.width * Boundary.height * FlutterGlobalData.spawnDensity do
        NewFlutter(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
    end
end
function NewFlutter(x, y)
    table.insert(Flutters, {
        x = x, y = y, radius = math.random(FlutterGlobalData.radius.min, FlutterGlobalData.radius.max),
        targetLocation = { x = nil, y = nil }, speed = math.random(FlutterGlobalData.speed.min, FlutterGlobalData.speed.max),
        floatSine = { current = 0, max = 359 },
    })
end
function UpdateFlutters()
    for _, self in ipairs(Flutters) do
        if not self.render then goto continue end

        if self.targetLocation.x == nil or zutil.distance(self.x, self.y, self.targetLocation.x, self.targetLocation.y) <= ToPixels(.4) then
            local angle = math.rad(math.random(360))
            local dist = math.random(ToPixels(3), ToPixels(6))
            self.targetLocation.x, self.targetLocation.y = self.x + math.sin(angle)*dist, self.y + math.cos(angle)*dist
        end

        local angleToTarget = zutil.angleBetween(self.x, self.y, self.targetLocation.x, self.targetLocation.y)
        self.x = self.x + math.sin(angleToTarget) * self.speed * GlobalDT
        self.y = self.y + math.cos(angleToTarget) * self.speed * GlobalDT

        self.floatSine = zutil.updatetimer(self.floatSine, nil, 2, GlobalDT)

        ::continue::
    end
end
function DrawFlutters()
    for _, self in ipairs(Flutters) do
        if not self.render then goto continue end

        love.graphics.setColor(FlutterGlobalData.color)
        love.graphics.circle("fill", self.x, self.y + math.sin(math.rad(self.floatSine.current))*FlutterGlobalData.floatHeight, self.radius)

        ::continue::
    end
end