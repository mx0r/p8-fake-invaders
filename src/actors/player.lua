Player = {
    lives = 3,
    x = 63,
    y = 112,
    phase = 1,
    fireInterval = 10,
    fireTicks = 10,
    projectiles = {},
    isDead = false,
    explodingTicks = 0
}

g_playerAnimPhases = {
    14, 32, -2,       -- basic movement
    42, 44, 46, -6,   -- explosion
}

function Player:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    return obj
end

function Player:reset()
    self.x = 63
    self.y = 112
    self.phase = 1
    self.fireInterval = 10
    self.fireTicks = 10
    self.projectiles = {}
    self.isDead = false
    self.explodingTicks = 0
end

function Player:draw()
    spr(g_playerAnimPhases[self.phase], self.x, self.y, 2, 1)
    for projectile in all(self.projectiles) do
        projectile:draw()
    end
end

function Player:update()
    self.fireTicks += 1
    for projectile in all(self.projectiles) do
        projectile:draw(0)
        projectile:moveDelta(-1)
        projectile:checkHit(-2)
        if projectile:isOffScreen() then
            del(self.projectiles, projectile)
        end
    end
end

function Player:tick()
    if self.phase >= 0 then
        -- update animation phase
        self.phase += 1
        if g_playerAnimPhases[self.phase] == nil then
            self.phase = -1    
        elseif g_playerAnimPhases[self.phase] < 0 then
            self.phase += g_playerAnimPhases[self.phase]
        end
    end
    if self.explodingTicks > 0 then
        self.explodingTicks -= 1
    end
end

function Player:moveDelta(dx)
    if self.explodingTicks > 0 then
        return
    end

    self.x += dx
    if self.x < 1 then
        self.x = 1
    end
    if self.x > 111 then
        self.x = 111
    end
end

function Player:fire()
    if self.explodingTicks > 0 then
        return
    end

    if self.fireTicks > self.fireInterval then
        add(self.projectiles, Projectile:new(nil, self.x + 8, self.y - 1))
        self.fireTicks = 0
    end
end

function Player:didHit(alien)
    hitValue = 0
    for projectile in all(self.projectiles) do
        if projectile.isHit then
            if alien:collide(projectile.x, projectile.y) then
                alien:kill()
                del(self.projectiles, projectile)
                hitValue += alien.value
            elseif projectile:isInBunkerRegion() then
                -- projectile hit the bunker (probably)
                projectile:draw(0, -2, 2)
                del(self.projectiles, projectile)
            end
        end
    end

    return hitValue
end

function Player:collide(x, y)
    if self.explodingTicks > 0 then
        return false
    end
    
    return (x >= self.x and x <= self.x + 16
        and y >= self.y + 3 and y <= self.y + 8)
        or (x >= self.x + 4 and x <= self.x + 8
        and y >= self.y and y <= self.y + 8)
end

function Player:kill()
    self.lives -= 1
    self.phase = 4
    self.explodingTicks = 4
    if self.lives == 0 then 
        self.isDead = true
    else
        sfx(Sfx.PlayerExplode)
    end
end