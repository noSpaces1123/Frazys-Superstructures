function SaveData()
    if Zen.doingSo then return end

    local dialogueDone = {}
    for _, dia in ipairs(Dialogue.list) do
        table.insert(dialogueDone, dia.done == true)
    end

    local data = {
        bubs = Bubs, objects = Objects, turrets = Turrets, checkpoints = Checkpoints, shrines = Shrines, dead = Player.respawnWait.dead, checkpoint = { x = Player.checkpoint.x, y = Player.checkpoint.y },
        level = Level, player = { x = Player.x, y = Player.y, xvelocity = Player.xvelocity, yvelocity = Player.yvelocity, temperature = Player.temperature, superJump = Player.superJump },
        playerSkill = { turretsDestroyed = PlayerSkill.turretsDestroyed, deaths = PlayerSkill.deaths, greatestBulletPresence = PlayerSkill.greatestBulletPresence, enemiesKilled = PlayerSkill.enemiesKilled },
        wayPoints = WayPoints, playerPerks = PlayerPerks, timeOnThisLevel = TimeOnThisLevel, dialogueDone = dialogueDone, totalTime = TotalTime, deathPositions = DeathPositions,
        enemies = Enemies, bestGameCompletionTime = BestGameCompletionTime, settings = Settings, playerCanMove = PlayerCanMove, descensionLevels = Descending.onLevels, playerUpgrades = PlayerUpgrades,
        weatherType = Weather.currentType, weatherStrength = Weather.strength, weatherWindEvent = Weather.windEvents, plinks = Plinks, descending = Descending.doingSo, gnatClouds = GnatClouds,
        flutters = Flutters
    }

    love.filesystem.write("data.csv", lume.serialize(data))
end

function LoadData()
    if not love.filesystem.getInfo("data.csv") or love.filesystem.read("data.csv") == nil then
        return
    end

    local data = lume.deserialize(love.filesystem.read("data.csv"))

    LoadPlayer()
    ResetPlayerData()

    Bubs = (data.bubs and data.bubs or {})
    Objects = (data.objects and data.objects or {})
    Turrets = (data.turrets and data.turrets or {})
    Checkpoints = (data.checkpoints and data.checkpoints or {})
    WayPoints = (data.wayPoints and data.wayPoints or {})
    Shrines = (data.shrines and data.shrines or {})
    Level = (data.level and data.level or 1)
    TimeOnThisLevel = (data.timeOnThisLevel and data.timeOnThisLevel or 0)
    TotalTime = (data.totalTime and data.totalTime or 0)
    BestGameCompletionTime = (data.bestGameCompletionTime and data.bestGameCompletionTime or nil)
    DeathPositions = (data.deathPositions and data.deathPositions or {})
    Enemies = (data.enemies and data.enemies or {})
    Weather.currentType = (data.weatherType and data.weatherType or "clear")
    Weather.strength = (data.weatherStrength and data.weatherStrength or math.random())
    Descending.onLevels = (data.descensionLevels and data.descensionLevels or PickDescensionLevels())
    Plinks = (data.plinks and data.plinks or 0)
    Descending.doingSo = (data.descending and data.descending or false)
    GnatClouds = (data.gnatClouds and data.gnatClouds or {})
    Flutters = (data.flutters and data.flutters or {})

    if data.playerUpgrades then
        PlayerUpgrades = data.playerUpgrades
    end

    if data.playerPerks then
        PlayerPerks = data.playerPerks
    end

    if data.weatherWindEvent then
        Weather.windEvents = data.weatherWindEvent
    end

    PlayerCanMove = (data.playerCanMove == nil and true or data.playerCanMove)

    if data.dialogueDone then
        for index, value in ipairs(data.dialogueDone) do
            Dialogue.list[index].done = value
        end
    end

    if data.checkpoint then
        Player.checkpoint.x = data.checkpoint.x
        Player.checkpoint.y = data.checkpoint.y
    end

    if data.dead then
        RespawnPlayer()
    else
        for key, value in pairs(data.player) do
            Player[key] = value
        end
    end

    if data.playerSkill ~= nil then
        for key, value in pairs(data.playerSkill) do
            PlayerSkill[key] = value
        end
    end

    if data.settings ~= nil then
        for key, value in pairs(data.settings) do
            Settings[key] = value
        end
    end

    CorrectBoundaryHeight()
    CorrectTurretDensity()
    CorrectEnemyDensity()
    ApplyUpgrades()

    ApplyShrineEffects()
end