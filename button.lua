function NewButton(text, x, y, width, height, alignMode, lineColor, fillColor, mouseOverFillColor, textColor, font, lineWidth, roundX, roundY, func, passive, enable)
    table.insert(Buttons, {
        x = x, y = y, width = width, height = height, text = text,
        lineColor = lineColor, fillColor = fillColor, mouseOverFillColor = mouseOverFillColor, textColor = textColor, font = font,
        func = func, mouseOver = false, enable = enable, passive = passive,
        sizeEasing = 0,
        draw = function (self)
            if self.enable(self) then

                local applyFunc = (self.mouseOver and zutil.easeOutQuint or zutil.easeInQuint)

                local amplitude = 20
                local buttonX = self.x - applyFunc(self.sizeEasing) * amplitude
                local buttonWidth = self.width + 2 * applyFunc(self.sizeEasing) * amplitude

                love.graphics.setColor((self.mouseOver and self.mouseOverFillColor or self.fillColor))
                love.graphics.rectangle("fill", buttonX, self.y, buttonWidth, self.height, roundX, roundY)

                love.graphics.setColor(self.lineColor)
                love.graphics.setLineWidth(lineWidth)
                love.graphics.rectangle("line", buttonX, self.y, buttonWidth, self.height, roundX, roundY)

                local obj = love.graphics.newText(self.font, self.text)
                love.graphics.setColor(self.textColor)
                love.graphics.setFont(self.font)

                local xpos = buttonX + buttonWidth / 2 - obj:getWidth() / 2
                local spacing = 20
                if alignMode == "left" then
                    xpos = buttonX + spacing
                elseif alignMode == "right" then
                    xpos = buttonX + buttonWidth - obj:getWidth() - spacing
                end

                love.graphics.draw(obj, xpos, self.y + self.height / 2 - obj:getHeight() / 2)

            end
        end,
        update = function (self)
            local before = self.mouseOver
            self.mouseOver = zutil.touching(love.mouse.getX(), love.mouse.getY(), 0, 0, self.x, self.y, self.width, self.height)

            if self.enable(self) then

                if not self.grayedOut then
                    if not before and self.mouseOver then
                        zutil.playsfx(SFX.hover, 0.6, 1)

                        self.sizeEasing = zutil.easeInQuint(self.sizeEasing)
                    elseif before and not self.mouseOver then
                        self.sizeEasing = zutil.easeOutQuint(self.sizeEasing)
                    end

                    local speed = 1/60
                    if self.mouseOver and self.sizeEasing < 1 then
                        self.sizeEasing = self.sizeEasing + speed * GlobalDT
                        if self.sizeEasing > 1 then self.sizeEasing = 1 end
                    elseif not self.mouseOver and self.sizeEasing > 0 then
                        self.sizeEasing = self.sizeEasing - speed * GlobalDT
                        if self.sizeEasing < 0 then self.sizeEasing = 0 end
                    end
                end

                if self.passive ~= nil then self.passive(self) end

            end
        end,
        mouseClick = function (self, key)
            if self.mouseOver and self.enable() and not ClickedWithMouse and not self.grayedOut then
                self.func(self)
                ClickedWithMouse = true
                zutil.playsfx(SFX.click, 0.6, 1)
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