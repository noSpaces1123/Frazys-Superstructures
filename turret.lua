function StartTurretUpdateThread()
    TurretUpdateThread = love.thread.newThread([[

Turrets, Player = ...

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

while true do
    local dataBack = love.thread.getChannel("turrets to thread"):demand()
    Player = love.thread.getChannel("turrets to thread player"):demand()

    Turrets = dataBack

    for _, turret in ipairs(Turrets) do
        if Distance(Player.centerX, Player.centerY, turret.x, turret.y) <= Player.renderDistance then
            turret.render = true
        end
    end

    love.thread.getChannel("turrets"):supply(Turrets)
end

    ]])

    TurretUpdateThread:start(Turrets, Player)
end

function SpawnTurrets(playerSafeArea)
    Turrets = {}

    math.randomseed(os.time())
    for _ = 1, ObjectGlobalData.turretDensity * Boundary.width * Boundary.height do
        NewTurret(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height),
        math.random(TurretGlobalData.fireInterval.min, TurretGlobalData.fireInterval.max))
    end

    for _, turret in ipairs(Turrets) do
        for _, obj in ipairs(Objects) do
            if Touching(turret.x, turret.y, 0, 0, obj.x, obj.y, obj.width, obj.height) or
            Touching(turret.x, turret.y, 0, 0, -playerSafeArea, Boundary.y + Boundary.height - playerSafeArea, playerSafeArea * 2, playerSafeArea * 2) then
                lume.remove(Turrets, turret)
            end
        end
    end
end
function NewTurret(x, y, fireInterval, notOnMap)
    table.insert(Turrets, {
        x = x, y = y, viewRadius = math.random(TurretGlobalData.viewRadius.min, TurretGlobalData.viewRadius.max),
        fireRate = { current = 0, max = fireInterval }, seesPlayer = false, searchingAngle = math.random(-360, 360), objectiveSearchingAngle = math.random(-360, 360),
        searchWait = { current = 0, max = 100, running = false, },
        type = lume.weightedchoice(TurretGenerationPalette),
        notMinimapVisible = notOnMap,
        threat = { x = 0, y = 0, on = false },
        homing = math.random() <= 0.05,
        inaccuracy = math.random(TurretGlobalData.inaccuracy.min, TurretGlobalData.inaccuracy.max),
        warble = { current = 0, max = math.random(TurretGlobalData.warble.min, TurretGlobalData.warble.max) },
    })
end
function UpdateTurrets()
    TurretGlobalData.threatUpdateInterval.current = TurretGlobalData.threatUpdateInterval.current + 1 * GlobalDT

    for turretIndex, turret in ipairs(Turrets) do
        if turret.render then

            local distance = Distance(turret.x, turret.y, Player.centerX, Player.centerY)

            local before = turret.seesPlayer
            turret.seesPlayer = distance <= turret.viewRadius

            if not Player.respawnWait.dead and turret.seesPlayer and not NextLevelAnimation.running and GameState == "game" then
                if not before and turret.seesPlayer then
                    PlaySFX(SFX.seesPlayer, 0.2, turret.fireRate.max / TurretGlobalData.fireInterval.min + 0.5)
                end

                Player.targeted = true

                turret.discovered = true

                turret.searchingAngle = math.deg(AngleBetween(turret.x, turret.y, Player.centerX, Player.centerY))
                turret.objectiveSearchingAngle = turret.searchingAngle

                local angle = AngleBetween(turret.x, turret.y, Player.x, Player.y) + math.rad(math.random(turret.inaccuracy) * (lume.randomchoice({true,false}) and 1 or -1))

                turret.fireRate.current = turret.fireRate.current + 1 * GlobalDT / (distance <= Player.destroyingTurretFireRateRangeDiminishment and 1.5 or 1)
                if turret.fireRate.current >= turret.fireRate.max then
                    if turret.type == "normal" then
                        PlaySFX(SFX.shoot, .2, turret.fireRate.max / TurretGlobalData.fireInterval.min * 1.5 + 0.5)
                        turret.fireRate.current = 0
                        FireBullet(turret.x, turret.y, angle, TurretGlobalData.bulletSpeed, turretIndex)
                    elseif turret.type == "laser" then
                        PlaySFX(SFX.jump, .1, .6)
                        IncreasePlayerTemperature(2.5)
                    elseif turret.type == "drag" then
                        turret.fireRate.current = 0
                        PlaySFX(SFX.drag, .05, turret.fireRate.max / TurretGlobalData.fireInterval.min / 2 + 0.5)
                        DragPlayerTowards(turret.x, turret.y, 10)
                    end
                end
            else
                turret.fireRate.current = 0

                turret.seesPlayer = false

                if Settings.graphics.current >= 2 then
                    local speed = 0.5
                    if turret.searchingAngle < turret.objectiveSearchingAngle then
                        turret.searchingAngle = turret.searchingAngle + speed * GlobalDT
                        if turret.searchingAngle > turret.objectiveSearchingAngle then
                            turret.searchingAngle = turret.objectiveSearchingAngle
                        end
                    elseif turret.searchingAngle > turret.objectiveSearchingAngle then
                        turret.searchingAngle = turret.searchingAngle - speed * GlobalDT
                        if turret.searchingAngle < turret.objectiveSearchingAngle then
                            turret.searchingAngle = turret.objectiveSearchingAngle
                        end
                    else
                        turret.searchWait.current = turret.searchWait.current + 1 * GlobalDT
                        if turret.searchWait.current >= turret.searchWait.max then
                            turret.objectiveSearchingAngle = math.random(-360, 360)
                            turret.searchWait.current = 0
                            turret.searchWait.max = math.random(100, 300)
                        end
                    end
                end
            end

            if TurretGlobalData.threatUpdateInterval.current >= TurretGlobalData.threatUpdateInterval.max then
                if IdentifyIfTurretIsAThreat(turret) then
                    MarkTurretAsThreat(turret)
                else
                    turret.threat.on = false
                end
            end

            -- warbling
            local maxWarbleHearing = 2000
            if turret.warble == nil then turret.warble = { current = 0, max = math.random(TurretGlobalData.warble.min, TurretGlobalData.warble.max) } end
            turret.warble.current = turret.warble.current + 1
            if turret.warble.current >= turret.warble.max then
                turret.warble.current = 0
                turret.warble.max = math.random(TurretGlobalData.warble.min, TurretGlobalData.warble.max)
                PlaySFX(lume.randomchoice(SFX.warble), (1 - Clamp(distance, 0, maxWarbleHearing) / maxWarbleHearing) * 0.1, math.random() / 5 + 0.4)
                NewMessage("~", turret.x, turret.y - TurretGlobalData.headRadius - 40, {1,1,1}, 100, Fonts.medium)
            end

            -- destroying turrets
            if distance <= TurretGlobalData.headRadius + Player.width / 2 then
                ExplodeTurret(turret)

                Player.xvelocity = -Player.xvelocity
                Player.yvelocity = -Player.yvelocity

                PlayerSkill.turretsDestroyed = PlayerSkill.turretsDestroyed + 1

                Player.superJump.current = Player.superJump.current + Player.superJump.reward.explodingTurret
                SaveData()
            end

        end
    end

    if TurretGlobalData.threatUpdateInterval.current >= TurretGlobalData.threatUpdateInterval.max then
        TurretGlobalData.threatUpdateInterval.current = 0
    end
