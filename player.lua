function LoadPlayer()
    Player = {
        x = 0, y = 0, centerX = 0, centerY = 0,
        width = 10, height = 10, color = { 0,1,1 }, baseZoom = 0.6, zoom = 0,
        baseSpeed = 0.35, speed = nil, netSpeed = 0, baseJumpStrength = 20, jumpStrength = nil, wallJumpXStrength = 10, jumped = false,
        xvelocity = 0, yvelocity = 0,
        standingOnObject = false, standingOnIcyObject = false, touchingObject = false, touchingSideOfObject = { left = false, right = false }, touchingStickyObject = false, touchingBottomOfObject = false,
        coyote = { current = 0, max = 10, running = false },
        groundFriction = 1, airFriction = 0.1,
        moving = false,
        divisorWhenConvertingXToYVelocity = 2,
        pressing = { a = false, d = false },
        blips = { interval = { current = 0, max = 7 }, speedThreshold = 17 },
        smashSpeedThreshold = 50,
        respawnWait = { current = 0, max = 200, dead = false },
        temperature = { current = 0, max = 500 }, passiveCooling = .4,
        superJump = { increase = 1, current = 0, max = 1500, cost = 900, replenished = false, reward = { explodingTurret = 300, onIce = 1 } }, superJumpStrength = 80,
        checkpoint = { x = nil, y = nil },
        renderDistance = ToPixels((love.system.getOS() == "Windows" and 14 or 10)),
        wallPush = false,
        instinctOfTheBulletJumperDistance = 700,
        doubleJumpUsed = false,
        enemyKillForgiveness = 3.5, destroyingTurretFireRateRangeDiminishment = 270,
        selfDestruct = { current = 0, max = 100 },
        speedMultiplierWhenDestroyingTurret = 2,
        invisible = false, draw = true,
        closeToCheckpoint = false, closeToCheckpointMinimumDistance = ToPixels(2),
        warningSine = 0,
    }
    Player.jumpStrength = Player.baseJumpStrength
    Player.speed = Player.baseSpeed
    Player.y = Boundary.y + Boundary.height - Player.height

    -- adjust zoom to be the same on all devices
    Player.baseZoom = 1440/love.graphics.getWidth() * Player.baseZoom

    Player.zoom = Player.baseZoom
    WayPoints = {}
end

function RespawnPlayer()
    if Player.checkpoint.x == nil and Player.checkpoint.y == nil then
        Player.x, Player.y = 0, (Descending.doingSo and 0 or Boundary.y + Boundary.height - Player.height)
    else
        Player.x, Player.y = Player.checkpoint.x, Player.checkpoint.y
    end
    Player.xvelocity, Player.yvelocity = 0, 0
    Player.coyote.current, Player.coyote.running = 0, false
    Player.respawnWait.dead = false
    Player.temperature.current = 0

    MessageWithPlayerStats()
    ApplyShrineEffects()

    zutil.playsfx(SFX.playerSpawn, 0.5, 1)
end
function ResetPlayerData()
    PlayerSkill = {
        turretsDestroyed = 0,
        enemiesKilled = 0,
        deaths = 0,
        greatestBulletPresence = 0, -- personal best of bullets near
    }

    PlayerPerks = {}
    for key, _ in pairs(ShrineGlobalData.types) do
        PlayerPerks[key] = false
    end

    PlayerUpgrades = {}
    for _, value in pairs(Upgrades) do
        PlayerUpgrades[value.name] = 0
    end

    AnalyticsUpgrades = {}
    for _, value in ipairs(Upgrades[3].list) do
        AnalyticsUpgrades[value] = false
    end

    Plinks = 0
end
function ResetGame()
    Level = 1
    TotalTime = 0
    ResetPlayerData()
    LoadPlayer()
    CorrectBoundaryHeight()
    CorrectEnemyDensity()
    CorrectTurretDensity()
    Descending.onLevels = PickDescensionLevels()
    GenerateObjects()
    SaveData()
    LoadData()
end

function UpdatePlayer()
    DoPlayerKeyPresses()
    UpdateKeyBuffer()

    if not Zen.doingSo then
        Player.netSpeed = zutil.pythag(Player.xvelocity, Player.yvelocity)

        Player.targeted = false -- this will be updated across other functions

        if not Player.respawnWait.dead and not NextLevelAnimation.running and not Paused and not Descending.hooligmanCutscene.running and not CommandLine.typing then
            Player.yvelocity = ApplyGravity(Player)
            Player.xvelocity = ApplyWind(Player.xvelocity)

            UpdatePlayerCoyote()
            DoPlayerSpeedParticles()
            DoObjectEffects()
            DoPlayerMovement()
            UpdateBlips()
            DoPlayerFriction()
            CheckIfPlayerHasCompletedLevel()
            UpdatePlayerTemperature()
            CheckCollisionWithWayPoint()
            DoPlayerGoalMagentismParticles()
            UpdatePlayerSuperJumpBar()
            CalculatePlayerGreatestBulletPresence()

            GuardianAngelGlide()
        end

        UpdatePlayerRespawnWait()

        UpdateEffectsOfPlayerSelfDestruct()
    end
end

