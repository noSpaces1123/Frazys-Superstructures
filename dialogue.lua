Dialogue = {
    index = 1,
    playing = {
        text = "", targetText = nil,
        charInterval = { current = 0, max = 2, defaultMax = 2,
            maxOn = { { char = ".", max = 20 }, { char = ",", max = 10 }, { char = "!", max = 20 }, { char = "?", max = 30 }, { char = "-", max = 40 } } },
        charIndex = 1,
        finished = false,
        postWait = { current = 0, max = 200 },
        running = false,
    },
    list = {
        {
            text = "I hope my team knows what they're doing sending me here. I hear this place is dangerous, but all I need to do is reach the top of each level.",
            when = function () return
                Level == 1
            end
        },
        {
            text = "I wonder if I can destroy that turret by hitting it...",
            when = function ()
                for _, turret in ipairs(Enemies) do
                    if turret.seesPlayer then
                        return true
                    end
                end
                return false
            end
        },
        {
            text = "Nice. Let's do that if they're ever a problem again.",
            when = function ()
                return PlayerSkill.turretsDestroyed == 1
            end
        },
        {
            text = "I'm really getting the hang of this!",
            when = function ()
                return PlayerSkill.turretsDestroyed == 10
            end
        },
        {
            text = "It's about time these guys got a taste of their own medicine.",
            when = function ()
                return PlayerSkill.turretsDestroyed == 50
            end
        },
        {
            text = "Ouch! That's hot. Intel, what happens when I get too hot?",
            when = function ()
                return Player.temperature.current > 0
            end,
            finishFunc = function ()
                IntelCallIn("don't get your temperature meter above 100%. use icy platforms to cool down.")
            end
        },
        {
            text = "Next level. Let's do this.",
            when = function ()
                return Level == 2
            end
        },
        {
            text = "Those orange turrets heat me up. I should stay away.",
            when = function ()
                local yes = false
                for _, turret in ipairs(Enemies) do
                    if turret.seesPlayer and turret.type == "laser" then
                        yes = true
                    end
                end
                return Level >= 2 and yes and Dialogue.list[3].done
            end
        },
        {
            text = "Those blue turrets just fire bullets, I suppose.",
            when = function ()
                local yes = false
                for _, turret in ipairs(Enemies) do
                    if turret.seesPlayer and turret.type == "normal" then
                        yes = true
                    end
                end
                return Level >= 2 and yes and Dialogue.list[3].done
            end
        },
        {
            text = "Those yellow turrets pull me in, but don't deal any damage.",
            when = function ()
                local yes = false
                for _, turret in ipairs(Enemies) do
                    if turret.seesPlayer and turret.type == "drag" then
                        yes = true
                    end
                end
                return Level >= 2 and yes and Dialogue.list[3].done
            end
        },
        {
            text = "It looks like the height of the levels increases every ten levels. Let's keep that in mind.",
            when = function ()
                return Level == 10
            end
        },
        {
            text = "First death...",
            when = function ()
                return PlayerSkill.deaths == 1
            end
        },
        {
            text = "Intel said I've got a special ability I can use with [Q], as long as I have enough charge in the top right bar. A fixed amount is removed from the bar with every use.",
            when = function ()
                return Level == 5
            end
        },
        {
            text = "Intel, how do I open up the minimap?",
            when = function ()
                return AnalyticsUpgrades["minimap"]
            end,
            finishFunc = function ()
                IntelCallIn("use [m] to open the minimap.")
            end
        },
        {
            text = "Whee!",
            when = function ()
                return Player.netSpeed >= 50
            end
        },
        {
            text = "Perfect. Now, when I die, I'll respawn here. Intel says these checkpoints also destroy turrets and those bastard hooligans nearby.",
            when = function ()
                return Player.checkpoint.x ~= nil
            end
        },
        {
            text = "That's a lot of bullets!",
            when = function ()
                return PlayerSkill.greatestBulletPresence >= 10
            end
        },
        {
            text = "Whoa!",
            when = function ()
                return PlayerSkill.greatestBulletPresence >= 3
            end
        },
        {
            text = "Holy cow...",
            when = function ()
                return PlayerSkill.greatestBulletPresence >= 15
            end
        },
        {
            text = "So that's what the strange signals were... What's different now?",
            when = function ()
                local yes = false
                for _, active in pairs(PlayerPerks) do
                    if active then
                        yes = true
                    end
                end
                return yes
            end
        },
        {
            text = "Victor at Intel said I only need to reach level 50 to get enough info and head home.",
            when = function ()
                return Level >= 11
            end
        },
        {
            text = "That's hot!",
            when = function ()
                return Level >= 3 and Player.temperature.current / Player.temperature.max >= 0.8
            end
        },
        {
            text = "These levels don't seem to be too complex, but I have a feeling more and more turrets are piling up...", -- LAST ONE TO DO MR SKIPPER
            when = function ()
                return Level >= 12
            end
        },
        {
            text = "The turrets are definitely getting more frequent.",
            when = function ()
                return Level >= 13
            end
        },
        {
            text = "Intel said they're getting strange signals from each of these levels... I should explore to find out what they are.",
            when = function ()
                local condition = Level >= 15 and Player.y <= Boundary.y + Boundary.height / 2
                if condition and #Shrines == 0 then SpawnShrines() end
                return condition
            end
        },
        {
            text = "Whoa! That guy's out to get me, but he doesn't seem very clever.",
            when = function ()
                local yes = false
                for _, enemy in ipairs(Enemies) do
                    if enemy.seesPlayer then
                        yes = true
                    end
                end
                return yes
            end
        },
        {
            text = "Here we go again! Let's see if I can get more data faster than before.",
            when = function ()
                return BestGameCompletionTime ~= nil
            end
        },
        {
            text = "Halfway done. 25 levels left.",
            when = function ()
                return Level == 25
            end
        },
        {
            text = "Boom. 100th turret dead.",
            when = function ()
                return PlayerSkill.turretsDestroyed == 100
            end
        },
        {
            text = "Those guys are gonna be annoying.",
            when = function ()
                return PlayerSkill.enemiesKilled == 1
            end
        },
        {
            text = "That's 10 of those bastards down.",
            when = function ()
                return PlayerSkill.enemiesKilled == 10
            end
        },
        {
            text = "Enemy number 100 dead.",
            when = function ()
                return PlayerSkill.enemiesKilled == 100
            end
        },
        {
            text = "Let's just finish this level already.",
            when = function ()
                return TimeOnThisLevel >= 5 * 60
            end
        },
        {
            text = "Why is this level taking so long...",
            when = function ()
                return TimeOnThisLevel >= 10 * 60
            end
        },
        {
            text = "All the intel under an hour, done. Once a boy- now a man.",
            when = function ()
                return BestGameCompletionTime ~= nil and BestGameCompletionTime < 60 * 60
            end
        },
        {
            text = "How did I even pull off that last run?",
            when = function ()
                return BestGameCompletionTime ~= nil and BestGameCompletionTime < 5 * 60
            end
        },
        {
            text = "WWHHHHHAAAAAAAA!!!",
            when = function ()
                return Player.yvelocity < -140
            end
        },
        {
            text = "I need a damn coffee.",
            when = function ()
                return Player.netSpeed <= 0.1 and Level == 50 and Player.y < Boundary.y + Boundary.height / 3
            end
        },
        {
            text = "I need a goddamn coffee.",
            when = function ()
                return BestGameCompletionTime ~= nil and Player.netSpeed <= 0.1 and Level == 50 and Player.y < Boundary.y + Boundary.height / 3
            end
        },
        {
            text = "Almost there!",
            when = function ()
                return Level == 50 and Player.y < Boundary.y + Boundary.height / 4
            end
        },
        {
            text = "Almost!!",
            when = function ()
                return Level == 50 and Player.y < Boundary.y + Boundary.height / 7
            end
        },
        {
            text = "These levels are getting really tall.",
            when = function ()
                return Level == 30
            end
        },
        {
            text = "I hate those hooligans.",
            when = function ()
                return PlayerSkill.enemiesKilled >= 20
            end
        },
        {
            text = "God save me.",
            when = function ()
                return PlayerSkill.greatestBulletPresence >= 22
            end
        },
        {
            text = "I think I can kill those red hooligans by hitting them with more speed than they hit me.",
            when = function ()
                return Level >= 4
            end
        },
        {
            text = "Around about 60% done. Intel doesn't need much more, let's finish this.",
            when = function ()
                return Level == 31
            end
        },
        {
            text = "Ten levels left!",
            when = function ()
                return Level == 40
            end
        },
        {
            text = "10 deaths thus far...",
            when = function ()
                return PlayerSkill.deaths == 10
            end
        },
        {
            text = "10 deaths.",
            when = function ()
                return BestGameCompletionTime ~= nil and PlayerSkill.deaths == 10
            end
        },
        {
            text = "This is the final level. Let's do this.",
            when = function ()
                return Level == 50
            end
        },
        {
            text = "Whoa! That was insane. I can't believe I made it outta there! Let's hope I don't have to go through that again...",
            when = function ()
                return Level == Descending.onLevels[1] + 1
            end
        },
        {
            text = "Intel says I can use [SHIFT] to get some extra sight.",
            when = function ()
                return Level == 7
            end
        },
        {
            text = "All the intel collected in under an hour and a half! But I bet I can do it faster.",
            when = function ()
                return BestGameCompletionTime ~= nil and BestGameCompletionTime < 90 * 60
            end
        },
        {
            text = "([P] to pause)",
            when = function ()
                return Level == 1 and Player.y <= Boundary.y + Boundary.height / 2 and not Dialogue.playing.running
            end
        },
        {
            text = "I guess I did have to go through that again! And it was more difficult this time...",
            when = function ()
                return Level == Descending.onLevels[2] + 1
            end
        },
        {
            text = "That's cold!",
            when = function ()
                return not Dialogue.playing.running and Weather.currentType == "rainy"
            end
        },
        {
            text = "Looks like checkpoints don't work in the rain...",
            when = function ()
                return false
            end
        },
        {
            text = "Weather conditions exist here, huh! Intel will be intrigued.",
            when = function ()
                return Weather.currentType ~= "clear"
            end,
            finishFunc = function ()
                IntelCallIn("it is quite intriguing!")
            end
        },
    },
    eventual = {
        killEnemy = {
            "Nice.",
            "Take that.",
            "Eat it.",
            "Ha-ha!",
            "Idiot.",
            "Oh yeah.",
            "How cute.",
            "Beat that.",
            "Goof.",
            "Hole in one.",
            "Who's the man?",
            "No mercy.",
            "What's it to ya?",
            "I'm just cool like that.",
            "Touchdown!",
            "Like taking candy from a baby."
        },
    },
}

