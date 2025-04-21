EnemyGlobalData = {
    enemyDensity = 0, baseEnemyDensity = 0.00000001,
    width = { min = 15, max = 30 },
    speed = { min = 3, max = 8, divide = 10 },
    viewRadius = { min = 800, max = 1000 },
    bounceReverberation = 0.4,
    airFriction = 0.05, rotationFriction = 0.001,
    minSpeedAgainstWallToDie = 32,
    warble = { min = 1000, max = 4000 },
    shortCircuitTime = { min = 60, max = 120 },
    voiceLines = {
        "*(#(!(",
        "!@*)(#*)#(!",
        "!&*@&&&*@",
        "#&&!#&#@(!)",
        "!@)(*@*()((@!&@%^",
        ")@()@*!",
        "!@)*@*@",
        "&%&$*()!&#&#@(",
        ")!(!@*^#%^*(@&^#&&@",
    },
}



function StartEnemyUpdateThread()
    EnemyUpdateThread = love.thread.newThread([[

Enemies, Player = ...

function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

while true do
    local dataBack = love.thread.getChannel("enemies to thread"):demand()
    Player = love.thread.getChannel("player"):demand()

    Enemies = dataBack

    for _, enemy in ipairs(Enemies) do
        if Distance(Player.centerX, Player.centerY, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2) <= Player.renderDistance then
            enemy.render = true
        end
    end

    love.thread.getChannel("enemies"):supply(Enemies)
end

    ]])

    EnemyUpdateThread:start(Enemies, Player)
end

function SpawnEnemies()
    if Level == 1 then return end

    Enemies = {}

    for _ = 1, EnemyGlobalData.enemyDensity * Boundary.width * Boundary.height do
        NewEnemy(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
    end
end

function NewEnemy(x, y)
    local m = (Weather.currentType == "foggy" and Weather.types.foggy.enemySizeMultiplier or 1)

    table.insert(Enemies, {
        x = x, y = y, xvelocity = 0, yvelocity = 0,
        width = math.random(EnemyGlobalData.width.min, EnemyGlobalData.width.max) * m, speed = math.random(EnemyGlobalData.speed.min, EnemyGlobalData.speed.max) / EnemyGlobalData.speed.divide,
        viewRadius = math.random(EnemyGlobalData.viewRadius.min, EnemyGlobalData.viewRadius.max), seesPlayer = false,
        warble = { current = 0, max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max) },
        rotationRadians = math.rad(math.random(360)), rotationVelocity = 0,
        fearful = math.random() < 1/5
    })
end

function DrawEnemies()
    for _, enemy in ipairs(Enemies) do
        if not enemy.dead and (enemy.discovered and ((not Minimap.showing and Distance(Player.centerX, Player.centerY, enemy.x, enemy.y) <= Player.renderDistance) or Minimap.showing) or Zen.doingSo) then
            if not enemy.shortCircuit then enemy.shortCircuit = { current = 0, max = 0, running = false } end

            local fillColor = { 1, (1 - enemy.speed / (EnemyGlobalData.speed.max / EnemyGlobalData.speed.divide)) * .3 ,0 }
            local eyeColor = { 0,0,0 }

            if Weather.currentType == "foggy" then
                fillColor = { .05, .05, .05 }

                local v = math.random() / 3 + .2
                eyeColor = { v, v, v }
            end

            love.graphics.push()
            love.graphics.translate(enemy.x + enemy.width/2, enemy.y + enemy.width/2)

            if not enemy.rotationRadians then enemy.rotationRadians = math.rad(math.random(360)) end
            love.graphics.rotate(enemy.rotationRadians)

            love.graphics.setColor(fillColor)
            love.graphics.rectangle("fill", -enemy.width/2, -enemy.width/2, enemy.width, enemy.width)

            love.graphics.pop()

            local r,g,b = love.graphics.getColor()
            love.graphics.setColor(r,g,b,.3)

            local boxSpacing = 2 + Jitter(3)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", enemy.x - boxSpacing, enemy.y - boxSpacing, enemy.width + boxSpacing * 2, enemy.width + boxSpacing * 2)

            if enemy.seesPlayer and not Player.respawnWait.dead then
                love.graphics.setColor(1,0,0,math.random()/2 + .3)
                love.graphics.setLineWidth((Weather.currentType == "foggy" and 6 or 3))
                love.graphics.line(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.centerX, Player.centerY)
            end


            local multiply = enemy.width / 6
            local angle = AngleBetween(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.centerX, Player.centerY)
            local eyeX, eyeY = enemy.x + enemy.width / 2 + math.sin(angle) * multiply, enemy.y + enemy.width / 2 + math.cos(angle) * multiply
            local eyeWidth = enemy.width * 0.5

            if Weather.currentType == "foggy" then
                eyeX = eyeX + Jitter(3)
                eyeY = eyeY + Jitter(3)
            end

            if not enemy.seesPlayer then
                eyeX, eyeY = enemy.x + enemy.width / 2, enemy.y + enemy.width / 2
            end

            love.graphics.setColor(eyeColor)

            if enemy.shortCircuit.running then
                eyeWidth = eyeWidth / 4
                multiply = enemy.width / 4
                for _ = 1, 3 do
                    angle = math.rad(math.random(360))
                    eyeX, eyeY = enemy.x + enemy.width / 2 + math.sin(angle) * multiply, enemy.y + enemy.width / 2 + math.cos(angle) * multiply
                    love.graphics.rectangle("fill", eyeX - eyeWidth / 2, eyeY - eyeWidth / 2, eyeWidth, eyeWidth)
                end
            else
                love.graphics.rectangle("fill", eyeX - eyeWidth / 2, eyeY - eyeWidth / 2, eyeWidth, eyeWidth)
            end
        end
    end