function love.keypressed(key)
    if key == "escape" then
        if CommandLine.typing then
            CommandLine.typing = false
        else
            if GameState == "complete" then ResetGame() end
            GameState = "menu"
            SaveData()
        end
    elseif CommandLine.typing then
        if key == "backspace" and #CommandLine.text > 0 then
            CommandLine.text = string.sub(CommandLine.text, 1, #CommandLine.text - 1)
        elseif key == "return" then
            RunCommandLine()
        end
    elseif not Player.respawnWait.dead and key ~= "d" and key ~= "a" and not CommandLine.typing then
        table.insert(KeyBuffer, { key = key, time = 5 })
    end
end

function love.textinput(text)
    if not CommandLine.typing then return end

    CommandLine.text = CommandLine.text .. text
end

function UpdateKeyBuffer()
    if Player.respawnWait.dead then return end

    for _, tuple in ipairs(KeyBuffer) do
        local key = tuple.key
        local did = true

        if key == "space" and not Zen.doingSo and not Paused and PlayerCanMove and (Player.standingOnObject or Player.coyote.running or Player.touchingBottomOfObject or (PlayerPerks["Power of the Achiever"] and not Player.doubleJumpUsed)) then -- jumping
            if Player.touchingBottomOfObject then
                Player.yvelocity = Player.yvelocity + Player.jumpStrength
            else
                Player.yvelocity = Player.yvelocity - Player.jumpStrength
            end

            -- wall jump?
            if Player.coyote.running and not Player.standingOnObject and (Player.touchingSideOfObject.right or Player.touchingSideOfObject.left) then
                Player.xvelocity = Player.xvelocity + Player.wallJumpXStrength * (Player.touchingSideOfObject.right and 1 or -1)
            end
            Player.coyote.running = false

            DoPlayerJumpParticles()

            if PlayerPerks["Power of the Achiever"] and not Player.standingOnObject and not Player.coyote.running then
                Player.doubleJumpUsed = true
            end

            --[[
            if love.keyboard.isDown("a") and Player.xvelocity > 0 then
                Player.xvelocity = -math.abs(Player.xvelocity)
            elseif love.keyboard.isDown("d") and Player.xvelocity < 0 then
                Player.xvelocity = math.abs(Player.xvelocity)
            end]]

            Player.jumped = true
        elseif key == "/" and not Zen.doingSo then
            --PlaySFX(SFX.jump, 0.5, 1)
            SaveData()
        elseif key == "q" and not Paused and GameState == "game" and not Zen.doingSo then
            DoPlayerSuperJump()
        elseif key == "m" and GameState == "game" and AnalyticsUpgrades["minimap"] and not Zen.doingSo then
            ToggleMinimap()
        elseif key == "p" and not Minimap.showing and GameState == "game" then
            if Paused then
                StartSlowMo(false, false, true)
            else
                StartSlowMo(true, true, false)
            end
        elseif CommandLine.verified and key == "r" and Paused and GameState == "game" then
            Seed = os.time()
            GenerateObjects()
            LoadPlayer()
            SaveData()
        elseif key == "0" then
            CommandLine.typing = true
        else
            did = false
        end

        if did then
            lume.remove(KeyBuffer, tuple)
        else
            tuple.time = tuple.time - 1 * GlobalDT
            if tuple.time <= 0 then lume.remove(KeyBuffer, tuple) end
        end
    end
end

function love.keyreleased(key)
    if Player.jumped and key == "space" then
        Player.jumped = false
    end
end

function love.mousepressed(mx, my, button)
    if GameState == "game" then
        if button == 1 and Minimap.showing then
            love.graphics.push()

            InitialiseMinimapCoordinateAlterations()

            local x, y = love.graphics.inverseTransformPoint(mx, my)

            for _, waypoint in ipairs(WayPoints) do
                if zutil.distance(waypoint.x, waypoint.y, x, y) <= waypoint.radius * 5 then
                    lume.remove(WayPoints, waypoint)
                    goto removedWayPoint
                end
            end

            NewWayPoint(x, y)

            ::removedWayPoint::

            SaveData()

            love.graphics.pop()
        end
    end

    CheckButtonsClicked(button)
end
function love.mousereleased()
    ClickedWithMouse = false
end

function love.wheelmoved(_, y)
    if GameState == "changelog" then
        local textHeight = love.graphics.newText(Fonts.changelog, Changelog):getHeight() - love.graphics.getHeight() + 90
        ChangelogYOffset = zutil.clamp(ChangelogYOffset + y * 10, -textHeight, 0)
    elseif Minimap.showing then
        local sound = function ()
            zutil.playsfx(SFX.zoom, 0.03, 1 - Minimap.zoom + 1)
        end

        local speed = 0.007
        if y > 0 then
            Minimap.zoom = Minimap.zoom + speed
            sound()
        elseif y < 0 then
            Minimap.zoom = Minimap.zoom - speed
            sound()
        end

        Minimap.zoom = zutil.clamp(Minimap.zoom, 0.05, 0.15)
    elseif Zen.doingSo then
        Zen.zoom = zutil.clamp(Zen.zoom + 0.007 * y, 0.05, 0.4)
    end
end

function love.focus(focus)
    if not focus and GameState == "game" then
        Paused = true
    end
end

function love.quit()
    SaveData()
end

function DrawPlayer()
    if Player.respawnWait.dead or NextLevelAnimation.running or not Player.draw or Zen.doingSo then return end

    --[[
    love.graphics.setColor(Player.color[1], Player.color[2], Player.color[3], .3)
    local x, y = Player.centerX, Player.centerY
    love.graphics.line(x, y, x + Player.xvelocity * 10, y + Player.yvelocity * 10)]]

    love.graphics.setColor(Player.color)

    if Player.netSpeed >= Player.smashSpeedThreshold then
        love.graphics.setColor(1,0,0)
    elseif PlayerPerks["Power of the Achiever"] and not Player.doubleJumpUsed and not Player.standingOnObject and not Player.coyote.running then
        love.graphics.setColor(ShrineGlobalData.types["Power of the Achiever"].color)
    end

    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

    -- temperature
    love.graphics.setColor(1,.5,0, Player.temperature.current / Player.temperature.max)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

    -- eye
    local seeRadius = ToPixels(6)
    local closestDistance = seeRadius
    local toX, toY = Player.centerX - Player.xvelocity, Player.centerY - Player.yvelocity

    for _, turret in ipairs(Enemies) do
        local distance = zutil.distance(Player.centerX, Player.centerY, turret.x, turret.y)
        if distance < closestDistance then
            closestDistance = distance
            toX, toY = turret.x, turret.y
        end
    end
    for _, enemy in ipairs(Enemies) do
        local distance = zutil.distance(Player.centerX, Player.centerY, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2)
        if not enemy.dead and distance < closestDistance then
            closestDistance = distance
            toX, toY = enemy.x + enemy.width / 2, enemy.y + enemy.width / 2
        end
    end

    local multiply = Player.width / 6 * (closestDistance == seeRadius and zutil.clamp(Player.netSpeed / 4, 0, 1) or 1)
    local angle = zutil.angleBetween(toX, toY, Player.centerX, Player.centerY) + (closestDistance == seeRadius and 0 or math.rad(180))
    local eyeX, eyeY = Player.centerX + math.sin(angle) * multiply, Player.centerY + math.cos(angle) * multiply
    local eyeRadius = Player.width * 0.3

    love.graphics.setColor(0,0,0)
    love.graphics.circle("fill", eyeX, eyeY, eyeRadius)
end

function DoPlayerKeyPresses()
    if Minimap.showing then
        if love.keyboard.isDown("w") then
            Minimap.y = Minimap.y - Minimap.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("a") then
            Minimap.x = Minimap.x - Minimap.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("s") then
            Minimap.y = Minimap.y + Minimap.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("d") then
            Minimap.x = Minimap.x + Minimap.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
    elseif Zen.doingSo then
        if love.keyboard.isDown("w") then
            Zen.camera.y = Zen.camera.y - Zen.camera.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("a") then
            Zen.camera.x = Zen.camera.x - Zen.camera.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("s") then
            Zen.camera.y = Zen.camera.y + Zen.camera.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
        if love.keyboard.isDown("d") then
            Zen.camera.x = Zen.camera.x + Zen.camera.speed * GlobalDT * (love.keyboard.isDown("lshift") and 2 or 1)
        end
    elseif not Player.respawnWait.dead and not Paused and not Descending.hooligmanCutscene.running then
        if not Player.touchingStickyObject and PlayerCanMove then
            Player.pressing.a = love.keyboard.isDown("a") or love.keyboard.isDown("left")
            Player.pressing.d = love.keyboard.isDown("d") or love.keyboard.isDown("right")

            -- keypresses
            if Player.pressing.a then
                Player.xvelocity = Player.xvelocity - Player.speed * GlobalDT
            end
            if Player.pressing.d then
                Player.xvelocity = Player.xvelocity + Player.speed * GlobalDT
            end
        end

        if love.keyboard.isDown("b") then
            Player.selfDestruct.current = Player.selfDestruct.current + 1 * GlobalDT
            if Player.selfDestruct.current >= Player.selfDestruct.max then
                Player.selfDestruct.current = 0
                KillPlayer()
            end
        elseif Player.selfDestruct.current > 0 then
            Player.selfDestruct.current = Player.selfDestruct.current - 4 * GlobalDT
            if Player.selfDestruct.current <= 0 then
                Player.selfDestruct.current = 0
            end
        end

        --[[
        if love.keyboard.isDown("o") then
            Player.yvelocity = Player.yvelocity - 2 * GlobalDT
        elseif love.keyboard.isDown("l") then
            Player.yvelocity = Player.yvelocity + 2 * GlobalDT
        end]]
    end
end

function DoPlayerMovement()
    local checks = 10
    for _ = 0, 1, 1 / checks do
        ApplyPlayerVelocities(checks)
        DoPlayerCollisions()
    end
end

function DoPlayerFriction()
    if Player.standingOnIcyObject and not PlayerPerks["Spirit of the Frozen Trekker"] then return end

    local friction = (Player.standingOnObject and Player.groundFriction or Player.airFriction)

    if not Player.standingOnObject then
        friction = friction + Weather.types[Weather.currentType].airFrictionAdd()
    elseif Weather.currentType == "rainy" and Player.standingOnObject then
        friction = zutil.clamp(friction - math.random() * Weather.types[Weather.currentType].groundFrictionRandomness(), 0, math.huge)
    end

    if Player.xvelocity > 0 and not Player.pressing.d then
        Player.xvelocity = Player.xvelocity - friction * GlobalDT
        if Player.xvelocity < 0 then
            Player.xvelocity = 0
        end
    elseif Player.xvelocity < 0 and not Player.pressing.a then
        Player.xvelocity = Player.xvelocity + friction * GlobalDT
        if Player.xvelocity > 0 then
            Player.xvelocity = 0
        end
    end
    if Player.yvelocity > 0 then
        Player.yvelocity = Player.yvelocity - friction * GlobalDT
        if Player.yvelocity < 0 then
            Player.yvelocity = 0
        end
    elseif Player.yvelocity < 0 then
        Player.yvelocity = Player.yvelocity + friction * GlobalDT
        if Player.yvelocity > 0 then
            Player.yvelocity = 0
        end
    end

    if Player.touchingStickyObject and not Player.pressing.a and not Player.pressing.d then
        Player.xvelocity = 0
    end
end

function ApplyPlayerVelocities(checks)
    Player.x = Player.x + Player.xvelocity * GlobalDT / checks
    Player.y = Player.y + Player.yvelocity * GlobalDT / checks
end

function DoPlayerCollisions()
    local wasStandingOnObject = Player.standingOnObject
    local wasTouchingStickyObject = Player.touchingStickyObject

    Player.standingOnObject = false
    Player.standingOnIcyObject = false
    Player.touchingStickyObject = false
    Player.touchingSideOfObject.left, Player.touchingSideOfObject.right = false, false
    Player.touchingBottomOfObject = false

    for objIndex, obj in ipairs(Objects) do
        local touching = Player.x + Player.width >= obj.x and Player.y + Player.height >= obj.y and Player.x <= obj.x + obj.width and Player.y <= obj.y + obj.height
        if touching then
            -- determine the closest side
            local closestSide = nil
            local closestDistance = math.huge

            if obj.playerTouchingSide == nil then
                local playerCenter = { x = Player.centerX, y = Player.centerY }

                local sides = {
                    { x = obj.x,             y = playerCenter.y     }, -- left
                    { x = obj.x + obj.width, y = playerCenter.y     }, -- right
                    { x = playerCenter.x,    y = obj.y              }, -- top
                    { x = playerCenter.x,    y = obj.y + obj.height }, -- bottom
                }

                for index, side in ipairs(sides) do
                    local distance = zutil.distance(side.x, side.y, playerCenter.x, playerCenter.y)
                    if distance < closestDistance then
                        closestDistance = distance
                        closestSide = index
                    end
                end

                zutil.playsfx(SFX.hit, ConvertVelocityToHitSFXVolume(Player.xvelocity, Player.yvelocity), math.random() / 10 + .95)
                DoPlayerHitObjectParticles(closestSide)

                if obj.type == "icy" and Player.temperature.current > Player.temperature.max / 3 then
                    zutil.playsfx(SFX.cool, 0.1, 2)
                elseif obj.type == "sticky" then
                    zutil.playsfx(SFX.stick, 0.2, math.random() / 10 + 0.95)
                end

                if PlayerPerks["Power of the Achiever"] then
                    Player.doubleJumpUsed = false
                end
            else
                closestSide = obj.playerTouchingSide
            end

            -- treat the physics accordingly. the closest side must be the side the player hit
            if closestSide == 3 then -- top
                Player.yvelocity = 0
                Player.y = obj.y - Player.height
                Player.standingOnObject = true
                if obj.type == "icy" then
                    Player.standingOnIcyObject = true
                end
            elseif closestSide == 4 then -- bottom
                Player.yvelocity = 0
                Player.y = obj.y + obj.height
                Player.touchingBottomOfObject = true
                --PlaySFX(SFX.cool, 0.1, 1)
            elseif closestSide == 1 then -- left
                CheckAndIfSoDoPlayerSmash(objIndex)
                if obj.impenetrable then
                    Player.xvelocity = -Player.xvelocity
                else
                    ConvertXIntoYVelocity()
                    StartPlayerCoyote()
                end
                Player.x = obj.x - Player.width
                Player.touchingSideOfObject.left = true
            elseif closestSide == 2 then -- right
                CheckAndIfSoDoPlayerSmash(objIndex)
                if obj.impenetrable then
                    Player.xvelocity = -Player.xvelocity
                else
                    ConvertXIntoYVelocity()
                    StartPlayerCoyote()
                end
                Player.x = obj.x + obj.width
                Player.touchingSideOfObject.right = true
            end

            if closestSide ~= nil then
                if obj.type == "sticky" and not love.keyboard.isDown("space") then
                    Player.touchingStickyObject = true
                end
            end

            obj.playerTouchingSide = closestSide
        else
            obj.playerTouchingSide = nil
        end
    end

    -- newly hit the ground?
    if not wasStandingOnObject and Player.standingOnObject then
        zutil.playsfx(SFX.hit, ConvertVelocityToHitSFXVolume(Player.xvelocity, Player.yvelocity), math.random() / 10 + .95)
    end

    -- coyote time
    if wasStandingOnObject and not Player.standingOnObject and Player.yvelocity >= 0 then
        StartPlayerCoyote()
    end

    -- unstick soundalound
    if wasTouchingStickyObject and not Player.touchingStickyObject then
        zutil.playsfx(SFX.unstick, 0.1, math.random()/10 + .95)
    end
end

function StartPlayerCoyote()
    Player.coyote.running = true
    Player.coyote.current = 0
end

function UpdatePlayerCoyote()
    Player.coyote.current = Player.coyote.current + 1 * GlobalDT
    if Player.coyote.current >= Player.coyote.max then
        Player.coyote.current = 0
        Player.coyote.running = false
    end
end

function ConvertVelocityToHitSFXVolume(xvelocity, yvelocity)
    local vol = (math.abs(xvelocity) / 20 + math.abs(yvelocity)) / 2
    return zutil.clamp(vol, 0.2, 1)
end

function ConvertXIntoYVelocity()
    Player.yvelocity = Player.yvelocity + -math.abs(Player.xvelocity) / Player.divisorWhenConvertingXToYVelocity
    Player.xvelocity = 0
end

function DoPlayerSpeedParticles()
    if math.floor(math.abs(Player.xvelocity) + math.abs(Player.yvelocity)) > 0 and Player.standingOnObject then
        local degrees = math.random(90, 135 + Player.netSpeed)
        local radius = math.random() * (Player.netSpeed / 5) + 0.1
        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {1,1,1,math.random()}, 2, (Player.xvelocity > 0 and 1 or -1) * degrees, 0.02, 50,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.05 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end
end

function DoPlayerJumpParticles()
    for _ = 1, 20 do
        local degrees = math.random(115, 245)
        local radius = math.random() + 1
        local speed = math.random() * 2 + 1
        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {1,1,1,math.random()}, speed, degrees, 0.04, 80,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.05 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end
end

function DoPlayerGoalMagentismParticles()
    local maxDistance = 300
    if ((not Descending.doingSo and Player.y <= maxDistance) or (Descending.doingSo and Player.y >= Boundary.y + Boundary.height - maxDistance)) and lume.randomchoice({true,false}) then
        local ratio = math.abs(Player.y / maxDistance)

        table.insert(Particles, NewParticle(math.random(Player.x, Player.x + Player.width), Player.centerY, math.random(), Player.color, math.random() * ratio * 3 + 1, 180, (Descending.doingSo and 180 or 0), math.random(200, 400)))
    end
end

function DoPlayerHitObjectParticles(side)
    for _ = 1, 12 do
        local degrees
        if side == 1 then -- left
            degrees = math.random(-180, 0)
        elseif side == 2 then -- right
            degrees = math.random(0, 180)
        elseif side == 3 then -- top
            degrees = math.random(90, 270)
        elseif side == 4 then -- bottom
            degrees = math.random(-270, 90)
        end

        assert(degrees, "invalid side entered!!11!1! :flushed:")

        local radius = math.random() * 2 + Player.netSpeed / 7
        local speed = math.random() * 2 + Player.netSpeed / 8
        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {1,1,1,math.random()}, speed, degrees, 0.04, 80,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.05 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end
end

function DoPlayerSpawnParticles()
    for _ = 1, 50 do
        local degrees = math.random(360)
        local radius = math.random() * 6 + 2
        local speed = math.random() * 10 + 4
        local decay = math.random(160, 300)
        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {Player.color[1],Player.color[2],Player.color[3],math.random()/2+.5}, speed, degrees, 0.01, decay,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.02 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end
end

function CheckAndIfSoDoPlayerSmash(objIndex)
    if Player.netSpeed < Player.smashSpeedThreshold or Player.yvelocity > 0 then return end

    ShakeIntensity = 30

    StartSlowMo(false, false, false)

    if not Objects[objIndex].impenetrable then
        SmashObject(Objects[objIndex])
        zutil.playsfx(SFX.smash, .7, math.random() / 10 + .95)
    else
        zutil.playsfx(SFX.clang, .6, math.random() / 10 + .95)
    end
end

function ConvertPlayerVelocityToCameraLookAhead()
    local xtowards, ytowards = (Player.xvelocity > 0 and -1 or 1), (Player.yvelocity > 0 and -1 or 1)
    return zutil.clamp((math.abs(Player.xvelocity) - 5) / 3, 0, math.huge) * xtowards, zutil.clamp((math.abs(Player.yvelocity) - 5) / 3, 0, math.huge) * ytowards
end
function ConvertPlayerVelocityToCameraRotation()
    if not Settings.cameraRotationOn then return 0 end
    return math.rad(Player.xvelocity / 20)
end
function CalculateZoom()
    local minVelocity = 15
    local zoom = 1 - zutil.clamp(math.abs(Player.xvelocity) / 200 - minVelocity / 300, 0, math.huge) / 2
    return zutil.clamp(zoom, .4, 1) - Player.zoom
end

function UpdateBlips()
    if Player.netSpeed >= Player.blips.speedThreshold then
        local playerSpeed = Player.netSpeed - Player.blips.speedThreshold
        Player.blips.interval.current = Player.blips.interval.current + 1 * GlobalDT

        if Player.blips.interval.current >= Player.blips.interval.max then
            Player.blips.interval.current = 0

            local pitch = 0.5 + playerSpeed / 200
            local volume = playerSpeed / 250
            Player.blips.interval.max = 7 - playerSpeed / 20
            zutil.playsfx(SFX.blip, volume, pitch)
        end
    end
end

function IncreasePlayerTemperature(amount)
    Player.temperature.current = Player.temperature.current + amount * GlobalDT
    if Player.temperature.current >= Player.temperature.max then
        KillPlayer()
    elseif Player.temperature.current < 0 then
        Player.temperature.current = 0
    end
end
function UpdatePlayerTemperature()
    if Player.temperature.current <= 0 then return end

    Player.temperature.current = Player.temperature.current - (Player.passiveCooling + Weather.types[Weather.currentType].passiveCoolingAdd()) * GlobalDT

    if Player.temperature.current < 0 then
        Player.temperature.current = 0
    end
end

function DragPlayerTowards(x, y, strength)
    local angle = zutil.angleBetween(Player.centerX, Player.centerY, x, y)

    Player.xvelocity = Player.xvelocity + math.sin(angle) * strength
    Player.yvelocity = Player.yvelocity + math.cos(angle) * strength
end

function KillPlayer()
    -- particles
    ShakeIntensity = 50

    for _ = 1, 100 do
        local degrees = math.random(360)

        local radius = math.random() * 10 + 2
        local speed = math.random() * 10 + 7
        local decay = math.random(160, 300)
        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, Player.color, speed, degrees, 0.01, decay,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.02 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end

    -- respawning
    Player.respawnWait.dead = true

    PlayerSkill.deaths = PlayerSkill.deaths + 1

    table.insert(DeathPositions, { x = Player.centerX, y = Player.centerY })

    SaveData()

    zutil.playsfx(SFX.death, 0.7, 1)

    Paused = false
    SlowMo.running = false
    SlowMo.current = 0

    TimeMultiplier = 1
end
function UpdatePlayerRespawnWait()
    if not Player.respawnWait.dead then return end

    Player.respawnWait.current = Player.respawnWait.current + 1 * GlobalDT
    if Player.respawnWait.current >= Player.respawnWait.max then
        Player.respawnWait.current = 0
        RespawnPlayer()
        SaveData()
    end
end

function UpdatePlayerSuperJumpBar()
    if Player.superJump.current >= Player.superJump.max then
        Player.superJump.current = Player.superJump.max
    else
        if Player.superJump.increase == nil then Player.superJump.increase = 1 end
        Player.superJump.current = Player.superJump.current + Player.superJump.increase * GlobalDT

        if not Player.superJump.replenished and Player.superJump.current >= Player.superJump.cost then
            Player.superJump.replenished = true
            zutil.playsfx(SFX.superJumpReplenish, .4, 1)
        elseif Player.superJump.current < Player.superJump.cost then
            Player.superJump.replenished = false
        end

        if Player.superJump.current >= Player.superJump.max then
            zutil.playsfx(SFX.superJumpFull, .4, 1)
        end
    end
end
function DrawPlayerSuperJumpBar()
    if not Dialogue.list[13].done or not Player.draw then return end

    local width, height = 200, 30
    local padding = 20
    love.graphics.setColor((CanSuperJump() and Player.color or {1,1,1}))

    love.graphics.rectangle("fill", love.graphics.getWidth() - width - padding, padding, zutil.lerp(0, width, Player.superJump.current / Player.superJump.max), height, 2, 2)

    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", love.graphics.getWidth() - width - padding, padding, width, height, 2, 2)

    love.graphics.setLineWidth(1)
    for i = Player.superJump.cost, Player.superJump.max, Player.superJump.cost do
        local x = love.graphics.getWidth() - width - padding + zutil.lerp(0, width, i / Player.superJump.max)
        love.graphics.line(x, padding, x, padding + height)
    end
end
function DoPlayerSuperJump()
    if not Dialogue.list[13].done then return end

    if CanSuperJump() then
        Player.touchingStickyObject = false
        Player.yvelocity = Player.yvelocity + Player.superJumpStrength * (Descending.doingSo and 1 or -1)
        Player.superJump.current = Player.superJump.current - Player.superJump.cost
        zutil.playsfx(SFX.superJump, .7, 1)
    end
end
function CanSuperJump()
    return Player.superJump.current - Player.superJump.cost >= 0
end

function DoObjectEffects()
    for _, obj in ipairs(Objects) do
        if obj.playerTouchingSide ~= nil then
            if obj.type == "death" then
                IncreasePlayerTemperature(9)
            elseif obj.type == "icy" then
                IncreasePlayerTemperature(-7)
                Player.superJump.current = Player.superJump.current + Player.superJump.reward.onIce
            elseif obj.type == "jump" then
                local jumpPlatformStrength = ObjectGlobalData.jumpPlatformStrength + Weather.types[Weather.currentType].jumpPadStrengthAdd()
                if obj.playerTouchingSide == 3 then
                    Player.yvelocity = Player.yvelocity - jumpPlatformStrength
                elseif obj.playerTouchingSide == 1 then -- left
                    Player.yvelocity = Player.yvelocity - jumpPlatformStrength / 2
                    Player.xvelocity = Player.xvelocity - jumpPlatformStrength / 3
                elseif obj.playerTouchingSide == 2 then -- right
                    Player.yvelocity = Player.yvelocity - jumpPlatformStrength / 2
                    Player.xvelocity = Player.xvelocity + jumpPlatformStrength / 3
                end
            end
        end
    end

    if Player.touchingStickyObject and not Player.jumped then
        Player.yvelocity = 0
        Player.xvelocity = 0
    end
end

function CheckCollisionWithCheckpointsAndUpdateCloseToCheckpointStatus()
    for _, checkpoint in ipairs(Checkpoints) do
        if checkpoint.x ~= Player.checkpoint.x and checkpoint.y ~= Player.checkpoint.y then

            local distance = zutil.distance(Player.x, Player.y, checkpoint.x, checkpoint.y)

            if distance <= Player.width / 2 + CheckpointGlobalData.radius * 1.2 then
                if Weather.currentType == "rainy" and not Player.waterProofCheckpoints then
                    local sfxIsPlaying = false
                    for _, value in ipairs(SFX.checkpointFizzleOut) do
                        if value:isPlaying() then sfxIsPlaying = true; break end
                    end

                    if not sfxIsPlaying then
                        zutil.playsfx(lume.randomchoice(SFX.checkpointFizzleOut), 0.3, math.random()/10+1)

                        TriggerDialogue(57)

                        for _ = 1, 20 do
                            local degrees = math.random(360)
                            local radius = math.random() * 3 + 2
                            local speed = math.random() * 5 + 2
                            local decay = math.random(400, 600)
                            table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {1,0,1,math.random()/2+.5}, speed, degrees, 0.01, decay,
                            function (self)
                                self.degrees = self.degrees + zutil.jitter(60)
                                if self.speed > 0 then
                                    self.speed = self.speed - 0.02 * GlobalDT
                                    if self.speed <= 0 then
                                        self.speed = 0
                                    end
                                end
                            end))
                        end
                    end
                else
                    SetCheckpoint(checkpoint)
                    SaveData()

                    for _ = 1, 30 do
                        local degrees = math.random(360)
                        local radius = math.random() * 3 + 4
                        local speed = math.random() * 6 + 6
                        local decay = math.random(100, 160)
                        table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, radius, {1,0,1,math.random()/2+.5}, speed, degrees, 0.01, decay,
                        function (self)
                            if self.speed > 0 then
                                self.speed = self.speed - 0.02 * GlobalDT
                                if self.speed <= 0 then
                                    self.speed = 0
                                end
                            end
                        end))
                    end

                    for _, turret in ipairs(Turrets) do
                        if zutil.distance(turret.x, turret.y, checkpoint.x, checkpoint.y) <= CheckpointGlobalData.clearRadius then
                            ExplodeTurret(turret)
                        end
                    end

                    for _, enemy in ipairs(Enemies) do
                        if zutil.distance(enemy.x, enemy.y, checkpoint.x, checkpoint.y) <= CheckpointGlobalData.clearRadius then
                            ExplodeEnemy(enemy)
                        end
                    end
                end
            end

            Player.closeToCheckpoint = distance <= Player.closeToCheckpointMinimumDistance
        end
    end