-- load the voicelines for each dialogue thing
for index, line in ipairs(Dialogue.list) do
    if love.filesystem.getInfo("assets/voicelines/" .. index .. ".mp3") then
        line.voice = love.audio.newSource("assets/voicelines/" .. index .. ".mp3", "static")
    end
end



function UpdateDialogue()
    for index, dialogue in ipairs(Dialogue.list) do
        if dialogue.when() and not dialogue.done then
            PlayDialogue(index)
            dialogue.done = true
        end
    end

    if Dialogue.playing.running then
        if Dialogue.playing.finished then
            Dialogue.playing.text = string.sub(Dialogue.playing.text, 1, #Dialogue.playing.text - 1)
            if #Dialogue.playing.text == 0 then
                Dialogue.playing.running = false
            end
        elseif Dialogue.playing.charIndex > #Dialogue.playing.targetText then
            PlayerCanMove = true
            if Dialogue.playing.finishFunc and not Dialogue.playing.playedFinishFunc then Dialogue.playing.finishFunc(); Dialogue.playing.playedFinishFunc = true end
            Dialogue.playing.postWait.current = Dialogue.playing.postWait.current + 1 * GlobalDT
            if Dialogue.playing.postWait.current >= Dialogue.playing.postWait.max then
                Dialogue.playing.finished = true
            end
        else
            Dialogue.playing.charInterval.current = Dialogue.playing.charInterval.current + 1 * GlobalDT
            if Dialogue.playing.charInterval.current >= Dialogue.playing.charInterval.max then
                local charToAdd = string.sub(Dialogue.playing.targetText, Dialogue.playing.charIndex, Dialogue.playing.charIndex)
                Dialogue.playing.charInterval.current = Dialogue.playing.charInterval.current - Dialogue.playing.charInterval.max
                Dialogue.playing.text = Dialogue.playing.text .. charToAdd

                local specialChar = false
                for _, char in ipairs(Dialogue.playing.charInterval.maxOn) do
                    if char.char == charToAdd then
                        Dialogue.playing.charInterval.max = char.max
                        specialChar = true
                    end
                end
                if not specialChar then Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax end

                Dialogue.playing.charIndex = Dialogue.playing.charIndex + 1

                PlaySFX(SFX.dialogue, 0.6, math.random()/2+.7)
            end
        end
    end
end
function PlayDialogue(index, event)
    Dialogue.playing.text = ""
    Dialogue.playing.charInterval.current = 0
    Dialogue.playing.charIndex = 1
    Dialogue.playing.charInterval.max = Dialogue.playing.charInterval.defaultMax
    Dialogue.playing.running = true
    Dialogue.playing.targetText = (event ~= nil and Dialogue.eventual[event][index] or Dialogue.list[index].text)
    Dialogue.playing.finished = false
    Dialogue.playing.postWait.current = 0
    Dialogue.playing.playedFinishFunc = false
    if not event then Dialogue.playing.finishFunc = Dialogue.list[index].finishFunc end

    if Dialogue.list[index].voice then
        Dialogue.list[index].voice:setEffect("player voice")
        PlaySFX(Dialogue.list[index].voice, .6, 1)
    end
end
function DrawDialogue()
    if not Dialogue.playing.running then return end
    DrawTextWithBackground(Dialogue.playing.text, Player.centerX, Player.y - 100, Fonts.dialogue, {0,1,1}, {0,0,0})
end
function TriggerDialogue(index)
    if index > #Dialogue.list then error("looks like you're tryna trigger dialogue that doesn't exist fool") end
    if Dialogue.list[index].done then return end

    Dialogue.list[index].done = true
    PlayDialogue(index)
end

function IntelCallIn(text)
    NewMessage(string.upper(text), 0, 50, {0,1,0}, 230, Fonts.medium, nil, true)
    PlaySFX(SFX.intel, 0.3, 1.4)
end