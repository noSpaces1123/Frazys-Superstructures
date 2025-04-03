function love.load()
    lume = require "lume"
    require "player"
    require "particle"
    require "data_management"
    require "button"
    require "enemy"
    require "bub"

    love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {highdpi=true, vsync=true})
    love.window.setTitle("Adam's Superstructures")
    love.window.setFullscreen(true)

    love.filesystem.setIdentity("Adam's Superstructures")

    SFX = {
        hit = love.audio.newSource("assets/sfx/hit.wav", "static"),
        jump = love.audio.newSource("assets/sfx/jump.wav", "static"),
        blip = love.audio.newSource("assets/sfx/blip.wav", "static"),
        nextLevel = love.audio.newSource("assets/sfx/nextlevel.wav", "static"),
        smash = love.audio.newSource("assets/sfx/smash.wav", "static"),
        clang = love.audio.newSource("assets/sfx/clang.wav", "static"),
        death = love.audio.newSource("assets/sfx/death.wav", "static"),
        shoot = love.audio.newSource("assets/sfx/shoot.wav", "static"),
        checkpoint = love.audio.newSource("assets/sfx/checkpoint.wav", "static"),
        playerSpawn = love.audio.newSource("assets/sfx/playerSpawn.wav", "static"),
        shrine = love.audio.newSource("assets/sfx/shrine.wav", "static"),
        drag = love.audio.newSource("assets/sfx/drag.wav", "static"),
        toggleMinimap = love.audio.newSource("assets/sfx/toggle minimap.wav", "static"),
        dialogue = love.audio.newSource("assets/sfx/dialogue.wav", "static"),
        hooligmanDialogue = love.audio.newSource("assets/sfx/hooligman dialogue.wav", "static"),
        hover = love.audio.newSource("assets/sfx/hover.wav", "static"),
        click = love.audio.newSource("assets/sfx/click.wav", "static"),
        seesPlayer = love.audio.newSource("assets/sfx/sees player.wav", "static"),
        enemySeesPlayer = love.audio.newSource("assets/sfx/enemy sees player.wav", "static"),
        cool = love.audio.newSource("assets/sfx/cool.wav", "static"),
        complete = love.audio.newSource("assets/sfx/complete.wav", "static"),
        resetRun = love.audio.newSource("assets/sfx/reset run.wav", "static"),
        zoom = love.audio.newSource("assets/sfx/zoom.wav", "static"),
        descended = love.audio.newSource("assets/sfx/descended.wav", "static"),
        stick = love.audio.newSource("assets/sfx/stick.wav", "static"),
        unstick = love.audio.newSource("assets/sfx/unstick.wav", "static"),
        upgrade = love.audio.newSource("assets/sfx/upgrade.wav", "static"),
        upgradeMenu = love.audio.newSource("assets/sfx/upgrade menu.wav", "static"),
        warble = {
            love.audio.newSource("assets/sfx/warble.wav", "static"),
            love.audio.newSource("assets/sfx/warble2.wav", "static"),
        },
        enemySpeak = {},
    }

    for i = 1, 13 do
        table.insert(SFX.enemySpeak, love.audio.newSource("assets/sfx/enemy speak" .. i .. ".wav", "static"))
    end

    Sprites = {
        cross = love.graphics.newImage("assets/sprites/cross.png", {dpiscale=10}),
        controls = love.graphics.newImage("assets/sprites/controls.png", {dpiscale=8}),
        fullControls = love.graphics.newImage("assets/sprites/full controls.png", {dpiscale=7}),
        posters = {}
    }
    for index, fileName in ipairs(love.filesystem.getDirectoryItems("assets/sprites/posters")) do
        if index == 1 then goto next end
        table.insert(Sprites.posters, love.graphics.newImage("assets/sprites/posters/" .. fileName, {dpiscale=8}))
        ::next::
    end

    Fonts = {
        normal = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 17),
        dialogue = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 27),
        medium = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 23),
        big = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 29),
        time = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 300),
        smallTime = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 150),
        title = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 100),
        levelNumber = love.graphics.newFont("assets/fonts/Geo/Geo-Regular.ttf", 70),
    }

    BG = {}

    Music = love.audio.newSource("assets/music/Numbers.wav", "stream")
    Music:setLooping(true)
    Music:setVolume(0.1)

    Settings = {
        musicOn = true,
        graphics = { current = 3, max = 3 },
    }

    Gravity = 0.6

    Level = 1

    Boundary = { x = -40000, y = 0, width = 80000, height = nil, baseHeight = 4000, heightIncrement = 6000 }
    Boundary.height = Boundary.baseHeight

    Turrets = {}
    Checkpoints = {}
    Shrines = {}

    ObjectGlobalData = {
        cornerRadius = 3,
        strokeWidth = 4,
        objectsToGenerate = 0, objectDensity = 0.0000022, turretDensity = 0, baseTurretDensity = 0.00000003, checkpointDensity = 0.000000016, shrineDensity = 0.0000000005,
        groundZeroNotchSpacing = 100, groundZeroNotchLength = 20,
        dangerPulseProgression = { current = 0, max = 500 },
        jumpPlatformStrength = 40,
    }
    ObjectGlobalData.objectsToGenerate = ObjectGlobalData.objectDensity * Boundary.width * Boundary.height
    ObjectGlobalData.turretDensity = ObjectGlobalData.baseTurretDensity

    TurretGlobalData = {
        height = 50,
        bulletRadius = 5,
        bulletSpeed = 7,
        fireInterval = { min = 36, max = 100 },
        viewRadius = { min = 800, max = 1300 },
        inaccuracy = { min = 0, max = 10 },
        warble = { min = 1000, max = 4000 },
        dragTurretCoolInterval = 600,
        headRadius = 20,
        readingsDistance = 25,
        threatWidth = 120, threatHeight = 120, threatUpdateInterval = { current = 0, max = 10 },
    }

    EnemyGlobalData = {
        enemyDensity = 0, baseEnemyDensity = 0.00000001,
        width = { min = 15, max = 30 },
        speed = { min = 3, max = 8, divide = 10 },
        viewRadius = { min = 800, max = 1000 },
        bounceReverberation = 0.4,
        airFriction = 0.05,
        minSpeedAgainstWallToDie = 32,
        warble = { min = 1000, max = 4000 },
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

    CheckpointGlobalData = {
        radius = 50,
        clearRadius = 2000,
    }

    ShrineGlobalData = {
        width = 100,
        spin = 0,
        maxHintDistance = 15000,
        types = {
            ["Spirit of the Frozen Trekker"] = {
                color = {0,1,1}, explanation = "This shrine keeps you from slipping around on ice.",
                func = function () end
            },
            ["Will of the Frogman"] = {
                color = {0,1,0}, explanation = "This shrine gives you a bigger super jump bar.",
                func = function () end
            },
            ["Blood of the Man in White"] = {
                color = {0,1,1}, explanation = "This shrine makes you passively cool faster.",
                func = function () end
            },
            ["Scale of the Rampant Mouse"] = {
                color = {1,0,0}, explanation = "This shrine makes you smaller.",
                func = function () end
            },
            ["Eye of the Crimson Eagle"] = {
                color = {.8,0,0}, explanation = "This shrine increases your range of sight.",
                func = function () end
            },
            ["Instinct of the Bullet Jumper"] = {
                color = {1,0,1}, explanation = "This shrine has bullets close to you slow down.",
                func = function () end
            },
            ["Power of the Achiever"] = {
                color = {1,1,0}, explanation = "This shrine lets you double-jump. Fun!",
                func = function () end
            },
            ["Wings of the Guardian Angel"] = {
                color = {1,1,1}, explanation = "This shrine lets you glide in the air by holding [SPACE].",
                func = function () end
            },
            ["Essence of the Grasshopper"] = {
                color = {0,1,0}, explanation = "This shrine lets you jump much higher.",
                func = function () end
            },
        },
    }

    BubGlobalData = {
        noticeDistance = ToPixels(4),
        dialogueSpacingFromBub = 60,
        edgeRounding = 2,
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
                        "Move left to hit, right to stay.",
                    },
                    hit = {
                        "I like your style, bub.",
                        "Interesting choice.",
                        "I'm on your side, my friend.",
                        "Let's hope this goes well.",
                    },
                    stay = {
                        "Playing it safe, hmm?",
                        "You do you.",
                        "Interesting choice.",
                        "I admire your caution.",
                    },
                    outcomes = {
                        ["player higher total"] = {
                            "You got the higher total! Nice job, bub!",
                            "You got the higher total! Well played, bub!",
                            "You got the higher total! Well done!"
                        },
                        ["player bust"] = {
                            "You bust! I was rootin' for you...",
                            "You bust! Better luck next time, bub.",
                            "You bust! But you had the right idea, ha-ha.",
                        },
                        ["player spot-on"] = {
                            "You got 21 exactly! You oughta shoot the moon.",
                            "You got 21 exactly! Lucky bastard!",
                            "You got 21 exactly! Didn't think you were so good, bub!",
                        },

                        ["dealer higher total"] = {
                            "I got the higher total! Good game.",
                            "I got the higher total! I had fun.",
                            "I got the higher total, ha-ha!"
                        },
                        ["dealer bust"] = {
                            "I bust! Well done!",
                            "I bust! Nicely done!",
                            "I bust! Good play.",
                        },
                        ["dealer spot-on"] = {
                            "I got 21 exactly! That's it for you, buddy.",
                            "I got 21 exactly! I'm legit, I swear!",
                            "I got 21 exactly! Good game.",
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
                event = function (self, bub, bubIndex)
                    if self.wait.current <= 0 then
                        if bub.phase == nil and Player.jumped then
                            Player.blackjackCards, Blackjack.dealerCards = {}, {}
                            BubSays(lume.randomchoice(self.voiceLines.hitOrStay), bubIndex)
                            BlackjackDeal(2, "player"); BlackjackDeal(2, "dealer")
                            bub.phase = "waiting"
                        elseif bub.phase == "waiting" and Player.netSpeed ~= 0 then
                            local outcome
                            local threshold = 3
                            if Player.xvelocity > threshold then
                                BubSays(lume.randomchoice(self.voiceLines.stay), bubIndex) -- stay
                                outcome = CheckBlackjackWinner()
                            elseif Player.xvelocity < -threshold then
                                BubSays(lume.randomchoice(self.voiceLines.hit), bubIndex) -- hit
                                outcome = BlackjackDeal(1, "player")
                                self.wait.current = self.wait.max
                            end

                            if outcome ~= nil then
                                BubSays(lume.randomchoice(self.voiceLines.outcomes[outcome]), bubIndex) -- win or lose
                                self.wait.current = self.wait.max
                                bub.phase = "play again"
                            end
                        elseif bub.phase == "play again" and Player.netSpeed ~= 0 then
                            BubSays(lume.randomchoice(self.voiceLines.playAgain), bubIndex)
                            bub.phase = "request"
                        elseif bub.phase == "request" and Player.jumped then
                            bub.phase = nil
                        end
                    else
                        self.wait.current = self.wait.current - 1 * GlobalDT
                    end
                end
            }
        }
    }

    PosterGlobalData = {
        spacingFromEdgesOfObject = 20,
        density = 0.03, -- posters to generate = density x number of objects
    }

    TurretGenerationPalette = { normal = 20, laser = 4, drag = 2 }
    ShrineGenerationPalette = {
        ["Spirit of the Frozen Trekker"] = 10,
        ["Will of the Frogman"] = 5,
        ["Blood of the Man in White"] = 5,
        ["Scale of the Rampant Mouse"] = 1,
        ["Eye of the Crimson Eagle"] = 6,
        ["Instinct of the Bullet Jumper"] = 1,
        ["Power of the Achiever"] = 1,
        ["Wings of the Guardian Angel"] = 2,
        ["Essence of the Grasshopper"] = 3,
    }

    ObjectGenerationPaletteAsNoiseConstraints = {
        { type = "normal", weight = 20 },
        { type = "icy", weight = 9 },
        { type = "death", weight = 4 },
        { type = "jump", weight = 6 },
        { type = "sticky", weight = 3 },
    }
    local total = 0
    local totalThusFar = 0
    for _, value in ipairs(ObjectGenerationPaletteAsNoiseConstraints) do total = total + value.weight end
    for _, value in ipairs(ObjectGenerationPaletteAsNoiseConstraints) do
        local new = 1 / total * value.weight
        value.max = new + totalThusFar
        totalThusFar = totalThusFar + new
    end

    ObjectTypeData = {
        normal = {
            width = { min = 400, max = 1100 },
            height = { min = 100, max = 300 }
        },
        icy = {
            width = { min = 500, max = 1200 },
            height = { min = 100, max = 300 }
        },
        death = {
            width = { min = 400, max = 1100 },
            height = { min = 100, max = 300 }
        },
        jump = {
            width = { min = 400, max = 900 },
            height = { min = 70, max = 200 }
        },
        sticky = {
            width = { min = 100, max = 250 },
            height = { min = 200, max = 400 }
        },
    }

    Blackjack = {
        cards = {},
        bust = 21,
        dealerCards = {},
        playerPlaying = false,
    }
    ResetBlackjackDeck()

    Messages = {}

    TimeOnThisLevel = 0
    TotalTime = 0
    BestGameCompletionTime = nil

    FinalLevel = 50

    Descending = {
        onLevels = PickDescensionLevels(),
        doingSo = false,
        music = love.audio.newSource("assets/music/Complex Numbers.wav", "stream"),
        hooligmanCutscene = {
            running = false,
            text = {
                "Hey! I'm the HOOLIGMAN! I'm displeased with your scrawny endeavors. The only way to escape is to reach the bottom of the level, but will you live to see it? No. Hooligans, GO!",
                "I'm back! And you're still alive. Time to die. Hooligans, DON'T FAIL ME THIS TIME!",
                "You and your scrawny endeavors have messed with my superstructures enough. TAKE YOUR LAST BREATH.",
            },
            intro = { current = 0, max = 100 },
            startedDialogue = false,
            dialogue = {
                text = "", targetText = nil,
                charInterval = { current = 0, max = 3, defaultMax = 3,
                    maxOn = { { char = ".", max = 50 }, { char = ",", max = 20 }, { char = "!", max = 20 }, { char = "?", max = 50 }, { char = "-", max = 40 } } },
                charIndex = 1,
                finished = false, displayedAll = false,
                postWait = { current = 0, max = 200 },
                running = false,
            },
            hooligman = {
                width = 1000,
            },
        },
        enemyDensity = {
            0.0000015,
            0.000002,
            0.0000025,
        },
    }
    Descending.music:setLooping(true)
    Descending.music:setVolume(0.5)

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
                    for _, turret in ipairs(Turrets) do
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
                text = "Ouch! That's hot. I'll be in big trouble if my temperature meter reaches 100%... Maybe I can cool down on those ice platforms?",
                when = function ()
                    return Player.temperature.current > 0
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
                    for _, turret in ipairs(Turrets) do
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
                    for _, turret in ipairs(Turrets) do
                        if turret.seesPlayer and turret.type == "normal" then
                            yes = true
                        end
                    end
                    return Level >= 2 and yes and Dialogue.list[3].done
                end
            },
            {
                text = "Those yellow turrets pull me in, but don't do any damage.",
                when = function ()
                    local yes = false
                    for _, turret in ipairs(Turrets) do
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
                text = "Intel said I've got a special ability I can use with [Q], as long as I have enough charge in the top left bar. A fixed amount is removed from the bar with every use.",
                when = function ()
                    return Level == 5
                end
            },
            {
                text = "Intel also said I can use [M] to open up a view of the map.",
                when = function ()
                    return Level == 6
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
                text = "These levels don't seem to be too complex, but I have a feeling more and more turrets are piling up...",
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
                    if condition then SpawnShrines() end
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
                text = "I think I can kill those red hooligans by hitting them with more speed than when they hit me.",
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
            },
        },
    }

    PlayerCanMove = false

    DeathPositions = {}

    Enemies = {}

    Bubs = {}

    Buttons = {}
    InitialiseButtons()

    InitialiseUpgrades()

    if love.filesystem.getInfo("data.csv") then
        LoadData()
    else
        LoadPlayer()
        ResetPlayerData()
    end

    if Settings.musicOn then Music:play() end

    NewBub(Player.x, Player.y-10, "Jack")

    MessageWithPlayerStats()

    Seed = os.time() + Level

    GenerateBG()

    if not love.filesystem.getInfo("data.csv") then
        GenerateObjects()
    end

    Particles = {}
    Bullets = {}

    SaveInterval = { current = 0, max = 600 }

    CamLookAhead = {
        xOff = 0,
        yOff = 0,
        easing = {
            origin = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }, dest = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 },
            current = 0, max = 20, running = false,
        },
        wasLooking = false,
    }

    ShakeIntensity = 0

    NextLevelAnimation = { current = 0, max = 100, running = false, done = false }

    Minimap = {
        showing = false,
        x = 0, y = 0,
        speed = 80,
        playerSine = 0,
        zoom = 0.1,
        wasPaused = false,
    }

    GameCompleteFlash = 0

    Paused = false

    KeyBuffer = {}

    MenuAnimation = { x = 0, overlay = 0, objectIntro = 0 }

    CommandLine = {
        typing = false,
        text = "",
        history = {},
    }

    GameState = "menu"

    ClickedWithMouse = false

    Version = "1.3.1"
    Changelog = Version ..