end
function SetCheckpoint(checkpointObject)
    Player.checkpoint.x = checkpointObject.x
    Player.checkpoint.y = checkpointObject.y

    zutil.playsfx(SFX.checkpoint, .7, math.random() + .9)
end

function CalculatePlayerSkill()
    local skill = PlayerSkill.turretsDestroyed/7 + PlayerSkill.enemiesKilled / 2 + (Level-1)^1.5/5 - PlayerSkill.deaths/3 + PlayerSkill.greatestBulletPresence / 3

    local decimalPoints = 2
    return math.floor(skill * 10^decimalPoints) / 10^decimalPoints
end
function MessageWithPlayerStats()
    NewMessage("Skill: " .. CalculatePlayerSkill(), Player.centerX, Player.y - 100, {1,0,0}, 300, Fonts.big)

    local index = 1
    for key, value in pairs(PlayerPerks) do
        if value then NewMessage(key, Player.centerX, Player.y - 100 - index * (Fonts.medium:getHeight() + 10), {1,1,1}, 300, Fonts.medium) end
        index = index + 1
    end
end
function CalculatePlayerGreatestBulletPresence()
    local maxDistance = 600
    local count = 0
    for _, bullet in ipairs(Bullets) do
        if zutil.distance(bullet.x, bullet.y, Player.centerX, Player.centerY) <= maxDistance then
            count = count + 1
        end
    end

    if count > PlayerSkill.greatestBulletPresence then
        PlayerSkill.greatestBulletPresence = count
        SaveData()
    end
