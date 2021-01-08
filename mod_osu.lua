function init()
    OPTS = {
        sw = 480,
        sh = 320,
        size = 80,
        number = 1
    }

    -- COLORSORDER[2,13] = {"BLUE","RED","YELLOW","CYAN","WHITE","ORANGE","MINT","SALMON","PURPLE","PINK","PERIWINKLE","GREEN"}
    COLORS = {0x555555, -- gray
        0x0000ff,0xff0000,
        0xffff00,0x00ffff,
        0xffffff,0xffbb00,
        0x99ff99,0xff9999,
        0xbb00ff,0xff88ff,
        0x9999ff,0x00ff00,
    }
    totalscore = 0
    scorelabel = {}
    labelmargin = 25
    score = 0
    maxsize = 100
    lastCircleradius = 0
    waittime = 0.25
    currenttime = 0
    init_game()
end

function init_game()
    OPTS.time = 0
    g2.game_reset()
    
    g2.ticks = 1
    g2.speed = 1

    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)

    spawnCircle()


end

function spawnCircle()
    local circlecolor = 0xff0000
    
    neutral_player = g2.new_user("", circlecolor)
    g2.player = neutral_player
    neutral_player.ships_production_enabled = false
    neutral_player.title_value = nil

    local marginW = 15
    local marginH = 10
    local x = math.random(OPTS.sw/marginW,OPTS.sw/marginW*(marginW-1))
    local y = math.random(OPTS.sh/marginH,OPTS.sh/marginH*(marginH-1))

    planetradius = prodToRadius(OPTS.size)
    local buffer = 2*planetradius
    circleradius = planetradius + buffer
    transparentCirclradius = planetradius + buffer*2

    new_planet = g2.new_planet(neutral_player, x, y, OPTS.size, OPTS.number)
    new_planet_x = new_planet.position_x
    new_planet_y = new_planet.position_y

    new_circle = g2.new_circle(circlecolor, x, y, transparentCirclradius)
end

function loop(t)

    OPTS.time = OPTS.time + t --make time not depend on fps
    --make circle go from transparent to full max alpha
    if transparentCirclradius >= circleradius then
        if OPTS.time >= waittime then
            new_circle.draw_r = transparentCirclradius - 0.25
            transparentCirclradius = transparentCirclradius - 0.25
        end
    end
    --make circle approach planet
    if circleradius >= planetradius and transparentCirclradius <= circleradius then
            new_circle.draw_r = circleradius - 0.25
            circleradius = circleradius - 0.25
    end
    --give score if planet is clicked before circle hits planetradius
    
    if circleradius > planetradius*2 and new_planet:selected() and score == 0 then
        currenttime = OPTS.time
        score = "X"
        g2.new_label(score, new_planet_x + labelmargin, new_planet_y - labelmargin, 0xff0000)
    end
    if circleradius > planetradius*5/3 and circleradius < planetradius*2 and new_planet:selected() and score == 0 then
        currenttime = OPTS.time
        score = 50
        totalscore = totalscore + score
        g2.new_label(score, new_planet_x + labelmargin, new_planet_y - labelmargin, 0xffffff)
    end
    if circleradius > planetradius*1.25 and circleradius < planetradius*5/3 and new_planet:selected() and score == 0 then
        currenttime = OPTS.time
        score = 100
        totalscore = totalscore + score
        g2.new_label(score, new_planet_x + labelmargin, new_planet_y - labelmargin, 0xffffff)
    end
    if circleradius >= planetradius and circleradius < planetradius*1.25 and new_planet:selected() and score == 0 then
        currenttime = OPTS.time
        score = 300
        totalscore = totalscore + score
        score_label = g2.new_label(score, new_planet_x + labelmargin, new_planet_y - labelmargin, 0xffffff)
    end
    --[[ if OPTS.time >= currenttime + 0.50 and currenttime ~= 0 then -- BUGGED
        score_label:destroy()
    end ]]
    --make planet increase in size and decrease in transparency when circleradius >= planetradius until 0 -> destroy object
    if circleradius <= planetradius and OPTS.size <= maxsize then
        new_planet:destroy()
        g2.new_planet(neutral_player, new_planet_x, new_planet_y, OPTS.size + 1, OPTS.number)
        OPTS.size = OPTS.size + 1
    end
   --[[  if OPTS.size == maxsize then - BUGGED
        new_planet:destroy()
        new_circle:destroy()
    end ]]
end

function event(e)

end

function prodToRadius(p)
    return (p*12/5 + 168)/17
end
--[[UTILITY FUNCTIONS]]--
-- passing a table like {255, 100, 20}
function rgbToHex(rgb)
	local hexadecimal = '0x'

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end
    return hexadecimal
    
end

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

function LightenDarkenColor(col, amt)
    local num = tonumber(col, 16)
    local r = rshift(num, 16) + amt
    local b = bit32.band(rshift(num, 8), 0x00FF) + amt
    local g = bit32.band(num, 0x0000FF) + amt
    local newColor = bit32.bor(g, lshift(b, 8), lshift(r, 16))
    return string.format("%d", newColor)
end

function lshift(x, by)
    return x * 2 ^ by
end
  
  function rshift(x, by)
    return math.floor(x / 2 ^ by)
end

function darkenColor(col)
    return col - 0x110000
end

function lightenColor(col)
    return col + 0x110000
end
