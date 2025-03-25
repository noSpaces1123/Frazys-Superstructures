function love.load()
    lume = require "lume"
    require "player"
    require "particle"
    require "data_management"
    require "button"
    require "enemy"

    love.window.setMode(100, 200, {highdpi=true})
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
        warble = {
            love.audio.newSource("assets/sfx/warble.wav", "static"),
            love.audio.newSource("assets/sfx/warble2.wav", "static"),
        },
        enemySpeak = {
            love.audio.newSource("assets/sfx/enemy speak.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak2.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak3.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak4.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak5.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak6.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak7.wav", "static"),
            love.audio.newSource("assets/sfx/enemy speak8.wav", "static"),
        },
    }

    Sprites = {
        cross = love.graphics.newImage("assets/sprites/cross.png", {dpiscale=10}),
    }

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
        reduceParticles = false,
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

    TurretGenerationPalette = { normal = 20, laser = 4, drag = 2 }
    ObjectGenerationPalette = { normal = 20, icy = 9, death = 4, jump = 6 }
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

    Messages = {}

    TimeOnThisLevel = 0
    TotalTime = 0
    BestGameCompletionTime = nil

    FinalLevel = 50

    Descending = {
        onLevels = { math.floor(FinalLevel / 2), FinalLevel },
        doingSo = false,
        hooligmanCutscene = {
            running = false,
            text = "Hey! I'm the HOOLIGMAN! I'm displeased with your scrawny endeavors. The only way to escape is to reach the bottom of the level, but you won't live to see it! Hooligans, GET HIM!!!",
            index = 1,
            intro = { current = 0, max = 400 },
            playing = {
                text = "", targetText = nil,
                charInterval = { current = 0, max = 2, defaultMax = 2,
                    maxOn = { { char = ".", max = 20 }, { char = ",", max = 10 }, { char = "!", max = 20 }, { char = "?", max = 30 }, { char = "-", max = 40 } } },
                charIndex = 1,
                finished = false,
                postWait = { current = 0, max = 200 },
                running = false,
            },
            hooligman = {
                width = 1000,
            }
        },
    }

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
                text = "Victor at HQ will be happy to see the progress.",
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
                text = "Intel said I've got a special ability I can use with [Q], as long as I have enough charge in the top left.",
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
                text = "Victor said I only need to reach level 50 to get enough info and head home.",
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
                    return Level >= 15 and Player.y <= Boundary.y + Boundary.height / 2
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
                text = "All the intel under ten minutes, done. Once a boy- now a man.",
                when = function ()
                    return BestGameCompletionTime ~= nil and BestGameCompletionTime < 10 * 60
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
        },
        eventual = {
            killEnemy = {
                "Nice.",
                "Take that.",
                "Eat it.",
                "Ha-ha!",
                "Idiot.",
                "Oh yeah.",
            },
        },
    }

    DeathPositions = {}

    Enemies = {}

    if love.filesystem.getInfo("data.csv") then
        LoadData()
    else
        LoadPlayer()
        ResetPlayerData()
    end

    if Settings.musicOn then Music:play() end

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

    Buttons = {}
    InitialiseButtons()

    Paused = false

    KeyBuffer = {}

    MenuAnimation = { x = 0, overlay = 0, objectIntro = 0 }

    GameState = "menu"

    Version = "1.0"

    GlobalDT = 0
end