end

function CalculatePlayerJumpHeight()
    local time = Player.jumpStrength / (Player.airFriction + Gravity)
    local jumpHeight = Player.jumpStrength * time / 2

    return jumpHeight
end

function ToggleMinimap()
    Minimap.showing = not Minimap.showing

    if Minimap.showing then
        Minimap.x, Minimap.y = Player.x, Player.y
        Minimap.zoom = 0.1

        Minimap.wasPaused = Paused
        Paused = true
    else
        Paused = Minimap.wasPaused
    end

    zutil.playsfx(SFX.toggleMinimap, 0.2, 1)
end
function DrawMinimap()
    love.graphics.push()

    InitialiseMinimapCoordinateAlterations()

    DrawObjects()
    DrawShines()
    DrawTurrets()
    DrawEnemies()
    DrawPlayer()

    love.graphics.setColor(Player.color)
    love.graphics.setLineWidth(20)
    love.graphics.circle("line", Player.x, Player.y, math.sin(math.rad(Minimap.playerSine)) * 40 + 200)

    Minimap.playerSine = Minimap.playerSine + 10 * GlobalDT
    if Minimap.playerSine > 360 then
        Minimap.playerSine = Minimap.playerSine - 360
    end

    for _, checkpoint in ipairs(Checkpoints) do
        local collected = Player.checkpoint.x == checkpoint.x and Player.checkpoint.y == checkpoint.y
        love.graphics.setColor(1,0,1)
        love.graphics.circle("fill", checkpoint.x, checkpoint.y, (collected and math.sin(math.rad(Minimap.playerSine))*20 + 70 or 70))
    end
    for _, waypoint in ipairs(WayPoints) do
        love.graphics.setColor(waypoint.color)
        love.graphics.circle("fill", waypoint.x, waypoint.y, waypoint.radius * 2)
    end

    DrawLevelGoal()

    love.graphics.pop()

    DrawTextWithBackground("Game is paused.", love.graphics.getWidth() / 2, love.graphics.getHeight() - 50, Fonts.normal, {1,1,1}, {0,0,0})