end

function UpdateEnemies()
    for index, enemy in ipairs(Enemies) do
        if (enemy.render or Zen.doingSo) and not enemy.dead then
            if not enemy.shortCircuit then enemy.shortCircuit = { current = 0, max = 0, running = false } end

            local distance
            if Zen.doingSo then
                distance = Distance(Zen.camera.x, Zen.camera.y, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2)
            else
                distance = Distance(Player.centerX, Player.centerY, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2)
            end

            local before = enemy.seesPlayer
            enemy.seesPlayer = distance <= enemy.viewRadius and not Player.invisible
            if enemy.seesPlayer and not before then
                local ratio = 1 - (enemy.width - EnemyGlobalData.width.min) / (EnemyGlobalData.width.max - EnemyGlobalData.width.min)
                PlaySFX(SFX.enemySeesPlayer, 0.6, Clamp(ratio * 1 + 1, 0.1, math.huge))
                if math.random() < 0.2 then
                    enemy.warble.current = enemy.warble.max
                end
            end

            if enemy.render or Zen.doingSo then
                local enemyNetSpeed = Pythag(enemy.xvelocity, enemy.yvelocity)

                enemy.xvelocity = ApplyWind(enemy.xvelocity)

                if not Player.respawnWait.dead and not NextLevelAnimation.running and not enemy.shortCircuit.running then
                    if enemy.seesPlayer then
                        Player.targeted = true

                        enemy.discovered = true

                        if not enemy.stuck then
                            local angle = AngleBetween(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.centerX, Player.centerY) + math.rad(Jitter(20))

                            if (enemy.fearful and Player.netSpeed - 10 > enemyNetSpeed) or Player.closeToCheckpoint then
                                angle = angle + math.rad(180)
                            end

                            local multiply = (Weather.types[Weather.currentType].enemySpeedMultiplier and Weather.types[Weather.currentType].enemySpeedMultiplier or 1)

                            enemy.xvelocity = enemy.xvelocity + math.sin(angle) * enemy.speed * multiply * GlobalDT
                            enemy.yvelocity = enemy.yvelocity + math.cos(angle) * enemy.speed * multiply * GlobalDT
                        end
                    end
                end

                DoEnemyFriction(index)

                if not enemy.stuck then
                    enemy.x = enemy.x + enemy.xvelocity * GlobalDT
                    enemy.y = enemy.y + enemy.yvelocity * GlobalDT
                end

                DoEnemyCollisions(index)

                enemy.rotationRadians = enemy.rotationRadians + enemy.rotationVelocity * GlobalDT
                if enemy.rotationRadians > 360 then
                    enemy.rotationRadians = enemy.rotationRadians - 360
                elseif enemy.rotationRadians < 0 then
                    enemy.rotationRadians = enemy.rotationRadians + 360
                end

                if not Player.respawnWait.dead and not NextLevelAnimation.running then
                    if Touching(Player.x, Player.y, Player.width, Player.height, enemy.x, enemy.y, enemy.width, enemy.width) then
                        if Player.netSpeed / (Weather.currentType == "foggy" and 4 or 1) + Player.enemyKillForgiveness >= enemyNetSpeed then
                            ExplodeEnemy(enemy)
                            PlayDialogue(math.random(#Dialogue.eventual.killEnemy), "killEnemy")
                            PlayerSkill.enemiesKilled = PlayerSkill.enemiesKilled + 1
                        else
                            KillPlayer()
                            enemy.warble.current = enemy.warble.max
                            NewMessage(lume.randomchoice(EnemyGlobalData.voiceLines), enemy.width / 2, -50, {1,0,0}, 200, Fonts.medium, index)
                        end
                    end
                end

                if enemy.xvelocity ~= 0 or enemy.yvelocity ~= 0 then
                    table.insert(Particles,
                    NewParticle(math.random(enemy.x + enemy.width / 4, enemy.x + enemy.width - enemy.width / 4), math.random(enemy.y + enemy.width / 4, enemy.y + enemy.width - enemy.width / 4), 4, {1,0,0,0.4}, 0, 0, 0, 30))
                end

                -- warbling
                local maxWarbleHearing = (Zen.doingSo and ToPixels(30) or ToPixels(10))
                if enemy.warble == nil then enemy.warble = { current = 0, max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max) } end
                enemy.warble.current = enemy.warble.current + 1
                if enemy.warble.current >= enemy.warble.max then
                    enemy.warble.current = 0
                    enemy.warble.max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max)
                    PlaySFX(lume.randomchoice(SFX.enemySpeak), (1 - Clamp(distance, 0, maxWarbleHearing) / maxWarbleHearing) * 0.1, Clamp(math.random() / 5 + 0.4 - (Weather.currentType == "foggy" and 0.27 or 0), 0.1, math.huge))
                    NewMessage(lume.randomchoice(EnemyGlobalData.voiceLines), enemy.width / 2, -50, {1,0,0}, 100, Fonts.medium, index)
                end
            end

            -- short circuit
            if Weather.currentType == "rainy" and not enemy.shortCircuit.running then
                if math.random() < Weather.strength / 100 then
                    enemy.shortCircuit.running = true
                    enemy.shortCircuit.max = math.random(EnemyGlobalData.shortCircuitTime.min, EnemyGlobalData.shortCircuitTime.max)

                    local maxHearingDistance = ToPixels(5)
                    PlaySFX(lume.randomchoice(SFX.shortCircuit), .2 * Clamp(1 - distance / maxHearingDistance, 0, 1), math.random()/20+.9)

                    for _ = 1, 8 do
                        local degrees = math.random(360)
                        local radius = math.random() * 2 + 2
                        local speed = math.random() * 5 + 2
                        local decay = math.random(400, 600)
                        table.insert(Particles, NewParticle(enemy.x+enemy.width/2, enemy.y+enemy.width/2, radius, {1,0,0,math.random()/2+.5}, speed, degrees, 0.01, decay,
                        function (self)
                            self.degrees = self.degrees + Jitter(60)
                            if self.speed > 0 then
                                self.speed = self.speed - 0.02 * GlobalDT
                                if self.speed <= 0 then
                                    self.speed = 0
                                end
                            end
                        end))
                    end
                end
            end

            if enemy.shortCircuit.running then
                enemy.shortCircuit.current = enemy.shortCircuit.current + 1 * GlobalDT
                if enemy.shortCircuit.current >= enemy.shortCircuit.max then
                    enemy.shortCircuit.current = enemy.shortCircuit.current - enemy.shortCircuit.max
                    enemy.shortCircuit.running = false
                end
            end
        end
    end