[[
 Changelog:

    Upgrades:
    - Change: Checkpoint display and level height display bundled together into level 1 of analytics
]]

    Debug = false

    TimeMultiplier = 1
    SlowMo = { current = 0, max = 20, slowingDown = false, running = false }

    GlobalUnaffectedDT = 0
    GlobalDT = 0
    ::continue::
end

function love.update(dt)
    GlobalUnaffectedDT = dt * 60
    GlobalDT = GlobalUnaffectedDT * TimeMultiplier

    if not CommandLine.typing then
        UpdateSlowMo()

        if not UpgradeData.picking then
            if GameState == "game" then
                UpdatePlayer()
                UpdateShakeIntensity()
                --UpdateDangerPulseProgression()
                UpdateCamLookAhead()
                ExtendView()

                UpdateNextLevelAnimation()

                if not Paused then
                    TimeOnThisLevel = TimeOnThisLevel + dt

                    if not Descending.hooligmanCutscene.running then
                        UpdateParticles()
                        UpdateTurrets()
                        UpdateBullets()
                        UpdateShrines()
                        UpdateMessages()
                        UpdateEnemies()
                        UpdateBubs()
                        UpdateDialogue()
                        UpdateBubDialogue()
                        DiscoverAndRenderDiscoverables()
                    end

                    UpdateHooligmanCutscene()
                    UpdateHooligmanDialogue()
                end

                --CheckForOddities()

                UpdateSaveInterval()
            else
                UpdateTurrets()
            end
        end

        UpdateButtons()

        if GameCompleteFlash > 0 then
            GameCompleteFlash = GameCompleteFlash - 0.005 * GlobalDT
            if GameCompleteFlash < 0 then
                GameCompleteFlash = 0
            end
        end

        if Settings.graphics.current == 1 then
            Particles = {}
        end
    end

    Player.centerX, Player.centerY = Player.x + Player.width / 2, Player.y + Player.height / 2

    SaveFrames()
