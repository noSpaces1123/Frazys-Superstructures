function NewButton(text, x, y, width, height, lineColor, fillColor, mouseOverFillColor, textColor, font, lineWidth, roundX, roundY, func, passive, enable)
    table.insert(Buttons, {
        x = x, y = y, width = width, height = height, text = text,
        lineColor = lineColor, fillColor = fillColor, mouseOverFillColor = mouseOverFillColor, textColor = textColor, font = font,
        func = func, mouseOver = false, enable = enable, passive = passive,
        draw = function (self)
            if self.enable(self) then

                love.graphics.setColor((self.mouseOver and self.mouseOverFillColor or self.fillColor))
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, roundX, roundY)

                love.graphics.setColor(self.lineColor)
                love.graphics.setLineWidth(lineWidth)
                love.graphics.rectangle("line", self.x, self.y, self.width, self.height, roundX, roundY)

                local obj = love.graphics.newText(self.font, self.text)
                love.graphics.setColor(self.textColor)
                love.graphics.setFont(self.font)
                love.graphics.draw(obj, self.x + self.width / 2 - obj:getWidth() / 2, self.y + self.height / 2 - obj:getHeight() / 2)

            end
        end,
        update = function (self)
            local before = self.mouseOver
            self.mouseOver = Touching(love.mouse.getX(), love.mouse.getY(), 0, 0, self.x, self.y, self.width, self.height)

            if self.enable(self) then

                if not before and self.mouseOver then
                    PlaySFX(SFX.hover, 0.6, 1)
                end

                if self.passive ~= nil then self.passive(self) end

            end
        end,
        mouseClick = function (self, key)
            if self.mouseOver and self.enable() and not ClickedWithMouse then
                self.func(self)
                ClickedWithMouse = true
                PlaySFX(SFX.click, 0.6, 1)
            end
        end
    })
end
function UpdateButtons()
    for _, button in ipairs(Buttons) do
        button:update(button)
    end
end
function DrawButtons()
    for _, button in ipairs(Buttons) do
        button:draw(button)
    end
end
function CheckButtonsClicked(key)
    for _, button in ipairs(Buttons) do
        button:mouseClick(button, key)
    end
end