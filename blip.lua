local lib = require('ed')

local Blip = lib.class({
  x = 0,
  y = 0,
  r = 10,
  age = 0,
  max_age = 1,
})
:implements("Drawable")
:implements("Updatable")

function Blip:update(dt)
  self.age = self.age + dt
  self.destroy = self.age > self.max_age
end

function Blip:draw()
  --Fade blips according to time since last detection
  local fadeout = (2.0 - self.age)/2.0
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0 * fadeout)
  love.graphics.circle('fill', self.x, self.y, self.r, self.r)
end

return Blip
