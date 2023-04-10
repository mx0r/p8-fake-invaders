Bunker = {
    x = 0
}

function Bunker:new(obj, x)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    -- init properties
    obj.x = x

    return obj
end

function Bunker:draw()
    spr(34, self.x, 100, 2, 2)
end