function love.update(dt)
    GlobalDT = dt * 60

    if GameState == "game" then
        UpdatePlayer()
        UpdateShakeIntensity()
        UpdateDangerPulseProgression()
        UpdateCamLookAhead()
        ExtendView()

        UpdateNextLevelAnimation()

        if not Paused then
            TimeOnThisLevel = TimeOnThisLevel + dt

            UpdateParticles()
            UpdateTurrets()
            UpdateBullets()
            UpdateShrines()
            UpdateMessages()
            UpdateEnemies()
            UpdateDialogue()
            UpdateHooligmanCutscene()
            UpdateHooligmanDialogue()
        end

        --CheckForOddities()

        UpdateSaveInterval()
    else
        UpdateTurrets()
        UpdateButtons()
    end

    if GameCompleteFlash > 0 then
        GameCompleteFlash = GameCompleteFlash - 0.005 * GlobalDT
        if GameCompleteFlash < 0 then
            GameCompleteFlash = 0
        end
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

            DisplayTurretInfo()

            DrawPlayer()

            DrawMessages()

            DrawCursorReadings()
            DrawDialogue()

            DrawHooligmanDialogue()

            love.graphics.pop()

            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 60)

            DrawDisplays()
            DrawPlayerSuperJumpBar()

            DrawHeatIndicator()

            DrawPausedOverlay()
        end
    elseif GameState == "menu" or GameState == "complete" or GameState == "settings" then
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
        love.graphics.setColor(0,0,0, 0.4)
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
        if Distance(obj.x + obj.width / 2, obj.y + obj.height / 2, Player.x, Player.y) > Player.renderDistance and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end

        love.graphics.setColor(.7,.7,.7, 1)
        love.graphics.setLineWidth(ObjectGlobalData.strokeWidth)
        love.graphics.rectangle("line", obj.x, obj.y, obj.width, obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

        ::continue::
    end
    for _, obj in ipairs(Objects) do
        local outsideRenderDistance = Distance(obj.x + obj.width / 2, obj.y + obj.height / 2, Player.x, Player.y) > Player.renderDistance
        if outsideRenderDistance and not Minimap.showing and not obj.impenetrable and GameState == "game" then goto continue end
        if (GameState == "menu" or GameState == "settings") and obj.y <= Lerp(Boundary.y, Boundary.y + Boundary.height, 1 - MenuAnimation.objectIntro) then goto continue end

        if outsideRenderDistance and Minimap.showing then
            love.graphics.setColor(0,0,0,1)
        elseif obj.type == "icy" then
            love.graphics.setColor(.3,1,1, 1)
        elseif obj.type == "death" then
            love.graphics.setColor(1,.5,0, 1)
        elseif obj.type == "jump" then
            love.graphics.setColor(0,1,0, 1)
        else
            love.graphics.setColor(1,1,1, 1)
        end
        love.graphics.rectangle("fill", obj.x, obj.y, obj.width, obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

        if obj.dangerPulse then
            local ratioUWU = ObjectGlobalData.dangerPulseProgression.current / ObjectGlobalData.dangerPulseProgression.max
            local alpha = ratioUWU
            love.graphics.setColor(1, 0, 0, alpha)
            love.graphics.rectangle("fill", obj.x, obj.y + (1 - ratioUWU) * obj.height, obj.width, ratioUWU * obj.height, ObjectGlobalData.cornerRadius, ObjectGlobalData.cornerRadius)

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
        local width, height = math.random(400, 1100), math.random(100, 300)
        if math.random() < .05 then
            local movingWidth = width
            width = height
            height = movingWidth
        end

        table.insert(Objects, {
            x = math.random(Boundary.x, Boundary.x + Boundary.width), y = math.random(Boundary.y, Boundary.y + Boundary.height),
            width = width, height = height,
        })
    end

    -- apply object clusters types
    math.randomseed(Seed)
    for objIndex, obj in ipairs(Objects) do
        local objectType = lume.weightedchoice(ObjectGenerationPalette)
        obj.type = objectType

        for obj2Index, obj2 in ipairs(Objects) do
            if obj2Index ~= objIndex and (obj2.type == nil or obj.type == "normal") and Touching(obj.x, obj.y, obj.width, obj.height, obj2.x, obj2.y, obj2.width, obj2.height) then
                obj2.type = objectType
            end
        end
    end

    for _, obj in ipairs(Objects) do
        if obj.impenetrable or obj.groundZero then
            obj.type = "normal"
        end
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

function NextLevel()
    TotalTime = TotalTime + TimeOnThisLevel
    TimeOnThisLevel = 0

    if Level >= FinalLevel then
        FinalLevelReached()
    elseif CheckIfDescending() then
        PlayHooligmanCutscene()
        Descending.doingSo = true
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
    end
end
function CorrectBoundaryHeight()
    Boundary.height = Boundary.baseHeight + math.floor(Level / 10) * Boundary.heightIncrement
end
function CorrectTurretDensity()
    ObjectGlobalData.turretDensity = ObjectGlobalData.baseTurretDensity + (Level - 1) * 0.00000002
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

        PlaySFX(SFX.playerSpawn, 0.5, 1)
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

    ResetGame()
end
function CheckIfDescending()
    for _, on in ipairs(Descending.onLevels) do
        if on == Level then return true end
    end
    return false
end

function PlayHooligmanCutscene()
    Descending.hooligmanCutscene.running = true
    Descending.hooligmanCutscene.intro.current = 0
end
function UpdateHooligmanCutscene()
    if not Descending.hooligmanCutscene.running then return end

    if Descending.hooligmanCutscene.intro >= Descending.hooligmanCutscene.intro.max then
        PlayHooligmanDialogue(Descending.hooligmanCutscene.text)
    else
        Descending.hooligmanCutscene.intro.current = Descending.hooligmanCutscene.intro.current + 1 * GlobalDT
    end

    if not Descending.hooligmanCutscene.playing.running then
        Descending.hooligmanCutscene.running = false
        Descending.doingSo = true
    end
end
function UpdateHooligmanDialogue()
    if Descending.hooligmanCutscene.dialogue.playing.running then
        if Descending.hooligmanCutscene.dialogue.playing.finished then
            Descending.hooligmanCutscene.dialogue.playing.text = string.sub(Descending.hooligmanCutscene.dialogue.playing.text, 1, #Descending.hooligmanCutscene.dialogue.playing.text - 1)
            if #Descending.hooligmanCutscene.dialogue.playing.text == 0 then
                Descending.hooligmanCutscene.dialogue.playing.running = false
            end
        elseif Descending.hooligmanCutscene.dialogue.playing.charIndex > #Descending.hooligmanCutscene.dialogue.playing.targetText then
            Descending.hooligmanCutscene.dialogue.playing.postWait.current = Descending.hooligmanCutscene.dialogue.playing.postWait.current + 1 * GlobalDT
            if Descending.hooligmanCutscene.dialogue.playing.postWait.current >= Descending.hooligmanCutscene.dialogue.playing.postWait.max then
                Descending.hooligmanCutscene.dialogue.playing.finished = true
            end
        else
            Descending.hooligmanCutscene.dialogue.playing.charInterval.current = Descending.hooligmanCutscene.dialogue.playing.charInterval.current + 1 * GlobalDT
            if Descending.hooligmanCutscene.dialogue.playing.charInterval.current >= Descending.hooligmanCutscene.dialogue.playing.charInterval.max then
                local charToAdd = string.sub(Descending.hooligmanCutscene.dialogue.playing.targetText, Descending.hooligmanCutscene.dialogue.playing.charIndex, Descending.hooligmanCutscene.dialogue.playing.charIndex)
                Descending.hooligmanCutscene.dialogue.playing.charInterval.current = Descending.hooligmanCutscene.dialogue.playing.charInterval.current - Descending.hooligmanCutscene.dialogue.playing.charInterval.max
                Descending.hooligmanCutscene.dialogue.playing.text = Descending.hooligmanCutscene.dialogue.playing.text .. charToAdd

                local specialChar = false
                for _, char in ipairs(Descending.hooligmanCutscene.dialogue.playing.charInterval.maxOn) do
                    if char.char == charToAdd then
                        Descending.hooligmanCutscene.dialogue.playing.charInterval.max = char.max
                        specialChar = true
                    end
                end
                if not specialChar then Descending.hooligmanCutscene.dialogue.playing.charInterval.max = Descending.hooligmanCutscene.dialogue.playing.charInterval.defaultMax end

                Descending.hooligmanCutscene.dialogue.playing.charIndex = Descending.hooligmanCutscene.dialogue.playing.charIndex + 1

                PlaySFX(SFX.hooligmanDialogue, 0.6, math.random()/2+.7)
            end
        end
    end
end
function PlayHooligmanDialogue(text)
    Descending.hooligmanCutscene.dialogue.playing.text = ""
    Descending.hooligmanCutscene.dialogue.playing.charInterval.current = 0
    Descending.hooligmanCutscene.dialogue.playing.charIndex = 1
    Descending.hooligmanCutscene.dialogue.playing.charInterval.max = Descending.hooligmanCutscene.dialogue.playing.charInterval.defaultMax
    Descending.hooligmanCutscene.dialogue.playing.running = true
    Descending.hooligmanCutscene.dialogue.playing.targetText = text
    Descending.hooligmanCutscene.dialogue.playing.finished = false
    Descending.hooligmanCutscene.dialogue.playing.postWait.current = 0
end
function DrawHooligmanDialogue()
    if not Descending.hooligmanCutscene.dialogue.playing.running then return end
    DrawTextWithBackground(Descending.hooligmanCutscene.dialogue.playing.text, Player.x + Player.width / 2, Player.y - 100, Fonts.dialogue, {0,1,1}, {0,0,0})
end
function DrawHooligman()
    if not Descending.hooligmanCutscene.running then return end

    local x, y = Player.x - Descending.hooligmanCutscene.hooligman.width / 2, -Descending.hooligmanCutscene.intro.current - 300
    local width = Descending.hooligmanCutscene.hooligman.width

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", x, y, width, width)


    local multiply = width / 6
    local angle = AngleBetween(x + width / 2, y + width / 2, Player.x + Player.width / 2, Player.y + Player.height / 2)
    local eyeX, eyeY = x + width / 2 + math.sin(angle) * multiply, y + width / 2 + math.cos(angle) * multiply
    local eyeWidth = width * 0.5

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", eyeX - eyeWidth / 2, eyeY - eyeWidth / 2, eyeWidth, eyeWidth)
end

function DrawLevelGoal()
    love.graphics.setColor(0,1,0)
    love.graphics.setLineWidth(2)

    local lineLength = 3

    for x = Boundary.x, (Boundary.x + Boundary.width), lineLength * 2 do
        love.graphics.line(x, 0, x + lineLength, 0)
    end

    local numberOfLines = 100
    love.graphics.setColor(0,1,0,0.3)
    for i = -1000, love.graphics.getWidth(), love.graphics.getWidth() / numberOfLines do
        local x, _ = love.graphics.inverseTransformPoint(i, 0)
        love.graphics.line(x, 0, x + 2000, -2000)
    end

    DrawTextWithBackground(TimeInSecondsToStupidFuckingHumanFormat(TimeOnThisLevel), (Minimap.showing and Minimap.x or Player.x), Boundary.y - (Minimap.showing and 800 or 400), Fonts.time, {0,1,0}, {0,0,0,0})
    DrawTextWithBackground(TimeInSecondsToStupidFuckingHumanFormat(TotalTime + TimeOnThisLevel) .. " in total", (Minimap.showing and Minimap.x or Player.x), Boundary.y - (Minimap.showing and 1200 or 800), Fonts.smallTime, {0,1,0}, {0,0,0,0})
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
    love.graphics.print("Skill: " .. CalculatePlayerSkill(), Fonts.levelNumber:getWidth(Level) + generalPadding * 2, generalPadding + 26)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.levelNumber)
    love.graphics.print(Level, generalPadding, generalPadding - 17)

    -- distance to goal, temperature
    love.graphics.setColor(0,1,0)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(
        math.floor(ToMeters(math.abs(Player.y))) .. " m | checkpoint at: " .. (Player.checkpoint.y and math.floor(ToMeters(math.abs(Player.checkpoint.y))) .. " m" or "nil") .. " | temperature: " .. math.floor(Player.temperature.current / Player.temperature.max * 100) .. "%",
        0, generalPadding, love.graphics.getWidth() - generalPadding * 2, "center")

    -- x location on map
    local x = ReverseLerp(Boundary.x, Boundary.x + Boundary.width, Player.x) * love.graphics.getWidth()
    love.graphics.setLineWidth(7)
    love.graphics.line(x, 38, x, 50)
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
        local distance = Distance(turret.x, turret.y, Player.x + Player.width / 2, Player.y + Player.height / 2)

        local before = turret.seesPlayer
        turret.seesPlayer = distance <= turret.viewRadius

        if distance > Player.renderDistance and GameState == "game" then goto continue end

        if not Player.respawnWait.dead and turret.seesPlayer and not NextLevelAnimation.running and GameState == "game" then
            if not before and turret.seesPlayer then
                PlaySFX(SFX.seesPlayer, 0.2, turret.fireRate.max / TurretGlobalData.fireInterval.min + 0.5)
            end

            turret.searchingAngle = math.deg(AngleBetween(turret.x, turret.y, Player.x + Player.width / 2, Player.y + Player.height / 2))
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

            love.graphics.line(turret.x, turret.y, Player.x + Player.width / 2 + (math.random()-math.random()) * 3, Player.y + Player.height / 2 + (math.random()-math.random()) * 3)
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
    ToMeters(Distance(turret.x, turret.y, Player.x + Player.width / 2, Player.y + Player.height / 2)) <= 5 then
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
        NewCheckpoint(math.random(Boundary.x, Boundary.x + Boundary.width), math.random(Boundary.y, Boundary.y + Boundary.height))
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

        if Distance(Player.x + Player.width / 2, Player.y + Player.height / 2, shrine.x, shrine.y) <= ShrineGlobalData.maxHintDistance then
            DrawArrowTowards(shrine.x, shrine.y, color, 0.3)
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
                if Distance(Player.x + Player.width / 2, Player.y + Player.height / 2,
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
            local distanceToPlayer = Distance(Player.x + Player.width / 2, Player.y + Player.height / 2, self.x, self.y)
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
        if Distance(Player.x + Player.width / 2, Player.y + Player.height / 2, element.x, element.y) <= Player.renderDistance then
            love.graphics.setColor(1,1,1, element.alpha)
            love.graphics.circle("fill", element.x, element.y, element.radius)
        end
    end
end
function GenerateBG()
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
    if Paused then
        love.graphics.setColor(0,0,0,0.2)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        DrawTextWithBackground("Paused.", love.graphics.getWidth()/2, love.graphics.getHeight() - 200, Fonts.big, {1,1,1}, {0,0,0})

        love.graphics.setFont(Fonts.normal)
        love.graphics.setColor(1,1,1)
        love.graphics.print(Version, 5, love.graphics.getHeight() - Fonts.normal:getHeight() - 5)
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

    -- settings
    width = 800
    NewButton("Music: ", CENTERX - width / 2, CENTERY - 200, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
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
    NewButton("Reduce particles: ", CENTERX - width / 2, CENTERY - 100, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        Settings.reduceParticles = not Settings.reduceParticles
        SaveData()
    end, function (self)
        self.text = "Reduce Particles: " .. (Settings.reduceParticles and "On" or "Off")
        self.textColor = (Settings.reduceParticles and {0,1,0} or {1,0,0})
        self.lineColor = self.textColor
    end, function (self)
        return GameState == "settings"
    end)

    NewButton("Back", CENTERX - width / 2, CENTERY + 300, width, 60, {1,1,1}, {0,0,0}, {.1,.1,.1}, {1,1,1}, Fonts.medium, 2, 10,10, function (self)
        GameState = "menu"
    end, nil, function (self)
        return GameState == "settings"
    end)

    width = 400
    NewButton("Reset Current Run", CENTERX - width / 2, CENTERY + 400, width, 60, {1,0,0}, {0,0,0}, {.1,.1,.1}, {1,0,0}, Fonts.medium, 2, 10,10, function (self)
        if not self.confirmation then
            self.confirmation = 0
            self.text = "Shift-click to confirm."
        elseif self.confirmation == 0 and love.keyboard.isDown("lshift") then
            self.confirmation = self.confirmation + 1
            self.key = lume.randomchoice({"u","i","o","p","k","l"})
            self.text = "Hold Shift & " .. string.upper(self.key) .. " to confirm."
        elseif self.confirmation == 1 and love.keyboard.isDown("lshift") and love.keyboard.isDown(self.key) then
            self.confirmation = nil
            self.text = "Reset Current Run"
            PlaySFX(SFX.resetRun, 0.5, 1)
            ResetGame()
        end
    end, nil, function (self)
        return GameState == "settings"
    end)
end