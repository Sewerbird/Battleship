geom = require 'geom'
moonshine = require 'moonshine'
lume = require 'lib/lume'
lume.wrap = function(value, minimum, maximum)
  local range = maximum - minimum
  while value < minimum do
    value = value + range
  end
  while value > maximum do
    value = value - range
  end
  return value
end

game = require 'game'

fancy = false
debug = false

function love.load(args)
  effect = moonshine(moonshine.effects.crt)
              .chain(moonshine.effects.pixelate)
              .chain(moonshine.effects.scanlines)
              .chain(moonshine.effects.glow)
              .chain(moonshine.effects.dmg)
  effect.pixelate.size = 2
  effect.dmg.palette = "green"
  effect.glow.strength = 10
  game.load()
end

function love.keypressed(key)
  if key == "return" then
    fancy = not fancy
  end
  if key == "delete" then
    debug = not debug
  end
end

function love.touchpressed(x,y)
  love.mousepressed(x,y)
end

function love.mousepressed(x,y)
end

function love.mousemoved(x,y,dx,dy)
end

function love.mousereleased(x,y)
end

function love.update(dt)
  frame_rate = 1.0 / dt
  local input = {}
  if love.keyboard.isDown("a") then
    input.hard_to_port = true
  end
  if love.keyboard.isDown("d") then
    input.hard_to_starboard = true
  end
  if love.keyboard.isDown("space") then
    input.ping_sonar = true
  end
  if love.mouse.isDown(1) then
    input.fire_torpedo = true 
  end
  game.commit_input(input)
  game.update(dt, input)
end

function love.draw()
  love.graphics.print(math.floor(frame_rate), 10, 10)
  if fancy then
    effect(function()
      love.graphics.setLineWidth(3)
      game.draw()
    end)
  else
    game.draw()
  end
end

