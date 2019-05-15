--Ed's Lua Utilities
local Lib = {}

function Lib.class(class_defaults, initialization_function)
  class_defaults = class_defaults or {}
  initialization_function = initialization_function or function(this) return this end
  local Klass = {}
  Klass.__index = Klass

  function Klass:create(instance_options)
    instance_options = instance_options or {}
    local this = lume.merge(class_defaults, instance_options)
    setmetatable(this, Klass)
    return initialization_function(this)
  end
  
  function Klass:implements(mixin)
    return self
  end

  return Klass
end

return Lib


