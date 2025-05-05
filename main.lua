function love.load()
---@diagnostic disable-next-line: lowercase-global
    lume = require "lume"
---@diagnostic disable-next-line: lowercase-global
    zutil = require "zutil"

    require "player"
    require "particle"
    require "data_management"
    require "button"
    require "enemy"
    require "turret"
    require "bub"
    require "weather"
    require "changelog"
    require "dialogue"
    require "ambient_life"

    NameOfTheGame = "Frazy's Superstructures"

    love.window.setTitle(NameOfTheGame)

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
        bubSpeak = love.audio.newSource("assets/sfx/bub speak.wav", "static"),
        drawCard = love.audio.newSource("assets/sfx/draw card.wav", "static"),
        bust = love.audio.newSource("assets/sfx/bust.wav", "static"),
        blackjackSpotOn = love.audio.newSource("assets/sfx/blackjack spot-on.wav", "static"),
        rainy = love.audio.newSource("assets/sfx/rain.mp3", "stream"),
        selfDestruct = love.audio.newSource("assets/sfx/self destruct.wav", "static"),
        push = love.audio.newSource("assets/sfx/push.wav", "static"),
        wind = love.audio.newSource("assets/sfx/wind.wav", "static"),
        windWarning = love.audio.newSource("assets/sfx/wind warning.wav", "static"),
        intel = love.audio.newSource("assets/sfx/wind over.wav", "static"),
        windy = love.audio.newSource("assets/sfx/windy.mp3", "stream"),
        superJump = love.audio.newSource("assets/sfx/super jump.wav", "static"),
        superJumpReplenish = love.audio.newSource("assets/sfx/super jump replenish.wav", "static"),
        superJumpFull = love.audio.newSource("assets/sfx/super jump full.wav", "static"),
        poof = love.audio.newSource("assets/sfx/poof.wav", "static"),
        changeWeather = love.audio.newSource("assets/sfx/change weather.wav", "static"),
        heart = love.audio.newSource("assets/sfx/heart.wav", "static"),
        primeShoot = love.audio.newSource("assets/sfx/prime shoot.wav", "static"),
        checkpointFizzleOut = {
            love.audio.newSource("assets/sfx/checkpoint fizzle out.wav", "static"),
            love.audio.newSource("assets/sfx/checkpoint fizzle out2.wav", "static"),
            love.audio.newSource("assets/sfx/checkpoint fizzle out3.wav", "static"),
        },
        warble = {
            love.audio.newSource("assets/sfx/warble.wav", "static"),
            love.audio.newSource("assets/sfx/warble2.wav", "static"),
        },
        shortCircuit = {
            love.audio.newSource("assets/sfx/short circuit.wav", "static"),
            love.audio.newSource("assets/sfx/short circuit2.wav", "static"),
            love.audio.newSource("assets/sfx/short circuit3.wav", "static"),
        },
        foggyEnemySmash = {
            love.audio.newSource("assets/sfx/foggy enemy smash.wav", "static"),
            love.audio.newSource("assets/sfx/foggy enemy smash2.wav", "static"),
            love.audio.newSource("assets/sfx/foggy enemy smash3.wav", "static"),
        },
        enemySpeak = {},
    }

    love.audio.setEffect("reverb", { type = "reverb", decaytime = 2 })
    love.audio.setEffect("player voice", { type = "equalizer", lowgain = 0.127, lowcut = 1000 })

    SFX.superJumpFull:setEffect("reverb")
    SFX.superJumpReplenish:setEffect("reverb")
    SFX.superJump:setEffect("reverb")
    SFX.poof:setEffect("reverb")

    for _, sfx in ipairs(SFX.foggyEnemySmash) do
        sfx:setEffect("reverb")
    end

    for i = 1, 13 do
        table.insert(SFX.enemySpeak, love.audio.newSource("assets/sfx/enemy speak" .. i .. ".wav", "static"))
    end

    Sprites = {
        cross = love.graphics.newImage("assets/sprites/cross.png", {dpiscale=10}),
        controls = love.graphics.newImage("assets/sprites/controls.png", {dpiscale=8}),
        fullControls = love.graphics.newImage("assets/sprites/full controls.png", {dpiscale=7}),
        jacksHat = love.graphics.newImage("assets/sprites/jack's hat.png", {dpiscale=13}),
        bullet = love.graphics.newImage("assets/sprites/bullet.png", {dpiscale=11}),
        homingCross = love.graphics.newImage("assets/sprites/homing cross.png", {dpiscale=2}),
        posters = {}
    }
    for index, fileName in ipairs(love.filesystem.getDirectoryItems("assets/sprites/posters")) do
        if index == 1 then goto next end
        table.insert(Sprites.posters, love.graphics.newImage("assets/sprites/posters/" .. fileName, {dpiscale=8}))
        ::next::
    end

    local fontName = "DMMono"
    local fontDirectory = "assets/fonts/" .. fontName .. "/" .. fontName .. "-"
    Fonts = {
        normal =      love.graphics.newFont(fontDirectory.."Regular.ttf", 11),
        small =       love.graphics.newFont(fontDirectory.."Regular.ttf", 9),
        changelog =   love.graphics.newFont(fontDirectory.."Regular.ttf", 13),
        dialogue =    love.graphics.newFont(fontDirectory.."Regular.ttf", 21),
        medium =      love.graphics.newFont(fontDirectory.."Regular.ttf", 17),
        big =         love.graphics.newFont(fontDirectory.."Medium.ttf", 23),
        time =        love.graphics.newFont(fontDirectory.."Regular.ttf", 294),
        smallTime =   love.graphics.newFont(fontDirectory.."Regular.ttf", 144),
        title =       love.graphics.newFont(fontDirectory.."Medium.ttf", 94),
        levelNumber = love.graphics.newFont(fontDirectory.."Italic.ttf", 45),
    }

    BG = {}

    Music = love.audio.newSource("assets/music/Numbers.wav", "stream")
    Music:setLooping(true)
    Music:setVolume(0.1)

    Settings = {
        musicOn = true,
        graphics = { current = 3, max = 3 },
        cameraRotationOn = true,
        weatherDarkening = true,
    }

    Characters = "abcdefghijklmnopqrstuvwxyz"

    Title = {
        goal = NameOfTheGame,
        unscrambleIndex = 1,
        unscrambleInterval = { current = 0, max = 10 },
        randomSeed = os.time(),
        draw = function (self)
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(Fonts.title)

            local text = string.sub(self.goal, 1, self.unscrambleIndex)
            math.randomseed(self.randomSeed)
            for _ = 1, #self.goal - self.unscrambleIndex do
                local i = math.random(#Characters)
                text = text .. string.sub(Characters, i,i)
            end

            love.graphics.printf(text, 0, 200, love.graphics.getWidth(), "center")
        end,
        update = function (self)
            if self.unscrambleIndex >= #self.goal then return end
            self.unscrambleInterval.current = self.unscrambleInterval.current + 1 * GlobalDT
            if self.unscrambleInterval.current >= self.unscrambleInterval.max then
                self.unscrambleInterval.current = self.unscrambleInterval.current - self.unscrambleInterval.max
                self.unscrambleIndex = self.unscrambleIndex + 1
                self.randomSeed = self.randomSeed + 1
            end
        end
    }

    Gravity = 0.6

    Level = 1

    Boundary = { x = nil, y = 0, width = ToPixels(300), height = nil, baseHeight = 4000, heightIncrement = 6000 }
    Boundary.x = -Boundary.width / 2
    Boundary.height = Boundary.baseHeight

    Turrets = {}
    Checkpoints = {}
    Shrines = {}

    ObjectGlobalData = {
        cornerRadius = 3,
        strokeWidth = 4,
        beamStrokeWidth = 50, beamColor = {.06,.06,.06},
        objectsToGenerate = 0, objectDensity = 0.0000022, turretDensity = 0, baseTurretDensity = 0.00000003, checkpointDensity = 0.000000014, shrineDensity = 0.0000000006, bubDensity = 0.000000002,
        groundZeroNotchSpacing = 100, groundZeroNotchLength = 20,
        dangerPulseProgression = { current = 0, max = 500 },
        jumpPlatformStrength = 40,
        scaleFactor = {
            current = 0,
            find = function ()
                return math.random() * 1.3 + 0.4
            end,
        }
    }
    ObjectGlobalData.objectsToGenerate = ObjectGlobalData.objectDensity * Boundary.width * Boundary.height
    ObjectGlobalData.turretDensity = ObjectGlobalData.baseTurretDensity
    ObjectGlobalData.scaleFactor.current = ObjectGlobalData.scaleFactor.find()

    CheckpointGlobalData = {
        radius = 50,
        clearRadius = 2000,
    }

    ShrineGlobalData = {
        width = 100,
        spin = 0,
        maxHintDistance = ToPixels(90),
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

    PosterGlobalData = {
        spacingFromEdgesOfObject = 20,
        density = 0.02, -- posters to generate = density x number of objects
    }

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
        { type = "jump", weight = 4 },
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

    PlayerCanMove = false

    DeathPositions = {}

    Enemies = {}

    Bubs = {}

    Buttons = {}
    InitialiseMenuButtons()
    InitialiseBubButtons()

    InitialiseUpgrades()

    Plinks = 0

    if love.filesystem.getInfo("data.csv") then
        LoadData()
    else
        LoadPlayer()
        ResetPlayerData()
    end

    if Settings.musicOn and Weather.currentType ~= "foggy" then Music:play() end

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

    Zen = {
        doingSo = false,
        camera = { x = 0, y = 0, speed = 30 },
        zoom = .3,
    }

    CommandLine = {
        typing = false,
        text = "",
        history = { "ENTER PASSKEY." },
    }

    GameState = "menu"

    ClickedWithMouse = false

    Debug = false

    TimeMultiplier = 1
    SlowMo = { current = 0, max = 20, slowingDown = false, running = false }

    GlobalUnaffectedDT = 0
    GlobalDT = 0

    GlobalCanvas = love.graphics.newCanvas()

    StartEnemyUpdateThread()
    StartTurretUpdateThread()
    StartAmbientLifeUpdateThread()

    CancelNextThreadSupply = false
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
                    if not Player.respawnWait.dead and not Zen.doingSo then TimeOnThisLevel = TimeOnThisLevel + dt end

                    GetThreadData()

                    if not Descending.hooligmanCutscene.running then
                        UpdateParticles()
                        UpdateMovables()
                        UpdateBullets()
                        UpdateShrines()
                        UpdateMessages()
                        UpdateBubs()
                        UpdateDialogue()
                        UpdateBubDialogue()
                        DiscoverAndRenderDiscoverables()
                        UpdateWeather()
                    end

                    UpdateHooligmanCutscene()
                    UpdateHooligmanDialogue()

                    SendThreadData()
                end

                --CheckForOddities()

                UpdateSaveInterval()
            else
                Title:update(Title)
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

    if TimeMultiplier > 1 then
        TimeMultiplier = 1
    end
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

            if Weather.types[Weather.currentType].shader ~= nil then
                love.graphics.setShader(Weather.types[Weather.currentType].shader)

                if Weather.currentType == "hot" then
                    Weather.types[Weather.currentType].shader:send("screenDimensions", {love.graphics.getWidth(), love.graphics.getHeight()})
                    Weather.types[Weather.currentType].shader:send("sinOffset", Weather.types[Weather.currentType].shaderSinOffset)
                elseif Weather.currentType == "foggy" then
                    --Weather.types[Weather.currentType].shader:send("screenDimensions", {love.graphics.getWidth(), love.graphics.getHeight()})
                    Weather.types[Weather.currentType].shader:send("screenCenter", {
                        love.graphics.getWidth() / (love.system.getOS() ~= "OS X" and 2 or 1),
                        love.graphics.getHeight() / (love.system.getOS() ~= "OS X" and 2 or 1),
                    })
                    Weather.types[Weather.currentType].shader:send("maxLightDistance", 1300)
                end
            end

            GlobalCanvas:renderTo(DrawGameFrame)

            love.graphics.pop()

            love.graphics.setColor(1,1,1)
            love.graphics.draw(GlobalCanvas)

            GlobalCanvas:renderTo(love.graphics.clear)

            if Weather.types[Weather.currentType].shader ~= nil then
                love.graphics.setShader()
            end

            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 60)

            DrawDisplays()
            DrawPlayerSuperJumpBar()

            DrawWeatherOverlay()

            DrawHeatIndicator()
            DrawPlayerSelfDestructOverlay()

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
        DrawWeatherOverlay()

        love.graphics.pop()

        -- overlay
        love.graphics.setColor(0,0,0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        if GameState == "menu" then
            if BestGameCompletionTime ~= nil then
                DrawTextWithBackground("Best time: " .. TimeInSecondsToStupidFuckingHumanFormat(BestGameCompletionTime), love.graphics.getWidth() / 2, 80, Fonts.medium, {0,1,0}, {0,0,0})
            end

            Title.draw(Title)

            if Level > 1 then
                love.graphics.setColor(Player.color)
                love.graphics.setFont(Fonts.medium)
                love.graphics.print(Plinks .. " plinks", 20, 20)
            end
        elseif GameState == "complete" then
            DrawTextWithBackground("Intel got what they needed. Nice job!\n" .. TimeInSecondsToStupidFuckingHumanFormat(TotalTime), love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, Fonts.big, Player.color, {0,0,0})
            DrawTextWithBackground("Hit [ESC] to return to the main menu.", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 300, Fonts.medium, {1,1,1}, {0,0,0})
        elseif GameState == "changelog" then
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(Fonts.changelog)
            love.graphics.print(Changelog, 10, 10 + ChangelogYOffset)
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
function DrawGameFrame()
    DrawBG()
    DrawBeams()
    DrawParticles()
    DrawObjects()
    DrawAmbientLife()
    DrawDeathPositions()
    DrawEnemies()
    DrawLevelGoal()

    DrawWayPoints()
    DrawWayPointArrow()

    DrawShines()
    DrawCheckpoints()
    DrawTurrets()
    DrawBullets()

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

    DrawDialogue()
end

function ApplyGravity(object)
    return object.yvelocity + Gravity * GlobalDT
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
        if (GameState == "menu" or GameState == "settings") and obj.y <= zutil.lerp(Boundary.y, Boundary.y + Boundary.height, 1 - MenuAnimation.objectIntro) then goto continue end

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

        if obj.darkGrading then
            local r,g,b = love.graphics.getColor()
            love.graphics.setColor(r - obj.darkGrading, g - obj.darkGrading, b - obj.darkGrading, 1)
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

    -- posters
    for _, obj in ipairs(Objects) do
        local outsideRenderDistance = not obj.render
        if not obj.discovered and GameState == "game" then goto continue end
        if outsideRenderDistance and not obj.discovered and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end
        if (GameState == "menu" or GameState == "settings") and obj.y <= zutil.lerp(Boundary.y, Boundary.y + Boundary.height, 1 - MenuAnimation.objectIntro) then goto continue end

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
function DrawBeams()
    for _, obj in ipairs(Objects) do
        if not obj.withinRenderDistance or not obj.beams then goto continue end

        love.graphics.setColor(ObjectGlobalData.beamColor)
        love.graphics.setLineWidth(ObjectGlobalData.beamStrokeWidth)

        for _, beam in ipairs(obj.beams) do
            love.graphics.line(obj.x+obj.width/2, obj.y+obj.height/2, beam.x, beam.y)
        end

        ::continue::
    end
end
function GenerateObjects()
    DeathPositions = {}

    local boundaryObjWidth = ToPixels(7)
    local playerSafeArea = ToPixels(5)
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
    Bullets = {}

    local newObj = function ()
        local x, y = math.random(Boundary.x - boundaryObjWidth, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height)

        local objectType = GetObjectTypeFromPerlinNoise(x, y)

        local width, height = math.random(ObjectTypeData[objectType].width.min, ObjectTypeData[objectType].width.max), math.random(ObjectTypeData[objectType].height.min, ObjectTypeData[objectType].height.max)
        if math.random() < .05 then
            local movingWidth = width
            width = height
            height = movingWidth
        end

        return {
            x = x, y = y,
            width = width * ObjectGlobalData.scaleFactor.current, height = height * ObjectGlobalData.scaleFactor.current, type = objectType,
            darkGrading = math.random() / 10,
        }
    end

    math.randomseed(Seed)

    -- objs
    for _ = 1, ObjectGlobalData.objectDensity * Boundary.width * Boundary.height * (2 - ObjectGlobalData.scaleFactor.current) do
        table.insert(Objects, newObj())
    end

    -- beams
    for _, obj in ipairs(Objects) do
        local beams = {}

        local maxDistance = ToPixels(5)

        for _ = 1, math.random(1,3) do
            local candidates = {}
            for _, candidate in ipairs(Objects) do
                if candidate.x == obj.x and candidate.y == obj.y or zutil.distance(obj.x+obj.width/2, obj.y+obj.height/2, candidate.x+candidate.width/2, candidate.y+candidate.height/2) > maxDistance then goto continue end

                table.insert(candidates, candidate)

                ::continue::
            end

            if #candidates > 0 then
                local choice = lume.randomchoice(candidates)
                table.insert(beams, { x = choice.x+choice.width/2, y = choice.y+choice.height/2 })
            end
        end

        obj.beams = beams
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
        if zutil.touching(obj.x, obj.y, obj.width, obj.height, -playerSafeArea, Boundary.y + Boundary.height - playerSafeArea, playerSafeArea * 2, playerSafeArea * 2) and
        not obj.impenetrable then
            table.insert(thoseToRemove, index)
        end
    end
    for loops, index in ipairs(thoseToRemove) do
        table.remove(Objects, index - (loops - 1))
    end

    GetThreadData()

    if Weather.currentType ~= "foggy" then
        SpawnTurrets(playerSafeArea)
    end

    SpawnCheckpoints()
    if Dialogue.list[25].done or true then SpawnShrines() end
    SpawnEnemies()
    SpawnBubs()
    GenerateBG()

    SendThreadData()
    CancelNextThreadSupply = true

    StartWeather()
end
function GetObjectTypeFromPerlinNoise(x, y)
    local totalObjectTypes = 0; for _, _ in pairs(ObjectTypeData) do totalObjectTypes = totalObjectTypes + 1 end
    local xyDivisor = 13000
    local noiseValue = zutil.clamp(love.math.noise(x / xyDivisor, y / xyDivisor) + zutil.jitter(0.1), 0, 1)

    for index, value in ipairs(ObjectGenerationPaletteAsNoiseConstraints) do
        local lastobj = ObjectGenerationPaletteAsNoiseConstraints[index-1]
        local lastMax = (lastobj and lastobj.max or 0)
        if noiseValue >= lastMax and noiseValue <= value.max then
            return value.type
        end
    end
end
function SmashObject(obj)
    for _ = 1, 60 do
        local degrees = math.random(360)
        local radius = math.random() * 10 + 2
        local speed = math.random() * 7 + 4
        local decay = math.random(160, 300)
        table.insert(Particles, NewParticle(obj.x+obj.width/2, obj.y+obj.height/2, radius, {1,1,1,math.random()/2+.5}, speed, degrees, 0.01, decay,
        function (self)
            if self.speed > 0 then
                self.speed = self.speed - 0.02 * GlobalDT
                if self.speed <= 0 then
                    self.speed = 0
                end
            end
        end))
    end

    lume.remove(Objects, obj)
end
function DiscoverAndRenderDiscoverables()
    if NextLevelAnimation.running then return end

    for _, obj in ipairs(Objects) do
        love.graphics.push()
        InitialiseRegularCoordinateAlterations()
        local objX, objY = love.graphics.transformPoint(obj.x, obj.y)
        love.graphics.pop()

        love.graphics.push()
        if love.keyboard.isDown("lshift") then ApplyCamLookAhead() end
        local screenX, screenY = love.graphics.inverseTransformPoint(0, 0)
        love.graphics.pop()

        if zutil.touching(objX, objY, obj.width, obj.height, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
            obj.discovered = true
            obj.render = true
        else
            obj.render = false
        end

        obj.withinRenderDistance = zutil.distance(obj.x+obj.width/2, obj.y+obj.height/2, Player.centerX, Player.centerY) <= Player.renderDistance
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

        if zutil.touching(turretX, turretY, TurretGlobalData.headRadius*2, TurretGlobalData.headRadius*2, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
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

        if zutil.touching(turretX, turretY, enemy.width, enemy.width, screenX, screenY, love.graphics.getWidth(), love.graphics.getHeight()) then
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

        ObjectGlobalData.scaleFactor.current = ObjectGlobalData.scaleFactor.find()

        if Level >= 10 then
            Weather.currentType = lume.weightedchoice(WeatherPalette)
            Weather.strength = math.random()
        else
            Weather.currentType = "clear"
        end

        zutil.playsfx(SFX.nextLevel, .4, 1)
        CorrectBoundaryHeight()
        CorrectEnemyDensity()
        CorrectTurretDensity()
        GenerateObjects()
        LoadPlayer()
        ApplyShrineEffects()
        ApplyUpgrades()

        NextLevelAnimation.running = true

        if Descending.doingSo then
            Descending.doingSo = false
            Descending.music:stop()
            if Settings.musicOn then Music:play() end
            zutil.playsfx(SFX.descended, 0.5, 1)
        end

        if Settings.musicOn and not Music:isPlaying() then
            Music:play()
        end

        SFX.rainy:stop()
        SFX.windy:stop()
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

        if Level >= UpgradeData.startGettingUpgradesOnLevel and Level % UpgradeData.upgradeInterval == 0 then
            OpenUpgradeMenu()
        else
            zutil.playsfx(SFX.playerSpawn, 0.5, 1)
        end
    end
end
function ApplyNextLevelAnimation()
    if not NextLevelAnimation.running then return end

    local ratio = NextLevelAnimation.current / NextLevelAnimation.max
    local yOff = zutil.lerp(Boundary.y, Player.y, zutil.easeInOutCubic(ratio))

    love.graphics.translate(0, -yOff)
end
function FinalLevelReached()
    GameState = "complete"
    zutil.playsfx(SFX.complete, 0.4, 1)
    GameCompleteFlash = 1

    if BestGameCompletionTime == nil or TotalTime > BestGameCompletionTime then
        BestGameCompletionTime = TotalTime
    end

    Level = 1
    CorrectBoundaryHeight()
    LoadPlayer()
    SaveData()
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

                zutil.playsfx(SFX.hooligmanDialogue, 0.6, math.random()/2+.7)
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
    local y = Player.y + zutil.easeInOutCubic(zutil.reverseLerp(0, Descending.hooligmanCutscene.intro.max, Descending.hooligmanCutscene.intro.current)) * 1000 - Descending.hooligmanCutscene.hooligman.width - 1300
    local width = Descending.hooligmanCutscene.hooligman.width

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", x, y, width, width)


    local multiply = width / 6
    local angle = zutil.angleBetween(x + width / 2, y + width / 2, Player.centerX, Player.centerY)
    local eyeX, eyeY = x + width / 2 + math.sin(angle) * multiply + zutil.jitter(1), y + width / 2 + math.cos(angle) * multiply + zutil.jitter(1)
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
    if Weather.currentType == "rainy" and math.random() > 1 - Weather.strength / 2 then return end
    if not Player.draw then return end

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

    local levelDisplay = Level

    love.graphics.print("Next upgrade: LVL " .. nextUpgrade, Fonts.levelNumber:getWidth(levelDisplay) + generalPadding * 2, generalPadding + 32)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.levelNumber)
    love.graphics.print(levelDisplay, generalPadding, generalPadding)

    -- self destruct button
    local divisor = 3
    love.graphics.setColor(1,0,0, Player.selfDestruct.current / Player.selfDestruct.max / divisor + 1/divisor)
    love.graphics.setFont(Fonts.medium)
    love.graphics.printf("[B] TO SELF-DESTRUCT", 0, love.graphics.getHeight() - love.graphics.getFont():getHeight() - generalPadding, love.graphics.getWidth() - generalPadding, "right")

    -- distance to goal, temperature
    love.graphics.setColor(0,1,0)

    local text = ""
    if AnalyticsUpgrades["misc display"] then
        local weatherClasses = { "A", "B", "C", "D" }
        local weatherClass
        local increment = 1 / #weatherClasses
        local index = #weatherClasses
        for i = 1 - increment, 0, -increment do
            if Weather.strength >= i then
                weatherClass = weatherClasses[index]
                break
            end
            index = index - 1
        end

        love.graphics.setFont(Fonts.normal)
        text = text .. math.floor(ToMeters(Boundary.height - math.abs(Player.y))) .. " / " .. ToMeters(Boundary.height) ..
        " m | checkpoint at: " .. (Player.checkpoint.y and math.floor(ToMeters(math.abs(Boundary.height - Player.checkpoint.y))) or "nil") ..
        " | temperature: " .. math.floor(Player.temperature.current / Player.temperature.max * 100) .. "%" ..
        " | weather: " .. Weather.currentType .. (Weather.currentType ~= "clear" and ", Class " .. weatherClass or "")

        -- meter scale
        local limit = 1
        local spacingFromBottom = 50
        local spacingFromSide = 50
        local halfNotchWidth = 8
        local function lilLine(i)
            local y = love.graphics.getHeight() / 2 + ToPixels(i)
            love.graphics.line(spacingFromBottom - halfNotchWidth, y, spacingFromBottom + halfNotchWidth, y)
        end

        love.graphics.setColor(0,1,0,0.5)
        love.graphics.setLineWidth(1)
        love.graphics.line(spacingFromSide, love.graphics.getHeight() / 2 - ToPixels(limit), spacingFromSide, love.graphics.getHeight() / 2 + ToPixels(limit))

        lilLine(0)
        for i = 1, limit do
            lilLine(i)
            lilLine(-i)
        end
    end

    text = text .. "\ntotal time: " .. TimeInSecondsToStupidFuckingHumanFormat(TotalTime + TimeOnThisLevel)

    love.graphics.setColor(0,1,0)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(text, 0, generalPadding, love.graphics.getWidth() - generalPadding * 2, "center")

    -- x location on map
    local x = zutil.reverseLerp(Boundary.x, Boundary.x + Boundary.width, Player.x) * love.graphics.getWidth()
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
    local angle = zutil.angleBetween(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY())
    local distance = -zutil.distance(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY())

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
        zutil.lerp(CamLookAhead.easing.origin.x, CamLookAhead.easing.dest.x, zutil.easeOutQuint(ratio)), zutil.lerp(CamLookAhead.easing.origin.y, CamLookAhead.easing.dest.y, zutil.easeOutQuint(ratio))
    end
end
function ApplyCamLookAhead()
    love.graphics.translate(CamLookAhead.xOff, CamLookAhead.yOff)
end

function SpawnCheckpoints()
    Checkpoints = {}
    for _ = 1, ObjectGlobalData.checkpointDensity * Boundary.width * Boundary.height do
        local x, y = math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height)
        NewCheckpoint(x, y)

        for _, obj in ipairs(Objects) do
            if zutil.touching(x, y, 0, 0, obj.x, obj.y, obj.width, obj.height) then
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

        local fillMode = ((checkpoint.x == Player.checkpoint.x and checkpoint.y == Player.checkpoint.y) and "fill" or "line")
        if Weather.currentType == "rainy" then
            local isPlaying = false
            for _, sfx in ipairs(SFX.checkpointFizzleOut) do
                if sfx:isPlaying() then isPlaying = true; break end
            end

            if isPlaying then
                fillMode = (math.random() < .2 and "fill" or "line")
            end
        end

        love.graphics.circle(fillMode, checkpoint.x +math.random()-math.random(), checkpoint.y +math.random()-math.random(), CheckpointGlobalData.radius)

        if Weather.currentType ~= "rainy" then
            for _ = 1, 10 do -- random characters around the checkpoint
                local d = math.random(360)
                local multiply = math.random(11, 20) / 10
                local x, y = math.sin(math.rad(d)) * CheckpointGlobalData.radius * multiply + checkpoint.x, math.cos(math.rad(d)) * CheckpointGlobalData.radius * multiply + checkpoint.y
                local charindex = math.random(#characters)
                love.graphics.print(string.sub(characters, charindex, charindex), x, y)
            end
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
        if zutil.touching(x, y, ShrineGlobalData.width, ShrineGlobalData.width, obj.x, obj.y, obj.width, obj.height) then
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

        if AnalyticsUpgrades["signal radar"] and zutil.distance(Player.centerX, Player.centerY, shrine.x, shrine.y) <= ShrineGlobalData.maxHintDistance then
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
        if zutil.touching(shrine.x, shrine.y, ShrineGlobalData.width, ShrineGlobalData.width, Player.x, Player.y, Player.width, Player.height) then
            zutil.playsfx(SFX.shrine, 0.6, math.random()/10+.95)

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

function UpdateSaveInterval()
    if Zen.doingSo then return end

    SaveInterval.current = SaveInterval.current + 1 * GlobalDT
    if SaveInterval.current >= SaveInterval.max then
        SaveInterval.current = 0
        SaveData()
    end
end

function DrawBG()
    for _, element in ipairs(BG) do
        if zutil.distance(Player.centerX, Player.centerY, element.x, element.y) <= Player.renderDistance then
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
    if Zen.doingSo then
        love.graphics.scale(Zen.zoom)
        love.graphics.translate(love.graphics.getWidth() / Zen.zoom / 2, love.graphics.getHeight() / Zen.zoom / 2)
        love.graphics.translate(-Zen.camera.x, -Zen.camera.y)
    else
        local zoom = CalculateZoom()
        local lookAheadX, lookAheadY = ConvertPlayerVelocityToCameraLookAhead()
        love.graphics.scale(zoom)
        love.graphics.translate(love.graphics.getWidth() / zoom / 2 + lookAheadX, love.graphics.getHeight() / zoom / 2 + lookAheadY)

        love.graphics.rotate(ConvertPlayerVelocityToCameraRotation())

        if not NextLevelAnimation.running then
            love.graphics.translate(-Player.x - Player.width / 2, -Player.y - Player.height / 2)
        end
    end
end

function DrawPausedOverlay()
    if Paused or (SlowMo.running and (SlowMo.toPause or SlowMo.toUnpause)) then
        local alpha = 0.2
        local multiplier = zutil.easeInOutCubic((SlowMo.running and (SlowMo.slowingDown and SlowMo.current or SlowMo.max - SlowMo.current) / SlowMo.max or 1))
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
        love.graphics.draw(Sprites.cross, position.x - Sprites.cross:getWidth() / 2 + zutil.jitter(3), position.y - Sprites.cross:getHeight() / 2 + zutil.jitter(3))
    end
end

function InitialiseMenuButtons()
    local width = love.graphics.getWidth() - 200
    local CENTERX, CENTERY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

    local x = 100

    -- main menu
    NewButton("Begin", x, CENTERY + 100, width, 80, "left", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.big, 2, 10,10, function (self)
        GameState = "game"
        MenuAnimation.overlay = 1
        TurnOffZen()
        LoadData()
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Zen", x, CENTERY + 200, width, 40, "left", {.4,.4,.4}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "game"
        MenuAnimation.overlay = 1
        StartZen()
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Settings", x, CENTERY + 250, width, 60, "left", {.4,.4,.4}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 0, 10,10, function (self)
        GameState = "settings"
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Changelog", x, CENTERY + 320, width, 40, "left", {.4,.4,.4}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 0, 10,10, function (self)
        GameState = "changelog"
    end, nil, function (self)
        return GameState == "menu"
    end)
    NewButton("Quit", x, CENTERY + 370, width, 40, "left", {.3,0,0}, {.1,0,0}, {.1,0,0}, {1,0,0}, Fonts.medium, 0, 10,10, function (self)
        love.event.quit()
    end, nil, function (self)
        return GameState == "menu"
    end)

    -- settings
    width = 800
    NewButton("music", CENTERX - width / 2, CENTERY - 200, width, 60, "center", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
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
    NewButton("camera rotation", CENTERX - width / 2, CENTERY - 100, width, 60, "center", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        Settings.cameraRotationOn = not Settings.cameraRotationOn
        SaveData()
    end, function (self)
        self.text = "Camera rotation: " .. (Settings.cameraRotationOn and "On" or "Off")
        self.textColor = (Settings.cameraRotationOn and {0,1,0} or {1,0,0})
        self.lineColor = self.textColor
    end, function (self)
        return GameState == "settings"
    end)
    NewButton("weather darkening", CENTERX - width / 2, CENTERY - 00, width, 60, "center", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        Settings.weatherDarkening = not Settings.weatherDarkening
        SaveData()
    end, function (self)
        self.text = "Weather darkening: " .. (Settings.weatherDarkening and "On" or "Off")
        self.textColor = (Settings.weatherDarkening and {0,1,0} or {1,0,0})
        self.lineColor = self.textColor
    end, function (self)
        return GameState == "settings"
    end)
    NewButton("graphics", CENTERX - width / 2, CENTERY + 100, width, 60, "center", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
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

    width = 200
    NewButton("Back", love.graphics.getWidth() - width - 40, love.graphics.getHeight() - 60, width, 40, "right", {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "menu"
    end, nil, function (self)
        return GameState == "settings" or GameState == "changelog"
    end)

    width = 500
    NewButton("Reset Current Run", CENTERX - width / 2, CENTERY + 400, width, 60, "center", {1,0,0}, {0,0,0}, {.1,.1,.1}, {1,0,0}, Fonts.medium, 2, 10,10, function (self)
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
            zutil.playsfx(SFX.resetRun, 0.1, 1)
            ResetGame()
            CorrectBoundaryHeight()
            LoadPlayer()
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
    TimeMultiplier = zutil.easeInOutCubic((SlowMo.slowingDown and SlowMo.max - SlowMo.current or SlowMo.current) / SlowMo.max)
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
        function () -- stronger jump-pads
            ObjectGlobalData.jumpPlatformStrength = 50
        end,
        function () -- vault higher
            Player.divisorWhenConvertingXToYVelocity = 1.7
        end,
        function () -- water-proof checkpoints
            Player.waterProofCheckpoints = true
        end,
        function () -- faster super jump charging
            Player.superJump.increase = 1.4
        end,
        function () -- better traction
            Player.groundFriction = 1.3
        end,
        function () -- better cooling
            Player.passiveCooling = 0.7
        end,
        function () -- vault higher ii
            Player.divisorWhenConvertingXToYVelocity = 1.3
        end,
        function () -- better traction ii
            Player.groundFriction = 1.7
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
                "water-proof checkpoints",
                "faster super jump charging",
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
                "signal radar ii",
            }
        },
    }

    for _, value in ipairs(Upgrades[3].list) do
        AnalyticsUpgrades[value] = false
    end

    local width = 400
    for index = 1, #Upgrades do
        NewButton("Commit", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() / 2 + UpgradeData.spacingOnMenu * (index - (#Upgrades+1)/2) + 50, width, 40, "center", {0,0,0}, {0,0,0}, {.2,.2,.2}, {1,1,1},
        Fonts.normal, 0, 10, 10, function (self)
            local listOfCategories = {}
            for _, value in ipairs(Upgrades) do
                table.insert(listOfCategories, value.name)
            end

            PlayerUpgrades[listOfCategories[index]] = PlayerUpgrades[listOfCategories[index]] + 1
            UpgradeData.picked = true

            ApplyUpgrades()
            SaveData()

            zutil.playsfx(SFX.upgrade, 0.4, 1)
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

    NewButton("Continue", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - 80, width, 40, "center", {0,1,0}, {0,0,0}, {.2,.2,.2}, {0,1,0}, Fonts.normal, 2, 10, 10, function (self)
        UpgradeData.picked, UpgradeData.picking = false, false
        zutil.playsfx(SFX.playerSpawn, 0.5, 1)
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
    ShakeIntensity = 0
    UpgradeData.picking = true
    zutil.playsfx(SFX.upgradeMenu, 0.7, 1)
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
        local text = string.upper(category) .. ": " .. string.upper(((level and PlayerUpgrades[category] < #Upgrades[index].list) and level .. " unlocked" or "not upgraded"))

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
        love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + UpgradeData.spacingOnMenu * (index - (#Upgrades+1)/2) + 30, Fonts.normal, {.7,.7,.7}, {0,0,0})
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
    if not CommandLine.verified then
        if love.data.encode("string", "hex", love.data.hash("sha512", CommandLine.text)) == "b59b33b84b8326aa576b78cb689e5fc288b3d1c0ced2a23bb9ccff0aa0c99a20e43c9126d6d371a92ca87dc4c110eebdeb3e2e9457a1793fa15c0a4b12d197d7" then
            CommandLine.text = ""
            table.insert(CommandLine.history, "VERIFIED. Welcome, Frazy.")
            CommandLine.verified = true
        else
            CommandLine.text = ""
            table.insert(CommandLine.history, "WRONG.")
        end
    elseif CommandLine.verified then
        table.insert(CommandLine.history, CommandLine.text)

        if CommandLine.text == "LOG OUT" then
            CommandLine.verified = false
            CommandLine.history = {CommandLine.history[1]}
        else
            lume.dostring(CommandLine.text)
        end

        CommandLine.text = ""
    end
end
function Print(text)
    table.insert(CommandLine.history, "> " .. text)
end
function DEBUG()
    Enemies = {}
    Turrets = {}
end

function DrawDebug()
    if not Debug then return end

    local enemiesRendered = 0
    for _, enemy in ipairs(Enemies) do
        if zutil.distance(Player.centerX, Player.centerY, enemy.x + enemy.width / 2, enemy.y + enemy.width / 2) <= Player.renderDistance then
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
        if zutil.distance(Player.centerX, Player.centerY, turret.x, turret.y) <= Player.renderDistance then
            turretsRendered = turretsRendered + 1
        end
    end

    love.graphics.setColor(0,1,0)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(
        "Hooligans " .. enemiesRendered ..
        "\nObjs " .. objsRendered ..
        "\nTurrets " .. turretsRendered ..
        "\nParticles " .. #Particles ..
        "\nAvg DT ms: " .. math.floor(love.timer.getAverageDelta() * 100 * 1000) / 100,

        5, 200, love.graphics.getWidth(), "left"
    )
end

function UpdateMovables()
    UpdateTurrets()
    UpdateEnemies()
    UpdateFlutters()
    CheckCollisionWithCheckpointsAndUpdateCloseToCheckpointStatus()
end
function GetThreadData()
    local dataTurrets = love.thread.getChannel("turrets"):pop()
    if dataTurrets then
        for index, data in ipairs(dataTurrets) do
            if Turrets[index] then Turrets[index].render = data.render end
        end
    end

    local dataEnemies = love.thread.getChannel("enemies"):pop()
    if dataEnemies then
        for index, data in ipairs(dataEnemies) do
            if Enemies[index] then Enemies[index].render = data.render end
        end
    end

    local dataFlutters = love.thread.getChannel("flutters"):pop()
    if dataFlutters then
        for index, data in ipairs(dataFlutters) do
            if Flutters[index] then Flutters[index].render = data.render end
        end
    end
end
function SendThreadData()
    if CancelNextThreadSupply then
        CancelNextThreadSupply = false
        return
    end

    love.thread.getChannel("turrets to thread"):push(Turrets)
    love.thread.getChannel("player"):push(Player)

    love.thread.getChannel("enemies to thread"):push(Enemies)
    love.thread.getChannel("player"):push(Player)

    love.thread.getChannel("flutters to thread"):push(Flutters)
    love.thread.getChannel("player"):push(Player)
end

function StartZen()
    Zen.doingSo = true
    GenerateObjects()
    Zen.camera.x = Boundary.x + Boundary.width / 2 - love.graphics.getWidth() / 2
    Zen.camera.y = Boundary.y + Boundary.height / 2 - love.graphics.getHeight() / 2
    Player.invisible = true
    Player.draw = false
    Minimap.showing = false
    Music:pause()
end
function TurnOffZen()
    Zen.doingSo = false
    Player.invisible = false
    Player.draw = true

    if Settings.musicOn then
        Music:play()
    end
end