pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init--

music(nil,0,0,3)

function _init()

	bunnies_total=0
	bunnies_collected=0

	defaults={
		friction=0.92,
		boost=5,
		gravity=0.3,
		max_dy=3,
		max_dx=1,
		acc=0.5
		}

	player={
	
		sp=1,
		x=15,
		y=248,
		flp=false,
		h=8,
		w=8,
		dx=0,
		dy=0,
		max_dx=1,
		max_dy=3,
		acc=0.5,
		boost=5,
		anim=0,
		jumping=false,
		falling=false,
		sliding=false,
		landed=false,
		swimming=false,
		oldx=0,
		oldy=0,
		zone="sky",
		wall=false
		
	}
	
	bunny_init()
	moses_init()
	
		gravity=0.3
		friction=0.85
		
		--simple camera
		
		cam_x=0
		cam_y=0
		
		--map limits
		map_start=0
		map_end=1024
		map_height=512
		
		
		--test--
		x1r=0 y1r=0 x2r=0 y2r=0
		collide_l="no"
		collide_r="no"
		collide_u="no"
		collide_d="no"
	
end
-->8
--update and draw--

function _update()

	player_update()
	player_animate()
	moses_update()
	

	

	player.oldx=player.x
	player.oldy=player.y
	
	if player.y<256 then

	if player.y<map_start then
		player.y=480
		sfx(1,2)
	end

	end	

	
	if player.x<map_start then
		player.x=map_end-player.w
	end
	
	if player.x>map_end-player.w then
		player.x=map_start
	end
	
	if player.y>map_height then
		player.y=map_start
	end
	
			--simple camera
	cam_x=player.x-64+player.w/2
	cam_y=player.y-96+player.h/2
	
	cam_x = mid(map_start,cam_x,map_end-128)
	
	if player.y >=350 then
	    cam_y = mid(376, player.y-96,488)
	else
	    cam_y = mid(0, player.y-96, 240)
	end
	

	
	bunny_update()
	
end // end update

function _draw()

	--blue sky, black space

	if player.y<260 then
		cls(12)
	else
		cls(0)
	end
	
	--map wrap
	
	camera(cam_x,cam_y)

	
	
	map(0,0,0,0,128,64)
	spr(player.sp,player.x,player.y,1,1,player.flp)
	
	
//	print(bunnies_collected.."/"..bunnies_total,cam_x+5,cam_y+5,7)
	


--npcs

bunny_draw()
moses_draw()
moses_chat()

--score
points(17,5,5, bunnies_collected,bunnies_total)


end
-->8
--utilities--

function collide_map(obj,aim,flag)
	--ojb= table, needs x,y,w,h
	
		local x=obj.x local y=obj.y
		local w=obj.w local h=obj.h
		
		local x1=0 local y1=0
		local x2=0 local y2=0
		
		if aim=="left" then
			x1=x-1	y1=y
			x2=x	y2=y+h-1
		
		elseif aim=="right" then
			x1=x+w-1	y1=y
			x2=x+w+1	y2=y+h-1
			
		elseif aim=="up" then
			x1=x+1		y1=y-1
			x2=x+w-2	y2=y
		
		elseif aim=="down" then
			x1=x+1		y1=y+h
			x2=x+w-2	y2=y+h
		end
		
		--test
		x1r=x1	y1r=y1
		x2r=x2	y2r=y2
		

	--pixels to tiles
	
	x1/=8	y1/=8
	x2/=8	y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
	
		return true
	else
		return false
	end	
	
end

function in_tile_flag(obj, flag)
	local tx=flr((obj.x+obj.w/2)/8)
	local ty=flr((obj.y+obj.h/2)/8)
	return fget(mget(tx,ty),flag)
end

function blink(obj,sprite)
	obj.t += 1
	obj.sp = sprite + (flr(obj.t/8) % 2)
end
	

function dialog(l1, l2, l3)
    camera()
    rrectfill(14, 88, 100, 22, 3, 0)
    rrect(14, 88, 100, 22, 3, 7)
    if l1 then print(l1, 19, 93, 7) end
    if l2 then print(l2, 19, 100, 7) end
    if l3 then print(l3, 19, 107, 7) end
    camera(cam_x, cam_y)
end

function points(sp, x, y, count, total)
    camera()
    spr(sp, x, y)
    print(count.."/"..total, x+9, y+3, 7)
    camera(cam_x, cam_y)
end

-->8
--player

function player_update()


	--physics
	player.dy+=gravity
	player.dx*=friction
	
	--controls
		if btn(⬅️) then
		
		if player.jumping or player.falling then
			player.dx-=player.acc*5
		else
		player.dx-=player.acc
		player.running=true
		player.flp=true
		end
		end
		
		if btn(➡️) then
		
		if player.jumping or player.falling then
			player.dx+=player.acc*5
		else
		player.dx+=player.acc
		player.running=true
		player.flp=false
		end
		end
		
		if player.running
		and not btn(⬅️)
		and not btn(➡️)
		and not player.falling
		and not player.jumping then
			player.running=false
			player.sliding=true
		end
		
		--jump
		
		if btnp(❎) then
			if player.landed==true
			and player.swimming==false then
				sfx(2,1)
				player.dy-=player.boost
				player.landed=false
			end
		end
		
		player.x+=player.dx
		player.y+=player.dy
		
--check collision up and down
		if player.dy>0 then
			player.falling=true
			player.landed=false
			player.jumping=false
			
		player.dy=limit_speed(player.dy,player.max_dy)
			
			if collide_map(player,"down",0) then
				player.landed=true
				player.falling=false
				player.dy=0
				player.y-=((player.y+player.h+1)%8)-1
	end
	
--bounce physics
			if collide_map(player,"down",4) then
				sfx(2,1)
				player.dy-=player.boost+2.5
				gravity=0.5
				player.landed=false
			end

			if collide_map(player,"up",4) 
			and collide_map(player,"up",1) then
				sfx(2,1)
				player.dy+=player.boost+5
				player.landed=false
			end			
	

			
		elseif player.dy<0 then
			player.jumping=true
			if collide_map(player,"up",1) then
				player.dy=0
		----test-----
		collide_u="yes"
		else collide_u="no"
		----test-----
				end
		end
		
