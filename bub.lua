BubGlobalData = {
    noticeDistance = ToPixels(4),
    dialogueSpacingFromBub = 60,
    edgeRounding = 2,
    maxHintDistance = ToPixels(30),
    types = {
        ["Jack"] = {
            width = 20, height = 20, color = { 176/255, 127/255, 63/255 },
            wait = { current = 0, max = 30 },
            voiceLines = {
                greeting = {
                    "Hi! I'm Jack. Wanna play some blackjack?",
                    "Hiya bub! The name's Jack. Wanna play some blackjack?",
                    "Hi! My name's Jack. Down for some blackjack?",
                    "Hey bub! My name's Jack. Wanna play blackjack?",
                    "Hey! My name's Jack and I sure love me some blackjack. Wanna play?",
                },
                hitOrStay = {
                    "What'll it be?",
                    "Make your choice.",
                    "Take your time!",
                    "You got this, bub.",
                },
                hit = {
                    "I like your style, bub.",
                    "Interesting choice.",
                    "I'm on your side, my friend.",
                    "Let's hope this goes well.",
                },
                stay = {
                    "Hmmm...",
                },
                outcomes = {
                    ["player higher total"] = {
                        "You got the higher total! Nice job, bub!",
                        "You got the higher total! Well played, bub!",
                        "You got the higher total! Well done!",
                        "You got the higher total, smarty pants!",
                    },
                    ["player bust"] = {
                        "You're bust! I was rootin' for you...",
                        "You're bust! Better luck next time, bub.",
                        "You're bust! But you had the right idea, ha-ha.",
                        "You're bust! Practice makes perfect.",
                    },
                    ["player spot-on"] = {
                        "You got 21 exactly! Didn't know I was playing a pro!.",
                        "You got 21 exactly! Lucky bastard!",
                        "You got 21 exactly! Didn't think you were so good, bub!",
                        "You got 21 exactly! Excellent performance!",
                    },

                    ["dealer higher total"] = {
                        "I got the higher total! Good game.",
                        "I got the higher total! I had fun.",
                        "I got the higher total, ha-ha!",
                        "I got the higher total! How thrilling.",
                    },
                    ["dealer bust"] = {
                        "I'm bust! Well done!",
                        "I'm bust! Nicely done!",
                        "I'm bust! Good play.",
                        "Whoopsie, I'm bust!",
                    },
                    ["dealer spot-on"] = {
                        "I got 21 exactly! That's it for you, buddy.",
                        "I got 21 exactly! I'm legit, I swear!",
                        "I got 21 exactly! Good game.",
                        "I got 21 exactly! Exhilarating!",
                        "I got 21 exactly! Gonna tell my mom about this one.",
                    },

                    ["tie"] = {
                        "Well would you look at that? We tied!",
                        "We tied! Well played.",
                        "Whoops, we tied! Had fun playin' with ya, bub.",
                    },
                },
                playAgain = {
                    "Wanna play again?",
                    "You got another one in ya?",
                    "How about a rematch, bub?",
                }
            },
            event = function (self, bub, bubIndex, event)
                if self.wait.current <= 0 then
                    if event == "play" then
                        Player.blackjackCards, Blackjack.dealerCards = {}, {}
                        BubSays(lume.randomchoice(self.voiceLines.hitOrStay), bubIndex)
                        ResetBlackjackDeck()
                        BlackjackDeal(2, "player"); BlackjackDeal(2, "dealer")
                        zutil.playsfx(SFX.drawCard, 0.2, 1)
                        bub.phase = "player"
                        Blackjack.playerPlaying = true
                        Blackjack.winner = nil
                    elseif event == "hit" then
                        BubSays(lume.randomchoice(self.voiceLines.hit), bubIndex)
                        local outcome = BlackjackDeal(1, "player")
                        self.wait.current = 30
                        zutil.playsfx(SFX.drawCard, 0.2, 1 + (#Player.blackjackCards - 2) / 8)

                        if outcome == "player bust" or outcome == "player spot-on" then
                            self.wait.current = 30
                            bub.phase = "play again"
                            BubSays(lume.randomchoice(self.voiceLines.outcomes[CheckBlackjackWinner(true)]), bubIndex) -- player wins or loses

                            if outcome == "player bust" then
                                zutil.playsfx(SFX.bust, 0.2, 1)
                            else
                                zutil.playsfx(SFX.blackjackSpotOn, 0.2, 1)
                            end
                        end
                    elseif event == "stay" then
                        BubSays(lume.randomchoice(self.voiceLines.stay), bubIndex)
                        local outcome = CheckBlackjackWinner(true)
                        self.wait.current = 50
                        bub.phase = "dealer's choice"

                        if outcome == "player spot-on" then
                            self.wait.current = 30
                            bub.phase = "play again"
                            BubSays(lume.randomchoice(self.voiceLines.outcomes[CheckBlackjackWinner(true)]), bubIndex)
                            zutil.playsfx(SFX.blackjackSpotOn, 0.2, 1)
                        end
                    elseif bub.phase == "dealer's choice" then
                        local outcome
                        local _, dealerTotal = CalculateBlackjackTotal()
                        if dealerTotal <= 16 then
                            BlackjackDeal(1, "dealer")
                            outcome = CheckBlackjackWinner(true)
                            self.wait.current = 50
                            if outcome == "dealer bust" then zutil.playsfx(SFX.bust, 0.2, 1) end
                        else
                            outcome = CheckBlackjackWinner()
                        end

                        if outcome ~= nil then
                            BubSays(lume.randomchoice(self.voiceLines.outcomes[outcome]), bubIndex) -- win or lose
                            self.wait.current = 40
                            bub.phase = "play again"
                        end
                    elseif bub.phase == "play again" and event == "acknowledged" then
                        BubSays(lume.randomchoice(self.voiceLines.playAgain), bubIndex)
                        bub.phase = "request"
                    end
                else
                    self.wait.current = self.wait.current - 1 * GlobalDT
                end
            end
        },
        ["Wygore"] = {
            width = 20, height = 50, color = { 1, 1, 1 },
            wait = { current = 300, max = 300 },
            voiceLines = {
                greeting = {
                    "Beware the decrepit hooligans... Destruction awaits you.",
                    "Visitor. Good day. Hold [SPACE] to negate the stickiness of sticky platforms.",
                    "Hello. Use [SPACE] just before hitting a jump pad to get an extra boost.",
                    "Greetings. See me again and I may just give you some of my wisdom.",
                    "Hello. Use the wind events in rainy levels to easily kill hooligans.",
                    "Good day. Decrepit hooligans can be killed.",
                    "Howdy. Hooligans are more orange the slower they are.",
                    "Hello. When a hooligan targets you, they make a lower-pitched sound the bigger they are.",
                    "Hello. Turrets have a chance to be friendly or overly angry.",
                    "I will see you another time. Toodles.",
                },
            },
            event = function (self, bub, bubIndex, event)
                if event == "left" then
                    bub.disabled = true

                    for _ = 1, 40 do
                        table.insert(Particles, NewParticle(bub.x+self.width/2, bub.y+self.height/2, math.random()*10+3, {1,1,1,math.random()/2+.4}, math.random()*3*3, math.random(360), 0.01, math.random(100,200)))
                    end

                    zutil.playsfx(SFX.poof, .4, .5)
                end
            end
        },
        ["Marvin"] = {
            width = 10, height = 10, color = { 116/255, 46/255, 1 },
            wait = { current = 300, max = 300 },
            voiceLines = {
                greeting = {
                    "Hello! I'm Marvin, and I'm a magic weatherman. Do you wish to change the weather? I'm magic, so I can do that!",
                },
            },
            event = function (self, bub, bubIndex, event)
                if event == "change weather" then
                    bub.disabled = true
                    for _ = 1, 40 do
                        table.insert(Particles, NewParticle(bub.x+self.width/2, bub.y+self.height/2, math.random()*10+3, {self.color[1],self.color[2],self.color[3],math.random()/2+.4}, math.random()*3*3, math.random(360), 0.01, math.random(100,200)))
                    end
                    zutil.playsfx(SFX.poof, .4, .5)

                    local choices = {}
                    for key, _ in pairs(Weather.types) do
                        if key ~= Weather.currentType then table.insert(choices, key) end
                    end
                    Weather.currentType = choices[math.random(#choices)]

                    zutil.playsfx(SFX.changeWeather, .4, 1)
                    SFX.windy:stop()
                    SFX.rainy:stop()

                    Player.bubEngagementIndex = nil
                    bub.says = nil

                    if Weather.currentType == "foggy" then
                        for _, enemy in ipairs(Enemies) do
                            enemy.width = enemy.width * Weather.types.foggy.enemySizeMultiplier
                            enemy.speed = enemy.speed * Weather.types.foggy.enemySpeedMultiplier
                        end
                        Turrets = {}
                    elseif Settings.musicOn then
                        Music:play()
                    end
                end
            end
        },
        ["Globu"] = {
            width = 20, height = 10, color = { 125/255, 245/255, 221/255 },
            wait = { current = 300, max = 300 },
            voiceLines = {
                greeting = {
                    "Globu is I. Wish to find a thing?",
                    "Globu. I know a thing. Want to see?",
                    "I am Globu. Want to find a thing?",
                },
            },
            event = function (self, bub, bubIndex, event)
                if event == "find a thing" then
                    bub.disabled = true
                    for _ = 1, 40 do
                        table.insert(Particles, NewParticle(bub.x+self.width/2, bub.y+self.height/2, math.random()*10+3, {self.color[1],self.color[2],self.color[3],math.random()/2+.4}, math.random()*3*3, math.random(360), 0.01, math.random(100,200)))
                    end
                    zutil.playsfx(SFX.poof, .4, .5)
                    Player.bubEngagementIndex = nil
                    bub.says = nil


                    local pickFrom = { {}, {} }
                    for i, t in ipairs(pickFrom) do
                        if i == 1 then
                            for _, shrine in ipairs(Shrines) do
                                table.insert(t, shrine)
                            end
                        elseif i == 2 then
                            for _, bub2 in ipairs(Bubs) do
                                if not bub2.disabled then
                                    table.insert(t, bub2)
                                end
                            end
                        end
                    end
                    for _, t in ipairs(pickFrom) do    if #t == 0 then lume.remove(pickFrom, t) end    end

                    local tablePick = pickFrom[math.random(#pickFrom)]
                    local pick = tablePick[math.random(#tablePick)]

                    local inaccuracy = 1.5

                    NewWayPoint(pick.x + zutil.jitter(ToPixels(inaccuracy)), pick.y + zutil.jitter(ToPixels(inaccuracy)))
                end
            end
        },
    }
}



function NewBub(x, y, type)
    table.insert(Bubs, {
        x = x, y = y, type = type, phase = nil,
    })

    for _, turret in ipairs(Enemies) do
        if zutil.distance(turret.x, turret.y, x+BubGlobalData.types[type].width/2, y+BubGlobalData.types[type].width/2) <= turret.viewRadius + BubGlobalData.noticeDistance then
            lume.remove(Turrets, turret)
        end
    end
    for _, enemy in ipairs(Enemies) do
        if zutil.distance(enemy.x+enemy.width/2, enemy.y+enemy.width/2, x+BubGlobalData.types[type].width/2, y+BubGlobalData.types[type].width/2) <= enemy.viewRadius + BubGlobalData.noticeDistance then
            lume.remove(Enemies, enemy)
        end
    end
end

function SpawnBubs()
    Bubs = {}

    local categories = {}
    for key, _ in pairs(BubGlobalData.types) do
        table.insert(categories, key)
    end

    local objWidth = 400

    for _ = 1, Boundary.width * Boundary.height * ObjectGlobalData.bubDensity do
        local x, y = math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height)
        local bubType = categories[math.random(#categories)]
        local bubData = BubGlobalData.types[bubType]
        NewBub(x, y, bubType)

        for _, obj in ipairs(Objects) do
            if zutil.touching(obj.x, obj.y, obj.width, obj.height, x, y, bubData.width, bubData.height) then
                lume.remove(Objects, obj)
            end
        end

        -- platform under the bub
        table.insert(Objects, {
            x = x + bubData.width / 2 - objWidth / 2, y = y + bubData.height, width = objWidth, height = 80, type = "normal"
        })
    end
end

function UpdateBubs()
    for bubIndex, bub in ipairs(Bubs) do
        if bub.disabled then goto continue end

        local bubData = BubGlobalData.types[bub.type]
        local distanceToPlayer = zutil.distance(Player.centerX, Player.centerY, bub.x + bubData.width / 2, bub.y + bubData.height / 2)

        if distanceToPlayer > Player.renderDistance then goto continue end

        if distanceToPlayer <= BubGlobalData.noticeDistance then
            bub.seesPlayer = true

            if Player.bubEngagementIndex ~= bubIndex then -- greeting
                Player.bubEngagementIndex = bubIndex

                BubSays(lume.randomchoice(bubData.voiceLines.greeting), bubIndex)
            else
                bubData.event(bubData, bub, Player.bubEngagementIndex, nil)
            end
        else
            bub.says = nil
            if Blackjack.playerPlaying then Blackjack.playerPlaying = false end
            if Player.bubEngagementIndex == bubIndex then
                Player.bubEngagementIndex = nil
                bubData.event(bubData, bub, Player.bubEngagementIndex, "left")
            end
        end

        ::continue::
    end
end

function DrawBubs()
    for bubIndex, bub in ipairs(Bubs) do
        if bub.disabled then goto continue end

        local distance = zutil.distance(bub.x, bub.y, Player.centerX, Player.centerY)
        local bubData = BubGlobalData.types[bub.type]
        if distance <= Player.renderDistance then
            love.graphics.setColor(bubData.color)
            love.graphics.rectangle("fill", bub.x, bub.y, bubData.width, bubData.height, BubGlobalData.edgeRounding, BubGlobalData.edgeRounding)

            if Player.bubEngagementIndex == bubIndex then
                love.graphics.setLineWidth(math.random(3,4))
                love.graphics.setColor(bubData.color[1], bubData.color[2], bubData.color[3], 0.2)
                love.graphics.circle("line", bub.x + bubData.width / 2, bub.y + bubData.height / 2, BubGlobalData.noticeDistance)
            end

            local multiply = bubData.width / 6
            local angle = zutil.angleBetween(bub.x + bubData.width / 2, bub.y + bubData.height / 2, Player.centerX, Player.centerY)
            local eyeX, eyeY = bub.x + bubData.width / 2 + math.sin(angle) * multiply, bub.y + bubData.height / 2 + math.cos(angle) * multiply
            local eyeRadius = bubData.width * 0.3

            if not bub.seesPlayer then
                eyeX, eyeY = bub.x + bubData.width / 2, bub.y + bubData.height / 2
            end

            love.graphics.setColor(0,0,0)
            love.graphics.circle("fill", eyeX, eyeY, eyeRadius, 100)

            if bub.type == "Jack" then
                love.graphics.setColor(1,1,1)
                love.graphics.draw(Sprites.jacksHat, bub.x + bubData.width / 2 - Sprites.jacksHat:getWidth() / 2, bub.y - Sprites.jacksHat:getHeight() * 0.6)
            end
        end

        if AnalyticsUpgrades["signal radar"] and distance <= BubGlobalData.maxHintDistance and distance > BubGlobalData.noticeDistance then
            DrawArrowTowards(bub.x + bubData.width / 2, bub.y + bubData.height / 2, bubData.color, 0.6, BubGlobalData.maxHintDistance)
        end

        ::continue::
    end
end

function BubSays(text, bubIndex)
    Bubs[bubIndex].says = { text = text, duration = 1000 }
    zutil.playsfx(SFX.bubSpeak, 0.6, math.random()/10+.95)
end
function UpdateBubDialogue()
    for _, bub in ipairs(Bubs) do
        if bub.says ~= nil then
            bub.says.duration = bub.says.duration - 1 * GlobalDT
            if bub.says.duration <= 0 then bub.says = nil end
        end
    end
end
function DrawBubDialogue()
    for _, bub in ipairs(Bubs) do
        if bub.says ~= nil then
            DrawTextWithBackground(bub.says.text, bub.x, bub.y - BubGlobalData.dialogueSpacingFromBub, Fonts.medium, BubGlobalData.types[bub.type].color, {0,0,0})
        end
    end
end

function ResetBlackjackDeck()
    Blackjack.cards = {}
    for index, fileName in ipairs(love.filesystem.getDirectoryItems("assets/sprites/blackjack")) do
        if index == 1 or fileName == "unknown.png" then goto continue end
        table.insert(Blackjack.cards, { sprite = love.graphics.newImage("assets/sprites/blackjack/" .. fileName, {dpiscale=10}), worth = zutil.clamp(tonumber(lume.split(lume.split(fileName, " ")[2], ".")[1]), 1, 10), suit = lume.split(fileName, " ")[1] })
        ::continue::
    end
    Blackjack.unknownSprite = love.graphics.newImage("assets/sprites/blackjack/unknown.png", {dpiscale=10})
    --error(lume.serialize(Blackjack.cards))
end
function BlackjackDeal(numberOfCards, person)
    if person == "player" then
        if Player.blackjackCards == nil then
            Player.blackjackCards = {}
        end

        for _ = 1, numberOfCards do
            local card = lume.randomchoice(Blackjack.cards)
            table.insert(Player.blackjackCards, card)
            lume.remove(Blackjack.cards, card)
        end
    elseif person == "dealer" then
        for _ = 1, numberOfCards do
            local card = lume.randomchoice(Blackjack.cards)
            table.insert(Blackjack.dealerCards, card)
            lume.remove(Blackjack.cards, card)
        end
    end

    return CheckBlackjackWinner(true)
end
function CheckBlackjackWinner(hit)
    local playerTotal, dealerTotal = CalculateBlackjackTotal()

    if playerTotal > Blackjack.bust then
        Blackjack.winner = "dealer"
        return "player bust"

    elseif playerTotal == Blackjack.bust then
        Blackjack.winner = "player"
        return "player spot-on"

    elseif dealerTotal > Blackjack.bust then
        Blackjack.winner = "player"
        return "dealer bust"

    elseif dealerTotal == Blackjack.bust then
        Blackjack.winner = "dealer"
        return "dealer spot-on"

    elseif dealerTotal < playerTotal and not hit then
        Blackjack.winner = "player"
        return "player higher total"

    elseif dealerTotal > playerTotal and not hit then
        Blackjack.winner = "dealer"
        return "dealer higher total"

    elseif dealerTotal == playerTotal and not hit then
        Blackjack.winner = "neither"
        return "tie"

    end
end
function CalculateBlackjackTotal(forDisplay)
    local playerTotal, playerAces = 0, 0
    if Player.blackjackCards ~= nil then
        for _, card in ipairs(Player.blackjackCards) do
            if card.worth == 1 then playerAces = playerAces + 1 end
            playerTotal = playerTotal + card.worth
        end
    end
    for _ = 1, playerAces do
        if playerTotal + 10 <= Blackjack.bust then
            playerTotal = playerTotal + 10
        end
    end

    local dealerTotal, dealerAces = 0, 0
    for index, card in ipairs(Blackjack.dealerCards) do
        if not (index == 2 and Bubs[Player.bubEngagementIndex].phase ~= "play again" and forDisplay) then
            if card.worth == 1 then dealerAces = dealerAces + 1 end
            dealerTotal = dealerTotal + card.worth
        end
    end
    for _ = 1, dealerAces do
        if dealerTotal + 10 <= Blackjack.bust then
            dealerTotal = dealerTotal + 10
        end
    end

    return playerTotal, dealerTotal
end
function DisplayBlackjackHand(person)
    local bub = Bubs[Player.bubEngagementIndex]
    if bub.phase == "player" or bub.phase == "play again" or bub.phase == "dealer's choice" then
        local cards, xAnchor, yAnchor
        if person == "player" then cards, xAnchor, yAnchor = Player.blackjackCards, Player.centerX, Player.y
        elseif person == "dealer" then cards, xAnchor, yAnchor = Blackjack.dealerCards, bub.x + BubGlobalData.types[bub.type].width / 2, bub.y
        end

        if cards == nil then return end

        local spacing = 10
        local away = 100
        love.graphics.setColor(1,1,1)
        for index, card in ipairs(cards) do
            local sprite = ((person == "dealer" and index == 2 and bub.phase ~= "play again" and bub.phase ~= "dealer's choice") and Blackjack.unknownSprite or card.sprite)
            love.graphics.draw(sprite, (index - (#cards + 1) / 2) * (card.sprite:getWidth() + spacing) - card.sprite:getWidth() / 2 + xAnchor, yAnchor - card.sprite:getHeight() - away)
        end

        local playerTotal, dealerTotal = CalculateBlackjackTotal(true)

        local textColor = {1,1,1}
        if (person == "player" and playerTotal > Blackjack.bust) or (person == "dealer" and dealerTotal > Blackjack.bust) then
            textColor = {1,0,0}
        end
        if Blackjack.winner == person then
            textColor = {0,1,0}
        end

        DrawTextWithBackground((person == "player" and playerTotal or dealerTotal) .. ((person == "dealer" and bub.phase == "player") and " + ?" or ""), xAnchor, yAnchor - Blackjack.cards[1].sprite:getHeight() - away - 40, Fonts.medium, textColor, {0,0,0})
    end
end

function InitialiseBubButtons()
    local spacing, width, height = 30, 200, 40
    NewButton("Hit", love.graphics.getWidth() / 2 - spacing / 2 - width, love.graphics.getHeight() - spacing - height, width, height, "center", {1,0,0}, {0,0,0}, {.2,0,0}, {1,0,0}, Fonts.normal, 0, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "hit")
    end, nil, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].phase == "player" and Blackjack.playerPlaying and BubGlobalData.types[Bubs[Player.bubEngagementIndex].type].wait.current <= 0
    end)
    NewButton("Stay", love.graphics.getWidth() / 2 + spacing / 2, love.graphics.getHeight() - spacing - height, width, height, "center", {0,1,1}, {0,0,0}, {0,.2,.2}, {0,1,1}, Fonts.normal, 0, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "stay")
    end, nil, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].phase == "player" and Blackjack.playerPlaying and BubGlobalData.types[Bubs[Player.bubEngagementIndex].type].wait.current <= 0
    end)

    NewButton("Hell yeah.", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - spacing - height, width, height, "center", {0,1,0}, {0,0,0}, {0,.2,0}, {0,1,0}, Fonts.normal, 2, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "play")
    end, nil, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].type == "Jack" and (not Blackjack.playerPlaying or Bubs[Player.bubEngagementIndex].phase == "request")
    end)

    NewButton("Okay", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - spacing - height, width, height, "center", {1,1,1}, {0,0,0}, {.2,.2,.2}, {1,1,1}, Fonts.normal, 2, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "acknowledged")
    end, function (self)
        if Blackjack.winner == "player" then
            self.text = "Yay!"
        elseif Blackjack.winner == "dealer" then
            self.text = "Okay"
        elseif Blackjack.winner == "neither" then
            self.text = "Huh!"
        end
    end, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].type == "Jack" and Bubs[Player.bubEngagementIndex].phase == "play again"
    end)

    NewButton("Sure!", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - spacing - height, width, height, "center", {1,1,1}, {0,0,0}, {.2,.2,.2}, {1,1,1}, Fonts.normal, 2, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "change weather")
    end, nil, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].type == "Marvin"
    end)

    NewButton("Sure!", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - spacing - height, width, height, "center", {1,1,1}, {0,0,0}, {.2,.2,.2}, {1,1,1}, Fonts.normal, 2, 10,10, function (self)
        local bubData = BubGlobalData.types[Bubs[Player.bubEngagementIndex].type]
        bubData.event(bubData, Bubs[Player.bubEngagementIndex], Player.bubEngagementIndex, "find a thing")
    end, nil, function (self)
        return GameState == "game" and not Paused and Player.bubEngagementIndex ~= nil and Bubs[Player.bubEngagementIndex].type == "Globu"
    end)
end