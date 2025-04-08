function InitialiseWeather()
    Weather = {
        currentType = "clear",
        strength = 0, -- real number from 0 to 1
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
                    if not SFX.rain:isPlaying() then
                        SFX.rain:setLooping(true)
                        PlaySFX(SFX.rain, 0.2 * Weather.strength + .02, 1)
                    end

                    for _, obj in ipairs(Objects) do
                        if obj.render and math.random() <= 0.1 * Weather.strength then
                            local x, y = math.random(obj.x, obj.x + obj.width), obj.y
                            for _ = 1, 6, 1 do
                                table.insert(Particles, NewParticle(x, y, math.random() * 2, {1,1,1,math.random()/2+.6}, math.random()*2+.5, math.random(160, 200), 0.06, math.random(100, 160)))
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
                end,
                start = function (self)
                    for _, obj in ipairs(Objects) do
                        if obj.type == "icy" then
                            obj.type = lume.randomchoice({"death", "normal"})
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
        local color = Weather.types[Weather.currentType].secondOverlay
        love.graphics.setColor(color[1], color[2], color[3], Weather.strength * color[4])
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        for _ = 1, Weather.strength * 300 do
            love.graphics.setColor(1,1,1, math.random()*0.4)
            local x, y = math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight())
            love.graphics.line(x, y, x, y + Weather.strength * 10 + 20)
        end
    elseif Weather.currentType == "hot" then
        love.graphics.setBlendMode("add", "alphamultiply")

        for _ = 1, Weather.strength * 100 do
            love.graphics.setColor(1,.5,0,math.random()*0.2)
            local x, y, width = math.random(0, love.graphics.getWidth()), EaseOutQuint(math.random()) * love.graphics.getHeight(), 3
            love.graphics.rectangle("fill", x, y, width, width)
        end

        love.graphics.setBlendMode("alpha")
    end
end

function UpdateWeather()
    if Weather.types[Weather.currentType].update ~= nil then
        Weather.types[Weather.currentType].update(Weather.types[Weather.currentType])
    end
end