WeatherPalette = { clear = 8, rainy = 6, hot = 4, foggy = 1 }



function InitialiseWeather()
    Weather = {
        currentType = "clear",
        strength = 0, -- real number from 0 to 1
        windEvents = {
            strength = 1, maxStrength = 0.15,
            duration = 0, maxDuration = 2000,
            current = 0, max = 3000,
        },
        types = {
            -- clear weather has no effects.
            clear = {
                airFrictionAdd = function () return 0 end,
                jumpPadStrengthAdd = function () return 0 end,
                passiveCoolingAdd = function () return 0 end,
                overlay = {0,0,0,0},
            },
            rainy = {
                airFrictionAdd = function () return 0.15 * Weather.strength end,
                jumpPadStrengthAdd = function () return 0 end,
                passiveCoolingAdd = function () return 0.5 * Weather.strength end,
                groundFrictionRandomness = function () return 3 * Weather.strength end,
                overlay = {0,0,.3,.5}, secondOverlay = {0,0,0,.4},
                update = function (self)
                    if not SFX.rainy:isPlaying() then
                        SFX.rainy:setLooping(true)
                        PlaySFX(SFX.rainy, 0.2 * Weather.strength + .02, 1)
                    end

                    for _, obj in ipairs(Objects) do
                        if obj.render and math.random() <= 0.1 * Weather.strength then
                            local x, y = math.random(obj.x, obj.x + obj.width), obj.y
                            for _ = 1, 6, 1 do
                                table.insert(Particles, NewParticle(x, y, math.random() * 2, {1,1,1,math.random()/2+.6}, math.random()*2+.5, math.random(160, 200), 0.06, math.random(100, 160)))
                            end
                        end
                    end

                    if Weather.strength >= 0.5 then
                        Weather.windEvents.current = Weather.windEvents.current + 1 * GlobalDT
                        if Weather.windEvents.current >= Weather.windEvents.max then
                            Weather.windEvents.current = 0
                            Weather.windEvents.strength = lume.randomchoice({ -Weather.windEvents.maxStrength, Weather.windEvents.maxStrength }) * Weather.strength
                            Weather.windEvents.duration = Weather.windEvents.maxDuration * Weather.strength

                            PlaySFX(SFX.wind, 0.4, 1)
                            PlaySFX(SFX.windWarning, 0.2, 1)

                            NewMessage("WIND EVENT " .. (Weather.windEvents.strength > 0 and "EASTWARD" or "WESTWARD"), 0, -50, {1,0,0}, 300, Fonts.medium, nil, true)
                        end

                        if Weather.windEvents.duration > 0 then
                            Weather.windEvents.duration = Weather.windEvents.duration - 1 * GlobalDT

                            if Weather.windEvents.duration <= 0 then
                                PlaySFX(SFX.intel, 0.2, 1)
                                NewMessage("WIND EVENT OVER", 0, -50, {1,0,0}, 300, Fonts.medium, nil, true)
                            end
                        end
                    end
                end,
                start = function (self)
                    for _, obj in ipairs(Objects) do
                        if obj.type == "death" then
                            obj.type = lume.randomchoice({"icy", "normal"})
                        end
                    end
                end
            },
            hot = {
                airFrictionAdd = function () return 0.1 * Weather.strength end,
                jumpPadStrengthAdd = function () return -22 * Weather.strength end,
                passiveCoolingAdd = function () return -0.26 * Weather.strength end,
                overlay = {1,.5,0,.3},
                shaderSinOffset = 0,
                enemySpeedMultiplier = .7,
                shader = love.graphics.newShader([[

extern vec2 screenDimensions;
extern float sinOffset;

vec4 effect(vec4 color, Image image, vec2 texture_coords, vec2 screen_coords) {

    vec2 newCoords = vec2( texture_coords.x + (sin(degrees(texture_coords.y / screenDimensions.y * 360 * 3 + sinOffset))) * 1 / screenDimensions.x, texture_coords.y );

    vec4 pixel = Texel(image, newCoords);

    return pixel * color;
}

                ]]),
                update = function (self)
                    self.shaderSinOffset = self.shaderSinOffset + 0.001 * GlobalDT
                    if self.shaderSinOffset >= 360 then
                        self.shaderSinOffset = self.shaderSinOffset - 360
                    end

                    if not SFX.windy:isPlaying() then
                        SFX.windy:setLooping(true)
                        PlaySFX(SFX.windy, 0.6, 1)
                    end
                end,
                start = function (self)
                    for _, obj in ipairs(Objects) do
                        if obj.type == "icy" then
                            obj.type = lume.randomchoice({"death", "normal"})
                        end
                    end
                end,
            },
            foggy = {
                airFrictionAdd = function () return 0.1 * Weather.strength end,
                jumpPadStrengthAdd = function () return 0 end,
                passiveCoolingAdd = function () return 0.4 * Weather.strength end,
                overlay = {.2,.2,.2,.2}, secondOverlay = {0,0,0,.5},
                shaderSinOffset = 0,
                enemySizeMultiplier = 4, enemySpeedMultiplier = .5,
                shader = love.graphics.newShader([[

extern vec2 screenCenter;
extern float maxLightDistance;

vec4 effect(vec4 color, Image image, vec2 texture_coords, vec2 screen_coords) {

    float distance = sqrt( pow(screenCenter.x - screen_coords.x, 2) + pow(screenCenter.y - screen_coords.y, 2) );

    float v = 1 - distance / maxLightDistance;
    vec4 fog = vec4( v, v, v, 1 );

    vec4 pixel = Texel(image, texture_coords);

    return pixel * color * fog;
}

                ]]),
                update = function (self)
                    self.shaderSinOffset = self.shaderSinOffset + 0.001 * GlobalDT
                    if self.shaderSinOffset >= 360 then
                        self.shaderSinOffset = self.shaderSinOffset - 360
                    end

                    if not SFX.windy:isPlaying() then
                        SFX.windy:setLooping(true)
                        PlaySFX(SFX.windy, 0.6, 1)
                    end

                    if Music:isPlaying() then
                        Music:pause()
                    end
                end,
                start = function (self)
                    for _, obj in ipairs(Objects) do
                        if obj.type ~= "normal" and obj.type ~= "jump" and not obj.impenetrable then
                            obj.type = "normal"
                        end
                    end
                end,
            },
        }
    }