end

function DoEnemyCollisions(enemyIndex)
    if Enemies[enemyIndex] == nil then return end

    for objIndex, obj in ipairs(Objects) do
        local touching = Enemies[enemyIndex].x + Enemies[enemyIndex].width >= obj.x and Enemies[enemyIndex].y + Enemies[enemyIndex].width >= obj.y and Enemies[enemyIndex].x <= obj.x + obj.width and Enemies[enemyIndex].y <= obj.y + obj.height
        if touching then
            -- determine the closest side
            local closestSide = nil
            local closestDistance = math.huge

            if obj.enemyTouchingSide == nil then
                local enemyCenter = { x = Enemies[enemyIndex].x + Enemies[enemyIndex].width / 2, y = Enemies[enemyIndex].y + Enemies[enemyIndex].width / 2 }

                local sides = {
                    { x = obj.x,             y = enemyCenter.y      }, -- left
                    { x = obj.x + obj.width, y = enemyCenter.y      }, -- right
                    { x = enemyCenter.x,     y = obj.y              }, -- top
                    { x = enemyCenter.x,     y = obj.y + obj.height }, -- bottom
                }

                for index, side in ipairs(sides) do
                    local distance = Distance(side.x, side.y, enemyCenter.x, enemyCenter.y)
                    if distance < closestDistance then
                        closestDistance = distance
                        closestSide = index
                    end
                end

                --PlaySFX(SFX.hit, ConvertVelocityToHitSFXVolume(Enemies[enemyIndex].xvelocity, Enemies[enemyIndex].yvelocity), math.random() / 10 + .95)
            else
                closestSide = obj.enemyTouchingSide
            end

            if Enemies[enemyIndex] == nil then goto continue end

            local bounce = 5
            local swapYVel = function ()
                Enemies[enemyIndex].yvelocity = -Enemies[enemyIndex].yvelocity * EnemyGlobalData.bounceReverberation + (Enemies[enemyIndex].yvelocity > 0 and -bounce or bounce)
            end
            local swapXVel = function ()
                Enemies[enemyIndex].xvelocity = -Enemies[enemyIndex].xvelocity * EnemyGlobalData.bounceReverberation + (Enemies[enemyIndex].xvelocity > 0 and -bounce or bounce)
            end

            -- treat the physics accordingly. the closest side must be the side the player hit
            if closestSide == 3 then -- top
                DetectIfEnemyDiesToSpeed(Enemies[enemyIndex])
                swapYVel()
                Enemies[enemyIndex].y = obj.y - Enemies[enemyIndex].width
            elseif closestSide == 4 then -- bottom
                DetectIfEnemyDiesToSpeed(Enemies[enemyIndex])
                swapYVel()
                Enemies[enemyIndex].y = obj.y + obj.height
            elseif closestSide == 1 then -- left
                DetectIfEnemyDiesToSpeed(Enemies[enemyIndex])
                swapXVel()
                Enemies[enemyIndex].x = obj.x - Enemies[enemyIndex].width
            elseif closestSide == 2 then -- right
                DetectIfEnemyDiesToSpeed(Enemies[enemyIndex])
                swapXVel()
                Enemies[enemyIndex].x = obj.x + obj.width
            end

            if closestSide ~= nil then
                if not obj.impenetrable and Weather.currentType == "foggy" and Enemies[enemyIndex].seesPlayer and lume.randomchoice({true,false}) then
                    local maxHearingDistance = ToPixels(6)
                    local distance = Distance(Player.centerX, Player.centerY, Enemies[enemyIndex].x+Enemies[enemyIndex].width/2, Enemies[enemyIndex].y+Enemies[enemyIndex].width/2)
                    local ratio = Clamp(1 - distance / maxHearingDistance, 0, 1)

                    SmashObject(obj)
                    PlaySFX(lume.randomchoice(SFX.foggyEnemySmash), .6 * ratio, math.random() / 5 + .9)
                    ShakeIntensity = 40 * ratio
                    Enemies[enemyIndex].xvelocity, Enemies[enemyIndex].yvelocity = 0, 0

                    StartSlowMo(false, false, false)
                end

                if obj.type == "sticky" then
                    local before = Enemies[enemyIndex].stuck
                    Enemies[enemyIndex].stuck = true
                    Enemies[enemyIndex].rotationVelocity, Enemies[enemyIndex].rotationRadians = 0, 0

                    if not before then
                        PlaySFX(SFX.stick, .3, 1.5)
                    end
                else
                    Enemies[enemyIndex].rotationVelocity = Enemies[enemyIndex].rotationVelocity + CalculateRotationVelocity(closestSide, Enemies[enemyIndex].xvelocity, Enemies[enemyIndex].yvelocity)
                    Enemies[enemyIndex].stuck = false
                end
            end

            obj.enemyTouchingSide = closestSide

            ::continue::
        else
            obj.enemyTouchingSide = nil
        end
    end
