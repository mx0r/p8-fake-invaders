Projectile = {
    x = 0,
    y = 0,
    isHit = false
}

function Projectile:new(obj, x, y)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    -- init properties
    obj.x = x
    obj.y = y

    return obj
end

function Projectile:draw(color, dy, r)
    circfill(self.x, self.y + (dy or 0), r or 1, color or 7)
end

function Projectile:moveDelta(dy)
    self.y += dy
end

function Projectile:isOffScreen()
    return self.y > 128 or self.y < 0
end

function Projectile:checkHit(dy)
    self.isHit = pget(self.x, self.y + dy) == 7
end

function Projectile:isInBunkerRegion()
    return self.y >= 100 and self.y <= 116
end