end

function love.draw()
    if GameState == "game" then
        if Minimap.showing then
            DrawMinimap()
        else
            love.graphics.push()

            -- zoom stuff
            InitialiseRegularCoordinateAlterations()

            ApplyNextLevelAnimation()
            ApplyCamLookAhead()

            ApplyShake()

            DrawBG()
            DrawParticles()
            DrawObjects()
            DrawDeathPositions()
            DrawEnemies()
            DrawLevelGoal()

            DrawWayPoints()
            DrawWayPointArrow()

            DrawShines()
            DrawCheckpoints()
            DrawTurrets()
            DrawBullets()

            DrawPlayerAlignmentAxes()

            love.graphics.setColor(1,1,1)
            if Level == 1 and PlayerCanMove then
                love.graphics.draw(Sprites.controls, -Sprites.controls:getWidth() / 2, Boundary.y + Boundary.height - 300)
            elseif Level == 5 then
                love.graphics.draw(Sprites.fullControls, -Sprites.fullControls:getWidth() / 2, Boundary.y + Boundary.height - 300)
            end

            DisplayTurretInfo()

            DrawPlayer()

            DrawMessages()

            DrawHooligman()
            DrawHooligmanDialogue()

            DrawBubs()
            DrawBubDialogue()

            if Blackjack.playerPlaying then
                DisplayBlackjackHand("player")
                DisplayBlackjackHand("dealer")
            end

            DrawCursorReadings()
            DrawDialogue()

            love.graphics.pop()

            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 60)

            DrawDisplays()
            DrawPlayerSuperJumpBar()

            DrawHeatIndicator()

            DrawDebug()

            if UpgradeData.picking then
                DrawUpgradeMenuOverlay()
            else
                DrawPausedOverlay()
            end

            DrawCommandLineOverlay()
        end
    elseif GameState == "menu" or GameState == "complete" or GameState == "settings" or GameState == "changelog" then
        love.graphics.push()

        local zoom = 0.2
        MenuAnimation.x = MenuAnimation.x + .01 * GlobalDT ; if MenuAnimation.x >= 360 then MenuAnimation.x = 0 end

        love.graphics.scale(zoom)
        love.graphics.translate(
            love.graphics.getWidth() / zoom / 2 + math.sin(math.rad(MenuAnimation.x)) * Boundary.width / 4,
            love.graphics.getHeight() / zoom / 2 - Boundary.y - Boundary.height / 2
        )

        if MenuAnimation.objectIntro < 1 then
            MenuAnimation.objectIntro = MenuAnimation.objectIntro + .003 * GlobalDT
            if MenuAnimation.objectIntro > 1 then MenuAnimation.objectIntro = 1 end
        end

        DrawObjects()
        DrawTurrets()
        DrawEnemies()
        DrawLevelGoal()

        love.graphics.pop()

        -- overlay
        love.graphics.setColor(0,0,0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        if GameState == "menu" then
            if BestGameCompletionTime ~= nil then
                DrawTextWithBackground("Best time: " .. TimeInSecondsToStupidFuckingHumanFormat(BestGameCompletionTime), love.graphics.getWidth() / 2, 80, Fonts.medium, {0,1,0}, {0,0,0})
            end

            love.graphics.setColor(1,1,1)
            love.graphics.setFont(Fonts.title)
            love.graphics.printf("Adam's Superstructures", 0, 200, love.graphics.getWidth(), "center")
        elseif GameState == "complete" then
            DrawTextWithBackground("Intel got what they needed. Nice job!\n" .. TimeInSecondsToStupidFuckingHumanFormat(TotalTime), love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, Fonts.big, Player.color, {0,0,0})
            DrawTextWithBackground("Hit [ESC] to return to the main menu.", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 300, Fonts.medium, {1,1,1}, {0,0,0})
        elseif GameState == "changelog" then
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(Fonts.medium)
            love.graphics.print(Changelog, 10, 10)
        end
    end

    DrawButtons()

    if MenuAnimation.overlay < 1 then
        MenuAnimation.overlay = MenuAnimation.overlay + .003 * GlobalDT
        if MenuAnimation.overlay > 1 then MenuAnimation.overlay = 1 end
    end
    love.graphics.setColor(0,0,0, 1 - MenuAnimation.overlay)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(Player.color[1],Player.color[2],Player.color[3], GameCompleteFlash)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function ApplyGravity(object)
    return object.yvelocity + Gravity * GlobalDT
end

function PlaySFX(sfx, vol, pitch)
    sfx:stop()

    sfx:setVolume(vol)
    sfx:setPitch(pitch)

    sfx:play()
end

function Clamp(x, min, max)
    if x < min then x = min
    elseif x > max then x = max
    end
    return x
end

function UpdateShakeIntensity()
    if ShakeIntensity > 0 then
        ShakeIntensity = ShakeIntensity - 1 * GlobalDT
        if ShakeIntensity <= 0 then
            ShakeIntensity = 0
        end
    end
end

function ApplyShake()
    love.graphics.translate(math.random()*ShakeIntensity-ShakeIntensity/2,math.random()*ShakeIntensity-ShakeIntensity/2)
end

function DrawObjects()
    for _, obj in ipairs(Objects) do
        if not obj.render and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end

        love.graphics.setColor(.7,.7,.7, 1)
        love.graphics.setLineWidth(ObjectGlobalData.strokeWidth)
        love.graphics.rectangle("line", obj.x, obj.y, obj.width, obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

        ::continue::
    end
    for _, obj in ipairs(Objects) do
        local outsideRenderDistance = not obj.render
        if not obj.discovered and GameState == "game" then goto continue end
        if outsideRenderDistance and not obj.discovered and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end
        if (GameState == "menu" or GameState == "settings") and obj.y <= Lerp(Boundary.y, Boundary.y + Boundary.height, 1 - MenuAnimation.objectIntro) then goto continue end

        if outsideRenderDistance and Minimap.showing and not obj.discovered then
            love.graphics.setColor(0,0,0,1)
        elseif obj.type == "icy" then
            love.graphics.setColor(.3,1,1,1)
        elseif obj.type == "death" then
            love.graphics.setColor(1,.5,0,1)
        elseif obj.type == "jump" then
            love.graphics.setColor(0,1,0,1)
        elseif obj.type == "sticky" then
            love.graphics.setColor(.8,0,1,1)
        else
            love.graphics.setColor(1,1,1, 1)
        end
        love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

        if obj.dangerPulse then
            local uwu = ObjectGlobalData.dangerPulseProgression.current / ObjectGlobalData.dangerPulseProgression.max -- ratio haha
            local alpha = uwu
            love.graphics.setColor(1, 0, 0, alpha)
            love.graphics.rectangle("fill", obj.x, obj.y + (1 - uwu) * obj.height, obj.width, uwu * obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", obj.x, obj.y, obj.width, obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)
        end

        if obj.groundZero then
            love.graphics.setColor(.7,.7,.7,1)
            love.graphics.setLineWidth(2)
            for x = obj.x, obj.width + obj.x, ObjectGlobalData.groundZeroNotchSpacing do
                love.graphics.line(x, obj.y, x, obj.y + ObjectGlobalData.groundZeroNotchLength)
            end
        end

        ::continue::
    end

    for _, obj in ipairs(Objects) do
        local outsideRenderDistance = not obj.render
        if not obj.discovered and GameState == "game" then goto continue end
        if outsideRenderDistance and not obj.discovered and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end
        if (GameState == "menu" or GameState == "settings") and obj.y <= Lerp(Boundary.y, Boundary.y + Boundary.height, 1 - MenuAnimation.objectIntro) then goto continue end

        if obj.poster ~= nil then
            if Sprites.posters[obj.poster.type] == nil then
                obj.poster = nil
            else
                love.graphics.setColor(1,1,1)
                love.graphics.draw(Sprites.posters[obj.poster.type], obj.x + obj.poster.x, obj.y + PosterGlobalData.spacingFromEdgesOfObject)
            end
        end

        ::continue::
    end
end
function GenerateObjects()
    DeathPositions = {}

    local boundaryObjWidth = 1500
    local playerSafeArea = 600
    Objects = {
        {
            x = Boundary.x, y = Boundary.y + Boundary.height,
            width = Boundary.width, height = boundaryObjWidth,
            groundZero = true, impenetrable = true,
        },
        {
            x = Boundary.x - boundaryObjWidth, y = Boundary.y,
            width = boundaryObjWidth, height = Boundary.height + boundaryObjWidth,
            impenetrable = true,
        },
        {
            x = Boundary.x + Boundary.width, y = Boundary.y,
            width = boundaryObjWidth, height = Boundary.height + boundaryObjWidth,
            impenetrable = true,
        },
    }
    Turrets = {}
    Shrines = {}

    math.randomseed(Seed)
    for _ = 1, ObjectGlobalData.objectDensity * Boundary.width * Boundary.height do
        local x, y = math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height)

        local objectType = GetObjectTypeFromPerlinNoise(x, y)

        local width, height = math.random(ObjectTypeData[objectType].width.min, ObjectTypeData[objectType].width.max), math.random(ObjectTypeData[objectType].height.min, ObjectTypeData[objectType].height.max)
        if math.random() < .05 then
            local movingWidth = width
            width = height
            height = movingWidth
        end

        table.insert(Objects, {
            x = x, y = y,
            width = width, height = height, type = objectType
        })
    end

    -- posters
    for _ = 1, #Objects * PosterGlobalData.density do
        local index = math.random(#Objects)
        Objects[index].poster = {}
        Objects[index].poster.type = math.random(#Sprites.posters)
        Objects[index].poster.x = lume.randomchoice({PosterGlobalData.spacingFromEdgesOfObject, Objects[index].width - PosterGlobalData.spacingFromEdgesOfObject - Sprites.posters[Objects[index].poster.type]:getWidth()})
    end

    -- safe area
    local thoseToRemove = {}
    for index, obj in ipairs(Objects) do
        if Touching(obj.x, obj.y, obj.width, obj.height, -playerSafeArea, Boundary.y + Boundary.height - playerSafeArea, playerSafeArea * 2, playerSafeArea * 2) and
        not obj.impenetrable then
            table.insert(thoseToRemove, index)
        end
    end
    for loops, index in ipairs(thoseToRemove) do
        table.remove(Objects, index - (loops - 1))
    end

    SpawnTurrets(playerSafeArea)
    SpawnCheckpoints()
    if Dialogue.list[25].done or true then SpawnShrines() end
    SpawnEnemies()
    GenerateBG()
end
function GetObjectTypeFromPerlinNoise(x, y)
    local totalObjectTypes = 0; for _, _ in pairs(ObjectTypeData) do totalObjectTypes = totalObjectTypes + 1 end
    local xyDivisor = 13000
    local noiseValue = Clamp(love.math.noise(x / xyDivisor, y / xyDivisor) + Jitter(0.1), 0, 1)

    for index, value in ipairs(ObjectGenerationPaletteAsNoiseConstraints) do
        local lastobj = ObjectGenerationPaletteAsNoiseConstraints[index-1]
        local lastMax = (lastobj and lastobj.max or 0)
        if noiseValue >= lastMax and noiseValue <= value.max then
            return value.type
        end
    end
end
function DiscoverAndRenderDiscoverables()
    for _, obj in ipairs(Objects) do
        love.graphics.push()
        InitialiseRegularCoordinateAlterations()
        local objX, objY = love.graphics.transformPoint(obj.x, obj.y)
        love.graphics.pop()

        love.graphics.push()
        if love.keyboard.isDown("lshift") then ApplyCamLookAhead() end
        local screenX, screenY = love.graphics.inverseTransformPoint(0, 0)
        love.graphics.pop()

        if Touching(objX, objY, obj.width, obj.height, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
            obj.discovered = true
            obj.render = true
        else
            obj.render = false
        end
    end

    for _, turret in ipairs(Turrets) do
        love.graphics.push()
        InitialiseRegularCoordinateAlterations()
        local turretX, turretY = love.graphics.transformPoint(turret.x - TurretGlobalData.headRadius, turret.y - TurretGlobalData.headRadius)
        love.graphics.pop()

        love.graphics.push()
        if love.keyboard.isDown("lshift") then ApplyCamLookAhead() end
        local screenX, screenY = love.graphics.inverseTransformPoint(0, 0)
        love.graphics.pop()

        if Touching(turretX, turretY, TurretGlobalData.headRadius*2, TurretGlobalData.headRadius*2, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
            turret.discovered = true
        end
    end

    for _, enemy in ipairs(Enemies) do
        love.graphics.push()
        InitialiseRegularCoordinateAlterations()
        local turretX, turretY = love.graphics.transformPoint(enemy.x, enemy.y)
        love.graphics.pop()

        love.graphics.push()
        if love.keyboard.isDown("lshift") then ApplyCamLookAhead() end
        local screenX, screenY = love.graphics.inverseTransformPoint(0, 0)
        love.graphics.pop()

        if Touching(turretX, turretY, enemy.width, enemy.width, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
            enemy.discovered = true
        end
    end
end

function UpdateDangerPulseProgression()
    ObjectGlobalData.dangerPulseProgression.current = ObjectGlobalData.dangerPulseProgression.current + 1 * GlobalDT
    if ObjectGlobalData.dangerPulseProgression.current >= ObjectGlobalData.dangerPulseProgression.max then
        ObjectGlobalData.dangerPulseProgression.current = 0

        for _, obj in ipairs(Objects) do
            if obj.dangerPulse then
                -- some particles >~< uwu
                for _ = 1, 40 do
                    local alongSides = lume.randomchoice({true,false})

                    local x, y
                    if alongSides then
                        x, y = math.random(obj.x, obj.x + obj.width), lume.randomchoice({ obj.y, obj.y + obj.height })
                    else
                        x, y = lume.randomchoice({ obj.x, obj.x + obj.width }), math.random(obj.y, obj.y + obj.height)
                    end

                    local radius = math.random() * 4 + 7
                    local degrees = math.random(360)

                    table.insert(Particles, NewParticle(x, y, radius, {1,0,0}, 2, degrees, 0.03, 100,
                    function (self)
                        if self.speed > 0 then
                            self.speed = self.speed - 0.01 * GlobalDT
                            if self.speed <= 0 then
                                self.speed = 0
                            end
                        end
                    end))
                end
            end
        end
    end
end

function Touching(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 + w1 >= x2 and y1 + h1 >= y2 and x1 <= x2 + w2 and y1 <= y2 + h2
end

function CheckIfPlayerHasCompletedLevel()
    if ((Descending.doingSo and Player.y >= Boundary.y + Boundary.height) or (not Descending.doingSo and Player.y <= 0)) then
        NextLevel()
    end
end
function NextLevel()
    TotalTime = TotalTime + TimeOnThisLevel
    TimeOnThisLevel = 0

    if CheckIfShouldBeDescending() and not Descending.hooligmanCutscene.running and not Descending.doingSo then
        PlayHooligmanCutscene()
    elseif Level >= FinalLevel then
        FinalLevelReached()
    else
        Level = Level + 1
        Seed = os.time()
        PlaySFX(SFX.nextLevel, .4, 1)
        CorrectBoundaryHeight()
        CorrectEnemyDensity()
        CorrectTurretDensity()
        GenerateObjects()
        LoadPlayer()
        ApplyShrineEffects()

        NextLevelAnimation.running = true

        if Descending.doingSo then
            Descending.doingSo = false
            Descending.music:stop()
            if Settings.musicOn then Music:play() end
            PlaySFX(SFX.descended, 0.5, 1)
        end
    end
end
function CorrectBoundaryHeight()
    Boundary.height = Boundary.baseHeight + math.floor(Level / 10) * Boundary.heightIncrement
end
function CorrectTurretDensity()
    ObjectGlobalData.turretDensity = ObjectGlobalData.baseTurretDensity + (Level - 1) * 0.000000016
end
function CorrectEnemyDensity()
    EnemyGlobalData.enemyDensity = EnemyGlobalData.baseEnemyDensity + (Level - 1) * 0.00000001
end
function UpdateNextLevelAnimation()
    if not NextLevelAnimation.running then return end

    NextLevelAnimation.current = NextLevelAnimation.current + 1 * GlobalDT
    if NextLevelAnimation.current >= NextLevelAnimation.max then
        NextLevelAnimation.current = 0
        NextLevelAnimation.running = false

        -- once done with the animation:
        DoPlayerSpawnParticles()
        MessageWithPlayerStats()
        SaveData()

        OpenUpgradeMenu()
    end
end
function ApplyNextLevelAnimation()
    if not NextLevelAnimation.running then return end

    local ratio = NextLevelAnimation.current / NextLevelAnimation.max
    local yOff = Lerp(Boundary.y, Player.y, EaseInOutCubic(ratio))

    love.graphics.translate(0, -yOff)
end
function FinalLevelReached()
    GameState = "complete"
    PlaySFX(SFX.complete, 0.4, 1)
    GameCompleteFlash = 1

    if BestGameCompletionTime == nil or TotalTime > BestGameCompletionTime then
        BestGameCompletionTime = TotalTime
        SaveData()
    end
end
function CheckIfShouldBeDescending()
    for _, on in ipairs(Descending.onLevels) do
        if on == Level then return true end
    end
    return false
end

function PlayHooligmanCutscene()
    Music:pause()
    Descending.hooligmanCutscene.running = true
    Descending.hooligmanCutscene.intro.current = 0
end
function UpdateHooligmanCutscene()
    if not Descending.hooligmanCutscene.running then return end

    if Descending.hooligmanCutscene.intro.current >= Descending.hooligmanCutscene.intro.max then
        if not Descending.hooligmanCutscene.startedDialogue then
            local i
            for index, lvl in ipairs(Descending.onLevels) do
                if lvl == Level then i = index end
            end
            assert(i, "cutscene occured on invalid level")

            PlayHooligmanDialogue(Descending.hooligmanCutscene.text[i])
            Descending.hooligmanCutscene.startedDialogue = true
        end

        if Descending.hooligmanCutscene.dialogue.displayedAll then
            Descending.hooligmanCutscene.intro.current = Descending.hooligmanCutscene.intro.max - 1
            SetUpDescension()
        end
    elseif Descending.doingSo and Descending.hooligmanCutscene.intro.current > 0 then
        Descending.hooligmanCutscene.intro.current = Descending.hooligmanCutscene.intro.current - 1 * GlobalDT
        if Descending.hooligmanCutscene.intro.current <= 0 then
            Descending.hooligmanCutscene.running = false
        end
    else
        Descending.hooligmanCutscene.intro.current = Descending.hooligmanCutscene.intro.current + 1 * GlobalDT
    end
end
function SetUpDescension()
    local i
    for index, lvl in ipairs(Descending.onLevels) do
        if lvl == Level then i = index end
    end

    EnemyGlobalData.enemyDensity = Descending.enemyDensity[i]

    Descending.doingSo = true
    Turrets, Enemies = {}, {}
    Player.checkpoint.x, Player.checkpoint.y = nil, nil
    SpawnEnemies()
    SaveData()
    table.remove(Objects, 1)
    Descending.music:play()
    Player.yvelocity = 0

    local width = 800
    table.insert(Objects, 1, { x = Player.x - width / 2, y = Player.y + Player.width + 20, width = width, height = 70, type = "normal", groundZero = true })
end
function UpdateHooligmanDialogue()
    if Descending.hooligmanCutscene.dialogue.running then
        if Descending.hooligmanCutscene.dialogue.finished then
            Descending.hooligmanCutscene.dialogue.text = string.sub(Descending.hooligmanCutscene.dialogue.text, 1, #Descending.hooligmanCutscene.dialogue.text - 1)
            if #Descending.hooligmanCutscene.dialogue.text == 0 then
                Descending.hooligmanCutscene.dialogue.running = false
            end
        elseif Descending.hooligmanCutscene.dialogue.charIndex > #Descending.hooligmanCutscene.dialogue.targetText then
            Descending.hooligmanCutscene.dialogue.postWait.current = Descending.hooligmanCutscene.dialogue.postWait.current + 1 * GlobalDT
            Descending.hooligmanCutscene.dialogue.displayedAll = true
            if Descending.hooligmanCutscene.dialogue.postWait.current >= Descending.hooligmanCutscene.dialogue.postWait.max then
                Descending.hooligmanCutscene.dialogue.finished = true
            end
        else
            Descending.hooligmanCutscene.dialogue.charInterval.current = Descending.hooligmanCutscene.dialogue.charInterval.current + 1 * GlobalDT
            if Descending.hooligmanCutscene.dialogue.charInterval.current >= Descending.hooligmanCutscene.dialogue.charInterval.max then
                local charToAdd = string.sub(Descending.hooligmanCutscene.dialogue.targetText, Descending.hooligmanCutscene.dialogue.charIndex, Descending.hooligmanCutscene.dialogue.charIndex)
                Descending.hooligmanCutscene.dialogue.charInterval.current = Descending.hooligmanCutscene.dialogue.charInterval.current - Descending.hooligmanCutscene.dialogue.charInterval.max
                Descending.hooligmanCutscene.dialogue.text = Descending.hooligmanCutscene.dialogue.text .. charToAdd

                local specialChar = false
                for _, char in ipairs(Descending.hooligmanCutscene.dialogue.charInterval.maxOn) do
                    if char.char == charToAdd then
                        Descending.hooligmanCutscene.dialogue.charInterval.max = char.max
                        specialChar = true
                    end
                end
                if not specialChar then Descending.hooligmanCutscene.dialogue.charInterval.max = Descending.hooligmanCutscene.dialogue.charInterval.defaultMax end

                Descending.hooligmanCutscene.dialogue.charIndex = Descending.hooligmanCutscene.dialogue.charIndex + 1

                PlaySFX(SFX.hooligmanDialogue, 0.6, math.random()/2+.7)
            end
        end
    end
end
function PlayHooligmanDialogue(text)
    Descending.hooligmanCutscene.dialogue.text = ""
    Descending.hooligmanCutscene.dialogue.charInterval.current = 0
    Descending.hooligmanCutscene.dialogue.charIndex = 1
    Descending.hooligmanCutscene.dialogue.charInterval.max = Descending.hooligmanCutscene.dialogue.charInterval.defaultMax
    Descending.hooligmanCutscene.dialogue.running = true
    Descending.hooligmanCutscene.dialogue.targetText = text
    Descending.hooligmanCutscene.dialogue.finished = false
    Descending.hooligmanCutscene.dialogue.postWait.current = 0
end
function DrawHooligmanDialogue()
    if not Descending.hooligmanCutscene.dialogue.running then return end
    DrawTextWithBackground(Descending.hooligmanCutscene.dialogue.text, Player.centerX, Player.y + 120, Fonts.dialogue, {1,0,0}, {0,0,0})
end
function DrawHooligman()
    if not Descending.hooligmanCutscene.running then return end

    local x = Player.x - Descending.hooligmanCutscene.hooligman.width / 2
    local y = Player.y + EaseInOutCubic(ReverseLerp(0, Descending.hooligmanCutscene.intro.max, Descending.hooligmanCutscene.intro.current)) * 1000 - Descending.hooligmanCutscene.hooligman.width - 1300
    local width = Descending.hooligmanCutscene.hooligman.width

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", x, y, width, width)


    local multiply = width / 6
    local angle = AngleBetween(x + width / 2, y + width / 2, Player.centerX, Player.centerY)
    local eyeX, eyeY = x + width / 2 + math.sin(angle) * multiply + Jitter(1), y + width / 2 + math.cos(angle) * multiply + Jitter(1)
    local eyeWidth = width * 0.5

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", eyeX - eyeWidth / 2, eyeY - eyeWidth / 2, eyeWidth, eyeWidth)
end

function DrawLevelGoal()
    local flipped = Descending.doingSo or Descending.hooligmanCutscene.running
    local y = (flipped and Boundary.y + Boundary.height or Boundary.y)

    love.graphics.setColor(0,1,0)
    love.graphics.setLineWidth(2)

    local lineLength = 3

    for x = Boundary.x, (Boundary.x + Boundary.width), lineLength * 2 do
        love.graphics.line(x, y, x + lineLength, y)
    end

    local numberOfLines = 100
    love.graphics.setColor(0,1,0,0.3)
    for i = -1000, love.graphics.getWidth(), love.graphics.getWidth() / numberOfLines do
        local x, _ = love.graphics.inverseTransformPoint(i, 0)
        love.graphics.line(x, y, x + 2000, y + (flipped and 1 or -1) * 2000)
    end

    DrawTextWithBackground(TimeInSecondsToStupidFuckingHumanFormat(TimeOnThisLevel), (Minimap.showing and Minimap.x or Player.x), Boundary.y + (flipped and Boundary.height or 0) + (flipped and 1 or -1) * (Minimap.showing and 800 or 400), Fonts.time, {0,1,0}, {0,0,0,0})
    DrawTextWithBackground(TimeInSecondsToStupidFuckingHumanFormat(TotalTime + TimeOnThisLevel) .. " in total", (Minimap.showing and Minimap.x or Player.x), Boundary.y + (flipped and Boundary.height or 0) + (flipped and 1 or -1) * (Minimap.showing and 1200 or 800), Fonts.smallTime, {0,1,0}, {0,0,0,0})
end
function TimeInSecondsToStupidFuckingHumanFormat(time)
    local seconds = tostring(math.floor(time % 60))
    local minutes = tostring(math.floor(time / 60 % 60))
    local hours = tostring(math.floor(time / 60 / 60))
    return hours .. " : " .. (#minutes == 1 and "0" or "") .. minutes .. " : " .. (#seconds == 1 and "0" or "") .. seconds
end

function DrawDisplays()
    local generalPadding = 5

    -- level number
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.normal)
    local nextUpgrade = Level + (Level % UpgradeData.upgradeInterval)
    for i = Level + 1, Level + UpgradeData.upgradeInterval do
        if i % UpgradeData.upgradeInterval == 0 then
            nextUpgrade = i
            break
        end
    end
    love.graphics.print("Next upgrade: LVL " .. nextUpgrade, Fonts.levelNumber:getWidth(Level) + generalPadding * 2, generalPadding + 26)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.levelNumber)
    love.graphics.print(Level, generalPadding, generalPadding - 17)

    -- distance to goal, temperature
    love.graphics.setColor(0,1,0)
    love.graphics.setFont(Fonts.normal)

    local text = ""
    if AnalyticsUpgrades["misc display"] then
        text = text .. math.floor(ToMeters(math.abs(Player.y))) .. " / " .. ToMeters(Boundary.height) .. " m | checkpoint at: " .. (Player.checkpoint.y and math.floor(ToMeters(math.abs(Player.checkpoint.y))) or "nil") .. " | temperature: " .. math.floor(Player.temperature.current / Player.temperature.max * 100) .. "%"
    end

    love.graphics.printf(text, 0, generalPadding, love.graphics.getWidth() - generalPadding * 2, "center")

    -- x location on map
    local x = ReverseLerp(Boundary.x, Boundary.x + Boundary.width, Player.x) * love.graphics.getWidth()
    love.graphics.setLineWidth(7)
    love.graphics.setColor(0,1,0,.3)
    love.graphics.line(x, 10, x, 24)

    -- performance
    --DrawTextWithBackground(love.timer.getAverageDelta() * 1000 .. " ms", 100, love.graphics.getHeight() - 30, Fonts.normal, {1,1,1}, {0,0,0})
end
function DrawHeatIndicator()
    local ratio = Player.temperature.current / Player.temperature.max / 2
    love.graphics.setBlendMode("add", "alphamultiply")
    love.graphics.setColor(1,.5,0, ratio)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setBlendMode("alpha")
end

function ToMeters(px)
    return px / 200
end
function ToPixels(meters)
    return meters * 200
end

function ExtendView()
    local angle = AngleBetween(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY())
    local distance = -Distance(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY())

    local xTranslate = math.sin(angle) * distance * 1.5
    local yTranslate = math.cos(angle) * distance * 1.5

    if love.keyboard.isDown("lshift") then

        CamLookAhead.easing.origin.x, CamLookAhead.easing.origin.y = 0, 0
        CamLookAhead.easing.dest.x, CamLookAhead.easing.dest.y = xTranslate, yTranslate
        CamLookAhead.easing.running = true

        if not CamLookAhead.wasLooking then
            CamLookAhead.easing.current = 0
        end

        CamLookAhead.wasLooking = true
    else
        CamLookAhead.easing.dest.x, CamLookAhead.easing.dest.y = 0, 0
        CamLookAhead.easing.origin.x, CamLookAhead.easing.origin.y = xTranslate, yTranslate

        if CamLookAhead.wasLooking then
            CamLookAhead.easing.current = 0
        end

        if CamLookAhead.easing.current >= CamLookAhead.easing.max then
            CamLookAhead.easing.running = false
        end

        CamLookAhead.wasLooking = false
    end
end
function UpdateCamLookAhead()
    if CamLookAhead.easing.running then
        if CamLookAhead.easing.current < CamLookAhead.easing.max then
            CamLookAhead.easing.current = CamLookAhead.easing.current + 1 * GlobalDT
            if CamLookAhead.easing.current > CamLookAhead.easing.max then CamLookAhead.easing.current = CamLookAhead.easing.max end
        end

        local ratio = CamLookAhead.easing.current / CamLookAhead.easing.max
        CamLookAhead.xOff, CamLookAhead.yOff =
        Lerp(CamLookAhead.easing.origin.x, CamLookAhead.easing.dest.x, EaseOutQuint(ratio)), Lerp(CamLookAhead.easing.origin.y, CamLookAhead.easing.dest.y, EaseOutQuint(ratio))
    end
end
function ApplyCamLookAhead()
    local multiply = 1 + EaseInOutCubic(Clamp((Player.timeStill - 60) / Player.timeStillFocusDivisor, 0, 1)) * 1.5
    love.graphics.translate(CamLookAhead.xOff * multiply, CamLookAhead.yOff * multiply)
end

function EaseOutQuint(x)
    return 1 - (1 - x)^5
end
function EaseInOutCubic(x)
    return (x < 0.5 and 4 * x^3 or 1 - (-2 * x + 2)^3 / 2)
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
        local distance = Distance(turret.x, turret.y, Player.centerX, Player.centerY)

        local before = turret.seesPlayer
        turret.seesPlayer = distance <= turret.viewRadius

        if distance > Player.renderDistance and GameState == "game" then goto continue end

        if not Player.respawnWait.dead and turret.seesPlayer and not NextLevelAnimation.running and GameState == "game" then
            if not before and turret.seesPlayer then
                PlaySFX(SFX.seesPlayer, 0.2, turret.fireRate.max / TurretGlobalData.fireInterval.min + 0.5)
            end

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

        ::continue::
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
    for _, turret in ipairs(Turrets) do
        local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
        if Distance(turret.x, turret.y, mx, my) <= TurretGlobalData.readingsDistance then
            love.graphics.setColor(0,1,0)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", turret.x, turret.y, turret.viewRadius)
            love.graphics.setFont(Fonts.normal)
            love.graphics.print("fire interval: " .. turret.fireRate.max, turret.x + TurretGlobalData.headRadius + 5, turret.y)
        end
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

function SpawnCheckpoints()
    Checkpoints = {}
    for _ = 1, ObjectGlobalData.checkpointDensity * Boundary.width * Boundary.height do
        local x, y = math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height)
        NewCheckpoint(x, y)

        for _, obj in ipairs(Objects) do
            if Touching(x, y, 0, 0, obj.x, obj.y, obj.width, obj.height) then
                lume.remove(Objects, obj)
            end
        end
    end
end
function NewCheckpoint(x, y)
    table.insert(Checkpoints, {
        x = x, y = y
    })
end
function DrawCheckpoints()
    local characters = "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*"

    for _, checkpoint in ipairs(Checkpoints) do
        love.graphics.setColor(1,0,1)
        love.graphics.setLineWidth(2)
        love.graphics.circle(((checkpoint.x == Player.checkpoint.x and checkpoint.y == Player.checkpoint.y) and "fill" or "line"),
        checkpoint.x +math.random()-math.random(), checkpoint.y +math.random()-math.random(), CheckpointGlobalData.radius)

        for _ = 1, 10 do
            local d = math.random(360)
            local multiply = math.random(11, 20) / 10
            local x, y = math.sin(math.rad(d)) * CheckpointGlobalData.radius * multiply + checkpoint.x, math.cos(math.rad(d)) * CheckpointGlobalData.radius * multiply + checkpoint.y
            local charindex = math.random(#characters)
            love.graphics.print(string.sub(characters, charindex, charindex), x, y)
        end
    end
end

function SpawnShrines()
    Shrines = {}

    for _ = 1, ObjectGlobalData.shrineDensity * Boundary.width * Boundary.height do
        NewShrine(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
    end
end
function NewShrine(x, y)
    local palette = ShrineGenerationPalette
    for key, value in pairs(PlayerPerks) do
        if value then
            palette[key] = 0
        end
    end

    local allZero = true
    for _, value in pairs(palette) do
        if value ~= 0 then allZero = false end
    end
    if allZero then return end

    table.insert(Shrines, {
        x = x - ShrineGlobalData.width / 2, y = y - ShrineGlobalData.width / 2, effect = lume.weightedchoice(palette)
    })

    for _, obj in ipairs(Objects) do
        if Touching(x, y, ShrineGlobalData.width, ShrineGlobalData.width, obj.x, obj.y, obj.width, obj.height) then
            lume.remove(Objects, obj)
        end
    end

    for distance = 500, 1100, 300 do
        for d = 0, 359, 360/math.random(5,7) do
            NewTurret(x + math.sin(math.rad(d)) * distance, y + math.cos(math.rad(d)) * distance, math.random(TurretGlobalData.fireInterval.min, TurretGlobalData.fireInterval.max), true)
        end
    end
end
function DrawShines()
    for _, shrine in ipairs(Shrines) do
        local color = {0,0,0}
        color[math.random(#color)] = 1

        local width = (shrine.minimapVisible and ShrineGlobalData.width * 1.5 or ShrineGlobalData.width)

        if Minimap.showing then goto continue end

        love.graphics.setColor(color[1],color[2],color[3], 0.5)

        love.graphics.push()

        love.graphics.translate(shrine.x + width / 2, shrine.y + width / 2)
        love.graphics.rotate(math.rad(ShrineGlobalData.spin))
        love.graphics.rectangle("fill", -width / 2, -width / 2, width, width)

        love.graphics.pop()

        color = {0,0,0}
        color[math.random(#color)] = 1
        DrawTextWithBackground(shrine.effect, shrine.x + width / 2, shrine.y + width / 2, Fonts.big, color, {0,0,0,0})

        ::continue::

        if AnalyticsUpgrades["signal radar"] and Distance(Player.centerX, Player.centerY, shrine.x, shrine.y) <= ShrineGlobalData.maxHintDistance then
            DrawArrowTowards(shrine.x, shrine.y, color, 1, ShrineGlobalData.maxHintDistance)
        end
    end
end
function UpdateShrines()
    ShrineGlobalData.spin = ShrineGlobalData.spin + 2
    if ShrineGlobalData.spin >= 360 then
        ShrineGlobalData.spin = 0
    end

    for _, shrine in ipairs(Shrines) do
        if Touching(shrine.x, shrine.y, ShrineGlobalData.width, ShrineGlobalData.width, Player.x, Player.y, Player.width, Player.height) then
            PlaySFX(SFX.shrine, 0.6, math.random()/10+.95)

            local shrineEffect = ShrineGlobalData.types[shrine.effect]
            shrineEffect.func()

            PlayerPerks[shrine.effect] = true

            ApplyShrineEffects()

            for _ = 1, 20 do
                table.insert(Particles, NewParticle(shrine.x, shrine.y, math.random() * 6, {0,0,0}, math.random() * 9 + 3, math.random(360), 0.02, math.random(300, 500), function (self)
                    self.color = {0,0,0}
                    self.color[math.random(#self.color)] = 1
                end))
            end

            NewMessage(shrine.effect .. ": " .. ShrineGlobalData.types[shrine.effect].explanation, 0, 100, {0,1,0}, 500, Fonts.big, nil, true)

            SaveData()

            Shrines = {}

            goto outOfLoop
        end
    end

    ::outOfLoop::
end
function ApplyShrineEffects()
    if PlayerPerks["Will of the Frogman"] then Player.superJump.max = 2000 end
    if PlayerPerks["Blood of the Man in White"] then Player.passiveCooling = 1.2 end
    if PlayerPerks["Scale of the Rampant Mouse"] then Player.width, Player.height = 7, 7 end
    if PlayerPerks["Eye of the Crimson Eagle"] then Player.zoom = 0.5 end
    if PlayerPerks["Essence of the Grasshopper"] then Player.jumpStrength = 30; Player.superJumpStrength = 100 end
end

function FireBullet(x, y, angle, speed, originTurretIndex)
    local lifespan = 400
    table.insert(Bullets, {
        x = x, y = y, radius = TurretGlobalData.bulletRadius, warningProgression = 0,
        draw = function (self)
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, self.radius)

            local maxdistance, checks = 1300, 20
            for i = 0, maxdistance, maxdistance / checks do
                if Distance(Player.centerX, Player.centerY,
                self.x + math.sin(angle) * i, self.y + math.cos(angle) * i) <= Player.width / 2 + self.radius + maxdistance/checks * 2 then
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

            love.graphics.setLineWidth(3)
            love.graphics.circle("line", self.x, self.y, self.radius * 5 * EaseOutQuint(self.warningProgression), 100)
        end,
        update = function (self)
            local distanceToPlayer = Distance(Player.centerX, Player.centerY, self.x, self.y)
            local multiplier = Lerp(0.3, 1, Clamp(distanceToPlayer / Player.instinctOfTheBulletJumperDistance, 0, 1))

            self.x = self.x + math.sin(angle) * speed * GlobalDT * (PlayerPerks["Instinct of the Bullet Jumper"] and multiplier or 1)
            self.y = self.y + math.cos(angle) * speed * GlobalDT * (PlayerPerks["Instinct of the Bullet Jumper"] and multiplier or 1)

            lifespan = lifespan - 1 * GlobalDT
            if lifespan < 0 then
                lume.remove(Bullets, self)
            end

            local maxLifeForShrink = 50
            if lifespan <= maxLifeForShrink then
                local ratio = lifespan / maxLifeForShrink
                self.radius = TurretGlobalData.bulletRadius * ratio
            end

            --[[
            for index, turret in ipairs(Turrets) do
                if index ~= originTurretIndex and Distance(turret.x, turret.y, self.x, self.y) <= TurretGlobalData.headRadius + TurretGlobalData.bulletRadius then
                    ExplodeTurret(turret)
                end
            end]]
        end
    })
end
function UpdateBullets()
    for _, bullet in ipairs(Bullets) do
        bullet:update()
    end
end
function DrawBullets()
    for _, bullet in ipairs(Bullets) do
        bullet:draw()
    end
end

function AngleBetween(x1, y1, x2, y2)
---@diagnostic disable-next-line: deprecated
    return math.atan2(x2 - x1, y2 - y1)
end

function UpdateSaveInterval()
    SaveInterval.current = SaveInterval.current + 1 * GlobalDT
    if SaveInterval.current >= SaveInterval.max then
        SaveInterval.current = 0
        SaveData()
    end
end

function DrawBG()
    for _, element in ipairs(BG) do
        if Distance(Player.centerX, Player.centerY, element.x, element.y) <= Player.renderDistance then
            love.graphics.setColor(1,1,1, element.alpha)
            love.graphics.circle("fill", element.x, element.y, element.radius)
        end
    end
end
function GenerateBG()
    if Settings.graphics.current == 1 then return end

    BG = {}
    for _ = 1, Boundary.width * Boundary.height * ObjectGlobalData.objectDensity do
        table.insert(BG,
        { x = math.random(Boundary.x, Boundary.x + Boundary.width), y = math.random(Boundary.y, Boundary.y + Boundary.height), radius = math.random() * 100 + 30, alpha = math.random() / 8 })
    end
end

function NewMessage(text, x, y, color, lifespan, font, followEnemyIndex, followPlayer)
    table.insert(Messages, {
        x = x, y = y, life = lifespan, followEnemyIndex = followEnemyIndex,
        draw = function (self)
            love.graphics.setColor(color)
            love.graphics.setFont(font)
            DrawTextWithBackground(text, self.x +math.random()-math.random(), self.y +math.random()-math.random(), font, color, {0,0,0})
        end,
        update = function (self)
            self.life = self.life - 1 * GlobalDT
            if self.life <= 0 then
                lume.remove(Messages, self)
            end

            if followEnemyIndex ~= nil and Enemies[followEnemyIndex] ~= nil then
                self.x = Enemies[followEnemyIndex].x + x
                self.y = Enemies[followEnemyIndex].y + y
            elseif followPlayer then
                self.x = Player.x + x
                self.y = Player.y + y
            end
        end
    })
end
function UpdateMessages()
    for _, message in ipairs(Messages) do
        message:update(message)
    end
end
function DrawMessages()
    for _, message in ipairs(Messages) do
        message:draw(message)
    end
end

function CheckForOddities()
    local spacing = 100

    -- clipping outside the map
    if Player.y > Boundary.y + Boundary.height then
        Player.y = Boundary.y + Boundary.height - 100

        NewMessage("Whoops! Looks like you clipped below the map.", Player.x, Player.y - spacing, {1,0,0}, 1000, Fonts.big)
    end
    if Player.x > Boundary.x + Boundary.width or Player.x < Boundary.x then
        Player.x = 0

        NewMessage("Whoops! Looks like you clipped outside the map.", Player.x, Player.y - spacing, {1,0,0}, 1000, Fonts.big)
    end
end

function InitialiseRegularCoordinateAlterations()
    local zoom = ConvertPlayerVelocityToZoom()
    local lookAheadX, lookAheadY = ConvertPlayerVelocityToCameraLookAhead()
    love.graphics.scale(zoom)
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 + lookAheadX, love.graphics.getHeight() / zoom / 2 + lookAheadY)

    if not NextLevelAnimation.running then
        love.graphics.translate(-Player.x - Player.width / 2, -Player.y - Player.height / 2)
    end

    --[[if Paused then
        love.graphics.translate(math.random()-math.random(), 0)
    end]]
end

function DrawPausedOverlay()
    if Paused or (SlowMo.running and (SlowMo.toPause or SlowMo.toUnpause)) then
        local alpha = 0.2
        local multiplier = EaseInOutCubic((SlowMo.running and (SlowMo.slowingDown and SlowMo.current or SlowMo.max - SlowMo.current) / SlowMo.max or 1))
        love.graphics.setColor(0,0,0, multiplier * alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        DrawTextWithBackground("Paused.", love.graphics.getWidth()/2, love.graphics.getHeight() - 200, Fonts.big, {1,1,1,multiplier}, {0,0,0,multiplier})
        DrawTextWithBackground("[P] to unpause.", love.graphics.getWidth()/2, love.graphics.getHeight() - 150, Fonts.medium, {1,1,1,multiplier}, {0,0,0,multiplier})

        love.graphics.setFont(Fonts.normal)
        love.graphics.setColor(1,1,1, multiplier)
        love.graphics.print(Version, 5, love.graphics.getHeight() - Fonts.normal:getHeight() - 5)

        local generalPadding = 10
        local scale = 0.6
        love.graphics.draw(Sprites.fullControls, love.graphics.getWidth() - generalPadding - Sprites.fullControls:getWidth() * scale, love.graphics.getHeight() - generalPadding - Sprites.controls:getHeight() * scale, 0, scale,scale)
    end
end

function DrawTextWithBackground(text, x, y, font, textColor, bgColor)
    local textObj = love.graphics.newText(font, text)
    local padding = 5
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x - textObj:getWidth()/2 - padding, y - textObj:getHeight()/2 - padding, textObj:getWidth() + padding * 2, textObj:getHeight() + padding * 2)

    love.graphics.setColor(textColor)
    love.graphics.draw(textObj, x - textObj:getWidth()/2, y - textObj:getHeight()/2)
end

function DrawDeathPositions()
    for _, position in ipairs(DeathPositions) do
        love.graphics.setColor(1,0,0,.3)
        love.graphics.draw(Sprites.cross, position.x - Sprites.cross:getWidth() / 2 + Jitter(3), position.y - Sprites.cross:getHeight() / 2 + Jitter(3))
    end
end

function Jitter(amplitude)
    return (math.random()-math.random())*amplitude
end

function InitialiseButtons()
    local width = 300
    local CENTERX, CENTERY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

    -- main menu
    NewButton("Begin", CENTERX - width / 2, CENTERY + 100, width, 80, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.big, 2, 10,10, function (self)
        GameState = "game"
        LoadData()
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Settings", CENTERX - width / 2, CENTERY + 200, width, 60, {.4,.4,.4}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "settings"
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Changelog", CENTERX - width / 2, CENTERY + 270, width, 40, {.4,.4,.4}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "changelog"
    end, nil, function (self)
        return GameState == "menu"
    end)

    -- settings
    width = 800
    NewButton("", CENTERX - width / 2, CENTERY - 200, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        Settings.musicOn = not Settings.musicOn
        SaveData()

        if Settings.musicOn then Music:play() else Music:pause() end
    end, function (self)
        self.text = "Music: " .. (Settings.musicOn and "On" or "Off")
        self.textColor = (Settings.musicOn and {0,1,0} or {1,0,0})
        self.lineColor = self.textColor
    end, function (self)
        return GameState == "settings"
    end)
    NewButton("", CENTERX - width / 2, CENTERY - 100, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        Settings.graphics.current = Settings.graphics.current + 1
        if Settings.graphics.current > Settings.graphics.max then Settings.graphics.current = 1 end
        if Settings.graphics.current >= 2 then
            GenerateBG()
        else
            BG = {}
        end

        SaveData()
    end, function (self)
        self.text = "Graphics: " .. Settings.graphics.current .. " / " .. Settings.graphics.max
    end, function (self)
        return GameState == "settings"
    end)

    NewButton("Back", CENTERX - width / 2, CENTERY + 300, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "menu"
    end, nil, function (self)
        return GameState == "settings" or GameState == "changelog"
    end)

    width = 500
    NewButton("Reset Current Run", CENTERX - width / 2, CENTERY + 400, width, 60, {1,0,0}, {0,0,0}, {.1,.1,.1}, {1,0,0}, Fonts.medium, 2, 10,10, function (self)
        if not self.confirmation then
            self.confirmation = 0
            self.text = "Shift-click to confirm."
        elseif self.confirmation == 0 and love.keyboard.isDown("lshift") then
            self.confirmation = self.confirmation + 1
            self.key = lume.randomchoice({"u","i","o","p","k","l"})
            self.text = "Hold shift, " .. string.upper(self.key) .. ", and click to confirm."
        elseif self.confirmation == 1 and love.keyboard.isDown("lshift") and love.keyboard.isDown(self.key) then
            self.confirmation = nil
            self.text = "Reset Current Run"
            PlaySFX(SFX.resetRun, 0.1, 1)
            ResetGame()
        end
    end, nil, function (self)
        return GameState == "settings"
    end)
end

function PickDescensionLevels()
    return { 17 - math.random(0, 3), 37 - math.random(0, 4), 50 }
end

function StartSlowMo(slowingDown, toPause, toUnpause)
    SlowMo.running = true
    SlowMo.slowingDown = slowingDown
    SlowMo.toPause = toPause
    SlowMo.toUnpause = toUnpause

    if toUnpause then
        Paused = false
    end
end
function UpdateSlowMo()
    if not SlowMo.running then return end

    SlowMo.current = SlowMo.current + 1 * GlobalUnaffectedDT
    TimeMultiplier = EaseInOutCubic((SlowMo.slowingDown and SlowMo.max - SlowMo.current or SlowMo.current) / SlowMo.max)
    if SlowMo.current >= SlowMo.max then
        SlowMo.running = false
        SlowMo.current = 0

        if SlowMo.toPause then
            Paused = true
        end
    end
end

function InitialiseUpgrades()
    AnalyticsUpgrades = {}

    SuitUpgrades = {
        function () -- vault higher
            Player.divisorWhenConvertingXToYVelocity = 1.7
        end,
        function () -- better traction
            Player.groundFriction = 1.3
        end,
        function () -- stronger jump-pads
            ObjectGlobalData.jumpPlatformStrength = 50
        end,
        function () -- vault higher ii
            Player.divisorWhenConvertingXToYVelocity = 1.3
        end,
        function () -- better traction ii
            Player.groundFriction = 1.7
        end,
        function () -- better cooling
            Player.passiveCooling = 0.7
        end,
    }

    UpgradeData = {
        jumpHeightIncrement = 1.2,
        speedIncrement = 0.02,
        spacingOnMenu = 170,
        picking = false, picked = false,
        startGettingUpgradesOnLevel = 0,
        upgradeInterval = 3
    }

    Upgrades = {
        {
            name = "jump height",
            list = {
                "hop",
                "hop higher",
                "leap",
                "leap higher",
                "fly",
                "fly higher",
            }
        },
        {
            name = "speed",
            list = {
                "run",
                "run faster",
                "sprint",
                "sprint faster",
                "drive",
                "drive faster",
            }
        },
        {
            name = "suit",
            list = {
                "stronger jump-pads",
                "vault higher",
                "better traction",
                "better cooling",
                "vault higher ii",
                "better traction ii",
            }
        },
        {
            name = "analytics",
            list = {
                "misc display",
                "minimap",
                "signal radar",
            }
        },
    }

    for _, value in ipairs(Upgrades[3].list) do
        AnalyticsUpgrades[value] = false
    end

    local width = 400
    for index = 1, #Upgrades do
        NewButton("Commit", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() / 2 + UpgradeData.spacingOnMenu * (index - (#Upgrades+1)/2) + 50, width, 40, {0,0,0}, {0,0,0}, {.2,.2,.2}, {1,1,1},
        Fonts.normal, 0, 10, 10, function (self)
            local listOfCategories = {}
            for _, value in ipairs(Upgrades) do
                table.insert(listOfCategories, value.name)
            end

            PlayerUpgrades[listOfCategories[index]] = PlayerUpgrades[listOfCategories[index]] + 1
            UpgradeData.picked = true

            ApplyUpgrades()
            SaveData()

            PlaySFX(SFX.upgrade, 0.4, 1)
        end, function (self)
            if UpgradeData.picked or PlayerUpgrades[Upgrades[index].name] >= #Upgrades[index].list then
                self.textColor = {.3,.3,.3}
                self.mouseOverFillColor = self.fillColor
                self.lineColor = self.textColor
                self.grayedOut = true
            else
                self.textColor = {1,1,1}
                self.mouseOverFillColor = {.2,.2,.2}
                self.lineColor = {.2,.2,.2}
                self.grayedOut = false
            end
        end, function (self)
            return UpgradeData.picking
        end)
    end

    NewButton("Continue", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - 80, width, 40, {0,1,0}, {0,0,0}, {.2,.2,.2}, {0,1,0}, Fonts.normal, 2, 10, 10, function (self)
        UpgradeData.picked, UpgradeData.picking = false, false
        PlaySFX(SFX.playerSpawn, 0.5, 1)
    end, nil, function ()
        return UpgradeData.picked
    end)
end
function ApplyUpgrades()
    Player.jumpStrength = Player.baseJumpStrength + PlayerUpgrades["jump height"] * UpgradeData.jumpHeightIncrement
    Player.speed = Player.baseSpeed + PlayerUpgrades["speed"] * UpgradeData.speedIncrement

    local index = 1
    for _, value in ipairs(Upgrades[4].list) do
        if index > PlayerUpgrades["analytics"] then break end
        AnalyticsUpgrades[value] = true
        index = index + 1
    end

    for i = 1, PlayerUpgrades["suit"] + 1 do
        SuitUpgrades[i]()
    end
end
function OpenUpgradeMenu()
    if Level >= UpgradeData.startGettingUpgradesOnLevel and Level % UpgradeData.upgradeInterval == 0 then
        UpgradeData.picking = true
        PlaySFX(SFX.upgradeMenu, 0.7, 1)
    end
end
function DrawUpgradeMenuOverlay()
    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local listOfCategories = {}
    for _, value in ipairs(Upgrades) do
        table.insert(listOfCategories, value.name)
    end

    for index = 1, #Upgrades do
        local category = Upgrades[index].name
        local level = Upgrades[index].list[PlayerUpgrades[category]]
        local text = string.upper(category) .. ": " .. string.upper((level and level .. " unlocked" or "not upgraded"))

        DrawTextWithBackground(text,
        love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + UpgradeData.spacingOnMenu * (index - (#Upgrades+1)/2), Fonts.medium, (level and {1,1,1} or {1,0,0}), {0,0,0})

        local nextLevel = Upgrades[index].list[PlayerUpgrades[category]+1]
        local subText
        if nextLevel == nil then
            subText = "Path complete"
        else
            subText = "next: " .. nextLevel
        end
        DrawTextWithBackground(subText,
        love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + UpgradeData.spacingOnMenu * (index - (#Upgrades+1)/2) + 30, Fonts.normal, {.5,.5,.5}, {0,0,0})
    end

    DrawTextWithBackground("PICK AN UPGRADE", love.graphics.getWidth() / 2, 80, Fonts.big, {1,1,0}, {0,0,0,0})
end

function DrawCommandLineOverlay()
    if not CommandLine.typing then return end

    love.graphics.setColor(0,0,0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local spacing = 10
    love.graphics.setColor(0,1,0)
    love.graphics.setFont(Fonts.medium)
    love.graphics.print(CommandLine.text .. "_", spacing, love.graphics.getHeight() - spacing - Fonts.medium:getHeight())

    love.graphics.setColor(0,1,0,.5)
    for index, text in ipairs(CommandLine.history) do
        love.graphics.print(text, spacing, love.graphics.getHeight() - spacing - Fonts.medium:getHeight() * (#CommandLine.history - index + 2))
    end
end
function RunCommandLine()
    table.insert(CommandLine.history, CommandLine.text)
    lume.dostring(CommandLine.text)
    CommandLine.text = ""
end
function Print(text)
    table.insert(CommandLine.history, "> " .. text)
end
function DEBUG()
    Enemies = {}
    Turrets = {}
    Player.jumpStrength = 40
end

function DrawDebug()
    if not Debug then return end

    local enemiesRendered = 0
    for _, enemy in ipairs(Enemies) do
        if Distance(Player.centerX, Player.centerY, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2) <= Player.renderDistance then
            enemiesRendered = enemiesRendered + 1
        end
    end

    local objsRendered = 0
    for _, obj in ipairs(Objects) do
        if obj.render then
            objsRendered = objsRendered + 1
        end
    end

    local turretsRendered = 0
    for _, turret in ipairs(Turrets) do
        if Distance(Player.centerX, Player.centerY, turret.x, turret.y) <= Player.renderDistance then
            turretsRendered = turretsRendered + 1
        end
    end

    love.graphics.setColor(0,1,0)
    love.graphics.printf(
        "Hooligans " .. enemiesRendered ..
        "\nObjs " .. objsRendered ..
        "\nTurrets " .. turretsRendered ..
        "\nAvg DT ms: " .. math.floor(love.timer.getAverageDelta() * 100 * 1000) / 100,

        5, 200, love.graphics.getWidth(), "left"
    )
end

function SaveFrames()
    if love.timer.getAverageDelta() > 0.07 and false then
        SaveData()
        LoadData()
    end
end