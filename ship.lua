local lib = require('ed')

local Ship = lib.class({
    id = lume.uuid(),
    x = 0,
    y = 0,
    angle = 0, --heading in radians
    r = 0, --radar signature in px
    dx = 0, --velocity (x-component) in px/s
    dy = 10, --velocity (y-component) in px/s
    hp = 1,
    speed = math.sqrt(math.pow(0, 2) + math.pow(1, 2)),
    is_sinking = false,
    is_firing = false,
    sink_timer = 0,
    max_sink_timer = 3,
    torpedo_fire_timer = 0,
    torpedo_fire_rate = 1,
    equipment = {}
})
:implements("Orientable")
:implements("Outfittable")
:implements("Drawable")
:implements("Updatable")

function Ship:draw()
  -- STATE: Sinking
  if self.is_sinking then
    love.graphics.print(self.sink_timer, self.x,self.y)
    love.graphics.setColor(1.0, 1.0, 1.0, (self.max_sink_timer - self.sink_timer) / self.max_sink_timer)
    love.graphics.circle('line', self.x, self.y, self.r, self.r * 2)
    local h_x, h_y = lume.vector(self.angle,self.r)
    love.graphics.line(self.x,self.y,self.x+h_x,self.y+h_y)
    return
  end

  -- STATE: Alive
  --Update Modules
  for _, module in ipairs(self.equipment) do
    if module.draw then module:draw(self) end
  end
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  love.graphics.circle('line', self.x, self.y, self.r, self.r * 2)
  local h_x, h_y = lume.vector(self.angle,self.r)
  love.graphics.line(self.x,self.y,self.x+h_x,self.y+h_y)
end

function Ship:update(dt, input)
  -- STATE: Sinking
  if self.is_sinking then
    self.sink_timer = self.sink_timer + dt
    self.destroy = self.sink_timer > self.max_sink_timer
    return self
  end

  -- STATE: Alive
  --Update Modules
  for _, module in ipairs(self.equipment) do
    if module.update then module:update(dt, self) end
  end
  --Update position and timers
  self.x = lume.wrap(self.x + self.dx * dt, 0, love.graphics.getWidth())
  self.y = lume.wrap(self.y + self.dy * dt, 0, love.graphics.getHeight())
  self.torpedo_fire_timer = self.torpedo_fire_timer + dt
  --Steer Player self
  if self.id == -1 then --player self
    if input.hard_to_port then
      self.angle = self.angle - (dt * math.pi / 2) --turning radius of 90* per second
    end
    if input.hard_to_starboard then
      self.angle = self.angle + (dt * math.pi / 2) --turning radius of 90* per second
    end
    if input.ping_sonar then
      game.ping_sonar()
    end
    if input.fire_torpedo then
      if self.torpedo_fire_timer >= self.torpedo_fire_rate then
        self.torpedo_fire_timer = self.torpedo_fire_timer - self.torpedo_fire_rate
        game.fire_torpedo(self, love.mouse.getX(), love.mouse.getY())
      end
    end
    local hx, hy = lume.vector(self.angle, self.speed)
    self.dx = hx * dt
    self.dy = hy * dt
  --Otherwise Do AI
  else
    if self.is_firing then
      if self.torpedo_fire_timer >= self.torpedo_fire_rate then
        self.torpedo_fire_timer = self.torpedo_fire_timer - self.torpedo_fire_rate
        game.fire_enemy_torpedo(self, self.x, self.y)
      end
    end
  end
  return self
end

function Ship:equip(equipment)
  table.insert(self.equipment, equipment:onEquip(self))
  return self
end

function Ship:get_module(equipment_type)
  return lume.match(self.equipment, function(e) return e.type == equipment_type end)
end

return Ship
