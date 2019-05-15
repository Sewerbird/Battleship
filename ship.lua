local Ship = {}
Ship.__index = Ship

local input = {}

function Ship:create(options)
  local this = {
    id = options.id or lume.uuid(),
    x = options.x or 0,
    y = options.y or 0,
    angle = options.angle or 0, --heading in radians
    r = options.r or 0, --radar signature in px
    dx = options.dx or 0, --velocity (x-component) in px/s
    dy = options.dy or 1, --velocity (y-component) in px/s
    hp = options.hp or 1,
    speed = options.speed or math.sqrt(math.pow(options.dx or 0, 2) + math.pow(options.dy or 1, 2)),
    is_sinking = options.is_sinking or false,
    is_firing = options.is_firing or false,
    sink_timer = options.sink_timer or 0,
    max_sink_timer = options.max_sink_timer or 3,
    torpedo_fire_timer = options.torpedo_fire_timer or 0,
    torpedo_fire_rate = options.torpedo_fire_rate or 1,
    uninitialized_equipment = options.equipment or {},
    equipment = {}
  }
  setmetatable(this,Ship)

  for k, v in pairs(this.uninitialized_equipment) do
    this:equip(v)
  end
  this.uninitialized_equipment = nil
  return this
end

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
  self.x = lume.wrap(self.x + self.dx, 0, love.graphics.getWidth())
  self.y = lume.wrap(self.y + self.dy, 0, love.graphics.getHeight())
  if self.is_firing then
    self.torpedo_fire_timer = self.torpedo_fire_timer + dt
  end
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
      game.fire_torpedo(self, love.mouse.getX(), love.mouse.getY())
    end
    local hx, hy = lume.vector(self.angle, self.speed)
    self.dx = hx * dt
    self.dy = hy * dt
  --Otherwise Do AI
  else
    if self.torpedo_fire_timer >= self.torpedo_fire_rate then
      self.torpedo_fire_timer = self.torpedo_fire_timer - self.torpedo_fire_rate
      game.fire_enemy_torpedo(self, self.x, self.y)
    end
  end
  return self
end

function Ship:equip(equipment)
  table.insert(self.equipment, equipment:onEquip(self))
end

function Ship:get_module(equipment_type)
  return lume.match(self.equipment, function(e) return e.type == equipment_type end)
end

return Ship