end
function DrawTurrets()
    for _, turret in ipairs(Turrets) do
        if turret.notMinimapVisible and Minimap.showing and GameState == "game" then goto continue end
        if not turret.discovered then goto continue end

        if turret.type == "normal" then
            love.graphics.setColor(0,.3,1)
            love.graphics.setLineWidth(2)
        elseif turret.type == "laser" then
            love.graphics.setColor(1,.5,0)
            love.graphics.setLineWidth(5)
        elseif turret.type == "drag" then
            love.graphics.setColor(1,1,0)
            love.graphics.setLineWidth(5)
        end

        love.graphics.circle("fill", turret.x, turret.y, TurretGlobalData.headRadius * (Minimap.showing and 2 or 1), 100)

        local alpha = .5
        if turret.type == "normal" then
            love.graphics.setColor(0,1,0, alpha)
        elseif turret.type == "laser" then
            love.graphics.setColor(1,.5,0, alpha)
        elseif turret.type == "drag" then
            love.graphics.setColor(1,1,0, alpha)
        end

        if turret.seesPlayer then
            local r, g, b = love.graphics.getColor()
            love.graphics.setColor(r, g, b, turret.fireRate.current / turret.fireRate.max)

            love.graphics.line(turret.x, turret.y, Player.centerX + (math.random()-math.random()) * 3, Player.centerY + (math.random()-math.random()) * 3)
        else
            local x2 = math.sin(math.rad(turret.searchingAngle)) * turret.viewRadius + turret.x
            local y2 = math.cos(math.rad(turret.searchingAngle)) * turret.viewRadius + turret.y

            love.graphics.line(turret.x, turret.y, x2, y2)
        end

        DrawThreatBox(turret)

        ::continue::
    end
end
function DisplayTurretInfo()
    for turretIndex, turret in ipairs(Turrets) do
        if not turret.render then goto continue end
        local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
        if Distance(turret.x, turret.y, mx, my) <= TurretGlobalData.readingsDistance then
            love.graphics.setColor(0,1,0)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", turret.x, turret.y, turret.viewRadius)
            love.graphics.setFont(Fonts.normal)
            love.graphics.print("fire interval: " .. turret.fireRate.max .. "\nindex: " .. turretIndex, turret.x + TurretGlobalData.headRadius + 5, turret.y)
        end
        ::continue::
    end
end
function ExplodeTurret(turret)
    -- particles
    for _ = 1, 15 do
        table.insert(Particles, NewParticle(turret.x, turret.y, math.random() * 5 + 4, Player.color, math.random() * 4 + 3, math.random(360), 0.02, math.random(300, 500)))
    end

    lume.remove(Turrets, turret)
    PlaySFX(SFX.smash, 0.5, 1.5)
end
function IdentifyIfTurretIsAThreat(turret)
    if turret.fireRate.max <= Lerp(TurretGlobalData.fireInterval.min, TurretGlobalData.fireInterval.max, 1/4) and
    ToMeters(Distance(turret.x, turret.y, Player.centerX, Player.centerY)) <= 5 then
        return true
    end

    return false
end
function MarkTurretAsThreat(turret)
    love.graphics.push()

    love.graphics.origin()

    local x, y = love.graphics.inverseTransformPoint(turret.x, turret.y)

    local randomness = 5
    turret.threat.x = x - TurretGlobalData.threatWidth / 2 + (math.random()-math.random())*randomness
    turret.threat.y = y - TurretGlobalData.threatHeight / 2 + (math.random()-math.random())*randomness

    turret.threat.on = true

    love.graphics.pop()
end
function DrawThreatBox(turret)
    if not turret.threat.on then return end

    love.graphics.push()
    --love.graphics.origin()

    local x, y = turret.threat.x, turret.threat.y

    local spacing = 5
    love.graphics.setLineWidth(3)
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", x, y, TurretGlobalData.threatWidth, TurretGlobalData.threatHeight)
    love.graphics.setFont(Fonts.normal)
    love.graphics.print("threat", x + spacing, y - Fonts.normal:getHeight() - spacing)

    love.graphics.pop()
end