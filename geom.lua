local geometry = {}

-- Lines have a point (x,y) and an angle (angle)
-- Circles have a center point (x,y) and a radius (r)
function geometry.line_intercepts_circle(line, circle)
  assert(geometry.is_a_line(line))
  assert(geometry.is_a_circle(circle))
  local r_x, r_y = lume.vector(line.angle, 1)
  local cX = circle.x - line.x
  local cY = circle.y - line.y
  local cR = circle.r
  local dxdy = (r_y/r_x)
  local a = -dxdy
  local d = math.abs((a*cX) + cY) / math.sqrt((a*a))
  return d < cR
end

-- Does circleA overlap Circle B?
-- Circles have a center point (x,y) and a radius (r)
function geometry.circle_collides_circle(circleA, circleB)
  assert(geometry.is_a_circle(circleA))
  assert(geometry.is_a_circle(circleB))
  local D = math.sqrt(math.pow(circleB.x - circleA.x, 2) + math.pow(circleB.y - circleA.y, 2))
  return D < (circleA.r + circleB.r)
end

function geometry.line_segment_intersects_line_segment(lineA, lineB)
  assert(geometry.is_a_line_segment(lineA))
  assert(geometry.is_a_line_segment(lineB))

  local A = {x = lineA.x1, y= lineA.y1}
  local B = {x = lineA.x2, y= lineA.y2}
  local C = {x = lineB.x1, y= lineB.y1}
  local D = {x = lineB.x2, y= lineB.y2}
  local function ccw(A, B, C)
    return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)
  end
  return ccw(A,C,D) ~= ccw(B,C,D) and ccw(A,B,C) ~= ccw(A,B,D)
end

-- Does circleB sit on circleA's boundary?
function geometry.circle_intercepts_circle(circleA, circleB)
  assert(geometry.is_a_circle(circleA))
  assert(geometry.is_a_circle(circleB))
  local D = math.sqrt(math.pow(circleB.x - circleA.x, 2) + math.pow(circleB.y - circleA.y, 2))
  return D < (circleA.r + circleB.r) and D > (circleA.r - circleB.r)
end

function geometry.is_a_line(line)
  return line.x and line.y and line.angle
end

function geometry.is_a_line_segment(line)
  return line.x0 and line.x1 and line.y0 and line.y1
end

function geometry.is_a_circle(circle)
  return circle.x and circle.y and circle.r 
end

return geometry