end
function InitialiseMinimapCoordinateAlterations()
    local zoom = Minimap.zoom
    love.graphics.scale(zoom)
    love.graphics.translate(love.graphics.getWidth() / zoom / 2, love.graphics.getHeight() / zoom / 2)
    love.graphics.translate(-Minimap.x, -Minimap.y)
end

function NewWayPoint(x, y)
    table.insert(WayPoints, { x = x, y = y, color = {140/255, 0, 1}, radius = 30 })
end
function CheckCollisionWithWayPoint()
    for _, waypoint in ipairs(WayPoints) do
        if zutil.distance(Player.centerX, Player.centerY, waypoint.x, waypoint.y) <= waypoint.radius * 4 then
            lume.remove(WayPoints, waypoint)
        end
    end
end
function DrawWayPoints()
    for _, waypoint in ipairs(WayPoints) do
        love.graphics.setColor(waypoint.color[1], waypoint.color[2], waypoint.color[3], math.random() / 2 + .5)
        love.graphics.circle("fill", waypoint.x + zutil.jitter(1), waypoint.y + zutil.jitter(1), waypoint.radius)
    end
end
function DrawWayPointArrow()
    if #WayPoints == 0 then return end

    local closest
    local closestDistance = math.huge
    for _, waypoint in ipairs(WayPoints) do
        local distance = zutil.distance(Player.centerX, Player.centerY, waypoint.x, waypoint.y)
        if distance < closestDistance then
            closestDistance = distance
            closest = waypoint
        end
    end

    DrawArrowTowards(closest.x, closest.y, closest.color, 1, ToPixels(50))
