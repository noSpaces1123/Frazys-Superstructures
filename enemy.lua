function SpawnEnemies()
    Enemies = {}

    for _ = 1, EnemyGlobalData.enemyDensity * Boundary.width * Boundary.height do
        NewEnemy(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
    end
end

function NewEnemy(x, y)
    table.insert(Enemies, {
        x = x, y = y, xvelocity = 0, yvelocity = 0,
        width = math.random(EnemyGlobalData.width.min, EnemyGlobalData.width.max), speed = math.random(EnemyGlobalData.speed.min, EnemyGlobalData.speed.max) / EnemyGlobalData.speed.divide,
        viewRadius = math.random(EnemyGlobalData.viewRadius.min, EnemyGlobalData.viewRadius.max), seesPlayer = false,
        warble = { current = 0, max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max) },
    })
end

function DrawEnemies()
    for _, enemy in ipairs(Enemies) do
        if not enemy.dead then
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.width)

            if enemy.seesPlayer and not Player.respawnWait.dead then
                love.graphics.setColor(1,0,0,math.random()/2)
                love.graphics.setLineWidth(3)
                love.graphics.line(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.x + Player.width / 2, Player.y + Player.height / 2)
            end


            local multiply = enemy.width / 6
            local angle = AngleBetween(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.x + Player.width / 2, Player.y + Player.height / 2)
            local eyeX, eyeY = enemy.x + enemy.width / 2 + math.sin(angle) * multiply, enemy.y + enemy.width / 2 + math.cos(angle) * multiply
            local eyeWidth = enemy.width * 0.5

            if not enemy.seesPlayer then
                eyeX, eyeY = enemy.x + enemy.width / 2, enemy.y + enemy.width / 2
            end

            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("fill", eyeX - eyeWidth / 2, eyeY - eyeWidth / 2, eyeWidth, eyeWidth)
        end
    end
end

function UpdateEnemies()
    for index, enemy in ipairs(Enemies) do
        if not enemy.dead then
            local distance = Distance(Player.x + Player.width / 2, Player.y + Player.height / 2, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2)

            local before = enemy.seesPlayer
            enemy.seesPlayer = distance <= enemy.viewRadius
            if enemy.seesPlayer and not before then
                local ratio = 1 - (enemy.width - EnemyGlobalData.width.min) / (EnemyGlobalData.width.max - EnemyGlobalData.width.min)
                PlaySFX(SFX.enemySeesPlayer, 0.6, ratio * 1 + 1)
                if math.random() < 0.2 then
                    enemy.warble.current = enemy.warble.max
                end
            end

            if distance <= Player.renderDistance then
                if not Player.respawnWait.dead and not NextLevelAnimation.running then
                    if enemy.seesPlayer then
                        local angle = AngleBetween(enemy.x + enemy.width / 2, enemy.y + enemy.width / 2, Player.x + Player.width / 2, Player.y + Player.height / 2) + math.rad(Jitter(20))
                        enemy.xvelocity = enemy.xvelocity + math.sin(angle) * enemy.speed * GlobalDT
                        enemy.yvelocity = enemy.yvelocity + math.cos(angle) * enemy.speed * GlobalDT
                    end

                    if Touching(Player.x, Player.y, Player.width, Player.height, enemy.x, enemy.y, enemy.width, enemy.width) then
                        if Player.netSpeed + Player.enemyKillForgiveness >= Pythag(enemy.xvelocity, enemy.yvelocity) then
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

                DoEnemyFriction(index)
                DoEnemyCollisions(index)

                enemy.x = enemy.x + enemy.xvelocity * GlobalDT
                enemy.y = enemy.y + enemy.yvelocity * GlobalDT

                -- warbling
                local maxWarbleHearing = 2000
                if enemy.warble == nil then enemy.warble = { current = 0, max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max) } end
                enemy.warble.current = enemy.warble.current + 1
                if enemy.warble.current >= enemy.warble.max then
                    enemy.warble.current = 0
                    enemy.warble.max = math.random(EnemyGlobalData.warble.min, EnemyGlobalData.warble.max)
                    PlaySFX(lume.randomchoice(SFX.enemySpeak), (1 - Clamp(distance, 0, maxWarbleHearing) / maxWarbleHearing) * 0.1, math.random() / 5 + 0.4)
                    NewMessage(lume.randomchoice(EnemyGlobalData.voiceLines), enemy.width / 2, -50, {1,0,0}, 100, Fonts.medium, index)
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