--check collision left and right
if player.dx<0 then
	player.dx=limit_speed(player.dx,player.max_dx)

	if collide_map(player,"left",1) then
		player.dx=0
		player.x=player.oldx	
	----test-----
	collide_l="yes"
	else collide_l="no"
	
	end
	----test-----
	
	
	
	elseif player.dx>0 then

	player.dx=limit_speed(player.dx,player.max_dx)
	if collide_map(player,"right",1) then
	player.dx=0
	player.x=player.oldx

	end
end

--stop sliding
if player.sliding then
	friction = 0.95
	if abs(player.dx)<.05
		or player.running then
		player.dx=0
		player.sliding=false
	end
end

----limit player to map
--	if player.x<mxap_start then
--		player.x=map_start
--	end
--	if player.x>map_end-player.w then
--		player.x=map_end-player.w
--	end


--sticky surfaces
if btn(❎) then
    if collide_map(player,"right",3) or collide_map(player,"left",3) then
        -- wall slide
        gravity=0.05
        player.max_dy=0.5
        player.falling=false
        player.wall=true
  	 if btn(⬆️) then
        player.dy=-2
   	 elseif btn(⬇️) then
        player.dy=2
   	 else
        player.dy=0  -- hold position if no direction
  	 end
  	 
    elseif collide_map(player,"up",3) then
        -- ceiling hang
        player.dy=0
        gravity=0
        player.jumping=false
        player.wall=true
    elseif collide_map(player,"down",3) then
        -- sticky floor
        friction=0.5
        player.wall=true
    else
        player.wall=false
        gravity=defaults.gravity
        player.max_dy=defaults.max_dy
        friction=defaults.friction
    end
elseif player.wall_stuck then
    player.wall_stuck=false
    player.dy=-player.boost*2
    gravity=defaults.gravity
    player.max_dy=defaults.max_dy
    friction=defaults.friction
    if btn(⬅️) then
        player.dx=-5
    elseif btn(➡️) then
        player.dx=5
    end

else
    gravity=defaults.gravity
    player.max_dy=defaults.max_dy
    friction=defaults.friction
end

--water physics

	if in_tile_flag(player, 2) then
		friction=.7
		gravity=0.3
		player.max_dy=.3
		player.swimming=true
		player.falling=false
		player.running=false
		player.sliding=false
		player.acc=defaults.acc*0.5
		if btnp(❎) then

			if btn(⬅️) then
				player.dy -= 3			
				player.dx -= 3
				player.sp = 7
				player.flp = true
			elseif btn(➡️) then
				player.dx += 3
				player.dy -= 3
				player.sp = 7
				player.flp = false
			else
				player.dy -= 5
			end
		end

	else
		friction=defaults.friction
		player.acc=defaults.acc
		player.swimming=false
		if not player.wall then
			gravity=defaults.gravity
			player.max_dy=defaults.max_dy
		end
	end
	
	
	--cloud physics

--	if in_tile_flag(player, 4) then
--		friction=0.3
--		gravity=0.01
--		player.max_dy=1
--		player.sp=6
--		player.acc=defaults.acc*0.5
--		if btnp(❎) then
--			sfx(2,1)
--			player.dy-=10 --small bounce
--		end
--	else
--		friction=defaults.friction
--		gravity=defaults.gravity
--		player.max_dy=defaults.max_dy
--		player.acc=defaults.acc
--	end

	
end --end update function


function player_animate()
	if player.jumping then
		player.sp=2
	elseif player.swimming then
		player.sp=7
	elseif player.falling then
		player.sp=5
	elseif player.sliding then
		player.sp=6
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=1
			if player.sp>4 then
				player.sp=3
			end
		end

	else --player idle
		if time()-player.anim>.3 then
			player.anim=time()
			player.sp+=1
			if player.sp>2 then
				player.sp=1
			end
		end
	end
	
end


function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end		








-->8
--bunnies

bunnies = {}

function bunny_init()
    for tx=0,127 do
        for ty=0,63 do
            local t = mget(tx,ty)
            if fget(t,5) then
                add(bunnies, {
                    sp=17,
                    x=tx*8,
                    y=ty*8,
                    t=0,
					collected=false
                })
                mset(tx,ty,0)
                bunnies_total+=1
            end
        end
    end
    
end

function bunny_update()
    
    for b in all(bunnies) do
		if not b.collected then
			
			blink(b,17)
			
			if abs(b.x-player.x)<8 and abs(b.y-player.y)<8 then
				b.collected=true
				bunnies_collected+=1
				sfx(0,2)
			end

   		 end 
	end
end

function bunny_draw()
    for b in all(bunnies) do
		if not b.collected then
        	spr(b.sp, b.x, b.y)
    	end
	end
end
-->8
--moses--

moses = {}

function moses_init()
    for tx=0,127 do
        for ty=0,63 do
            local t = mget(tx,ty)
			if fget(t,7) then
				moses.sp = 49
				moses.x = tx*8
				moses.y = ty*8
				moses.t = 0
				moses.happy = false
				moses.win = false
				moses.talking = false
				moses.talked = false
				moses.cooldown = 0
				mset(tx,ty,0)
            end
        end
    end
    
end

function moses_draw()

	spr(moses.sp, moses.x, moses.y)

end

function moses_update()

	if moses.talking then
		if btnp(❎) then
			moses.talking = false
			moses.cooldown = 30
			moses.talked = false
		end
	end

	if bunnies_collected==bunnies_total then
		moses.happy=true
	end
	
	if moses.cooldown>0 then
		moses.cooldown-=1
	end
	
	
	if moses.happy==false then

		blink(moses,49)
		
	elseif moses.happy then
		
		blink(moses,51)
			
	end

	if moses.cooldown==0 and
		abs(moses.x-player.x)<8
		and abs(moses.y-player.y)<8 then
		moses.talking=true
		if not moses.talked then
		sfx(3,3)
		moses.talked=true
		end
	end
	
end

function moses_chat()
	
	if moses.talking then
		
		if not moses.happy and
		not moses.win then
		
		dialog(
		"i lost my bunnies.",
		"please find them.")
		
		elseif moses.happy 
		and not moses.win then
		
		dialog
		("thank you for",
		"finding my bunnies♥")
		
		elseif moses.win and
		not moses.happy then
		dialog("why am i so clumsy?")
		end
	end
