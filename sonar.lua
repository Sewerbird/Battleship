local lib = require('ed')

local Blip = require('blip')

local Sonar = lib.class({
  type= "sonar",
  x= 0,
  y= 0,
  r= 9999,
  dr= 90,
  angle= 0,
  false_positive_rate= -1,
  false_positive_accumulator= 0,
  cooldown_timer= 0,
  max_cooldown_timer= 3, --seconds
  distance= 1500,
})
:implements("Sensor")
:implements("Orientable")
:implements("Equippable")
:implements("Drawable")
:implements("Updatable")

function Sonar:update(dt, equipper)
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  self.x = equipper.x
  self.y = equipper.y
  self.r = math.min(self.r + (self.dr * dt), 1.1 * math.sqrt(w*w + h*h))
  self.false_positive_accumulator = self.false_positive_accumulator + (self.false_positive_rate * dt)
  self.cooldown_timer = math.min(self.cooldown_timer + dt, self.max_cooldown_timer)
  -- Check Sonar for new blips (ghosts or ships)
  -- True Positives
  for _, ship in ipairs(game.get_ships()) do
    if geom.circle_intercepts_circle(self, ship) and ship.id ~= equipper.id and ship.id ~= self.equipper_id then
      table.insert(game.get_blips(), Blip:create({x= ship.x, y= ship.y, r= ship.r}))
      love.audio.play(game.get_sounds().pings.sonar_1)
    end
  end
  return self
end

function Sonar:draw(equipper)
  --Draw sonar ping
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.circle('line', self.x, self.y, self.r, self.r)
end

function Sonar:activate()
  if self.cooldown_timer >= self.max_cooldown_timer then
    game.get_sounds().actions.sonar_ping()
    print(self.cooldown_timer)
    self.cooldown_timer = 0
    self.r = 0
  end
end

function Sonar:onEquip(equipper)
  self.x = equipper.x
  self.y = equipper.y
  self.angle = equipper.angle
  return self
end

return Sonar
