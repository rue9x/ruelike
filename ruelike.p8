pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- main
function _init()
  init_tiles()
  init_draws()
	 init_player_state()
	 init_player_status()
	 init_debug()
	 init_first_level()
	 new_tile = 0
	 
end

function _update()
		frame_counter += 1
	 current_level = get_current_level()
  update_check_buttons()
  update_character_offset()
  update_stat_ui()
end

function _draw()
		cls(0)
		draw_level()
		draw_player()
		draw_windows()
	 --if (debug_mode == true) show_msg(debugstring)
  
end


-->8
-- player tools
function move_player(direction, amount)
				dest_x, dest_y = player_x, player_y
				player_direction = direction
				if (player_state == "standing" or player_state == "end_dest") then
				    if (player_direction == "left") and (handle_collision("left",amount) == true) then
				        dest_x = (player_x - amount)
				        player_state = "moving"
				        player_offset_x = 0
				    end
				    
				    if (player_direction == "right") and (handle_collision("right",amount) == true) then
				        dest_x = (player_x + amount)
					       player_state = "moving"
					       player_offset_x = 0
				   
					   end
				    
				    if (player_direction == "up") and (handle_collision("up",amount) == true) then
				        dest_y = player_y - amount
					       player_state = "moving"
				        player_offset_y = 0
					   end
				    
				    if (player_direction == "down" ) and (handle_collision("down",amount) == true) then
				        dest_y = (player_y + amount)
					       player_state = "moving"
				        player_offset_y = 0
					   end	   				
    end
    
end


-->8
-- map tools
function get_tile_info_by_coords(x,y)
				-- returns target sprite, if it's walkable, if its collectable, and what it is
				retval = {}
				tspr = mget(x,y)
    -- get item info
			 for k,v in pairs(tile_info) do
			    if (v == tspr) retval["target_info"] = k
			 end
			 retval.target_sprite = tspr
				retval.target_unwalkable = fget(tspr,0)
				retval.target_collectable = fget(tspr,1)
				retval.target_enemy= fget(tspr,2)

				return retval
end


function handle_collision(direction,amount)
				target_tile_coords = {player_x, player_y}
				if (direction == "left") then
							target_tile_coords[1] = player_x - amount
				end
				if (direction == "right") then 
				   target_tile_coords[1] = player_x + amount
				end
				if (direction == "up") then
				   target_tile_coords[2] = player_y - amount
				end
				if (direction == "down") then
				   target_tile_coords[2] = player_y + amount	
				end
				
				ti = get_tile_info_by_coords(target_tile_coords[1],target_tile_coords[2])								

				if (ti.target_collectable == true) then
			    if (ti.target_info == "coin") then
			     	collect_actor(target_tile_coords[1],target_tile_coords[2])
			      gp = get_actor_data(target_tile_coords[1],target_tile_coords[2])
         gp = gp.value
				     player_gold = player_gold+gp
			      make_window(player_x*8,player_y*8-5-10,5,5,{"+"..gp.." gold"},30,"quip")				     
         end	    	
				end			
				if (ti.target_unwalkable == true) then 
								sfx(0)							
								make_window(player_x*8,player_y*8-5-10,5,5,{"oof!"},10,"quip")
				    return false
				else
				    return true
				end
end

function collect_actor(x,y)
		new_tile = level_map[player_x][player_y]
	 sfx(1)
		mset(x, y, new_tile)	
  current_level = get_current_level() 
end

function get_actor_data(px,py)
		for k,v in pairs(level_actors) do
    actor_x = v.x
    actor_y = v.y
    if (actor_x == px and actor_y == py) then
      return v
    end
  end
		return nil 
end

-->8
-- messaging tools

function rectfill2(x,y,w,h,c)
    -- rectfill but takes width/height instead of bottom right corner
    rectfill(x,y,x+w-1,y+h-1,c)
end

function rect2(x,y,w,h)
    -- rect but takes width/height instead of bottom right corner
    rect(x,y,x+w-1,y+h-1)