end
__gfx__
00000000017bb710017bb710071bb710071bb710017bb71000000000b000b000bb0000bb00000000000000000000000000000000000000000000000000000000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb0077bb770bb77bbb70bbbbbb000000000000000000000000000000000000a00000000000000000000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb0071bb1700b778bb1077777700000000000000000000000000000000000000000000000000a000000
000000000b8bb8b0bb8bb8bbbb8bb8bbbb8bb8bbbb8bb8bb0bbbbbb00b78bbbb0778877000000000000000000000000000000000000000000000000000000000
000000000778877007788770077887700778877007788770bb8bb8bb0b78bbbb0b8bb8b000000000000000000000000000000000000000000000000000000000
0000000007777770077887700777777007777770b778877b077887700b778bb7bbbbbbbb00000000000000000000000000000000000000000000a00000000000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb000bbbb00b778877bbb77bbb10bbbbbb000000000000000000000000000000000000a00000000000000000000
000000000b0000b00b0000b00b000b00b000000b00000000bbbbbbbbb000b000071bb17000000000000000000000000000000000000000000000000000000000
00000000077777707770077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e000007e77e707e7777e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777707777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007c77c7007c77c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070070077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000076996700769967000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c000000077667700776677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000122552211114411108ee888008ee88800000000000066000
00e0000000000000000000000dddddd0000000000000000000000000000000000000000000000000255555521899998188888888888888880000000006677600
000000000dddddd0dddddddd0dedded00000000000000000000000000000000000000000000000002577775219355391e888888ee898898e0066666006777760
000c00000deeeed0deeeeeed0deeeed0000000000000000000000000000000000000000000000000357ee75349522594e8888888e89889880067777667777776
000000000dccccd0ddccccdd0dccccd0000000000000000000000000000000000000000000000000357ee7534952259488888888888888880667777777777776
0e0000e00d5ee5d0dd5ee5dd0d5ee5d0000000000000000000000000000000000000000000000000257777521935539188888888888888880677777777766660
000000000dedded0deeddeed0dedded0000000000000000000000000000000000000000000000000255555521899998100666600006666000677667776677760
000000000dddddd0dddddddd0dedded00000000000000000000000000000000000000000000000001225522111144111006666000066c6006776776777777776
0000000000000000aa00a0aaee0000ee020000200000000000000000000000000000000000000000cccccccc7effffe700666600006666006777776777777776
009000a0009bc2000a9bc2a0009bc200009bc20000e000e000000000000000000000000000000000c777777cec6996ce00c66c0000c66c006777777777777776
00000000001bc100001bc1000e1bc1e0221bc1220000000000000000000000000000000000000000c7eeee7cf6bbbb6f00666600006666006677777777777776
00000e0000977200aa9772aa009772000097720000000e0000000000000000000000000000000000c7e66e7cf9baab9f00666600006666000066666777777776
00000000001881000a1881a0ee1881ee021881200000000000000000000000000000000000000000c7e66e7cf9baab9f006c6600006c66000000066777777776
0080000000dddd0000dddd0000dddd0000dddd0000e0000000000000000000000000000000000000c7eeee7cf6bbbb6f00666600006666000000006677777666
00000000009bc200aa9bc2aa0e9bc2e0029bc2200000e00000000000000000000000000000000000c777777cec6996ce0066c600006666000000000666666600
0000000000000000a00a000ae0e00e0e202002020000000000000000000000000000000000000000cccccccc7effffe700666600006666000000000000000000
bbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbb000000004444464400000005444449444444464444444444f444449433c333ca3333333ccc3323c3c3ce333b
3bbbbbb33bbabbb3bbb3bb3bb2bb3bbb00b33444be0000bb0084944b000000351594444e44544444414944414454411141c3cc33ccc3e3cc1cc33cc33cc3cc9b
333bb33333bbb3333bbbbbbbbbbbbbb30e3344643bb00bb300005455000000e511144f441444a1111114441144441111e53c1cc3c1cc3cc111ccc111133c11bb
4433334443bb334443bbbbbbbbbeb33400b33444433b63340000554600000336111134491111111f1111431146411f114433c1cc1111cc11a11111111113ce33
444444e444334444443bbb333bbbb354000a344f44433944000003540000956611111a4411e11111f11141114411111644441111111111111111111113313346
4424444444334444443b33344333344400034444444f4444000a0335000555441c11114f11111111111111114e16111146442411119111111111111133444444
44449444444444f4d4434444d444444f03334e44d44444440000000505544444111171e411f111e1111f1111441111a144644441111111111111111134444425
4444444446444444444444d444f444f433424444444444d4e00000035d44444411f1111411111111111111114111111144445444111111111111111344445444
444444a4444444444444444444444444444466644944464411111114444446441f1111111111111111111111111111141e3bb31a411111111111111438111111
44444444444644244494444444545444444655664444944311911144e4000449111111611111c1111111c1111c1a114ae8e3b31141119111119111443311c111
474494444844444444444444444544444666556644444383111113440e400000113111111166111111111111111114641e3bb31e441161111111114443311111
44444444444fff44444494444454444466566666459430001111344400000000111311111111c11111e1111111114f447133b31144165118111114444433111c
44444444444f644444444444444545446666666444400000111134440200000811311e111111111111116111191f4444113bb31144466161111114444444a111
4e444444444444e44444444444445454465566444406000011114444000000001113111111111511111111811144e494113b331145416661111144444e443311
44444f4444d44e44449444944444454446666444430000501113444400000f0013444313145344514311134415544444143bb341445411111111444444444331
4444444444444444444444444444444444444444433000001114444400000000444444444444444444444444ff44f445443b3344544441111114444444444431
03335930005444444442438144453b0044444444453b1111114446440044440b00ffff0033333333333333330000000000000000000000bbb800000000000000
454553550055444444444433444553034444444445531e1113444444004544b0004ff40b3bbbbbb33bbbbbb3000000000000000000000bebbbb0000000000000
47549555035444444554433144445330444444444453b11114444444004444000044440b3bbbbbb33bbbbbb3000050000000099000000bbbb3bba00003000000
44444444e054444445454a3e44443b0a44444444443b11114444444400454400b04444b033bbbb3333bbbb3311b11111111711111711bb33333bbb1100000000
444444440055444444444433444439004444e44b4439111144544444b04544000b444400113bb311113bb311111111a1131111a1111bb346433e333100000000
4e444444035544444644644344445303493337344453111144444f440b45440000454400713b3331713b33e11711111111111b11c1eb34444433333100000900
44444f44b05444446566463144455330333030034553b1114444444400444400004444001a3bb3131a3bbe8e111e17111111111111b342254444443300000000
44444444005444444446443344453300000800e045331111444444440054450000544500113b3331113b33e11111111111b11111113354444446445300000000
b000000a035444440000000044453b0044000000453b1111453b000000444400313bb311313bb31a1e3bb31a1111111111111111113444444446644100000000
3b00000080544444440000004445530e45400e0045531e1145530e00004454001333b3111333b311e8e3b3111117111111111711e14466444444644111000111
47a000000355444447400000444453b04453b0009453b1114453b00000445400313bb311313bb31e1e3bb31e111111111111111111146444454444a111111117
4433000000a544444444000044443b00443b0000443b1111443b0000004444007333b3117333b3117133b311111111111111111113f444444454441111a11111
4443b30000354444444440004444390044390000443911114439000000445400113bb311113bb313113bb3e111111171111111111f4445444444f11111111111
4e443b30903544444e4444004444530044530000445311114453000000444400113b33111a3b33311a3b3e8e17111111117111111444444444f4445111111111
44444f390335444444444f00444553b0455800004853b1114553b00004444440413bb314713bb313713bb3e1111111b111111171114a44444444444111111a11
4444444300544444444444404445330044000000453311114533000044544544443b3344113b3331113b33111111111111111111b144a444944944e111111111
96b696c6b6a6c6b6d61434143404240424340424143414340424241434143404241434143404240424343434241404140424343424c4d4e4e4e4f40424241434
143404240424343414041404243434c4d4d4e4e4f4241436f6170424042414041404243434241404241434141404140424343424140414e6c6b6a6b6a6b696b6
a7b797b7b7a7c7c7d7050505050505050505050505050505050505050505050505050505050505054646252505251515050525250525f5c7c7e5150505050505
05050525252515150505252505251525f5c7c7e515050536f6170525151505052525052515150505050505052515150505252505251515e7b7b797c797b7a7b7
97b797b7c7a7c7c7d715051535051525252545251525252545252525254646452555644646464646f60164252535250535051525253525b7b766251525252545
2525252515352505350515252535253525d5e53525252536f6172535250535051525253525053505251525253525053505152525352505e7b7b7a7c7a7b797b7
a7b797b7c7a7b7b7d71505153505152525251525250525252546462555f6f66455f6f6f6f6f6f6f6f602e0642525051525052525051545b7b715252505252515
352525252515450505052525051545050505252505252536f6172515450505052525051545050505250515352505153525352505153525e7b7b797c797b7a7b7
a7b797b7b7a7b7c7d725054646464646464646460515352536f6011736f6f6f6f6f6f60144540701f6f6f6f66415352535150515254646b7b746464645150515
252505152515252505150515252505152515353546464655f6170515251525250515051525250515253525252535252525252535252525e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7d7252601f6f6f6f6f6f6f6f66425252536f6f617060647f6f6f6f6442525350607f6f6f6f66446464646464655f6f6b7c7f6f6f664464646
4646464646464646464646464646464625252555f6f6f6f6f6173525352505153525352505153525352525051525250515051525250515e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7d74555f6f6f6f6f6f6f6f6f6f664464655f6f617455501f6f6f6f617051525152507f6f6f6f6f6f6f6f6f6f6f6f6f6b7b7f6f6f6f6f6f6f6
f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6643536f6f6f6f6f6f6172525252535252525252535252525250515352505153525352505153525e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c794a4f7f7f7f7f7f7f7b507f6f6f6f6f6f6f6f6161536f602f6f6f616352505054536f602f601f6f6f6f6f6f6f6f601b7b7f6f6f6f6f6f6f6
01f6f6f6f6f6f6f6f6f6f6f6f6f6f601743536f6f6f6f6f6f6170515251525250515051525250515253525252535252525252535252525e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7c7c78595a5b5052525152507f6f6f6f6f6f602644655f6f6f6f6f616252515350556f7f7d634e6c6f7b6c6f7c6f7a6b7c7c6f7b506060606
0606060606060606060606060606060615252507f601f6f674453525052505153525352505153525052525051525250515051525250515e7b7b7a7b7a7b7a7b7
a7b797b7b7a7b7c7b7b50505252525352525051507f6f6f601f6f6f6f6f6f6f6f6f6f617152525053557b7b7d725e7c7c7c7c7c7c7c7a7c7b7b7b53525252525
35252525352535252525252535252525352535350606060606252525352535252525252535252525352525253525252525253525252525e7b7b7a7b7a7b7a7b7
c5a587a585c5a595b53525250515352505153515250606060607f6f6f6f6f6f6f6f67435253535052556c7c7d725e7b7b7c7c7b7b7b797c7b7b7d72505150515
25250515251525250515051525250515251525250515051525250515251525250515051525250515252505152525051505152525051525e79595c5a5c595c5a5
252525050505052505253525352525253525252505153525352507f6f6f6f6f6f67425252525052525f5a5b7d715e7959585a5a5a595a7a5a585d71535253525
05153525052505153525352505153525052505153525352505153525052505153525352505153525051535250515352535250515352535150505050505052525
15252505150515252505152505150515252505152515252505150506060606060625250515250515252505152525252505150515252505152515252505150515
25250515251525250515051525250515251525250515051525250515252525051505152525051525352525253525252525253525252525152525452525253515
25051535253525051535253535253525051535253525051535253525350515350605253525053525051535253525051535253525051535253525051535253525
05153525352505153525352505153525352505153525352505153525350515352535250515352535252505152525051505152525051525252525153535252525
b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2
b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2a3a3a3a3a3a3a3a3a3b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0f0f0f0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0f0f0d0d0f0f0f0d0d0d0d0d0d0f0f0f0f0d0f0f0f0
f0d0d0d0d0f0f0d0d0d0d0d0d0d0f0d0d0d0d0d0d0d0e0e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0f0f0d0d0d0d0d000
d0d0f0f0f0f0d0d0d0d0d0f0f0f0d0d0f0f0d0d0f0f0f0f0f0d0d0f0f0f0f0f0f0f0f0d0f0f0f0f0d0d0d0f0f0f0f0f0d0d0f0f0f0d0d0d0f0f0d0d0f0d0d0e0
e0e0e0e0f0f0f0d0d0d0d0f0d0d0d0f0f0d0e0a3e033e0a3e0d0d0e0e0e0e0d0d0d0d0d0d0d0d0d0d0f0f0f0f0f0f0f0f0f0d0f0d0e0e0e0d0d0f0f0d0f0d0f0
f0f0f0f0d0d0f0f0f0f0f0f0f0f0f0f0f0f0d0d0d0f0e0d0f0e0f0d0f0f0f0f0f0f0f0d0b2a2b2f0f0f0f0f0f0f0b2a2b2d0f0f0f0d0d0f0d0f0f0f0f0d0e0d0
d0d0d0d0d0e0f0d0f0f0f0f0f0d0d0d0e0f0e0a3a3d0a3a301d0d0e0d0d0d0e0e0d0f0f0f0f0f0d0d0f0f0f0d0d0d0d0d0e0e0e0d0d0d0e0f0d0d0e0f0d0f0f0
f0f0f0f0f0d0f0f0d0f0f0f0f0f0f0f0d0f0f0d0f0d0d0d0d0f0f0d0f0d0f0d0d0f0f0f0f0f0f0d0f0d0e0d0f0d0d0f0f0d0f0d0d0d0d0f0d0f0d0f0d0d0e0e0
e0e0d0d0b2a2b2f0e0e0b2a2b2e0e0e0e0d0a3a3a3a3a3a3a3d0e0e0f0f0f0d0f0f0f0d0d0f0f0f0d0d0f0f0d0d0d0e0d0e0e0d0b2a2b2e0e0e0e0e0f0f0f000
d0f0d0d0f0f0d0f0d0f0d0f0f0f0f0f0d0d0f0f0f0d0e0e0e0f0f0f0d0d0d0d0e0f0e0e0d0f0f0f0d0d0d0e0d0d0f0f0f0f0f0f0f0d0f0f0f0d0d0d0f0d0f0f0
f0d0e0e0e0d0d0d0f0d0d0d0d0d0d0f0f0e0e0f0f0d0f0d0f0f0f0e0e0e0f0d0f0d0f0e0f0d0f0f0f0f0f0d0e0e0e0f0e0e0e0d0e0f0f0f0f0f0d0e0f0f0d000
d0f0d0d0d0f0f0f0f0d0d0d0d0d0d0d0d0e0f0f0f0d0f0f0f0d0d0f0f0d0e0e0d0d0d0d0d0f0d0d0f0f0e0e0d0d0f0e0f0d0d0f0d0d0e0d0e0e0d0d0f0d0f0d0
f0e0d0d0e0e0e0e0d0d0e0d0d0d0f0f001f0e0f0d0f0f0e0f001d0e0e0e0f0f0d0d0d0e0e0d0e0e0e0f0f0f0e0f0d0f0d0d0e0e0e0e0d0d0f0f0e0f0d0d0f000
d0f0f0f0f0f0f0d0e0e0e0d0f0d0d0d0e0e0d0e0f0d0f0d0f0e0f0d0d0d0e0d0b2a2b2f0f0d0f0f0b2a2b2d0d0d0f0f0e0b2a2b2f0d0d0d0e0e0e0e0f0f0d0d0
d0d0d0d0f0f0f0f0e0f0f0d0f0e0f0b2a2b2f0d0e0f0e0e0b2a2b2d0e0e0e0e0d0d0e0d0d0f0d0f0d0d0d0e0e0d0e0e0e0d0d0e0e0d0d0e0e0e0e0e0d0d0f0f0
f0f001f0d0f0f0e0d0f0d0d0f0f0b2a2b2d0e0e0f0f0d0d0d0e0f0d0e0e0e0d0d0f0f0f0e0f0f0d0d0d0e0e0e0e0d0f0d0f0e0e0f0e0e0e0e0d0d0d0e0d0d0e0
d0f0e0f0f0e0f0e0e0f0d0f0e0d0e0d0d0d0f0d0d0d0d0d0e0e0d0d0d0d0e0d0d0e0d0f0e0f0d0f0d0b2a2b2e0e0e0d0f0f0f0e0e0f0f0e0d0d0f0f0e0d0d0f0
f0b2a2b2f0f0e0d0d0f0e0f0f0f0d0f0f0f0f0f0f0d0d0f0d0d0f0f0d0f0f0f0d0d0f0e0e0d0f0f0e0e0e0d0d0d0f0e0d0f0d0d0f0d0b2a2b2d0d0e0d001d0d0
e0b2a2b2f0e0e0f0e0e0e001e0d0d0e0e0f0d0f0f0f0f0d0e0e0e0e0f0f0e0e0e0e0d0f0e0e0d0d0d0d0d0f0f0d0e0f0d0d0f0e0e0e0f0f0f0e0b2a2b2f0f000
f0f0d0f0f0f0f0e0d0e0f0f0d0d0f0f0f0d0d0e0f0f0f0f0f0f0f0f0f0e0d0d0e0f0e0e0e0e0e0f0e0e0d0e0d0e0f0d0d0f0d0d0e0e0e0d0d0e0d0e0b2a2b2e0
e0e0e0d0e0e0f0f0f0d0b2a2b2f0f0d0f0d0d0d0f0f0f0d0e0d0d0e0e0b2a2b2e0e0f0f0f0f0d0e0e0f0f0f0f0e0d0e0d0f0e0e0e0d0f0d0d0e0e0e0f0d0f000
d0f0d0f0d0f0f0f0b2a2b2f0f0f0d0f0f0f0f0d0b2a2b2f0e0f0d0d0b2a2b2d0f0f0d0d0e0e0d0f0f0b2a2b2e0d0f0f0d0b2a2b2d0d0d0e0d0d0e0e0d0d0d0d0
e0e0f0f0f0d0e0d0d0f0d0d0f0f0f0f0f0d0f0f0d0f001f0e0d0d0d0e0d0f0d0f0e0e0e0e001e0d0d0d0d0d0d0e0d0d2f0f0e0d001e0d0d0d0e0e0d0e0f0d0f0
d0f0f0f0f0f0e0f0f0f0f0f0f0f0d0f0d0f0f0f0d0d0d0f0d0e0e0e0e0d0d0d0e0f0f0d0d0d0f0f0f0f0f0e0f0d0d0d0d0f0d0e0e0d0e0e0e0e0d0e0e0e0e0e0
e0e0d0e0d0b2a2b2f0f0f0f0f0f0f0f0f0f0f0f0d0b2a2b2f0e0e0f0d0e0e0e0e0d0d0d0b2a2b2e0d0f0f0d0d0d0f0d3d0e0d0b2a2b2e0d0d0d0d0e0d0f0d0d2
d0f0f0f0f0f0f0d0f0d0d0e0f0f0f0d0d0d0f0e0e0e0e0f0d0f0f0d0e0e0e0e0e0f0d2e0e0e0d0e0d0e0d0d0e0e0e0e0f0d0d0e0e0e0e0d0d2e0d0e0d0e0e0d0
f0d0d0d0d0d0d0e0e0f0f0f0f0f0f0f0f0d0f0f0d0f0d0f0f0d0f0f0e0e0e0e0d0d0f0f0d0d0f0f0f0d0e0e0d2e0e0d3e0d0d0d0d0f0f0e0d2e0e0f0f0f0d0d3
f0d0d0f0f0f0f0f0f0e0f0f0f0f0d2e0e0e0f0f0f0d0e0f0d0f0f0f0f0f0d0e0d0f0d3f0d0e0d2d0d0d0e0f0f0f0d2e0e0f0d0d0e0f0d0f0d3f0e0e0e0e0e0f0
e0e0e0e0d0e0e0e0f0f0f0d0d0d0d2d0f0f0f0d2d0f0f0f0f0f0d2d0e0f0d0f0f0f0e0d0d0e0d0f0d0f0f0f0d3e0e0d3e0f0d0f0f0f0f0e0d3f0f0f0d0f0f0d3
d0d0d0d0d0d0d0f0f0d0f0f0f0f0d3f0d0e0f0f0d0f0f0d2d0f0d0f0e0e0d0e0d2f0d3f0d0f0d3e0f0f0d0f0d0f0d3f0f0f0f0d2d0f0d0f0d3f0e0e0d0e0e0f0
f001d0e0e0d0d0e0f0f0e0e0e0e0d3f0d0d0f0d3d0f0d0f0d0f0d3d0d0f0d0f0d0f0e0e0e0d0e0f0d0f0d0f0d3d0d0d3e0f0d0f0d0f0e0f0d3f0f0f0d2f0d0d3
d2d0d2f0d0d2f0f0d0d0f0d2f0f0d3f0d0d2f0d0d2f0d0d3f0f0d0d0d0e0d0e0d3f0d3f0e0f0d3e0d001e0f0f0f0d3f0d0f0f0d3f0f0d0d0d3f0d2f0d2d0d2f0
d2d2d2f0d2d0d2e0d2f0f0f0d0d0d3f0f0d0d0d3f0f0e0f0d0d0d3f0d0e0d2f0e0f0d0d2f0e0d0d2f0d0d2d0d3f0f0d3d0f0f0d0e0f0d0e0d3d0e0e0d3f0e0d3
d3d0d3e0e0d3f0f0e0d2f0d3f0f0d3f0e0d3f0e0d3f0e0d3f0f0e0d2e0d2d0d0d3d0d3f0f0f0d3d0d2d2d2f0f0f0d3f0f0f0f0d3f0e0f0f0d3f0d3d0d3f0d3f0
d3d3d3f0d3e0d3d0d3f0f0f0e0e0d3f0f0e0e0d3f0f0f0f0e0e0d3f0e0e0d3f0f0f0e0d3f0d0e0d3f0e0d3f0d3e0f0d3e0d0f0e0e0f0d0d0d3e0f0e0d3f0f0d3
__label__
ccccccccccccccccccccccccccccccccccccccccccccccccccc66666777777776cccccccccccccccccccccccccccccccccccccccccc67777667777776ccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc66777777776ccccccccccccccccccccccccccccccccccccccccc667777777777776ccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777666ccccccccccccccccccccccccccccccccccccccccc67777777776666cccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666ccccccccccccccccccccccccccccccccccccccccccc67766777667776cccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6776776777777776ccccccc
cccccccccccccccccccc66ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777776777777776ccccccc
cccccccccccccccccc66776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777776ccccccc
ccccccccccc66666cc677776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777777777776ccccccc
ccccccccccc67777667777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666777777776ccccccc
cccccccccc667777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66777777776ccccccc
cccccccccc67777777776666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777666ccccccc
cccccccccc67766777667776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666ccccccccc
ccccccccc6776776777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc6777776777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc6777777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc6677777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc66666777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc66777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc6677777666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc6666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66776ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666cc677776cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777667777776ccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc667777777777776ccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777777776666cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67766777667776cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6776776777777776ccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777776777777776ccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777776ccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777777777776ccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccc7c7c77cc77cccccc777c777c777cccccccccccccccccccccccccccccc66666777777776ccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccc7c7cc7ccc7cccccccc7ccc7c7c7ccccccccccccccccccccccccccccccccc66777777776ccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777cc7ccc7cccccccc7c777c777cccccccccccccccccccccccccccccccccc6677777666ccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc7cc7ccc7cccccccc7c7ccc7c7ccccccccccccccccccccccccccccccccccc6666666ccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccc7c777c777cc7cccc7c777c777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6ccccccccc777c7c7c777ccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc7c7c7ccc7ccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777c777cc77cccccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccccc7ccc7ccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777ccc7c777cc7cc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc66cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66cccccccccc
cccccccccccccccccccccccccccccccccccccccccc66776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66776ccccccccc
ccccccccccccccccccccccccccccccccccc66666cc677776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666cc677776cccccccc
ccccccccccccccccccccccccccccccccccc67777667777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777667777776ccccccc
cccccccccccccccccccccccccccccccccc667777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc667777777777776ccccccc
cccccccccccccccccccccccccccccccccc67777777776666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777777776666cccccccc
cccccccccccccccccccccccccccccccccc67766777667776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67766777667776cccccccc
ccccccccccccccccccccccccccccccccc6776776777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccc6776776777777776ccccccc
ccccccccccccccccccccccccccccccccc6777776777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777776777777776ccccccc
ccccccccccccccccccccccccccccccccc6777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777776ccccccc
ccccccccccccccccccccccccccccccccc6677777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777777777776ccccccc
ccccccccccccccccccccccccccccccccccc66666777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666777777776ccccccc
cccccccccccccccccccccccccccccccccccccc66777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66777777776ccccccc
ccccccccccccccccccccccccccccccccccccccc6677777666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777666ccccccc
cccccccccccccccccccccccccccccccccccccccc6666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666ccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc8ee888cc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc88888888c7e77e7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccce898898ec777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccce8988988c7c77c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc88888888c777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc88888888c769967cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc6996ccc776677cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc6696ccc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc8ee888ccc6666ccc8ee888cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc88888888ccc66ccc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccce888888ecc6666cce888888eccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccce8888888cc6666cce8888888cccccccccccc17bb71c777c7c7ccccc77cc7c7c777ccccc777ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc88888888cc6c66cc88888888ccccccccccc7bbbbbbc777c7c7cc7ccc7cc7c7ccc7ccccccc7ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc88888888cc6666cc88888888ccccccccccc7bbbbbbc7c7c777cccccc7cc777ccc7cccccc77ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc6666cccc6666cccc6666cccccccccccccbb8bb8bb7c7ccc7cc7ccc7cccc7ccc7ccccccc7ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc6666cccc6666cccc6666cccccccccccccc778877c7c7c777ccccc777ccc7ccc7cc7cc777ccccccccccccccccccccccccccccc
cccccccccccccccccc8ee888ccc6666cccc6666cccc6666cccccccccccccc778877ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc88888888ccc66cccccc66cccccc66cccccccccccccccbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccce898898ecc6666cccc6666cccc6666ccccccccccccccbccccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccce8988988cc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc88888888cc6c66cccc6c66cccc6c66ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc88888888cc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc6996cccc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc6696cccc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
bbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb39f999f99999999fff9999f9ff9999f9ff9999f9f9f999fbbbbb8bb
bbbb3bb3b3bbabbb33bbbbbb33bbabbb33bbbbbb3bbb3bb3bb2bb3bbbb2bb3bbbbbb3bb3b49f9ff99fff999ff9ff99ff99ff99ff99ff99ff99ff9ff9b3bbbbbb
33bbbbbbb33bbb333333bb33333bbb333333bb3333bbbbbbbbbbbbbb3bbbbbbb33bbbbbbbe59f9ff9f9ff9ff999fff99999fff99999fff999999f99bb333bb33
443bbbbbb43bb33444433334443bb33444433334443bbbbbbbbbeb334bbbeb33443bbbbbb4499f9ff9999ff99f99999fff99999fff99999ffff99f3334433334
4443bbb3344334444444444e444334444444444e4443bbb333bbbb3543bbbb354443bbb3344449f99ff999999ff999f99ff999f99ff999f99f99f3346444444e
4443b333444334444442444444433444444244444443b33344333344443333444443b3334464424ff9ffff9ff9ff9ffff9ff9ffff9ff9ffff994444444424444
fd4434444444444f444449444444444f444449444d4434444d444444fd444444fd44344444464444999f999f999ff999f99ff999f99ff999f944444254444944
4444444d446444444444444444644444444444444444444d444f444f444f444f4444444d444445444999ff999999999999999999999999999444454444444444
4444444a4444444444444444444444444444444a4444444a44444444444444444444444a44444444439f999f99999999f9999999f9f9999f444444444444444a
44444444444944444444644244446442444444444444444444494444444944444444444444494444449f9ff99fff999fffff999ff999fff44444644244444444
447449444444444444844444448444444474494444744944444444444444444444744944444444444e59f9ff9f9ff9ff9f9ff9ff99ffff444484444444744944
44444444444449444444fff44444fff444444444444444444444494444444944444444444444494444499f9ff9999ff999999ff99f99f4444444fff444444444
44444444444444444444f6444444f644444444444444444444444444444444444444444444444444444449f99ff999999ff9999999f9f9444444f64444444444
44e44444444444444444444e4444444e44e4444444e44444444444444444444444e44444444444444464424ff9ffff9ff9ffff9ff9ff4f444444444e44e44444
444444f444494449444d44e4444d44e4444444f4444444f44449444944494449444444f44449444944464444999f999f999f999f94f44444444d44e4444444f4
44444444444444444444444444444444444444444444444444444444444444444444444444444444444445444999ff999999ff99944444444444444444444444
4444444444444444444444444444444a444444444444444a44444444444444444444444444444444444444444444444449f9999f444444444444444444444444
4449444444454544444944444444444444454544444444444444644244494444444944444445454444494444444944444999fff4444545444449444444446442
44444444444454444444444444744944444454444474494444844444444444444444444444445444444444444444444449ffff44444454444444444444844444

