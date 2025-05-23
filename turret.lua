TurretGlobalData = {
    height = 50,
    bulletRadius = 5, bulletSpeed = 7, bulletTurnSpeed = math.rad(3),
    fireInterval = { min = 36, max = 100 },
    viewRadius = { min = 800, max = 1300 },
    inaccuracy = { min = 0, max = 10 },
    warble = { min = 1000, max = 4000 },
    dragTurretCoolInterval = 600,
    headRadius = 20,
    readingsDistance = 25,
    threatWidth = 120, threatHeight = 120, threatUpdateInterval = { current = 0, max = 10 },

    moodPalette = {
        ["normal"] = 25,
        ["angry"] = 1,
        ["peaceful"] = 1,
    },
}

TurretGenerationPalette = { normal = 20, laser = 4, drag = 2, push = 6, prime = 5 }



function StartTurretUpdateThread()
    TurretUpdateThread = love.thread.newThread([[

Turrets, Player = ...

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

while true do
    local dataBack = love.thread.getChannel("turrets to thread"):demand()
    Player = love.thread.getChannel("player"):demand()

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
    if Level == 1 then return end

    Turrets = {}

    math.randomseed(os.time())
    for _ = 1, ObjectGlobalData.turretDensity * Boundary.width * Boundary.height do
        NewTurret(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height),
        math.random(TurretGlobalData.fireInterval.min, TurretGlobalData.fireInterval.max))
    end

    for _, turret in ipairs(Turrets) do
        for _, obj in ipairs(Objects) do
            if zutil.touching(turret.x, turret.y, 0, 0, obj.x, obj.y, obj.width, obj.height) or
            zutil.touching(turret.x, turret.y, 0, 0, -playerSafeArea, Boundary.y + Boundary.height - playerSafeArea, playerSafeArea * 2, playerSafeArea * 2) then
                lume.remove(Turrets, turret)
            end
        end
    end
end
function NewTurret(x, y, fireInterval, notOnMap)
    local palette = TurretGenerationPalette

    if Weather.currentType == "rainy" then
        palette.drag = 0
    else
        palette.push = 0
    end
    if Weather.currentType == "hot" then
        palette.normal = 0
    else
        palette.prime = 0
    end

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
        mood = lume.weightedchoice(TurretGlobalData.moodPalette)
    })
