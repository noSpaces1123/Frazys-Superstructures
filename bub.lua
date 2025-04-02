function NewBub(x, y, type)
    table.insert(Bubs, {
        x = x, y = y, type = type
    })
end

function UpdateBubs()
    for bubIndex, bub in ipairs(Bubs) do
        local bubData = BubGlobalData[bub.type]
        local distanceToPlayer = Distance(Player.x + Player.width / 2, Player.y + Player.height / 2, bub.x + bubData.width / 2, bub.y + bubData.height / 2)

        if distanceToPlayer > Player.renderDistance then goto continue end

        if distanceToPlayer <= BubGlobalData.noticeDistance then
            bub.seesPlayer = true

            if Player.bubEngagementIndex ~= bubIndex then -- greeting
                Player.bubEngagementIndex = bubIndex

                BubSays(lume.randomchoice(bubData.voiceLines.greeting), bubIndex)
            else
                bubData.event(bubData)
            end
        end

        ::continue::
    end
end

function DrawBubs()
    for _, bub in ipairs(Bubs) do
        local bubData = BubGlobalData[bub.type]
        love.graphics.setColor(bubData.color)
        love.graphics.rectangle("fill", bub.x, bub.y, bub.width, bub.height, BubGlobalData.edgeRounding, BubGlobalData.edgeRounding)

        local multiply = bub.width / 6
        local angle = AngleBetween(bub.x + bub.width / 2, bub.y + bub.height / 2, Player.x + Player.width / 2, Player.y + Player.height / 2)
        local eyeX, eyeY = bub.x + bub.width / 2 + math.sin(angle) * multiply, bub.y + bub.height / 2 + math.cos(angle) * multiply
        local eyeRadius = bub.width * 0.3

        if not bub.seesPlayer then
            eyeX, eyeY = bub.x + bub.width / 2, bub.y + bub.height / 2
        end

        love.graphics.setColor(0,0,0)
        love.graphics.circle("fill", eyeX, eyeY, eyeRadius)
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
            DrawTextWithBackground(bub.says.text, bub.x, bub.y - BubGlobalData.dialogueSpacingFromBub, Fonts.medium, BubGlobalData[bub.type].color, {0,0,0})
        end
    end
end