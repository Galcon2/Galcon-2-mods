function init()
    OPTS = {
        sw = 480,
        sh = 320, 
        neutrals = 25,
        player_prod = 100,
        player_ships = 100,
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
	local lines_horizontal = 10
    local lines_vertical = 15
    local x = 0
    local y = 0
    local x_1 = 0
	local y_1 = 0
	local x_2 = 0
    local y_2 = 0
    local oldCoordinates = {}
    local newCoordinates = {}
    local spacingBuffer = 60 -- change to actual buffer value
    for i=1, OPTS.neutrals/2 do
        local prod = math.random(15,100)
        local ships = math.random(0,50)
        --spawn first neutral
        if i == 1 then
            x = math.random(OPTS.sw/lines_vertical,OPTS.sw/lines_vertical*(lines_vertical-1))
            y = math.random(OPTS.sh/lines_horizontal,OPTS.sh/lines_horizontal*(lines_horizontal-1))
            x_1 = x
            y_1 = y
            print ("old coordinates: "..dump(oldCoordinates))
            table.insert(oldCoordinates, {x_1, y_1})
            print ("old coordinates: "..dump(oldCoordinates))
            g2.new_planet(neutral_player, x, y, prod, ships)
            g2.new_planet(neutral_player, OPTS.sw - x, OPTS.sh - y, prod, ships)

            print ("first neutral: "..x_1.."  "..y_1)
		elseif i >= 2 and i < 5 then -- change to i >= 2 | else
            x = math.random(OPTS.sw/lines_vertical,OPTS.sw/lines_vertical*(lines_vertical-1))
            y = math.random(OPTS.sh/lines_horizontal,OPTS.sh/lines_horizontal*(lines_horizontal-1))
            x_2 = x
            y_2 = y
            print ("new coordinates: "..dump(newCoordinates))
            table.insert(newCoordinates, {x_2, y_2})
            print ("new coordinates: "..dump(newCoordinates))
            print ("distance: "..distance(newCoordinates[1][1],oldCoordinates[1][1], newCoordinates[1][2],oldCoordinates[1][2]))
            print ("distance: "..distance(newCoordinates[1][1],OPTS.sw-oldCoordinates[1][1], newCoordinates[1][2],OPTS.sh-oldCoordinates[1][2]))
            if distance(newCoordinates[1][1],oldCoordinates[1][1], newCoordinates[1][2],oldCoordinates[1][2]) > spacingBuffer and distance(newCoordinates[1][1],OPTS.sw-oldCoordinates[1][1], newCoordinates[1][2],OPTS.sh-oldCoordinates[1][2]) > spacingBuffer then
                g2.new_planet(neutral_player, x, y, prod, ships)
                g2.new_planet(neutral_player, OPTS.sw - x, OPTS.sh - y, prod, ships)
                table.remove(newCoordinates, 1)
                print ("new coordinates2: "..dump(newCoordinates))
                table.insert(oldCoordinates, {x_2, y_2})
                print ("old coordinates2: "..dump(oldCoordinates))
            end
			print ("second neutral: "..x_2.."  "..y_2)
		end
		-- print properly cause obsessive compulsive disorder
		--[[ if x < 100 then
			print (x.."   "..y)
		else
			print (x.."  "..y)
		end ]]
        
    end
	-- draw grid
	
	for i=0, lines_horizontal do
		g2.new_line(0xffffff, 0, OPTS.sh/lines_horizontal*i, OPTS.sw, OPTS.sh/lines_horizontal*i)
	end
	for i=0, lines_vertical do
		g2.new_line(0xffffff, OPTS.sw/lines_vertical*i, 0, OPTS.sw/lines_vertical*i, OPTS.sh)
	end
	-- define square
	g2.new_line(0xff0000, 0, 0, OPTS.sw/lines_vertical, 0)
	g2.new_line(0xff0000, OPTS.sw/lines_vertical, 0, OPTS.sw/lines_vertical, OPTS.sh/lines_horizontal)
	g2.new_line(0xff0000, OPTS.sw/lines_vertical, OPTS.sh/lines_horizontal, 0, OPTS.sh/lines_horizontal)
	g2.new_line(0xff0000, 0, OPTS.sh/lines_horizontal, 0, 0)
	
    local player = g2.new_user("Player", 0x0000ff)
    g2.player = player
    OPTS.player = player
 
    local enemy = g2.new_user("Enemy", 0xff0000)
    OPTS.enemy = enemy
	
	local a = math.random(0,360)
	local pad = OPTS.sh/lines_horizontal
    local x = OPTS.sw/2 + (OPTS.sw-pad)*math.cos(a*math.pi/180.0)/2.0
    local y = OPTS.sh/2 + (OPTS.sh-pad)*math.sin(a*math.pi/180.0)/2.0
	function border()
		while x < OPTS.sw/lines_vertical or x > OPTS.sw/lines_vertical*(lines_vertical-1) do
			x = math.random()*OPTS.sw
			print("x:"..x)
		end
		
		while y < OPTS.sh/lines_horizontal or y > OPTS.sh/lines_horizontal*(lines_horizontal-1) do
			y = math.random()*OPTS.sh
			print("y:"..y)
		end
	end
	function middle()
		while x > OPTS.sw/lines_vertical*4 and x < OPTS.sw/lines_vertical*(lines_vertical-4) and y > OPTS.sh/lines_horizontal*2 and y < OPTS.sh/lines_horizontal*(lines_horizontal-2) do
			x = math.random()*OPTS.sw
			print("x2:"..x)
			y = math.random()*OPTS.sh
			print("y2:"..y)
		end
	end
	
    local prod = OPTS.player_prod
    local ships = OPTS.player_ships
    g2.new_planet(player, x, y, prod, ships)
    g2.new_planet(enemy, OPTS.sw - x, OPTS.sh - y, prod, ships)
	
	--g2.planets_settle(0, 0, OPTS.sw, OPTS.sh) 
end

function distance(x_2,x_1,y_2,y_1)
	return math.sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2)
end
 
--[[ function loop(t)
    local player_planets = g2.search("planet owner:"..OPTS.player)
    local enemy_planets = g2.search("planet owner:"..OPTS.enemy)
 --[[
    if #player_planets == 0 then
        init_lose()
    elseif #enemy_planets == 0 then
        init_win()
    end
end ]]--
 
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
    g2.html = "<table><tr><td><h1>Good job!"..
              "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end
 
function init_lose()
    g2.state = "pause"
    g2.html = "<table><tr><td><h1>Try again?"..
              "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end
-- UTILITY FUNCTIONS
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
