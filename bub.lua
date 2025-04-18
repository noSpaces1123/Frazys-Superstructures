function NewBub(x, y, type)
    table.insert(Bubs, {
        x = x, y = y, type = type, phase = nil,
    })

    for _, turret in ipairs(Enemies) do
        if Distance(turret.x, turret.y, x+BubGlobalData.types[type].width/2, y+BubGlobalData.types[type].width/2) <= turret.viewRadius + BubGlobalData.noticeDistance then
            lume.remove(Turrets, turret)
        end
    end
    for _, enemy in ipairs(Enemies) do
        if Distance(enemy.x+enemy.width/2, enemy.y+enemy.width/2, x+BubGlobalData.types[type].width/2, y+BubGlobalData.types[type].width/2) <= enemy.viewRadius + BubGlobalData.noticeDistance then
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
            if Touching(obj.x, obj.y, obj.width, obj.height, x, y, bubData.width, bubData.height) then
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
        local distanceToPlayer = Distance(Player.centerX, Player.centerY, bub.x + bubData.width / 2, bub.y + bubData.height / 2)

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

        local distance = Distance(bub.x, bub.y, Player.centerX, Player.centerY)
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
            local angle = AngleBetween(bub.x + bubData.width / 2, bub.y + bubData.height / 2, Player.centerX, Player.centerY)
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
    PlaySFX(SFX.bubSpeak, 0.6, math.random()/10+.95)
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
        table.insert(Blackjack.cards, { sprite = love.graphics.newImage("assets/sprites/blackjack/" .. fileName, {dpiscale=10}), worth = Clamp(tonumber(lume.split(lume.split(fileName, " ")[2], ".")[1]), 1, 10), suit = lume.split(fileName, " ")[1] })
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