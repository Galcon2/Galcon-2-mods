function init()
    OPTS = {
        sw = 480,
        sh = 320,
        neutrals = 25,
        player_prod = 100,
        player_ships = 100,
        lines_horizontal = 10,
        lines_vertical = 15
    }
    init_game()
end

function init_game()
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)

    local neutral_player = g2.new_user("neutral", 0x555555)
    neutral_player.user_neutral = true
    neutral_player.ships_production_enabled = false
    --SPAWN NEUTRALS
    local x, y = 0
    local x_1, y_1 = 0
    local x_2, y_2 = 0
    local oldCoordinates, newCoordinates = {}, {}
    local spacingBuffer = 60
    local padv = OPTS.sw / lines_vertical
    local padh = OPTS.sh / lines_horizontal
    for i = 1, OPTS.neutrals / 2 do
        local prod = math.random(15, 100)
        local ships = math.random(0, 50)
        --spawn first neutral
        if i == 1 then
            x = math.random(padv, padv * (lines_vertical - 1))
            y = math.random(padh, padh * (lines_horizontal - 1))
            x_1 = x
            y_1 = y
            table.insert(oldCoordinates, {x_1, y_1})
            g2.new_planet(neutral_player, x, y, prod, ships)
            g2.new_planet(neutral_player, OPTS.sw - x, OPTS.sh - y, prod, ships)
        elseif i >= 2 and i < 5 then -- change to i >= 2 | else
            x = math.random(padv, padv * (lines_vertical - 1))
            y = math.random(padh, padh * (lines_horizontal - 1))
            x_2 = x
            y_2 = y
            table.insert(newCoordinates, {x_2, y_2})
            if
                distance(newCoordinates[1][1], oldCoordinates[1][1], newCoordinates[1][2], oldCoordinates[1][2]) >
                    spacingBuffer and
                    distance(
                        newCoordinates[1][1],
                        OPTS.sw - oldCoordinates[1][1],
                        newCoordinates[1][2],
                        OPTS.sh - oldCoordinates[1][2]
                    ) > spacingBuffer
             then
                g2.new_planet(neutral_player, x, y, prod, ships)
                g2.new_planet(neutral_player, OPTS.sw - x, OPTS.sh - y, prod, ships)
                table.remove(newCoordinates, 1)
                table.insert(oldCoordinates, {x_2, y_2})
            end
        end
    end

    -- draw grid
    for i = 0, lines_horizontal do
        g2.new_line(0xffffff, 0, padh * i, OPTS.sw, padh * i)
    end
    for i = 0, lines_vertical do
        g2.new_line(0xffffff, padv * i, 0, padv * i, OPTS.sh)
    end
    -- define square
    g2.new_line(0xff0000, 0, 0, padv, 0)
    g2.new_line(0xff0000, padv, 0, padv, padh)
    g2.new_line(0xff0000, padv, padh, 0, padh)
    g2.new_line(0xff0000, 0, padh, 0, 0)

    local player = g2.new_user("Player", 0x0000ff)
    g2.player = player
    OPTS.player = player

    local enemy = g2.new_user("Enemy", 0xff0000)
    OPTS.enemy = enemy

    local a = math.random(0, 360)
    local pad = padh
    local x = OPTS.sw / 2 + (OPTS.sw - pad) * math.cos(a * math.pi / 180.0) / 2.0
    local y = OPTS.sh / 2 + (OPTS.sh - pad) * math.sin(a * math.pi / 180.0) / 2.0
    function border()
        while x < padv or x > padv * (lines_vertical - 1) do
            x = math.random() * OPTS.sw
            print("x:" .. x)
        end

        while y < padh or y > padh * (lines_horizontal - 1) do
            y = math.random() * OPTS.sh
            print("y:" .. y)
        end
    end
    function middle()
        while x > padv * 4 and x < padv * (lines_vertical - 4) and y > padh * 2 and y < padh * (lines_horizontal - 2) do
            x = math.random() * OPTS.sw
            print("x2:" .. x)
            y = math.random() * OPTS.sh
            print("y2:" .. y)
        end
    end

    local prod = OPTS.player_prod
    local ships = OPTS.player_ships
    g2.new_planet(player, x, y, prod, ships)
    g2.new_planet(enemy, OPTS.sw - x, OPTS.sh - y, prod, ships)

    --g2.planets_settle(0, 0, OPTS.sw, OPTS.sh)
end

function distance(x_2, x_1, y_2, y_1)
    return math.sqrt((x_2 - x_1) ^ 2 + (y_2 - y_1) ^ 2)
end

function bot_loop(user)
end

function event(e)
    if e.type == "pause" then
        g2.state = "pause"
        g2.html = "<table><tr><td><input type='button' value='Resume' onclick='resume' />"
    end
    if e.type == "onclick" and e.value == "resume" then
        g2.state = "play"
    end
    if e.type == "onclick" and e.value == "new_game" then
        g2.state = "play"
        init_game()
    end
end

function init_win()
    g2.state = "pause"
    g2.html = "<table><tr><td><h1>Good job!" .. "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end

function init_lose()
    g2.state = "pause"
    g2.html = "<table><tr><td><h1>Try again?" .. "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end
-- UTILITY FUNCTIONS
function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end
