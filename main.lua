function love.load()
    ship = {}
    ship.x = 400
    ship.y = 300
    ship.speed = 200
    ship.angle = -math.pi / 2
    ship.img = love.graphics.newImage("spaceship.png")
    ship.health = 100

    projectiles = {}
    projectileSpeed = 420
    shootCooldown = 0
    projectileImg = love.graphics.newImage("projectile.png")

    enemies = {}
    enemyImg = love.graphics.newImage("enemy.png")
    enemySpawnTimer = 0
end

function love.update(dt)
    if love.keyboard.isDown("left") then
        ship.angle = ship.angle - 2 * dt
    end
    if love.keyboard.isDown("right") then
        ship.angle = ship.angle + 2 * dt
    end

    if love.keyboard.isDown("up") then
        ship.x = ship.x + math.cos(ship.angle) * ship.speed * dt
        ship.y = ship.y + math.sin(ship.angle) * ship.speed * dt
    end
    if love.keyboard.isDown("down") then
        ship.x = ship.x - math.cos(ship.angle) * ship.speed * dt
        ship.y = ship.y - math.sin(ship.angle) * ship.speed * dt
    end

    if shootCooldown > 0 then
        shootCooldown = shootCooldown - dt
    end

    if (love.mouse.isDown(1) or love.keyboard.isDown("space")) and shootCooldown <= 0 then
        local muzzleOffset = 30
        table.insert(projectiles, {
            x = ship.x + math.cos(ship.angle) * muzzleOffset,
            y = ship.y + math.sin(ship.angle) * muzzleOffset,
            angle = ship.angle,
            vx = math.cos(ship.angle) * projectileSpeed,
            vy = math.sin(ship.angle) * projectileSpeed,
            life = 4,
            img = projectileImg
        })
        shootCooldown = 0.2
    end

    for i = #projectiles, 1, -1 do
        local projectile = projectiles[i]
        projectile.x = projectile.x + projectile.vx * dt
        projectile.y = projectile.y + projectile.vy * dt
        projectile.life = projectile.life - dt

        if projectile.life <= 0 then
            table.remove(projectiles, i)
        end
    end

    enemySpawnTimer = enemySpawnTimer - dt
    if enemySpawnTimer <= 0 then
        local side = math.random(4)
        local enemy = {
            x = 0,
            y = 0,
            img = enemyImg,
            speed = 80 + math.random() * 40,
            angle = 0
        }

        if side == 1 then
            enemy.x = -20
            enemy.y = math.random(0, love.graphics.getHeight())
        elseif side == 2 then
            enemy.x = love.graphics.getWidth() + 20
            enemy.y = math.random(0, love.graphics.getHeight())
        elseif side == 3 then
            enemy.x = math.random(0, love.graphics.getWidth())
            enemy.y = -20
        else
            enemy.x = math.random(0, love.graphics.getWidth())
            enemy.y = love.graphics.getHeight() + 20
        end

        table.insert(enemies, enemy)
        enemySpawnTimer = 1.5
    end

    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        local dx = ship.x - enemy.x
        local dy = ship.y - enemy.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 0 then
            enemy.angle = math.atan2(dy, dx)
        end

        enemy.x = enemy.x + math.cos(enemy.angle) * enemy.speed * dt
        enemy.y = enemy.y + math.sin(enemy.angle) * enemy.speed * dt

        local shipRadius = 25
        local enemyRadius = 20
        if distance < shipRadius + enemyRadius then
            ship.health = ship.health - 10
            table.remove(enemies, i)
        end
    end

    for i = #projectiles, 1, -1 do
        local projectile = projectiles[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            local dx = projectile.x - enemy.x
            local dy = projectile.y - enemy.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < 20 then
                table.remove(projectiles, i)
                table.remove(enemies, j)
                break
            end
        end
    end
end

function love.draw()
    love.graphics.draw(ship.img, ship.x, ship.y, ship.angle, 1, 1, ship.img:getWidth() / 2, ship.img:getHeight() / 2)

    for _, projectile in ipairs(projectiles) do
        love.graphics.draw(projectile.img, projectile.x, projectile.y, projectile.angle, 1, 1, projectile.img:getWidth() / 2, projectile.img:getHeight() / 2)
    end

    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y, enemy.angle, 1, 1, enemy.img:getWidth() / 2, enemy.img:getHeight() / 2)
    end

    love.graphics.print("Health: " .. ship.health, 20, 20)
end