end


function make_window(_x,_y,_w,_h,_msg,_dur,_sty)
    local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          msg=_msg,
          dur=_dur,
          style=_sty}
    add(wind,w)
    return w
end
function msg(txt)
   make_window(32,32,5,5,{tostr(txt)},30,"quip")				   
end

-->8
-- level building
-- 10x8
function init_levels()
			level_map = { -- big square.
				{13,13,13,13,13,13,13,13,13,13,13,13,13,13,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
				{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
 			{13,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
				{13,13,13,13,13,13,13,13,13,13,13,13,13,13,13}			
			}
   level_map = level_map
			level_actors = {
			 {sprite=38,x=3,y=5,atype="gold",value=10}
			}
			build_level(level_map)
end

function build_level(map_data)
  -- draws whatever map you provide it with
  for _y=1,room_max_y do
    for _x=1,room_max_x do
      
      mset(_x,_y,map_data[_y][_x])
    end
  end
  map()
end

function place_actors(actor_data)
  for k,v in pairs(actor_data) do
     actor_spr = v.sprite
     actor_x = v.x
     actor_y = v.y   
     mset(actor_x,actor_y,actor_spr)
  end
end

function get_blank_level()
  blank_level = {}
		for _y=1,room_max_y do
		  add(blank_level,{}) -- add a new row
		end
		
		for _y=1,#blank_level do
		   for _x=1,room_max_x do
  		   add(blank_level[_y],13)
		   end
		end
return blank_level
end

function get_current_level()
  current_level = get_blank_level()
		for k,v in pairs(current_level) do
    for k2,v2 in pairs(v) do
		  		-- copy what's on screen
		  		tile = mget(k2,k)
				  current_level[k][k2] = tile
				end
		end
  
  return current_level
end


function rnd_between(minv,maxv)
  return flr(rnd(maxv)+minv)
end


-->8
-- draws

function draw_windows()
    draw_count = draw_count + 1
    if (draw_count > 60) draw_count = 0    
    for each in all(wind) do
        wx, wy, ww, wh, msg = each.x, each.y, each.w, each.h, each.msg
				    if (each.style == false or each.style == nil) then
								    -- assume they want borders
								    rectfill2(wx,wy,ww,wh,7) -- outer most border
								    rectfill2(wx+1,wy+1,ww-2,wh-2,0) -- border fill
								    rectfill2(wx+2,wy+2,ww-4,wh-4,7) -- inner border
											 rectfill2(wx+3,wy+3,ww-6,wh-6,0) -- -- actual box
											 clip(wx+3,wy+3,ww-6,wh-6)
					
        elseif (each.style == "quip") then
            
        				-- "quip" style oof! 14 
        		  for eachmsg in all(msg) do   
               -- there really shouldn't be
               -- more than 1 msg per quip...   
        		     rectfill2(wx+4,wy+6,#tostr(eachmsg)*4+2,8,1)    
            end
        end     
								for i=1,#msg do
     						print(msg[i],wx+5,wy+(i*8),7)
 							end
 			    clip()   
        if (each.dur!=nil) then
           each.dur-=1
           if (each.dur<=0) then
              del (wind,each)
           end
        end   
     end
     if (debug_mode == true) then
         print ("window count: "..#wind,0,0)
     end
end

function draw_player()
  -- this handles player draw position
  -- and how the animation is draw.
  palt(0,false)
  playerframe = getframe(player_anim,8)
  if (player_state == "moving") then
		   spr(playerframe,(player_x*8)+player_offset_x,(player_y*8)+player_offset_y)
	 elseif (player_state == "end_dest") then
     spr(playerframe,(player_x*8)+player_offset_x,(player_y*8)+player_offset_y)
     -- revert to standing at end of ani
     if (playerframe == player_anim[2] or playerframe == player_anim[1]) player_state = "standing"
	 elseif (player_state == "standing") then
	    spr(player_anim[1],(player_x*8)+player_offset_x,(player_y*8)+player_offset_y)
	 end
	 palt(0,true)


end

function draw_level()
			build_level(current_level)
end

function getframe(ani,speed)
 if (speed == nil) speed = 15
 return ani[flr(frame_counter/speed)%#ani+1]
end

-->8
-- updates

function update_stat_ui()
   if (lstat_window != nil) then
      del(wind,lstat_window)
   end
   lstat_window = make_window(1,100,127/2,28,{"level: "..player_level,"health: "..player_direction},nil,nil)
   if (rstat_window != nil) then
      del(wind,rstat_window)
   end
   rstat_window = make_window(130/2,100,62,28,{"gold: "..player_state,"item: "..player_x .. " " .. player_y},nil,nil)
   
   --make_window(player_x*8,player_y*8-5-10,5,5,{"oof!"},10,"quip")				    
end

function update_character_offset()
	if (player_state == "moving") then  
   if (player_direction == "left") then     
     player_offset_x -= 1  
     if (player_offset_x == -8) player_state = "end_dest"
   end

   if (player_direction == "right") then
     player_offset_x = player_offset_x +1 
     if (player_offset_x == 8) player_state = "end_dest"
   end

   if (player_direction == "up") then     
     player_offset_y -= 1  
     if (player_offset_y == -8) player_state = "end_dest"
   end

   if (player_direction == "down") then
     player_offset_y = player_offset_y +1 
     if (player_offset_y == 8) player_state = "end_dest"
   end

   
   if (player_state == "end_dest") then
        player_x = dest_x
        player_y = dest_y
        player_offset_x = 0
        player_offset_y = 0      
   end  
 end  
end

function update_check_buttons()
  if (player_state == "standing" or player_state == "end_dest") then
					if (btn(⬅️)) then
					  move_player("left",1)				
					elseif (btn(➡️)) then
					  move_player("right",1)
					elseif (btn(⬆️)) then 
					  move_player("up",1)
					elseif (btn(⬇️)) then 
					  move_player("down",1)		
	    elseif (btn(❎)) then
	      current_level = mapgen()
	    end
	    
	 end
end

function update_camera()
   camera(camera_x,camera_y)
end

-->8
-- inits
function init_tiles()
-- tile setup
  ti = {}
  calls = 0
  ti.target_info = "14"
  target_tile_coords = {0,0}
  room_max_x = 16
  room_max_y = 11
  
  -- tile definitions
	 tile_info = {
			 wall=13,
			 floor=14,
			 down_stairs=28,
			 up_stairs=29,
			 water=12,
			 slime=22,
			 golem=23,
			 snowman=24,
			 somemob=25,
			 somemob2=26,
			 goo=6,
			 rock=7,
			 ice=8,
			 coin=38,
			 coins=39,
			 gold_bars=40,
			 chalice=41,
			 crown=42,
			 bag=43,
			 potion=44,
			 hammer=54,
			 bazooka=55,
			 hook=56,
			 weapon_4=57,
			 weapon_5=58,
	 }
end

function init_draws()
-- draw setup
  wind = {} -- window info
  frame_counter = 0 -- frame counts
	 draw_count = 0 -- draw frames
  camera_x = 0
  camera_y = 0
end

function init_player_state()
-- player state info
  player_anim = {16,17,18,17}
		player_x = 3
		player_y = 3
		player_offset_x = 0
		player_offset_y = 0
  player_state = "standing"
  player_direction = "down"
end

function init_player_status()
-- player game status
	 player_level = 1
	 player_hp = 10
	 player_gold = 0
	 player_weapon = "empty"
	 player_item = nil
end

function init_debug()
-- debug setup
		debug_mode = true
	 debug_x = 0
	 debug_y = 100
end

function init_first_level()
-- game inits
	 init_levels()
	 --build_level(level_map)
  place_actors(level_actors)
end

__gfx__
00000000000000000000000000000000000000000000000033333333000000007777777700000000000000000000000000000000655055600000000000000000
0000000000000000000000000000000000000000000000003bbbbbb3005555007ccc7cc70000000000000000000000000ddddddd000000000000000000000300
0070070000000000000000000000000000000000000000003bbbbbb3056565507cc7ccc70000000000000000000000000ddddddd605605600000000000000300
0007700000000000000000000000000000000000000000003bbbbbb3055656507c7ccc770000000000000000000000000ddddddd000000000004000003000000
0007700000000000000000000000000000000000000000003bbbbbb30555655077ccc7c70000000000000000000000000ddddddd560560600000000003000000
0070070000000000000000000000000000000000000000003bbbbbb3055656507ccc7cc70000000000000000000000000ddddddd000000000000000000000300
0000000000000000000000000000000000000000000000003bbbbbb3005565007cc7ccc70000000000000000000000000ddddddd556055600000000000000300
0000000000000000000000000000000000000000000000003333333300000000777777770000000000000000000000000ddddddd000000000000000000000000
00000000000000000000000000000000000000000088880000000000000000000066600000444000004440000000000055566660500000000000000000000000
000aa000000aa000000aa000000aa000000000000800008000000000003550000061640004000400040004000000000050000000506500000000000000000000
00aaa00000aaa00000aaa00000aaa000000000000800008000bbbb00005850006067600604000400040004000000000050500000506506500000000000000000
00aaa00000aaa00000aaa00000aaa000000000000800008003bb77b0055535000666666000004000000040000000000050505000006506500000000000000000
00aa000000aa00000aaaa0000aaa00000000000008000080333bbb7b553353500677760000040000000400000000000050505050500006500000300000200000
00aa00000aaaa00000aa000000aaa000000000000088880033333bbb500500506666666000040000000400000000000050505050505500000000000002a20000
00aaa00000aa00000aaaa00000aa0000000000000000000003333330003530006777776000000000000000000000000050505050505505500000000000200000
00a0a0000a00a0000000000000a0a000000000000000000000000000055055006666666000040000000400000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000a7000000000990000000000000000000000000000070700000000000000000000000000
000000000000000000000000000000000000000000000000000000000aa00770000999900aa77770000000000000000000075700000000000000000000099000
0000000000000000000000000000000000000000000000000000000000000a700055500000aa7700000070000000000000070700000000000099000000900900
000000000000000000000000000000000000000000000000000a700000000000099aa90000aaa7000a0aa7070000000000700070000000000009000000009900
000000000000000000000000000000000000000000000000000a7000077000000999990a000aa00008aa8a7800000000007ddd70000000000009000000090000
000000000000000000000000000000000000000000000000000000000a70a700a9999900000aa0000aaaaaa700000000007ddd70000000000009000000999900
000000000000000000000000000000000000000000000000000000000000aa00009990aa00aaaa00000000000000000000077700000000000099900000000000
00000000000000000000000000000000000000000000000000000000000000000a0a000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000005040500000006000060006000000000000000000000000000000000000000000009900000900900
00000000000000000000000000000000000000000000000005545500666677760006060000000000000000000000000000000000000000000090090000900900
00000000000000000000000000000000000000000000000005040500555666660000400000000000000000000000000000000000000000000000900000099900
00000000000000000000000000000000000000000000000000040000455555550000400000000000000000000000000000000000000000000000090000000900
00000000000000000000000000000000000000000000000000040000040400400004400000000000000000000000000000000000000000000090090000000900
00000000000000000000000000000000000000000000000000040000004000000004000000000000000000000000000000000000000000000009900000000000
__gff__
000000000000050505000000010f000000000000000005050005050000000000000000000000020202020200020004040000000000000200020000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000a75008750067500675006750067500575005750047500375003750037500000000000000000000000000000000000000000000000000000000000000000000000
000300000050009500079502055029550005000650012b5012b5012b5012b5017600176003050026700367002040012b5012b501db501db501db5012b50343003630028300253001730000300120000000012000
0008000019300183001830018300183001830018300183001830017300183001830017300173001730017300173001730017300163001530015300153001330013300123001130014300103000f300143000f300
__music__
04 41424344