end

function DrawArrowTowards(x, y, color, size, maxDistance, waypoint)
    local distance = zutil.distance(Player.centerX, Player.centerY, x, y)
    local ratio = zutil.clamp(1 - distance / maxDistance, 0.1, 1)
    local angle = zutil.angleBetween(Player.centerX, Player.centerY, x, y)
    local points = {
        Player.x + math.sin(angle - math.rad(20 * size * ratio)) * 80, Player.y + math.cos(angle - math.rad(20 * size * ratio)) * 80,
        Player.x + math.sin(angle) * 100,               Player.y + math.cos(angle) * 100,
        Player.x + math.sin(angle + math.rad(20 * size * ratio)) * 80, Player.y + math.cos(angle + math.rad(20 * size * ratio)) * 80,
    }

    if AnalyticsUpgrades["signal radar ii"] or waypoint then
        love.graphics.setColor(color)
    else
        love.graphics.setColor(.7,.7,.7,1)
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(points)

    love.graphics.setFont(Fonts.medium)
    local width = 500
    local printAway = 140
    love.graphics.printf(math.floor(ToMeters(distance)) .. " m",
    Player.x + math.sin(angle) * printAway - width / 2, Player.y + math.cos(angle) * printAway - love.graphics.getFont():getHeight("A") / 2, width, "center")
