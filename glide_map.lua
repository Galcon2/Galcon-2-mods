LICENSE =
    [[
mod_training.lua

Copyright (c) 2013 Phil Hassey

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

function reset()
    counter = 0
end

function init()
    counter = 0
    math.randomseed(os.time())
    costs = 0
    COLORS = {
        0x555555,
        0x0000ff,
        0xff0000,
        0xffff00,
        0x00ffff,
        0xffffff,
        0xffbb00,
        0x99ff99,
        0xff9999,
        0xbb00ff,
        0xff88ff,
        0x9999ff,
        0x00ff00
    }
    sw = 480
    sh = 320
    CENTER = {sw / 2, sh / 2}
    OPTS = {
        sw = 480,
        sh = 320,
        isStarted = false,
        mapType = "circular",
        num_planets = 8,
        homeProd = 100,
        neutralProd = 25
    }

    main_menu()
end

function loop(t)
    OPTS.time = OPTS.time + t
    local user_planets = g2.search("planet owner:user")
    if user_planets ~= nil and user_planets[1] ~= nil then
        local home = user_planets[1]
        if home:selected() and not OPTS.isStarted then
            OPTS.isStarted = true
            OPTS.time = 0
        end
    end
    counter = 0
    for p in pairs(g2.search("planet -neutral")) do
        counter = counter + 1
    end

    if counter >= OPTS.num_planets + 1 then
        glide_victory()
        g2.state = "pause"
    end
end

function start()
    g2.state = "play"
    glide_init()
end

function event(e)
    if e["type"] == "onclick" and e["value"] then
        if string.find(e["value"], "mode:") ~= nil then
            OPTS.mode = string.sub(e["value"], 6)
            _ENV[OPTS.mode .. "_menu"]()
        elseif string.find(e["value"], "newmap:") ~= nil then
            OPTS.num_planets = g2.form.num_planets
            OPTS.homeProd = g2.form.homeProd
            OPTS.neutralProd = g2.form.neutralProd
            OPTS.mapType = string.sub(e["value"], 8)
            start()
        elseif e["value"] == "restart" then
            start()
        elseif e["value"] == "home" then
            main_menu()
        elseif (e["value"] == "resume") then
            if OPTS.time == nil then
                OPTS.time = 0
            end
            g2.state = "play"
        elseif (e["value"] == "quit") then
            g2.state = "quit"
        end
    elseif e["type"] == "pause" then
        paused()
        g2.state = "pause"
    end
end

function main_menu()
    counter = 0
    reset()
    get_ready()
    g2.state = "menu"
end

function get_ready()
    g2.html =
        "glide" ..
        "<table>" ..
            "<tr><td><h1>Gliding Challenge: Get Ready!</h1>" ..
                "<tr><td><input type='button' value='ZigZag map' onclick='newmap:zigzag' />" ..
                    "<tr><td><input type='button' value='Circular map' onclick='newmap:circular' />" ..
                        "<tr><td><input type='button' value='Line map' onclick='newmap:row' />" ..
                            "<tr><td><input type='button' value='Cross map' onclick='newmap:cross' /></tr>" ..
                                "<tr><td><input type='button' value='Log Spiral map' onclick='newmap:logspiral' />" ..
                                    "<tr><td><input type='button' value='Astroid map' onclick='newmap:astroid' />" ..
                                        "<tr><td><input type='button' value='Butterfly map' onclick='newmap:butterfly' />" ..
                                            "<tr><td><input type='button' value='Random 5x5 Grid map' onclick='newmap:randomgrid' /></tr>" ..
                                                "<tr><td><p>Neutrals (depends on map type):</p><td><input type='text' name='num_planets'  />" ..
                                                    "<tr><td><p>Home production:</p><td><input type='text' name='homeProd'  />" ..
                                                        "<tr><td><p>Neutral production:</p><td><input type='text' name='neutralProd'  />" ..
                                                            "glide"

    g2.form.num_planets = OPTS.num_planets
    g2.form.homeProd = OPTS.homeProd
    g2.form.neutralProd = OPTS.neutralProd
end

function paused()
    local restart_opts = "glide"
    if OPTS.data then
        restart_opts = ":" .. OPTS.data
    end
    g2.html =
        "glide" ..
        "<table>" ..
            "<tr><td><input type='button' value='Resume'          onclick='resume' />" ..
                "<tr><td><input type='button' value='Restart'   onclick='restart' />" ..
                    "<tr><td><input type='button' value='New Challenge'   onclick='home' />" ..
                        "<tr><td><input type='button' value='Quit'            onclick='quit' />" .. "glide"
end

function glide_init()
    g2.game_reset()

    OPTS.isStarted = false
    OPTS.time = 0

    local neutral = g2.new_user("neutral", COLORS[1])
    neutral.user_neutral = 1
    neutral.ships_production_enabled = 0

    local player = g2.new_user("player", COLORS[11])
    player.ui_ships_show_mask = 0xf
    player.ships_production_enabled = 0
    g2.player = player
    g2.item(player, "has_player", 1)

    local function create_shape(shape)
        local radius = 7 * (OPTS.num_planets + 1)
        local radial_spacing = 2 * math.pi / (OPTS.num_planets + 1)
        local neutralRadius = prodToRadius(OPTS.neutralProd)
        local homeRadius = prodToRadius(OPTS.homeProd)

        local linearSpacingDiff = homeRadius - neutralRadius
        local firstNeutralAngleOffset = linearSpacingDiff / radius

        local neutralAngleSpan = 2 * math.pi - 2 * firstNeutralAngleOffset

        if shape == "row" then
            g2.new_planet(player, 0, 0, OPTS.homeProd, 100)
            for i = 1, OPTS.num_planets do
                g2.new_planet(neutral, 40 * i + linearSpacingDiff, 0, OPTS.neutralProd, costs)
            end
        elseif shape == "zigzag" then
            local diagonalLinearSpacingDiff = math.sqrt(20 ^ 2 + linearSpacingDiff ^ 2)
            local neutralOffset = diagonalLinearSpacingDiff / radius
            local homeOffset = neutralOffset + linearSpacingDiff
            g2.new_planet(player, -homeOffset, 0, OPTS.homeProd, 100)
            for i = 1, OPTS.num_planets do
                if i % 2 == 0 then
                    g2.new_planet(neutral, 40 * i + neutralOffset, 0, OPTS.neutralProd, costs)
                else
                    g2.new_planet(neutral, 40 * i + neutralOffset, 20 + neutralOffset, OPTS.neutralProd, costs)
                end
            end
        elseif shape == "circular" then
            for i = 0, OPTS.num_planets do
                local angle = firstNeutralAngleOffset + neutralAngleSpan * i / (OPTS.num_planets + 1)
                if i == 0 then
                    g2.new_planet(player, radius * math.cos(0), radius * math.sin(0), OPTS.homeProd, 100)
                else
                    g2.new_planet(neutral, radius * math.cos(angle), radius * math.sin(angle), OPTS.neutralProd, costs)
                end
            end
        elseif shape == "logspiral" then
            for i = 0, OPTS.num_planets do
                local angle = firstNeutralAngleOffset + neutralAngleSpan * i / (OPTS.num_planets + 1)
                if i == 0 then
                    g2.new_planet(
                        player,
                        radius * math.exp(0) * math.cos(0),
                        radius * math.exp(0) * math.sin(0),
                        OPTS.homeProd,
                        100
                    )
                else
                    g2.new_planet(
                        neutral,
                        radius * math.exp(angle / 5) * math.cos(angle),
                        radius * math.exp(angle / 5) * math.sin(angle),
                        OPTS.neutralProd,
                        costs
                    )
                end
            end
        elseif shape == "astroid" then
            for i = 0, OPTS.num_planets do
                local angle = firstNeutralAngleOffset + neutralAngleSpan * i / (OPTS.num_planets + 1)
                if i == 0 then
                    g2.new_planet(
                        player,
                        radius * math.pow(math.cos(0), 3),
                        radius * math.pow(math.sin(0), 3),
                        OPTS.homeProd,
                        100
                    )
                else
                    g2.new_planet(
                        neutral,
                        radius * math.pow(math.cos(angle), 3),
                        radius * math.pow(math.sin(angle), 3),
                        OPTS.neutralProd,
                        costs
                    )
                end
            end
        elseif shape == "butterfly" then
            for i = 0, OPTS.num_planets do
                if i == 0 then
                    local angle = 0
                    local bit1 = math.sin(angle)
                    local bit1y = math.cos(angle)
                    local bit2 = math.exp(math.cos(angle)) - 2 * math.cos(4 * angle) - math.pow(math.sin(angle / 12), 5)
                    g2.new_planet(player, radius * bit1 * bit2, radius * bit1y * bit2, OPTS.homeProd, 100)
                else
                    local angle = firstNeutralAngleOffset + neutralAngleSpan * i / (OPTS.num_planets + 1)
                    local bit1 = math.sin(angle)
                    local bit1y = math.cos(angle)
                    local bit2 = math.exp(math.cos(angle)) - 2 * math.cos(4 * angle) - math.pow(math.sin(angle / 12), 5)
                    g2.new_planet(neutral, radius * bit1 * bit2, radius * bit1y * bit2, OPTS.neutralProd, costs)
                end
            end
        elseif shape == "randomgrid" then
            theGrid = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
            for i = 1, 5 do
                for j = 1, 5 do
                    local randv = math.floor(math.random(1, 100.5))
                    if randv % 2 == 0 then
                        theGrid[i][j] = 0
                    else
                        theGrid[i][j] = 1
                    end
                end
            end

            local home = math.floor(math.random(1, 25.5))

            planetAsPix(theGrid, player, neutral, OPTS.neutralProd, costs, home)
        elseif shape == "cross" then
            local t = OPTS.num_planets / 4
            radius = 1.4 * (OPTS.num_planets + 1)
            local diagonalLinearSpacingDiff = math.sqrt(20 ^ 2 + linearSpacingDiff ^ 2)
            local neutralOffset = diagonalLinearSpacingDiff / radius
            local homeOffset = neutralOffset + linearSpacingDiff
            for i = 0, OPTS.num_planets do
                if i == 0 then
                    g2.new_planet(player, 0, 0, OPTS.homeProd, 100)
                elseif i <= t and i >= 0 then
                    g2.new_planet(
                        neutral,
                        -5 / t * (i - t * 0) * radius - homeOffset + 5.6,
                        5 / t * (i - t * 0) * radius + homeOffset - 5.6,
                        OPTS.neutralProd,
                        costs
                    )
                elseif i > t and i <= t * 2 then
                    g2.new_planet(
                        neutral,
                        -5 / t * (i - t * 1) * radius - homeOffset + 5.6,
                        -5 / t * (i - t * 1) * radius - homeOffset + 5.6,
                        OPTS.neutralProd,
                        costs
                    )
                elseif i > t * 2 and i <= t * 3 then
                    g2.new_planet(
                        neutral,
                        5 / t * (i - t * 2) * radius + homeOffset - 5.6,
                        -5 / t * (i - t * 2) * radius - homeOffset + 5.6,
                        OPTS.neutralProd,
                        costs
                    )
                elseif i > t * 3 and i <= t * 4 then
                    g2.new_planet(
                        neutral,
                        5 / t * (i - t * 3) * radius + homeOffset - 5.6,
                        5 / t * (i - t * 3) * radius + homeOffset - 5.6,
                        OPTS.neutralProd,
                        costs
                    )
                end
            end
        end
    end
    create_shape(OPTS.mapType)
end

function prodToRadius(p)
    return (p * 12 / 5 + 168) / 17
end

function glide_victory()
    local function fix(v, d, a, b)
        if (type(v) == "string") then
            v = tonumber(v)
        end
        if (type(v) ~= "number") then
            v = d
        end
        if v < a then
            v = a
        end
        if v > b then
            v = b
        end
        return v
    end
    local rank = math.floor(10 - (((OPTS.time / OPTS.num_planets) * 10) - 10))
    rank = fix(rank, 1, 1, 10)

    g2.html =
        "glide" ..
        "<table>" ..
            "<tr><td><h1>Good Job!</h1>" ..
                "<tr><td><p>Time: " ..
                    string.format("%f", OPTS.time) ..
                        " seconds</p>" ..
                            "<tr><td>" ..
                                "<tr><td>" ..
                                    "<input type='image' src='rank" ..
                                        rank ..
                                            ".png' width=34 height=34/>" ..
                                                "<tr><td><input type='button' value='Replay' onclick='restart' />" ..
                                                    "<tr><td><input type='button' value='New Challenge' onclick='home' />" ..
                                                        "<tr><td><input type='button' value='Quit' onclick='quit' />" ..
                                                            "glide"
end

function planetAsPix(thePix, pla, neu, pro, co, hm)
    local spacefac = 50
    --  pla.planet_crash = 1
    if thePix[1][1] == 1 then
        if hm == 1 then
            g2.new_planet(pla, -2 * spacefac, -2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -2 * spacefac, -2 * spacefac, pro, co)
        end
    end
    if thePix[1][2] == 1 then
        if hm == 2 then
            g2.new_planet(pla, -2 * spacefac, -1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -2 * spacefac, -1 * spacefac, pro, co)
        end
    end
    if thePix[1][3] == 1 then
        if hm == 3 then
            g2.new_planet(pla, -2 * spacefac, 0 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -2 * spacefac, 0 * spacefac, pro, co)
        end
    end
    if thePix[1][4] == 1 then
        if hm == 4 then
            g2.new_planet(pla, -2 * spacefac, 1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -2 * spacefac, 1 * spacefac, pro, co)
        end
    end
    if thePix[1][5] == 1 then
        if hm == 5 then
            g2.new_planet(pla, -2 * spacefac, 2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -2 * spacefac, 2 * spacefac, pro, co)
        end
    end

    if thePix[2][1] == 1 then
        if hm == 6 then
            g2.new_planet(pla, -1 * spacefac, -2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -1 * spacefac, -2 * spacefac, pro, co)
        end
    end
    if thePix[2][2] == 1 then
        if hm == 7 then
            g2.new_planet(pla, -1 * spacefac, -1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -1 * spacefac, -1 * spacefac, pro, co)
        end
    end
    if thePix[2][3] == 1 then
        if hm == 8 then
            g2.new_planet(pla, -1 * spacefac, 0 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -1 * spacefac, 0 * spacefac, pro, co)
        end
    end
    if thePix[2][4] == 1 then
        if hm == 9 then
            g2.new_planet(pla, -1 * spacefac, 1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -1 * spacefac, 1 * spacefac, pro, co)
        end
    end
    if thePix[2][5] == 1 then
        if hm == 10 then
            g2.new_planet(pla, -1 * spacefac, 2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, -1 * spacefac, 2 * spacefac, pro, co)
        end
    end

    if thePix[3][1] == 1 then
        if hm == 11 then
            g2.new_planet(pla, 0 * spacefac, -2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 0 * spacefac, -2 * spacefac, pro, co)
        end
    end
    if thePix[3][2] == 1 then
        if hm == 12 then
            g2.new_planet(pla, 0 * spacefac, -1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 0 * spacefac, -1 * spacefac, pro, co)
        end
    end
    if thePix[3][3] == 1 then
        if hm == 13 then
            g2.new_planet(pla, 0 * spacefac, 0 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 0 * spacefac, 0 * spacefac, pro, co)
        end
    end
    if thePix[3][4] == 1 then
        if hm == 14 then
            g2.new_planet(pla, 0 * spacefac, 1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 0 * spacefac, 1 * spacefac, pro, co)
        end
    end
    if thePix[3][5] == 1 then
        if hm == 15 then
            g2.new_planet(pla, 0 * spacefac, 2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 0 * spacefac, 2 * spacefac, pro, co)
        end
    end

    if thePix[4][1] == 1 then
        if hm == 16 then
            g2.new_planet(pla, 1 * spacefac, -2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 1 * spacefac, -2 * spacefac, pro, co)
        end
    end
    if thePix[4][2] == 1 then
        if hm == 17 then
            g2.new_planet(pla, 1 * spacefac, -1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 1 * spacefac, -1 * spacefac, pro, co)
        end
    end
    if thePix[4][3] == 1 then
        if hm == 18 then
            g2.new_planet(pla, 1 * spacefac, 0 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 1 * spacefac, 0 * spacefac, pro, co)
        end
    end
    if thePix[4][4] == 1 then
        if hm == 19 then
            g2.new_planet(pla, 1 * spacefac, 1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 1 * spacefac, 1 * spacefac, pro, co)
        end
    end
    if thePix[4][5] == 1 then
        if hm == 20 then
            g2.new_planet(pla, 1 * spacefac, 2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 1 * spacefac, 2 * spacefac, pro, co)
        end
    end

    if thePix[5][1] == 1 then
        if hm == 21 then
            g2.new_planet(pla, 2 * spacefac, -2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 2 * spacefac, -2 * spacefac, pro, co)
        end
    end
    if thePix[5][2] == 1 then
        if hm == 22 then
            g2.new_planet(pla, 2 * spacefac, -1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 2 * spacefac, -1 * spacefac, pro, co)
        end
    end
    if thePix[5][3] == 1 then
        if hm == 23 then
            g2.new_planet(pla, 2 * spacefac, 0 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 2 * spacefac, 0 * spacefac, pro, co)
        end
    end
    if thePix[5][4] == 1 then
        if hm == 24 then
            g2.new_planet(pla, 2 * spacefac, 1 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 2 * spacefac, 1 * spacefac, pro, co)
        end
    end
    if thePix[5][5] == 1 then
        if hm == 25 then
            g2.new_planet(pla, 2 * spacefac, 2 * spacefac, pro, 100)
        else
            g2.new_planet(neu, 2 * spacefac, 2 * spacefac, pro, co)
        end
    end
end