end

function StartWeather()
    if Weather.types[Weather.currentType].start ~= nil then
        Weather.types[Weather.currentType].start(Weather.types[Weather.currentType])
    end
end

function DrawWeatherOverlay()
    love.graphics.setBlendMode("add", "alphamultiply")
    love.graphics.setColor(Weather.types[Weather.currentType].overlay)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setBlendMode("alpha")

    if Weather.currentType == "rainy" then
        if Settings.weatherDarkening then
            local color = Weather.types[Weather.currentType].secondOverlay
            love.graphics.setColor(color[1], color[2], color[3], Weather.strength * color[4])
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        end

        love.graphics.setLineWidth(1)
        for _ = 1, Weather.strength * 300 do
            love.graphics.setColor(1,1,1, math.random()*0.4)

            local x, y = math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight())
            local x2 = x + (Weather.windEvents.duration > 0 and Weather.windEvents.strength or 0) * 45

            love.graphics.line(x, y, x2, y + Weather.strength * 10 + 20)
        end
    elseif Weather.currentType == "hot" then
        love.graphics.setBlendMode("add", "alphamultiply")

        for _ = 1, Weather.strength * 100 do
            love.graphics.setColor(1,.5,0,math.random()*0.2)
            local x, y, width = math.random(0, love.graphics.getWidth()), EaseOutQuint(math.random()) * love.graphics.getHeight(), 3
            love.graphics.rectangle("fill", x, y, width, width)
        end

        love.graphics.setBlendMode("alpha")
    elseif Weather.currentType == "foggy" then
        if Settings.weatherDarkening then
            local color = Weather.types[Weather.currentType].secondOverlay
            love.graphics.setColor(color[1], color[2], color[3], Weather.strength * color[4])
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        end
    end
end

function UpdateWeather()
    if Weather.types[Weather.currentType].update ~= nil then
        Weather.types[Weather.currentType].update(Weather.types[Weather.currentType])
    end
end

function ApplyWind(xvelocity)
    if Weather.currentType ~= "rainy" or Weather.windEvents.duration <= 0 then return xvelocity end
    return xvelocity + Weather.windEvents.strength
end