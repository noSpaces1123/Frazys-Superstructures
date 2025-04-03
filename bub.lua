function NewBub(x, y, type)
    table.insert(Bubs, {
        x = x, y = y, type = type, phase = nil,
    })
end

function UpdateBubs()
    for bubIndex, bub in ipairs(Bubs) do
        local bubData = BubGlobalData.types[bub.type]
        local distanceToPlayer = Distance(Player.centerX, Player.centerY, bub.x + bubData.width / 2, bub.y + bubData.height / 2)

        if distanceToPlayer > Player.renderDistance then goto continue end

        if distanceToPlayer <= BubGlobalData.noticeDistance then
            bub.seesPlayer = true

            if Player.bubEngagementIndex ~= bubIndex then -- greeting
                Player.bubEngagementIndex = bubIndex

                BubSays(lume.randomchoice(bubData.voiceLines.greeting), bubIndex)
                Blackjack.playerPlaying = true
            else
                bubData.event(bubData, bub, bubIndex)
            end
        elseif Blackjack.playerPlaying and bub.type == "Jack" then
            Blackjack.playerPlaying = false
        end

        ::continue::
    end
end

function DrawBubs()
    for _, bub in ipairs(Bubs) do
        local bubData = BubGlobalData.types[bub.type]
        love.graphics.setColor(bubData.color)
        love.graphics.rectangle("fill", bub.x, bub.y, bubData.width, bubData.height, BubGlobalData.edgeRounding, BubGlobalData.edgeRounding)

        local multiply = bubData.width / 6
        local angle = AngleBetween(bub.x + bubData.width / 2, bub.y + bubData.height / 2, Player.centerX, Player.centerY)
        local eyeX, eyeY = bub.x + bubData.width / 2 + math.sin(angle) * multiply, bub.y + bubData.height / 2 + math.cos(angle) * multiply
        local eyeRadius = bubData.width * 0.3

        if not bub.seesPlayer then
            eyeX, eyeY = bub.x + bubData.width / 2, bub.y + bubData.height / 2
        end

        love.graphics.setColor(0,0,0)
        love.graphics.circle("fill", eyeX, eyeY, eyeRadius, 100)
    end
end

function BubSays(text, bubIndex)
    Bubs[bubIndex].says = { text = text, duration = 1000 }
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
        return "player bust"
    elseif playerTotal == Blackjack.bust then
        return "player spot-on"
    elseif dealerTotal > Blackjack.bust then
        return "dealer bust"
    elseif dealerTotal == Blackjack.bust then
        return "dealer spot-on"
    elseif dealerTotal < playerTotal and not hit then
        return "player higher total"
    elseif dealerTotal > playerTotal and not hit then
        return "dealer higher total"
    elseif dealerTotal == playerTotal and not hit then
        return "tie"
    end
end
function CalculateBlackjackTotal()
    local player = 0; if Player.blackjackCards ~= nil then for _, card in ipairs(Player.blackjackCards) do player = player + card.worth end end
    local dealer = 0; for index, card in ipairs(Blackjack.dealerCards) do if not (index == 2 and Bubs[Player.bubEngagementIndex].phase ~= "play again") then dealer = dealer + card.worth end end
    return player, dealer
end
function DisplayBlackjackHand(person)
    local bub = Bubs[Player.bubEngagementIndex]
    if bub.phase == "waiting" or bub.phase == "play again" then
        local cards, xAnchor, yAnchor
        if person == "player" then cards, xAnchor, yAnchor = Player.blackjackCards, Player.centerX, Player.y
        elseif person == "dealer" then cards, xAnchor, yAnchor = Blackjack.dealerCards, bub.x + BubGlobalData.types[bub.type].width / 2, bub.y
        end

        if cards == nil then return end

        local spacing = 10
        local away = 100
        love.graphics.setColor(1,1,1)
        for index, card in ipairs(cards) do
            local sprite = ((person == "dealer" and index == 2 and bub.phase ~= "play again") and Blackjack.unknownSprite or card.sprite)
            love.graphics.draw(sprite, (index - (#cards + 1) / 2) * (card.sprite:getWidth() + spacing) - card.sprite:getWidth() / 2 + xAnchor, yAnchor - card.sprite:getHeight() - away)
        end

        local playerTotal, dealerTotal = CalculateBlackjackTotal()
        DrawTextWithBackground((person == "player" and playerTotal or dealerTotal), xAnchor, yAnchor - Blackjack.cards[1].sprite:getHeight() - away - 40, Fonts.medium, {1,1,1}, {0,0,0})
    end
end