function NewParticle(x, y, radius, color, speed, degrees, gravity, lifespan, behavior)
    return {
        x = x, y = y, yvelocity = 0,
        radius = radius, speed = speed, gravity = gravity, degrees = degrees,
        lifespan = lifespan, color = color,
        draw = function (self)
            love.graphics.setColor(self.color)
            love.graphics.circle("fill", self.x, self.y, self.radius)
        end,
        update = function (self)
            self.lifespan = self.lifespan - (1 + (Settings.graphics.current == 2 and 2 or 0)) * GlobalDT
            if self.lifespan <= 0 then
                lume.remove(Particles, self)
            end

            self.radius = self.lifespan / lifespan * radius

            self.x = self.x + math.sin(math.rad(self.degrees)) * self.speed * GlobalDT
            self.y = self.y + math.cos(math.rad(self.degrees)) * self.speed * GlobalDT

            self.yvelocity = self.yvelocity + self.gravity * GlobalDT
            self.y = self.y + self.yvelocity * GlobalDT

            if behavior ~= nil then behavior(self) end
        end
    }
end

function UpdateParticles()
    for _, particle in ipairs(Particles) do
        particle.update(particle)
    end
end

function DrawParticles()
    for _, particle in ipairs(Particles) do
        particle.draw(particle)
    end
end