end

function DetectIfEnemyDiesToSpeed(enemy)
    if math.abs(Pythag(enemy.xvelocity, enemy.yvelocity)) >= EnemyGlobalData.minSpeedAgainstWallToDie then
        ExplodeEnemy(enemy)
    end
end

function DoEnemyFriction(enemyIndex)
    local friction = EnemyGlobalData.airFriction

    if Enemies[enemyIndex].xvelocity > 0 then
        Enemies[enemyIndex].xvelocity = Enemies[enemyIndex].xvelocity - friction * GlobalDT
        if Enemies[enemyIndex].xvelocity < 0 then
            Enemies[enemyIndex].xvelocity = 0
        end
    elseif Enemies[enemyIndex].xvelocity < 0 then
        Enemies[enemyIndex].xvelocity = Enemies[enemyIndex].xvelocity + friction * GlobalDT
        if Enemies[enemyIndex].xvelocity > 0 then
            Enemies[enemyIndex].xvelocity = 0
        end
    end
    if Enemies[enemyIndex].yvelocity > 0 then
        Enemies[enemyIndex].yvelocity = Enemies[enemyIndex].yvelocity - friction * GlobalDT
        if Enemies[enemyIndex].yvelocity < 0 then
            Enemies[enemyIndex].yvelocity = 0
        end
    elseif Enemies[enemyIndex].yvelocity < 0 then
        Enemies[enemyIndex].yvelocity = Enemies[enemyIndex].yvelocity + friction * GlobalDT
        if Enemies[enemyIndex].yvelocity > 0 then
            Enemies[enemyIndex].yvelocity = 0
        end
    end

    if not Enemies[enemyIndex].rotationVelocity then Enemies[enemyIndex].rotationVelocity = 0 end
    if not Enemies[enemyIndex].rotationRadians then Enemies[enemyIndex].rotationRadians = 0 end

    if Enemies[enemyIndex].rotationVelocity > 0 then
        Enemies[enemyIndex].rotationVelocity = Enemies[enemyIndex].rotationVelocity - EnemyGlobalData.rotationFriction * GlobalDT
        if Enemies[enemyIndex].rotationVelocity < 0 then
            Enemies[enemyIndex].rotationVelocity = 0
        end
    elseif Enemies[enemyIndex].rotationVelocity < 0 then
        Enemies[enemyIndex].rotationVelocity = Enemies[enemyIndex].rotationVelocity + EnemyGlobalData.rotationFriction * GlobalDT
        if Enemies[enemyIndex].rotationVelocity > 0 then
            Enemies[enemyIndex].rotationVelocity = 0
        end
    end
end

function ExplodeEnemy(enemy)
    for _ = 1, 15 do
        local angle = math.random(360)
        table.insert(Particles, NewParticle(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, math.random() * 5 + 4, {1,0,0}, math.random() * 4 + 3, angle, 0.02, math.random(300, 500)))
    end

    for _, message in ipairs(Messages) do
        if message.enemyFollowIndex ~= nil and Enemies[message.enemyFollowIndex].x == enemy.x and Enemies[message.enemyFollowIndex].x == enemy.y then
            lume.remove(Messages, message)
        end
    end

    for _, e in ipairs(Enemies) do
        if e == enemy then
            e.dead = true
            break
        end
    end
    PlaySFX(SFX.smash, 0.5, 1.5)
end

function CalculateRotationVelocity(side, xvelocity, yvelocity)
    local divisor = 1
    local xUltimateAdd = math.rad(xvelocity / divisor)
    local yUltimateAdd = math.rad(yvelocity / divisor)

    if side == 3 then -- top
        return xUltimateAdd
    elseif side == 4 then -- bottom
        return -xUltimateAdd
    elseif side == 1 then -- left
        return -yUltimateAdd
    elseif side == 2 then -- right
        return yUltimateAdd
    end

    error("invalid side >~<")
end