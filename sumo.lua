LICENSE =
    [[
mod_training.lua

Copyright (c) 2013 Phil Hassey

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

all_planets = nil

player = nil
player2 = nil
home = nil
home2 = nil
neutral = nil
first = true
p1color = nil
p2color = nil

function init()
    all_planets = nil
    math.randomseed(os.time())
    max_cost = 10
    max_prod = 70
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
    OPTS = {
        time = 0,
        sw = 480,
        sh = 320,
        num_planets = 24,
        homeProd = 100,
        circleRad = 150,
        forceFac = 2
    }
    main_menu()
end

function loop(t)
    OPTS.time = OPTS.time + t

    local countdown = 3 - math.floor(OPTS.time)

    sumo_move(countdown)

    if home1 ~= nil and home2 ~= nil then
        if home1.position_x * home1.position_x + home1.position_y * home1.position_y > OPTS.circleRad * OPTS.circleRad then
            sumo_victory("PLAYER 2")
            g2.state = "pause"
        elseif
            home2.position_x * home2.position_x + home2.position_y * home2.position_y > OPTS.circleRad * OPTS.circleRad
         then
            sumo_victory("PLAYER 1")
            g2.state = "pause"
        end
    end
end

function start()
    OPTS.time = 0
    first = true
    g2.state = "play"
    sumo_init()
end

function event(e)
    if e["type"] == "onclick" and e["value"] then
        if string.find(e["value"], "mode:") ~= nil then
            OPTS.mode = string.sub(e["value"], 6)
            _ENV[OPTS.mode .. "_menu"]()
        elseif string.find(e["value"], "newmap:") ~= nil then
            OPTS.num_planets = g2.form.num_planets
            OPTS.circleRad = g2.form.sumorad
            OPTS.homeProd = g2.form.homeProd
            OPTS.forceFac = g2.form.force
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
    get_ready()
    g2.state = "menu"
end

function get_ready()
    g2.html =
        "sumo" ..
        "<table>" ..
            "<tr><td><h1>Sumo! Eat rice!</h1>" ..
                "<tr><td><h3>-AlGalcone.</h3>" ..
                    "<tr><td><h3></h3>" ..
                        "<tr><td><input type='button' value='Fight!' onclick='newmap:sumomap' />" ..
                            "<tr><td><p>Sumo Radius:</p><td><input type='text' name='sumorad'  />" ..
                                "<tr><td><p>Neutrals (must be 15% of radius*):</p><td><input type='text' name='num_planets'  />" ..
                                    "<tr><td><p>Home production:</p><td><input type='text' name='homeProd'  />" ..
                                        "<tr><td><p>Force factor:</p><td><input type='text' name='force'  />" ..
                                            "<tr><td><p></p>/>" ..
                                                "<tr><td><p>*will automatically update next challenge</p>/>" .. "sumo"
    g2.form.homeProd = OPTS.homeProd
    g2.form.sumorad = OPTS.circleRad
    g2.form.num_planets = (24 / 150) * OPTS.circleRad
    g2.form.force = OPTS.forceFac
end

function paused()
    local restart_opts = "sumo"
    if OPTS.data then
        restart_opts = ":" .. OPTS.data
    end
    g2.html =
        "sumo" ..
        "<table>" ..
            "<tr><td><input type='button' value='Resume'          onclick='resume' />" ..
                "<tr><td><input type='button' value='Restart'   onclick='restart' />" ..
                    "<tr><td><input type='button' value='New Challenge'   onclick='home' />" ..
                        "<tr><td><input type='button' value='Quit'            onclick='quit' />" .. "sumo"
end

function prodToRadius(p)
    return (p * 12 / 5 + 168) / 17
end

function create_shape()
    g2.new_circle(0xff5555, 0, 0, OPTS.circleRad)
    g2.new_circle(0x222222, 0, 0, 1.2 * OPTS.circleRad)
    g2.new_planet(player, -OPTS.circleRad + 50, 0, OPTS.homeProd, 100)
    g2.new_planet(player2, OPTS.circleRad - 50, 0, OPTS.homeProd, 100)

    local radius = 8 * (OPTS.num_planets + 1)
    local radial_spacing = 2 * math.pi / (OPTS.num_planets + 1)
    local neutralRadius = prodToRadius(0)
    local homeRadius = prodToRadius(OPTS.homeProd)

    local neutralAngleSpan = 2 * math.pi
    for i = 0, OPTS.num_planets / 2 do
        local angle = neutralAngleSpan * i / (OPTS.num_planets + 1)
        local rand_cost = math.floor(math.random(0, max_cost))
        local rand_prod = math.floor(math.random(1, max_prod))
        g2.new_planet(neutral, radius * math.cos(angle), 1.5 * radius * math.sin(angle), rand_prod, rand_cost)
        g2.new_planet(neutral, -radius * math.cos(angle), -1.5 * radius * math.sin(angle), rand_prod, rand_cost)
    end
    return false
end


function vector_len(vx, vy)
    return math.sqrt(vx * vx + vy * vy)
end

function sumo_move(countdown)
    if home1 ~= nil then
        home1.has_motion = false
    end
    if home2 ~= nil then
        home2.has_motion = false
    end
    local lab = nil
    if countdown == 3 then
        lab = g2.new_label(string.format(" ..%d", countdown), 0, 1.15 * OPTS.circleRad + 60, 0x300210)
    elseif countdown == 2 then
        lab = g2.new_label(string.format(" ..%d        ", countdown), 0, 1.15 * OPTS.circleRad + 60, 0x300210)
    elseif countdown == 1 then
        lab = g2.new_label(string.format(" ..%d                ", countdown), 0, 1.15 * OPTS.circleRad + 60, 0x300210)
    elseif countdown == 0 then
        lab =
            g2.new_label(
            string.format("%s                               ", "Ready"),
            0,
            -1.15 * OPTS.circleRad + 40,
            0x301410
        )
    elseif countdown == -1 then
        lab =
            g2.new_label(
            string.format("%s                                     ", "Go!"),
            0,
            -1.15 * OPTS.circleRad + 10,
            0x302510
        )
    else
        if lab ~= nil then
            lab:destroy()
        end
    end

    if countdown ~= nil and countdown < 0 then
        --		if lab~= nil then
        --			lab:destroy()
        --		end
        --		if home1~=nil then
        --			home1.has_motion= false
        --		end
        --		if home2~=nil then

        --			home2.has_motion= false
        --		end

        all_planets = g2.search("planet")

        local user_planets = g2.search("planet owner:user")

        if user_planets ~= nil and user_planets[1] ~= nil then
            home1 = user_planets[1]
            home1.has_physics = true
            home1.has_motion = true
            home1.fleet_crash = true
        end

        if user_planets ~= nil and user_planets[2] ~= nil then
            home2 = user_planets[2]
            home2.has_physics = true
            home2.has_motion = true
            home2.fleet_crash = true

            local fleets = g2.search("fleet")
            for i = 1, #fleets do
                local fleet = fleets[i]
                if fleet ~= nil and all_planets ~= nil then
                    --					local target_planet = all_planets[fleet.fleet_target]
                    if
                        fleet.position_x * fleet.position_x + fleet.position_y * fleet.position_y <
                            1.2 * 1.2 * OPTS.circleRad * OPTS.circleRad
                     then
                        if player2 ~= nil and fleet.owner_n == player2.n then
                            local multiplier = -0.05 * fleet.fleet_ships * OPTS.forceFac
                            home2.motion_vx =
                                multiplier * (fleet.position_x - home2.position_x) /
                                vector_len(fleet.position_x - home2.position_x, fleet.position_y - home2.position_y)
                            home2.motion_vy =
                                multiplier * (fleet.position_y - home2.position_y) /
                                vector_len(fleet.position_x - home2.position_x, fleet.position_y - home2.position_y)
                        end
                    end
                end
            end
        end
    end
end

function sumo_init()
    g2.game_reset()
    g2.speed = 1.25

    neutral = g2.new_user("neutral", COLORS[1])
    neutral.user_neutral = 1
    neutral.ships_production_enabled = 0

    local rand_color = math.floor(math.random(2, 13))
    player = g2.new_user("player", COLORS[rand_color])
    p1color = COLORS[rand_color]
    player.ui_ships_show_mask = 0xf
    player.ships_production_enabled = 1
    g2.player = player
    if rand_color ~= 2 then
        rand_color2 = math.floor(math.random(2, rand_color - 1))
    else
        rand_color2 = 2
    end
    if rand_color2 ~= 12 then
        rand_color3 = math.floor(math.random(rand_color2 + 1, 13))
    else
        rand_color3 = 12
    end
    local whichcolor = math.floor(math.random(0, 2))
    if whichcolor < 1 then
        player2 = g2.new_user("player2", COLORS[rand_color2])
        p2color = COLORS[rand_color2]
    else
        player2 = g2.new_user("player2", COLORS[rand_color3])
        p3color = COLORS[rand_color3]
    end
    player2.ui_ships_show_mask = 0xf
    player2.ships_production_enabled = 1
    g2.player = player2

    if first and player ~= nil and neutral ~= nil and player2 ~= nil then
        first = create_shape()
    end
end

function sumo_victory(who)
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
        "sumo" ..
        "<table>" ..
            "<tr><td><h1>" ..
                who ..
                    " WINS!</h1>" ..
                        "<tr><td><p>Time: " ..
                            string.format("%f", OPTS.time) ..
                                " seconds</p>" ..
                                    "<tr><td><p>Total ships: </p>" ..
                                        "<tr><td>" ..
                                            "<tr><td>" ..
                                                "<tr><td><input type='button' value='Replay' onclick='restart' />" ..
                                                    "<tr><td><input type='button' value='New Challenge' onclick='home' />" ..
                                                        "<tr><td><input type='button' value='Quit' onclick='quit' />" ..
                                                            "sumo"
end