__gff__
000000000000000000000000000000002000000000000000000000000000000040000000000000000000031301111010800101010100000000000303000010100b0b0b0b0b0b02010404040404040405030303030300040004040404040404050b0a020a0a04030303010104040b0b000b08030a0b0402030404040404020204
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000
00000000000000002e2f00002e2f00000000002e2f0000000000000000000000002e2f00000000000000000000000000000000000000002e2f00000000000000000000000000000000000000000000000000000000002e2f000000000000000000000000000000000000000000000000000000000000000000000000002e2f00
00000000000000003e3f00003e3f00000000003e3f0000000000000000000000003e3f00000000000000000000000000000000000000003e3f00000000000000000000000000000000000000000000000000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000003e3f00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2f00000000000000000000000000000000000000000000000000000000000000000000002e2f000000000000000000000000000000000000000000
0000000000000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000000000000000002e2f000000000000000000000000003e3f0000000000000000000000000000000000002e2f0000000000000000000000000000003e3f00000000000000000000002e2f00002e2f00000000
0000000000002e2f000000000000003e3f0000000000000000000000000000000000000000000010000000000000000000000000003e3f0000002e2f000000000000000000000000000000000000000000000000000000003e3f000000000000000000000000000000000000000000000000000000003e3f00003e3f00000000
0000100000003e3f0000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000000000000000003e3f0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000100000000000000000000000000000000000
002e2f000000000000000000000000000000000000000000000000000000000000002e2f00003e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000000000000000002e2f00000000000000000000000000000000
003e3f0000000000000000000000002e2f00000000002e2f000000000000000000003e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e3f0000002e2f00002e2f0000000000000000003e3f00000000000000000000000000000000
0000000000000000000000000000003e3f00000000003e3f0000000000002e2f00000000000000000000000000000000002e2f000000000000000000002e2f00000000000000000000001000000000000000000000000000000000000000003e3f00003e3f000000000000000000000000000000000000000000000000000000
000000000000002e2f0000000000000000000000000000000000000000003e3f00000000000000000000000000000000003e3f000000000000000000003e3f000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000002e2f00
000000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e3f0000000000000000000000000000000000000000000000000000000000000000000000003e3f00002e2f00000000000000003e3f00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000000000000000002e2f0000000000000000003e3f0000000000000000000000
000000000000000000000000000000000000000000000000000000100000000000000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000002e2f000000000000003e3f0000000000000000000000000000000000003e3f00000000000000000000000000000000000000000000
0000000000000000000000002e2f00000000002e2f00000000002e2f000000000000002e2f0000000000003e3f0000000000000000000000000000000000000000000000000000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000003e3f00000000003e3f00000000003e3f000000000000003e3f0000000000000000000000000000000000002e2f0000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e3f00000000000000000000002e2f000000000000002e2f000000000000000000000000000000002e2f00000000000000000000002e2f0000002e2f000000002e2f00000000000000
00000000002e2f000000000000000000000000000000002e2f000000000000000000000000000000000000000000002e2f000000000000000000000000000000000000003e3f000000000000003e3f00000000000000000000002e2f0000003e3f00000000000000000000003e3f0000003e3f000000003e3f000000002e2f00
00000000003e3f000000000000000000000000000000003e3f000000000000000000000000002e2f000000000000003e3f000000000000000000000000000000000000000000000000000000000000000000002e2f00000000003e3f0000000000000000100000000000000000000000000000000000000000000000003e3f00
000000000000000000000000002e2f000000000000000000000000000000002e2f00000000003e3f000000000000000000000000001000000000002e2f000000000000000000000000000000000000000000003e3f00000000000000000000000000002e2f000000000000000000000000000000000010000000000000000000
000000000000000000000000003e3f000000000000000000000000000000003e3f000000000000000000001000000000000000002e2f00000000003e3f00000000000000000000000000000000000000000000000000000000000000000000000000003e3f000000000000000000000000000000002e2f000000000000000000
000000000000002e2f0000000000000000002e2f000000000000000000000000000000000000000000002e2f00000000000000003e3f000000000000000000000000000000000000002e2f00000000000000000000000000000000000000000000000000000000002e2f00000000000000000000003e3f000000000000000000
000000000000003e3f0000000000000000003e3f000000000000000000000000000000000000000000003e3f00000000000000000000000000000000000000002e2f000000000000003e3f000000000000000000000000000000002e2f00000000000000000000003e3f00000000000000000000000000000000000000000000
00002e2f00000000000000000000000000000000000000000000002e2f0000000000002e2f0000000000000000000000000000000000000000000000000000003e3f00000000000000000000000000000000000000002e2f0000003e3f0000000000000000000000000000000000002e2f000000000000000000002e2f000000
00003e3f00000000000000000000000000000000000000000000003e3f0000000000003e3f00000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000000000000000003e3f00000000000000000000000000000000000000000000003e3f000000000000000000003e3f000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000003e3f000000000000000000000000000000000000000000000000000000002e2f000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000006800000000000000000000000000000000000000000000000000000000680000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000002e2f000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000670000000000000000000000002e2f0000000000000000000000000000670000000000000000000000000000000000000000000000000010000000000000000000000000001000000000003e3f000000000000000000
0000000000000000000000000000001000000000000000000000000000000000001000001000002d00006700000000002d1000000000003e3f00000000000000000000002d0000670000002d000000000000000000001000000000002d000000002d000000000000000000000000002d00000000000000000000000000000000
0000000000000000000000300000006700000000000000000000000000000000002c00006800003c000067000000002c3d2c0000000000000000000000002c00006800003d00006700002d3d2d0000000000000000002c00000068003d0000002c3d2c00000000000000000000002d3d2c000000000000000000000000000000
00000000000000000000002c0000007700000000000000000000000000000000003c00007700003d0000770000002c3c3d3d0000000000001000000000003c00007700003d000077102d3d3d3d0000000000000000003c00000077003d00002c3c3d3c000000000000000000002c3d3d3c000000000000000000000010000000
__sfx__
a00200001256015560185601b5601d5602056023560235601f5601e5601d5601d5601e56022560245602456023560235602256021560205601f5601e5601c5601b5601a560195601856016560155601456012560
a408000021050260502a0502d0502f05031050300502e0502a05027050260502605027050290502b0502e05031050340503605038050380503505033050300503105033050350503a0503d0503d0503e0503f050
300100000e3500e3500e3500e3500e3500e3500e3500e3500e3500e3500d3500d3500e3500e3500e3500f3500f35010350103501235013350153501635018350193501b3501c3501e35020350223502435028350
460e000008150061500815006150071500515007150051500415004150041500415004150041500415004100041000a1000a1000a1000a1000a1000a1000a1000b1000b1000b1000b1000b1000b1000b1000b100
94010020392503925039250392503825038250382503825038250382503825038250382503825037250372503925039250392503a250392503925039250392503925039250392503925039250392503a2503b250
00100010234531f4531c453244531d4531c453264531d4531b453274531e4531b453254531b4531e453224530f403124031240314403164030c4030e40310403114031340315403184031a4031c4031d40321403
310200201301612016110161101610016100160f0160e0160d0160c0160c0160b0160b0160b0160b0160a0160a0160a0160a0160a0160a0160a0160a0160a0160a0160b0160b0160c0160d0160e0160f01612016
0001000000b0031b5032b5032b5032b5031b5031b5030b5030b5030b502fb502fb502fb502eb502db502bb502bb5029b5028b5024b5022b5020b501eb501ab5018b5016b5015b5013b5013b5012b5011b5010b50
d240001019334193341c3341c3341933419334163341633418334183341b3341b3341833418334153341533415304183040d3040c3040b3040c3040c3040c3040b3040a304083040630405304043040330402304
0e0300001e63023640286402b6502e650316603266033660316502d6402864026640216301d650196501665013650106500e6500c65009650076500565003650026500165000650006502d600286002660025600
000100003d3503b3503a35037350353503335032350303502f3502f3502d3502b3502a3502835025350253502435024350224502345021450204502245023450294502f4502f450304503445035450394503e450
__music__
02 444b4844
03 04424344
03 08464344
00 02424344