end
function UpdateTurrets()
    TurretGlobalData.threatUpdateInterval.current = TurretGlobalData.threatUpdateInterval.current + 1 * GlobalDT

    for turretIndex, turret in ipairs(Turrets) do
        if turret.render or Zen.doingSo then

            if not turret.mood then
                turret.mood = lume.weightedchoice(TurretGlobalData.moodPalette)
            end

            local distance = zutil.distance(turret.x, turret.y, Player.centerX, Player.centerY)

            local before = turret.seesPlayer
            turret.seesPlayer = distance <= turret.viewRadius and not Player.invisible

            local updateSearching = function()
                turret.fireRate.current = 0

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

            if not Player.respawnWait.dead and turret.seesPlayer and not NextLevelAnimation.running and GameState == "game" then
                if not before and turret.seesPlayer then
                    if turret.mood == "peaceful" then
                        if math.random() < .6 then    zutil.playsfx(SFX.heart, .12, math.random()/10+.95)    end
                        NewMessage("<3", turret.x, turret.y - TurretGlobalData.headRadius - 40, {1,25/255,240/255}, 170, Fonts.medium)
                    else
                        zutil.playsfx(SFX.seesPlayer, 0.2, turret.fireRate.max / TurretGlobalData.fireInterval.min + 0.5)
                    end
                end

                Player.targeted = true

                turret.discovered = true

                turret.searchingAngle = math.deg(zutil.angleBetween(turret.x, turret.y, Player.centerX, Player.centerY))
                turret.objectiveSearchingAngle = turret.searchingAngle

                if turret.mood ~= "peaceful" then
                    local angle = zutil.angleBetween(turret.x, turret.y, Player.x, Player.y) + math.rad(math.random(turret.inaccuracy) * (lume.randomchoice({true,false}) and 1 or -1))

                    turret.fireRate.current = turret.fireRate.current + 1 * GlobalDT / (distance <= Player.destroyingTurretFireRateRangeDiminishment and 1.5 or 1)
                    if turret.fireRate.current >= turret.fireRate.max then
                        if turret.type == "normal" then
                            zutil.playsfx(SFX.shoot, .2, turret.fireRate.max / TurretGlobalData.fireInterval.min * 1.5 + 0.5)
                            turret.fireRate.current = 0
                            FireBullet(turret.x, turret.y, angle, TurretGlobalData.bulletSpeed, 1)
                        elseif turret.type == "laser" then
                            zutil.playsfx(SFX.jump, .1, .6)
                            IncreasePlayerTemperature(2.5)
                            table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, math.random()*(Player.temperature.current/Player.temperature.max)*4+2, {1,.5,0,math.random()/2+.5}, 1, math.random(360), 0.02, 300))
                        elseif turret.type == "drag" then
                            turret.fireRate.current = 0
                            zutil.playsfx(SFX.drag, .05, turret.fireRate.max / TurretGlobalData.fireInterval.min / 2 + 0.5)
                            DragPlayerTowards(turret.x, turret.y, 10)
                        elseif turret.type == "push" then
                            if not SFX.push:isPlaying() then zutil.playsfx(SFX.push, .05, turret.fireRate.max / TurretGlobalData.fireInterval.min / 2 + 0.5) end

                            DragPlayerTowards(turret.x, turret.y, -0.8 * GlobalDT)

                            table.insert(Particles, NewParticle(Player.x+Player.width/2, Player.y+Player.height/2, math.random()*3+2, {1,0,.7,math.random()/2+.5}, 2, math.random(360), 0, 300,
                            function (self)
                                self.degrees = self.degrees + zutil.jitter(60)
                                if self.speed > 0 then
                                    self.speed = self.speed - 0.02 * GlobalDT
                                    if self.speed <= 0 then
                                        self.speed = 0
                                    end
                                end
                            end))
                        elseif turret.type == "prime" then
                            zutil.playsfx(SFX.primeShoot, .2, turret.fireRate.max / TurretGlobalData.fireInterval.min * 1.5 + 0.5)
                            turret.fireRate.current = 0
                            FireBullet(turret.x, turret.y, angle, TurretGlobalData.bulletSpeed*1.4, 0.6, true)
                        end

                        if turret.mood == "angry" then
                            turret.fireRate.max = math.random(TurretGlobalData.fireInterval.min/3, TurretGlobalData.fireInterval.max/4)
                        end
                    end
                end
            else
                turret.seesPlayer = false
                updateSearching()
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
                zutil.playsfx(lume.randomchoice(SFX.warble), (1 - zutil.clamp(distance, 0, maxWarbleHearing) / maxWarbleHearing) * 0.1, math.random() / 5 + 0.4)
                NewMessage("~", turret.x, turret.y - TurretGlobalData.headRadius - 40, {1,1,1}, 100, Fonts.medium)
            end

            -- destroying turrets
            if distance <= TurretGlobalData.headRadius + Player.width / 2 then
                ExplodeTurret(turret)

                ShakeIntensity = 20

                if Player.superJump.current >= Player.superJump.max then
                    GainPlinks(1)
                end

                Player.xvelocity, Player.yvelocity = Player.xvelocity * Player.speedMultiplierWhenDestroyingTurret, Player.yvelocity * Player.speedMultiplierWhenDestroyingTurret

                PlayerSkill.turretsDestroyed = PlayerSkill.turretsDestroyed + 1

                StartSlowMo(false, false, false)

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
        elseif turret.type == "push" then
            love.graphics.setColor(1,0,.7)
            love.graphics.setLineWidth(3)
        elseif turret.type == "prime" then
            love.graphics.setColor(0,1,.7)
            love.graphics.setLineWidth(5)
        end

        local x, y = turret.x, turret.y
        if turret.mood == "angry" then
            local jitter = 8
            x, y = x + zutil.jitter(jitter), y + zutil.jitter(jitter)
        end

        love.graphics.circle("fill", x, y, TurretGlobalData.headRadius * (Minimap.showing and 2 or 1), 100)

        local alpha = .5
        if turret.type == "normal" then
            love.graphics.setColor(0,1,0, alpha)
        elseif turret.type == "laser" then
            love.graphics.setColor(1,.5,0, alpha)
        elseif turret.type == "drag" then
            love.graphics.setColor(1,1,0, alpha)
        elseif turret.type == "push" then
            alpha = .2
            love.graphics.setColor(1,0,.7, alpha * math.random())
        elseif turret.type == "prime" then
            love.graphics.setColor(0,1,.7, alpha)
        end

        if turret.seesPlayer then
            local r, g, b = love.graphics.getColor()
            love.graphics.setColor(r, g, b, (turret.mood == "peaceful" and alpha or turret.fireRate.current / turret.fireRate.max))

            local drawLine = function (amplitude)
                love.graphics.line(turret.x, turret.y, Player.centerX + zutil.jitter(amplitude), Player.centerY + zutil.jitter(amplitude))
            end

            if turret.type == "push" then
                for _ = 1, 4 do
                    drawLine(13)
                end
            else
                drawLine((turret.mood == "angry" and 10 or 3))
            end
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
        if zutil.distance(turret.x, turret.y, mx, my) <= TurretGlobalData.readingsDistance then
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
    zutil.playsfx(SFX.smash, 0.5, 1.5)