end

function GuardianAngelGlide()
    if PlayerPerks["Wings of the Guardian Angel"] and not Player.jumped and love.keyboard.isDown("space") and
    ((PlayerPerks["Power of the Achiever"] and Player.doubleJumpUsed) or (not PlayerPerks["Power of the Achiever"])) and not Player.coyote.running and not Player.standingOnObject then
        Player.yvelocity = Player.yvelocity / 2

        table.insert(Particles, NewParticle(Player.centerX, Player.centerY, math.random() * 2 + 1, Player.color, math.random(), 0, 0.03, 100, function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.02 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end
end

function UpdateEffectsOfPlayerSelfDestruct()
    Player.zoom = Player.baseZoom + 0.2 * zutil.easeInExpo(Player.selfDestruct.current / Player.selfDestruct.max)

    if Player.selfDestruct.current > 0 then
        local ratio = Player.selfDestruct.current / Player.selfDestruct.max
        zutil.playsfx(SFX.selfDestruct, ratio * 0.5, math.random() * ratio + ratio * 2)
        ShakeIntensity = ratio * 10
    end
end
function DrawPlayerSelfDestructOverlay()
    love.graphics.setBlendMode("add", "alphamultiply")
    love.graphics.setColor(1,0,0, Player.selfDestruct.current / Player.selfDestruct.max / 2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setBlendMode("alpha")
end

function GainPlinks(amount)
    Plinks = Plinks + 1
    NewMessage("+" .. amount .. " plink", 0, -50, Player.color, 130, Fonts.medium, nil, true)
    NewMessage(Plinks .. " plinks total", 0, 50, Player.color, 130, Fonts.normal, nil, true)
end