end
function IdentifyIfTurretIsAThreat(turret)
    if turret.fireRate.max <= zutil.lerp(TurretGlobalData.fireInterval.min, TurretGlobalData.fireInterval.max, 1/4) and
    ToMeters(zutil.distance(turret.x, turret.y, Player.centerX, Player.centerY)) <= 5 then
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

function FireBullet(x, y, angle, speed, size, homing)
    table.insert(Bullets, {
        x = x, y = y, radius = TurretGlobalData.bulletRadius, warningProgression = 0,
        angle = angle,
        speed = speed,
        size = size, startSize = size,
        lifespan = 400,
        homing = homing,
    })
end
function UpdateBullets()
    for _, self in ipairs(Bullets) do
        local distanceToPlayer = zutil.distance(Player.centerX, Player.centerY, self.x, self.y)
        local multiplier = zutil.lerp(0.3, 1, zutil.clamp(distanceToPlayer / Player.instinctOfTheBulletJumperDistance, 0, 1))

        if self.homing and not Player.respawnWait.dead then
            local targetAngle = zutil.angleBetween(self.x, self.y, Player.centerX, Player.centerY)

            if self.angle < targetAngle then
                self.angle = self.angle + TurretGlobalData.bulletTurnSpeed * GlobalDT
                if self.angle > targetAngle then self.angle = targetAngle end
            elseif self.angle > targetAngle then
                self.angle = self.angle - TurretGlobalData.bulletTurnSpeed * GlobalDT
                if self.angle < targetAngle then self.angle = targetAngle end
            end

            Player.targeted = true
        end

        self.x = self.x + math.sin(self.angle) * self.speed * GlobalDT * (PlayerPerks["Instinct of the Bullet Jumper"] and multiplier or 1)
        self.y = self.y + math.cos(self.angle) * self.speed * GlobalDT * (PlayerPerks["Instinct of the Bullet Jumper"] and multiplier or 1)

        self.lifespan = self.lifespan - 1 * GlobalDT
        if self.lifespan < 0 then
            lume.remove(Bullets, self)
        end

        local maxLifeForShrink = 50
        if self.lifespan <= maxLifeForShrink then
            local ratio = self.lifespan / maxLifeForShrink
            self.size = self.startSize * ratio
            self.radius = TurretGlobalData.bulletRadius * ratio
        end

        if not Player.respawnWait.dead and zutil.distance(self.x, self.y, Player.centerX, Player.centerY) <= Player.width / 2 + TurretGlobalData.bulletRadius * self.size then
            KillPlayer()
        end

        --[[
        for index, turret in ipairs(Turrets) do
            if index ~= originTurretIndex and Distance(turret.x, turret.y, self.x, self.y) <= TurretGlobalData.headRadius + TurretGlobalData.bulletRadius then
                ExplodeTurret(turret)
            end
        end]]
    end
end
function DrawBullets()
    for _, self in ipairs(Bullets) do
        local color = (self.homing and {0,1,.7} or {1,0,0})

        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(-self.angle + math.rad(180))
        love.graphics.setColor(color) ; love.graphics.draw(Sprites.bullet, -Sprites.bullet:getWidth()*self.size/2, -Sprites.bullet:getHeight()*self.size/2, 0, self.size, self.size)
        love.graphics.pop()

        local maxdistance, checks = 1300, 20
        for i = 0, maxdistance, maxdistance / checks do
            if zutil.distance(Player.centerX, Player.centerY,
            self.x + math.sin(self.angle) * i, self.y + math.cos(self.angle) * i) <= Player.width / 2 + self.radius + maxdistance/checks * 2 then
                self.warningProgression = self.warningProgression + .1 * GlobalDT
                if self.warningProgression > 1 then
                    self.warningProgression = 1
                end
            else
                self.warningProgression = self.warningProgression - 0.02 * GlobalDT
                if self.warningProgression < 0 then
                    self.warningProgression = 0
                end
            end
        end

        love.graphics.setColor(color)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", self.x, self.y, self.radius * 5 * zutil.easeOutQuint(self.warningProgression) * self.size, 100)
    end
end