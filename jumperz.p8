pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--init and utilities--


function _init()

music(-1,0,0,3)

cd = 10

epi = 0
whoa=false


npcs={}

bugs = {}

bunnies = {}

stars={}

credstars={}

state="play"


 mode="ground"
 bunnies_total=0
 bunnies_collected=0
 
 bugs_total=0
 bugs_squished=0
 bob_spawn=false
 game_win=false

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
  wall=false,
  yum=false,
  yum_t=0,
  eat_t=0,
  t=0
 }
 

 set_starfield()
 set_credstars()
 bunny_init()
 bugs_init()
 gravity=0.3
 friction=0.85
 
  
 moses=npc_init(49,48,49,moses_chat)
 noah=npc_init(50,48,50,noah_chat)
 goku=npc_init(51,48,51,goku_chat)
 
 
 cam_x=0
 cam_y=0
 map_start=0
 map_end=1024
 map_height=512
end

--utilities--

function collide_map(obj,aim,flag)
 local x=obj.x
 local y=obj.y
 local w=obj.w
 local h=obj.h
 local x1=0
 local y1=0
 local x2=0
 local y2=0

 if aim=="left" then
  x1=x-1
  y1=y
  x2=x
  y2=y+h-1

 elseif aim=="right" then
  x1=x+w-1
  y1=y
  x2=x+w+1
  y2=y+h-1

 elseif aim=="up" then
  x1=x+1
  y1=y-1
  x2=x+w-2
  y2=y

 elseif aim=="down" then
  x1=x+1
  y1=y+h
  x2=x+w-2
  y2=y+h
 end

--pixels to tiles
 x1/=8
 y1/=8
 x2/=8
 y2/=8

 if fget(mget(x1,y1), flag)
  or fget(mget(x1,y2), flag) 
  or fget(mget(x2,y1), flag)
  or fget(mget(x2,y2), flag)
  then
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

function blink(obj,sp1,sp2)
 obj.t += 1
 local s={sp1,sp2}
 obj.sp = s[flr(obj.t/8) % 2 + 1]
end

function dialog(l1, l2)

 camera()
 rrectfill(14, 88, 100, 22, 3, 0)
 rrect(14, 88, 100, 22, 3, 7)
 
 
 if l1 then
  print(l1, 19, 93, 7)
 end
    
 if l2 then
  print(l2, 19, 100, 7)
 end
 
// if l3 then
//  print(l3, 19, 107, 7)
// end
 
 camera(cam_x, cam_y)
 
end

function points(sp, x, y, col, count, total)
 camera()
 spr(sp, x, y)
 print(count.."/"..total, x+9, y+2, col)
 camera(cam_x, cam_y)
end

function sp_pnts(sp, x, y, col, text)
 camera()
 spr(sp, x, y)
 print(text, x+9, y+2, col)
 camera(cam_x, cam_y)
end

function player_loop()

 if player.x<map_start then
  player.x=map_end-player.w
 end
 
 if player.x>map_end-player.w then
  player.x=map_start
 end

end
-->8
--update and draw--

function music_check()
 if mode=="space" then
  if not space_music then
   music(0,4)
    space_music=true
  end
 else
  music(-1)
  space_music=false
 end
end

function epi_update()
 if epi<=15 then
  epi+=1
 else
  epi=0
 end
end

function countdown()
 if cd >0 then
  cd-=1
 else
  cd=10
 end
end


function _update()

if state=="play" then

 music_check()
 epi_update()
 countdown()
 
 rndbool = rnd{false,true}

 player_update()
 player_animate() 
 player.oldx=player.x
 player.oldy=player.y

 bunny_update()
 
 bugs_update()
 
 npc_update()
   
 cam_x=player.x-64+player.w/2
 cam_y=player.y-96+player.h/2

 mode_check()
 win_check()
 
// moses.win=true
// noah.win=true
// goku.win=true
end

if state=="credits" then

player.x=64
player.y=64
player.x=player.oldx
player.y=player.oldy
player.spr=14
update_credstars()

end

end

function _draw()

if state=="play" then

 if mode=="ground" then
  ground_draw()
 elseif mode=="under" then
  under_draw()
 elseif mode=="space" then
  space_draw()
 elseif mode=="warp" then
  warp_draw()
 elseif mode=="bonus" then
  under_draw()
 end

 camera(cam_x,cam_y)
 map(0,0,0,0,128,64)
 spr(player.sp,player.x,player.y,1,1,player.flp)
 
 yum_draw()
 
--npcs

 bunny_draw()
 bugs_draw()
 npc_draw()
 npc_chat()

--score

 all_points()

// print(player.flp,player.x-4, player.y-10,15)
// print(player.yum,player.x,player.y-20,3)
// print(player.yum_t,player.x+4,player.y-30,0)
// print(mode,player.x-8,player.y-10,14)
// print(player.x,player.x-12,player.y-20,7)
// print(player.y,player.x,player.y-20,8)

end

if state=="credits" then

 camera(0,0)
 map(0,0,0,0,128,64)
 
 draw_credstars()

 spr(14,64,64,2,2,0)

end


end

function mode_check()

 if player.y < 0 then
  player.y = 480
 end
 
 if player.y > 512 then
  player.y = 10
 end
 
 if mode ~= "bonus" then
  if player.y<260 
  and player.y>0 then
   mode="ground"
   mode_ground()
  elseif player.y>260
  and player.y<361 then
   mode="under"
   mode_under()
  elseif player.y>361 then
   mode_space()
   mode="space"
    if whoa==false then
     sfx(1,2)
     whoa=true
   end
  end
 end
end

function mode_space()
 player_loop()
 cam_y=mid(376, player.y-108,480)
 cam_x=mid(map_start,cam_x,map_end-127)
 update_starfield()
end
 

function mode_ground()
 player_loop()
 cam_y=mid(0, player.y-96, 240)
 cam_x=mid(map_start,cam_x,map_end-127)
end

function mode_under()
 player_loop()
 cam_y=mid(240, player.y-96, 240)
 cam_x=mid(map_start,cam_x,map_end-127)
end

function mode_spacewarp()

end

function mode_waterwarp()

end


function mode_bonus()

end


function ground_draw()
 cls(12)
end

function under_draw()
 cls(0)
end

function space_draw()
 draw_starfield()
end

function bonus_draw()

end

function waterwarp_draw()

end

function spacewarp_draw()

end


//starfield

function set_starfield()
 for i=1,1000 do
  local newstar={}
  newstar.x=rnd(1300)
  newstar.y=376+rnd(256)
  newstar.spd=rnd(1)
  add(stars,newstar)
  newstar.homex=newstar.x
  newstar.homey=newstar.y
 end
end

function update_starfield()
 for i=1,#stars do
  local s=stars[i]
   s.x=s.x % 1028
   if s.spd<0.2 then
   s.x=s.homex - player.x*.05
   elseif s.spd<.6 then
   s.x=s.homex - player.x*.1
   elseif s.spd<.8 then
   s.x=s.homex - player.x*.15
   elseif s.spd<.9 then
   s.x=s.homex - player.x*.2
   end
 end
end

function set_credstars()
 for i=1,1000 do
  local newstar={}
  newstar.x=rnd(128)
  newstar.y=rnd(128)
  newstar.spd=rnd(1)
  add(credstars,newstar)
 end
end

--function update_credstars()
-- for i=1,#stars do
--  local s=stars[i]
--   s.x=s.x % 128
--   if s.spd<0.2 then
--   s.x=s.x*.05
--   elseif s.spd<.6 then
--   s.x=s.x*.1
--   elseif s.spd<.8 then
--   s.x=s.x*.15
--   elseif s.spd<.9 then
--   s.x=s.x*.2
--   end
-- end
--end


function update_credstars()
 for i=1,#credstars do
  local mystar=credstars[i]
  mystar.y=mystar.y+mystar.spd
  if mystar.y>1028 then
   mystar.y=mystar.y-1028
   mystar.x=mystar.x+32
  end
  if mystar.y>512 then
   mystar.y=mystar.y-128
 end
 end
end

function draw_starfield()

 cls(0)

 for i=1, #stars do
  local mystar=stars[i]
  local scol=6
    
   if mystar.spd<0.2 then
    scol=8
   elseif mystar.spd<.3 then
    scol=9
   elseif mystar.spd<.4 then
    scol=10
   elseif mystar.spd<.7 then
    scol=7
   elseif mystar.spd<.9 then
    scol=12
   end
    pset(mystar.x,mystar.y,scol)
 end
end

function draw_credstars()

 cls(0)

 for i=1, #stars do
  local mystar=stars[i]
  local scol=6
    
   if mystar.spd<0.2 then
    scol=8
   elseif mystar.spd<.3 then
    scol=9
   elseif mystar.spd<.4 then
    scol=10
   elseif mystar.spd<.7 then
    scol=7
   elseif mystar.spd<.9 then
    scol=12
   end
    pset(mystar.x,mystar.y,scol)
 end
end
-->8
--player

function player_update()

--physics
 player.dy+=gravity
 player.dx*=friction

--controls
 if btn(⬅️) then
  if player.jumping
  or player.falling then
   player.dx-=player.acc*5
  else
   player.dx-=player.acc
   player.running=true
   player.flp=true
  end
 end

 if btn(➡️) then
  if player.jumping
  or player.falling then
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
   sfx(2,0)
   player.dy-=player.boost
   player.landed=false
  end
 end
 
--yum

 if btnp(🅾️) then
  if player.swimming==false
  and player.yum==false then
   sfx(5,0)
   player.yum=true
   player.yum_t=0
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
  end
 end

--check collision left and right
if player.dx<0 then
 player.dx=limit_speed(player.dx,player.max_dx)
 if collide_map(player,"left",1) then
  player.dx=0
  player.x=player.oldx	
 end
 
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
 if player.yum then
  player_yum()
 elseif player.jumping then
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
  if time()-player.anim>.5 then
   blink(player,1,2)
  end
 end
 
end


function limit_speed(num,maximum)
 return mid(-maximum,num,maximum)
end
-->8
--npcs and win conditions


function npc_init(spnum,blink1,blink2,dialogs) 
local npc={
  sp=spnum,
  x=0,
  y=0,
  t=0,
  happy=false,
  win=false,
  talking=false,
  talked=false,
  cooldown=0,
  dialogs=dialogs,
  blink1=blink1,
  blink2=blink2,
  }
  
  for tx=0,127 do
   for ty=0,127 do
    if mget(tx,ty)==spnum then
     npc.x=tx*8
     npc.y=ty*8
     mset(tx,ty,0)
    end
   end
  end
  add(npcs,npc)
  return npc
end

function npc_update()
 for npc in all(npcs) do
  blink(npc, npc.blink1, npc.blink2)
   if npc.talking then
    if btnp(❎) then
     npc.talking=false
     npc.cooldown=30
     npc.talked=false
    end
   end
   if npc.cooldown>0 then
    npc.cooldown -= 1
   end
   if npc.cooldown==0
 //  and not npc.talking
   and abs(npc.x-player.x)<8
   and abs(npc.y-player.y)<8 then
   npc.talking=true
   if not npc.talked
   and not npc.win then
    sfx(3,3)
    npc.talked=true
   elseif not npc.talked
   and npc.win then
    sfx(6,3)
    npc.talked=true
   end
  end
 end
end

function npc_draw()
 for npc in all(npcs) do
  spr(npc.sp,npc.x,npc.y)
 end
end

function npc_chat()
 for npc in all(npcs) do
  if npc.talking then
   npc.dialogs()
  end
 end
end

function moses_chat()

 if not moses.win then
  dialog("i lost my bunnies.",
  "please find them.")
 elseif moses.win then
  dialog("thank you for",
    "finding my bunnies ♥")
 end
end

function noah_chat()

 if not noah.win then
  dialog("i'm scared!",
  "bugs are scary!")
 elseif noah.win then
  dialog("you saved my life!",
    "thank you ♥")
 end
end

function goku_chat()

 if not noah.win 
 and not moses.win then
  dialog("my brothers have",
  "silly problems..")
 elseif noah.win and moses.win
 and not goku.win then
  dialog("your final test",
  "is not yet ready.")
 elseif goku.win then
  dialog("your work here is done.",
    "return to the ship.")
 end
end

function bob_chat()

 if goku.win then
  dialog("time to go home",
  "little one.")
 end
end


function win_check()
 
 if bunnies_total==bunnies_collected then
  moses.win=true
 end
 
 if bugs_total==bugs_squished then
  noah.win=true
 end
 
 if bonus_done==true then
  goku.win=true
 end
 
 if goku.win==true 
 and not bob_spawn then
  bob=npc_init(55,56,57,bob_chat)
  bob_spawn=true
 end
 
 if bob_spawn
  and abs(bob.x-player.x)<8
 and abs(bob.y-player.y)<8 then
  game_win=true
//  state="credits"
  end
 

end

function all_points()

 if not goku.win then

  if not moses.win then
   points(17,5,5,7, bunnies_collected,bunnies_total)
  elseif moses.win then
   points(49,5,5,10, bunnies_collected,bunnies_total)
  end

  if not noah.win then
   points(34,5,15,7, bugs_squished, bugs_total)
  elseif noah.win then
   points(50,5,15,11, bugs_squished, bugs_total)
  end

 if moses.win and noah.win 
 and not goku.win then
  sp_pnts(51,5,25,7, "?")
 end
 end
 
 if goku.win
 and not game_win then
  sp_pnts(54,5,5,epi, " ???")
 elseif game_win then
  sp_pnts(54,5,5,epi, game_win)
 end
 
end
-->8
--bugs, yum, bunnies

function bugs_init()
 for bx=0,127 do
  for by=0,63 do
   local b = mget(bx,by)
   if fget(b,6) then
    add(bugs, {
    sp=32,
    x=bx*8,
    y=by*8,
    sx=bx*8,
    vx=rnd(2)-1,
    t=0,
    squishy=false,
    squished=false,
    slurped=false,
    eaten=false
    })
    mset(bx,by,0)
    bugs_total+=1
   end
  end
 end   
end

function bugs_update()
 for b in all(bugs) do
  if not b.squishy
  and not b.squished 
  and not b.slurped 
  and not b.eaten then
   blink(b,32,33)
   if rnd(1)<0.05 then
    b.vx=rnd(2)-1
   end
   
   --wall check
   local nx=b.vx>0 and b.x+8 or b.x-1
   local tile=mget(flr(nx)/8, flr(b.y/8))
   if fget(tile,1) then
    b.vx = -b.vx
   end
   
   --ledge check
   local fx=b.vx>0 and b.x+8 or b.x-1
   local floor=mget(flr(fx/8), flr(b.y/8)+1)
   if not fget(floor, 0) then
    b.vx = -b.vx
   end
   
   b.x += b.vx
   
   if abs(b.x-b.sx)>16 then
    b.vx = sgn(b.sx-b.x)
   end
  end
  
   if player.falling
   and not b.squishy
   and not b.squished
   and not b.slurped
   and not b.eaten
   and (abs(b.x-player.x)<8)
   and (abs(b.y-player.y)<8)
   and (player.y < b.y)
   and (player.dy > 0) then
    b.squishy=true
    b.cd=20
    bugs_squished+=1
    sfx(4,2)
    player.dy-=player.boost+1
    gravity=0.5
    player.landed=false
   end
  
  if b.squishy and b.cd>0 then
   b.cd-=1
  elseif b.squishy and b.cd<=0 then
   b.squished=true
  end  

 if b.slurped
 and player.yum_t>9 then
  b.slurped=false
  b.eaten=true
  bugs_squished+=1 
 end
 end
end

function bugs_draw()
 for b in all(bugs) do
  if not b.squished 
  and not b.eaten then
   if b.squishy and b.cd>0 then
    pal(14,epi)
    spr(34,b.x,b.y)
    pal()
   elseif not b.squishy then
    spr(b.sp,b.x,b.y)
   end
  end
 end
end

--yum

function player_yum()

   if player.eat_t>0 then
    player.eat_t-=1
   end

 player.yum_t+=1
 
 if player.yum==true then
  if player.yum_t>0
  and player.yum_t<=9 then
     player.sp=20
  end
  
  if player.yum_t>9
  and player.yum_t<=12 then
   player.sp=24
  end
  
  if player.yum_t>12
  and player.yum_t<=15 then
   player.sp=25
  end
  
  if player.yum_t>15
  and player.yum_t<=18 then
   player.sp=26
  end
  
  if player.yum_t>18 then
   player.yum=false
   player.yum_t=0
  end
 end
  
end

function yum_draw()

 if player.yum==true then
 
  if player.flp==false then
 
   if player.yum_t>0
   and player.yum_t<=2 then
    spr(23,player.x+8,player.y,1,1)
    bugs_yum(player.x+8,player.y)
   end
  
   if player.yum_t>2
   and player.yum_t<=4 then
    spr(21,player.x+8,player.y,1,1)
    spr(23,player.x+16,player.y,1,1)
    bugs_yum(player.x+16,player.y)
   end
  
   if player.yum_t>4
   and player.yum_t<=7 then
    spr(21,player.x+8,player.y,1,1)
    spr(22,player.x+16,player.y,1,1)
    spr(23,player.x+20,player.y,1,1)
    bugs_yum(player.x+20,player.y)
   end
  
   if player.yum_t>7
   and player.yum_t<=8 then
    spr(21,player.x+8,player.y,1,1)
    spr(23,player.x+16,player.y,1,1)
    bugs_yum(player.x+16,player.y)
   end
  
   if player.yum_t>8
   and player.yum_t<=9 then
    spr(23,player.x+8,player.y,1,1)
    bugs_yum(player.x+8,player.y)
   end
   
  elseif player.flp==true then
   if player.yum_t>0
   and player.yum_t<=2 then
    spr(23,player.x-8,player.y,1,1,true)
    bugs_yum(player.x-8,player.y)
   end
  
   if player.yum_t>2
   and player.yum_t<=4 then
    spr(21,player.x-8,player.y,1,1,true)
    spr(23,player.x-16,player.y,1,1,true)
    bugs_yum(player.x-16,player.y)
   end
  
   if player.yum_t>4
   and player.yum_t<=7 then
    spr(21,player.x-8,player.y,1,1,true)
    spr(22,player.x-16,player.y,1,1,true)
    spr(23,player.x-20,player.y,1,1,true)
    bugs_yum(player.x-20,player.y)
   end
  
   if player.yum_t>7
   and player.yum_t<=8 then
    spr(21,player.x-8,player.y,1,1,true)
    spr(23,player.x-16,player.y,1,1,true)
    bugs_yum(player.x-16,player.y)
   end
  
   if player.yum_t>8
   and player.yum_t<=9 then
    spr(23,player.x-8,player.y,1,1,true)
    bugs_yum(player.x-8,player.y)
   end
  
  end
  
 end
 
end

function bugs_yum(tx,ty)
 for b in all(bugs) do
  if not b.squishy
  and not b.squished
  and not b.slurped
  and player.eat_t==0
  and abs(b.x-tx)<8
  and abs(b.y-ty)<8 then
   sfx(7,2)
   b.slurped=true
   player.eat_t=10
  end
  if b.slurped then
  b.x=tx
  b.y=ty
 end
 end
end

--bunnies


function bunny_init()
 for tx=0,127 do
  for ty=0,63 do
   local t = mget(tx,ty)
   if fget(t,5) then
    add(bunnies, {
    sp=16,
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
   blink(b,16,17)
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
__gfx__
00000000017bb710017bb710071bb710071bb710017bb71000000000b000b000bb0000bb071bb170071bb7100000000011111111111111110000000000000000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb0077bb770bb77bbb70bbbbbb0077bb770077bb770000000001131111ee1131c110000000ee0000000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb0071bb1700b778bb1077777700bbbbbb00bbbbbb000000000111311eeee131166000000eeee000000
000000000b8bb8b0bb8bb8bbbb8bb8bbbb8bb8bbbb8bb8bb0bbbbbb00b78bbbb07788770bb8bb8bbbb8bb8bb0000000011131eeeee311c1100000eeeeee00000
000000000778877007788770077887700778877007788770bb8bb8bb0b78bbbb0b8bb8b00778877007788770000000001131eeeeee3e11110000eeeeeeee0000
0000000007777770077887700777777007777770b778877b077887700b778bb7bbbbbbbb077887700778877000000000113eeecccc3ee111000eeecccceee000
000000000bbbbbb00bbbbbb00bbbbbb00bbbbbb000bbbb00b778877bbb77bbb10bbbbbb0bbbbbbbbbbbbbbbb0000000011e3ecccccc3ee1100eee77bb77eee00
000000000b0000b00b0000b00b000b00b000000b00000000bbbbbbbbb000b000071bb170b000000bb000000b000000001e3ecccccc3ceee30eeec70bb07ceee0
07777770777007770000000000000000017bb710000000000000000000000000017bb710017bb710011bb11000000000eee3ccccccc3ee3eeeeecbbbbbbceeee
07e77e707e7777e700000000000000000bbbbbb0000000000000000000000000077bb7700bbbbbb0033bb33000000000ee3eeeecceeeee3eeeeeeee88eeeeeee
077777707777777700000000000000000bbbbbb00000000000000000088800000bb8eee00bbbbbb00bbbbbb0000000001183eeee3eee1813008eeeeeeeeee800
07c77c7007c77c700000000000000000bb888888888888888888000088888000bb88cccbbbbbbbbbbb8bb8bb0000000011311ee3eee1111300800eeeeee00800
07777770077777700000000000000000077887700000000000000000088800000778e7e007788770077bb7700000000011131eee3ee1113100000eeeeee00000
076996700769967000000000000000000777777000000000000000000000000007777770077777700777777000000000113111e344411131000000eeee000000
077667700776677000000000000000000bbbbbb00000000000000000000000000bbbbbb00bbbbbb00bbbbbb00000000011434444344414430000000000000000
077777700077770000000000000000000b0000b00000000000000000000000000b0000b00b0000b00b0000b00000000044444444444444440000000000000000
000000000000000000000000000000000000000000070000000c0700007c07000050050000500500122552211114411108ee888008ee88800000000000066000
000000000dddddd00000000000000000000000000000000000000000070070700865568009655690255555521899998188888888888888880000000006677600
0dddddd00dedded0dddddddd00000000000000000000070000707c00007c00c768866886699669962577775219355391e888888ee898898e0066666006777760
0deeeed00deeeed0deeeeeed00000000000000000070000000000070070707005666666556666665357ee75349522594e8888888e89889880067777667777776
0dccccd00dccccd0ddccccdd00000000000000000000c00007c0700070c00c706568865665699656357ee7534952259488888888888888880667777777777776
0d5ee5d00d5ee5d0dd5ee5dd00000000000000000000000000000070007070006688886666999966257777521935539188888888888888880677777777766660
0dedded00dedded0deeddeed00000000000000000000000000007000070c07000665566006655660255555521899998100666600006666000677667776677760
0dddddd00dedded0dddddddd000000000000000000000000000c00000007000000500500005005001225522111144111006666000066c6006776776777777776
00000000aa00a0aa000b00000e0000e00000000000000000000000001111111171191b12911c1b18cccccccc7effffe700666600006666006777776777777776
009bc2000a9bc2a00b9bc2bb009bc20000000000000000000000b0001111b1111a19b1811c91b121c777777cec6996ce00c66c0000c66c006777777777777776
001bc100001bc100001bc1000e1bc1e0000000000000000088ac900c88ac911c88ac981c22ca121ac7eeee7cf6bbbb6f00666600006666006677777777777776
00977200aa9772aabb9772b000977200000000000000000000ce79c011ce79c111ce79c119a7e1a1c7e66e7cf9baab9f00666600006666000066666777777776
001881000a1881a000188100ee1881ee00000000000000000097e0001197e1111b97eb111b1e7b91c7e66e7cf9baab9f006c6600006c66000000066777777776
00dddd0000dddd000bddddbb00dddd0000000000000000000089000011891111b189ba88b121bc22c7eeee7cf6bbbb6f00666600006666000000006677777666
009bc200aa9bc2aa009bc2000e9bc2e00000000000000000000c90a0111c91a1181c91a1121a19c1c777777cec6996ce0066c600006666000000000666666600
00000000a00a000a000b000000e00e00000000000000000020c0000021c1111121c1911781a1c119cccccccc7effffe700666600006666000000000000000000
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
3b00000080544444440000004445530e45400e0045531e1145530e00004454001333b3111333b311e8e3b3111111111111111111e14466444444644111000111
47a000000355444447400000444453b04453b0009453b1114453b00000445400313bb311313bb31e1e3bb31e111111111111111111146444454444a111111117
4433000000a544444444000044443b00443b0000443b1111443b0000004444007333b3117333b3117133b31111111a111111111113f444444454441111a11111
4443b30000354444444440004444390044390000443911114439000000445400113bb311113bb313113bb3e111111111111111111f4445444444f11111111111
4e443b30903544444e4444004444530044530000445311114453000000444400113b33111a3b33311a3b3e8e1711111111111c111444444444f4445111111111
44444f390335444444444f00444553b0455800004853b1114553b00004444440413bb314713bb313713bb3e11111111111111111114a44444444444111111a11
4444444300544444444444404445330044000000453311114533000044544544443b3344113b3331113b33111111111111111111b144a444944944e111111111
96b696c6b6a6c6b6d61434143404240424340424143414340424241434143404241434143404240424343434241404140424343424c4d4e4e4e4f40424241434
143404240424343414041404243434c4d4d4e4e4f4241436f6170424042414041404243434241404241434141404140424343424140414e6c6b6a6b6a6b696b6
a7b797b7b7a7c7c7d7050505050505050505050505050505050505050505050505050505050505054646252505251515050525250525f5c7c7e5150505557575
75757575757575757575757575756425f5c7c7e515050536f6172535252515352505350515252515352505352525153525053505151515e7b7b797c797b7a7b7
97b797b7c7a7c7c7d715051535051525252545251525252545252525254646452555644646464646f6f664252535250535051525253525b7b766251555f6f6f6
f6f6f6f6f6f6f6f6f6f6f6f6f6f6f66425d5e53525252536f6170545464646464646464646464646464646464646464646464646464605e7b7b7a7c7a7b797b7
a7b797b7c7a7b7b7d71505153505152525251525250525252546462555f6f66455f6f6f6f6f6f6f6f6f6f6642525051525052525051545b7b7152555f6f6f6f6
f6f6f6f602f60202f602f6f6f6f6f6f66446462505252536f6172555f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f617e7b7b797c797b7a7b7
a7b797b7b7a7b7c7d725054646464646464646460515352536f6f6173601f6f6f6f6f6f644540701f6f6f6f66415352535150515254646b7b7464647f6f6f6f6
f6f6440606060606060607f6f6f6f6f6f6f6f66446464655f6171547f6f6f600f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f617e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7d72526f6f6f6f6f6f6f6f6f66425252536f6f617060647f6f6f6f6f61625350607f6f6f6f66446464646464655f6f6b7c7f6f6f6f6f64407
f6f61715252515250515250607f6f6f6f6f6f6f6f6f6f6f6f6172547f6f6f623f6f6f6f6f6f6f6f6f6f6f6f6f601f6f6f6f6f602f67415e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7d74555f6f6f6f6f6f6f6f6f6f664464655f6f6174555f6f6f6f6f6f6171525152507f6f6f6f6f6f6f6f6f6f6f6f6f6b7b7f6f6f6f67425e7
c6b7d7250505250535253525250607f6f6f6f6f6f6f6f6f6f6160547f6f6a3a3a3f6f6f6f6f6f6f6f6f6f6f6f644e6f6f6f64454343545e7b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c794a4f7f7f7f7f7f7f7b507f6f6f6f6f6f6f6f6161536f6f6f602f674352505054536f6f6f601f6f6f6f6f6f6f6f601b7b7f6f6f6742525e7
c7b7d71525251525051505152515250607f6f6f6f6f6f6f6f6644647f6f6f6f6f6f6f6f6f6f602f6f6f6f6f6f61637f6f6f61735252535b4b7b7a7c7a7b7a7b7
a7b797b7b7a7b7c7c7c78595a5b5052525152507f6f6f6f6f6f6f6644655f6f644540635252515350556f7f7d634e6c6f7b6c6f7c6f7a6b7c7c6f7b5060515e7
c7b78405352505354535b4a49484250525060702f601f602f6f6f6f6f6f6f6f6f6f6f6f6f6a3a3a3f6f6f6f6f61756f7f7f79494a494a4c7b7b7a7b7a7b7a7b7
a7b797b7b7a7b7c7b7b50505252525352525051507f6f6f601f6f6f6f6f6f6f616351525152525053557b7b7d725e7c7c7c7c7c7c7c7a7c7b7b7b535253525b4
b7b7b794a49494a49494c7b7b7c79494841525060606060607f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f61656b7c7c7b7c7c7c7c7c7b7b7a7b7a7b7a7b7
c5a587a595c5a595b53525250515352505153515250606060607f6f6f6f6f6f617252535253535052556c7c7d725e7b7b7c7c7b7b7b797c7b7b7d7250525b4c7
b7b7c7b7b7b7b7b7b7b7b7b7c7b7c7c7b7842525051505152507f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f617f5a5a595a5c7c7c7c7c7c795c5a5c595c5a5
252525052505052505253525352525253525252505153525352507f6f6f602f6163525252525052525f5a5b7d715e7959585a5a5a595a7a5a585d7153525b7b7
b7b7b79585a595b785b7b7c7c7c0d0c773c7d71535253525051507f6f6f602f6f602f6f602f602f6f602f6f674253545051535f5a595a585b505050505052525
1525251525051525250515250515051525250515251525250515050606060606252525051525051525250515252525250515051525250515251525250545d595
a585b5352525152505f5a595a5c1d185a5b525250515051525250506060606060606060606060606060606061525252525253525252525252525452525253515
25051525053525051535253535253525051535253525051535253525350515351505253525053525051535253525051535253525051535253525051535253505
15350525352505354535350535051535052505153525352505153525350515352535250515352535252505152525051505152525051525252525153535252525
b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2
b2b2b2b2b2b2b2b2b2b2b2a2a2a2a2a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000b2a2b200000000000000b2a2b200000000000000000000b2a2b20000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a30000330000a30000000100000000000000000000000000000000000000000000000000000000000000b2a2b2000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a3a3a3a3a3a3a30000b2a2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b2a2b20000000000b2a2b2000000000000b2a2b2000000000000000000000000
000000000000000001000000000000000000000000000000b2a2b200000000000000000000000000000000000000000000000000000000000000000000000000
0000010000000000000000000000b2a2b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000b2a2b200000000000000000000000000000000000000000000000000000000000000b2a2b20000000000000000000000000000000000000000
00b2a2b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2a2b200000000010000
00b2a2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2a2b2000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2a2b200
0000000000000000000000000000000000000000000000000000000000b2a2b20000000000000000000000000000000000000000000000000000000000000000
0000000000000000b2a2b2000000000000000000b2a2b20000000000b2a2b200000000000000000000b2a2b20000000000b2a2b2000000000000000000000000
0000000000000000000000000000000000000000000001000000000000000000000000000001000000000000000000d200000000010000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b2a2b200000000000000000000000000b2a2b2000000000000000000000000b2a2b20000000000000000d3000000b2a2b2000000000000000000d2
00000000000000000000000000000000000000000000000000000000000000000000d2000000000000000000000000000000000000000000d200000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d20000d30000000000000000d2000000000000d3
0000000000000000000000000000d200000000000000000000000000000000000000d3000000d200000000000000d2000000000000000000d300000000000000
0000000000000000000000000000d200000000d2000000000000d20000000000000000000000000000000000d30000d30000000000000000d3000000000000d3
0000000000000000000000000000d30000000000000000d20000000000000000d200d3000000d300000000000000d300000000d200000000d300000000000000
0001000000000000000000000000d300000000d3000000000000d30000000000000000000000000000000000d30000d30000000000000000d3000000d20000d3
d200d20000d20000000000d20000d30000d20000d20000d30000000000000000d300d3000000d300000100000000d300000000d300000000d300d200d200d200
d2d2d200d200d200d20000000000d300000000d3000000000000d3000000d200000000d2000000d20000d200d30000d30000000000000000d3000000d30000d3
d300d30000d3000000d200d30000d30000d30000d30000d3000000d200d20000d300d3000000d300d2d2d2000000d300000000d300000000d300d300d300d300
d3d3d300d300d300d30000000000d300000000d3000000000000d3000000d300000000d3000000d30000d300d30000d30000000000000000d3000000d30000d3
__label__
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777cc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7e7777e7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7c77c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc777cc777ccccccccccccccccccccccccccccccccccccccccccccccccc769967cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc7e7777e7ccccccccccccccccccccccccccccccccccccccccccccccccc776677cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc77777777c777ccc7c777c777cccccccccccccccccccccccccccccccccc7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc7c77c7cccc7cc7cc7ccc7c7ccccccccccccccccccccccccccccccccccc66cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc777777cc777cc7cc777c7c7ccccccccccccccccccccccccccccccccc66776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc769967cc7cccc7cccc7c7c7cccccccccccccccccccccccccc66666cc677776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc776677cc777c7ccc777c777cccccccccccccccccccccccccc67777667777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc7777ccccccccccccccccccccccccccccccccccccccccccc667777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc67777777776666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc67766777667776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc6776776777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc6777776777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccddddddddc777ccc7c777c777cccccccccccccccccccccccc6777777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccdeeeeeedccc7cc7cccc7c7cccccccccccccccccccccccccc6677777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccddccccddc777cc7cc777c777cccccccccccccccccccccccccc66666777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccdd5ee5ddc7cccc7cc7ccccc7ccccccccccccccccccccccccccccc66777777776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccdeeddeedc777c7ccc777c777cccccccccccccccccccccccccccccc6677777666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccddddddddccccccccccccccccccccccccccccccccccccccccccccccc6666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66cccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66776ccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666cc677776cccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777667777776ccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc667777777777776ccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67777777776666cccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc67766777667776cccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6776776777777776ccccccccccccccccccc
66ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777776777777776ccccccccccccccccccc
776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777776ccccccccccccccccccc
7776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777777777776ccccccccccccccccccc
77776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666777777776ccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66777777776ccccccccccccccccccc
6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777666ccccccccccccccccccc
7776cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666ccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77776ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc777cc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc7e7777e7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc77777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc7c77c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc769967cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccc776677cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
e888cccccccccccccccccccccccccccccccccc8ee888cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
88888cccccccccccccccccccccccccccccccc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
8898ecccccccccccccccccccccccccccccccce898898eccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
88988cccccccccccccccccccccccccccccccce8988988ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
88888cccccccccccccccccccccccccccccccc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
88888cccccccccccccccccccccccccccccccc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccccccccccccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6c6cccccccccccccccccccccccccccccccccccc66c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666ccccccccccccccccccccccccccc8ee888ccc6666ccc8ee888cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
66ccccccccccccccccccccccccccc88888888ccc66ccc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccce888888ecc6666cce888888eccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccce8888888cc6666cce8888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c66cccccccccccccccccccccccccc88888888cc6c66cc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccc88888888cc6666cc88888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccccc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666cccccccccccccccccccccccccccc6666cccc6666cccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666ccccccccccccccccccc8ee888ccc6666cccc6666cccc6666cccccccccc17bb71ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ddddddccccccccccccccc88888888ccc66cccccc66cccccc66cccccccccccbbbbbbcccccccccccccccccccccccddddddcccccccccccccccccccccccccccccccc
deddedccccccccccccccce888888ecc6666cccc6666cccc6666ccccccccccbbbbbbcccccccccccccc888ccccccdeddedcccccccccccccccccccccccccccccccc
deeeedccccccccccccccce8888888cc6666cccc6666cccc6666cccccccccbb88888888888888888888888cccccdeeeedcccccccccccccccccccccccccccccccc
dccccdccccccccccccccc88888888cc6c66cccc6c66cccc6c66cccccccccc778877cccccccccccccc888ccccccdccccdcccccccccccccccccccccccccccccccc
d5ee5dccccccccccccccc88888888cc6666cccc6666cccc6666cccccccccc777777cccccccccccccccccccccccd5ee5dcccccccccccccccccccccccccccccccc
deddedccccccccccccccccc6666cccc66c6cccc6666cccc66c6ccccccccccbbbbbbcccccccccccccccccccccccdeddedcccccccccccccccccccccccccccccccc
deddedccccccccccccccccc6666cccc6666cccc6666cccc6666ccccccccccbccccbcccccccccccccccccccccccdeddedcccccccccccccccccccccccccccccccc
b8bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb3bbb3bb3b3bbabbb33bbbbbb33bbabbb33bbbbbb3bbb3bb3bb2bb3bbbb2bb3bbbbbb3bb3b3bbabbb33bbbbbb3bbb3bb3b3bbabbb3b2bb3bbb3bbabbb33bb
bb3333bbbbbbb33bbb333333bb33333bbb333333bb3333bbbbbbbbbbbbbb3bbbbbbb33bbbbbbb33bbb333333bb3333bbbbbbb33bbb333bbbbbbb333bbb33333b
3334443bbbbbb43bb33444433334443bb33444433334443bbbbbbbbbeb334bbbeb33443bbbbbb43bb33444433334443bbbbbb43bb3344bbbeb33443bb334443b
444e4443bbb3344334444444444e444334444444444e4443bbb333bbbb3543bbbb354443bbb3344334444444444e4443bbb33443344443bbbb35444334444443
44444443b333444334444442444444433444444244444443b33344333344443333444443b33344433444444244444443b3334443344444333344444334444443
49444d4434444444444f444449444444444f444449444d4434444d444444fd444444fd4434444444444f444449444d4434444444444f4d444444f444444f4444
44444444444d446444444444444444644444444444444444444d444f444f444f444f4444444d44644444444444444444444d44644444444f444f446444444464
4444444444444444444444444444444444444444444a444444444444444a4444444444444444444444444444444444444444444444444444444a444444444444
44444449444444446442444545444449444444444444444545444444444444446442444944444449444444446442444545444449444444444444444545444449
44444444444444844444444454444444444444744944444454444474494444844444444444444444444444844444444454444444444444744944444454444444
4944444449444444fff444454444444449444444444444454444444444444444fff444444944444449444444fff4444544444444494444444444444544444444
4444444444444444f64444445454444444444444444444445454444444444444f64444444444444444444444f644444454544444444444444444444454544444
4444444444444444444e444445454444444444e444444444454544e444444444444e44444444444444444444444e444445454444444444e44444444445454444
444944494449444d44e44444445444494449444444f444444454444444f4444d44e44449444944494449444d44e44444445444494449444444f4444444544449
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b4444e44b444
33734493337344933373449333734493337344933373449333734493337344933373449333734493337344933373449333734493337344933373449333734493
c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333c3cc3333
8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc8ccecccc

__gff__
000000000000000000000000040404042000000000000000000000000404040440000000000000000000031301111010808000000000008400000303000010100303030303030201040404040404040503030303030004000404040404040405030303030304030303010104040b0b0007030703030408030404040404020204
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
002e2f000000000000000000000000000000000000000000000000000000000000002e2f00003e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000100000000000000000002e2f00000000000000000000000000000000
003e3f0000000000000000000000002e2f00000000002e2f000000000000000000003e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e3f0000002e2f00002e2f0000000000000000003e3f00000000000000000000000000000000
0000000000000000000000000000003e3f00000000003e3f0000000000002e2f00000000000000000000000000000000002e2f000000000000000000002e2f00000000000000000000001000000000000000000000000000000000000000003e3f00003e3f000000000000000000000000000000000000000000000000000000
000000000000002e2f0000000000000000000000000000000000000000003e3f00000000000000000000000000000000003e3f000000000000000000003e3f000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000002e2f00
000000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e3f0000000000000000000000000000000000000000000000000000000000000000000000003e3f00002e2f00000000000000003e3f00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000002e2f0000000000000000000000000000000000002e2f0000000000000000003e3f0000000000000000000000
000000000000000000000000001000000000000000000000000000100000000000000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000002e2f000000000000003e3f0000000000000000000000000000000000003e3f00000000000000000000000000000000000000000000
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
00003e3f00000000000000000000000000000000000000000000003e3f0000000000003e3f00000000000000000000002e2f0000000000000000000000000000000000000000000000000000000000100000000000003e3f00000000000000000000000000000000000000000000003e3f000000000000000000003e3f000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000003e3f000000000000000000000000000000000000000000100000000000002e2f000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000006800000000000000000000000000100000000000000000000000000000680000000000003e3f000000000000000000000000000000000000000000000000000000000000000000000000002e2f000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000670000000000000000000000002e2f0000000000000000000000000000670000000000000000000000000000000000000000000000000010000000000000000000000000001000000000003e3f000000000000000000
0000000000000000000000000000001000000000000000000000000000000000001000001000002d00006700000000002d1000000000003e3f00000000001000000000002d0000670000002d000000000000000000001000000000002d000000002d000000000000000000000000002d00000000000000000000000000000000
0000000000000000000000310000006700000000000000000000000000000000002c00006800003c000067000000002c3d2c0000000000000000000000002c00006800003d00006700002d3d2d0000000000000000002c00000068003d0000002c3d2c00000000000000000000002d3d2c000000000000000000000000000000
00000000000000000000002c0000007700000000000000200000002000000000003c00007700003d0000770000002c3c3d3d0020000000000000000020003c20007700003d200077002d3d3d3d0010000000000000003c00000077003d20002c3c3d3c000000200000200000002c3d3d3c000020000000000000000010000000
__sfx__
a00200001254015540185401b5401d5402054023540235401f5401e5401d5401d5401e54022540245402454023540235402254021540205401f5401e5401c5401b5401a540195401854016540155401454012540
a408000021050260502a0502d0502f05031050300502e0502a05027050260502605027050290502b0502e05031050340503605038050380503505033050300503105033050350503a0503d0503d0503e0503f050
c00100000e3200e3200e3200e3200e3200e3200e3200e3200e3200e3200d3200d3200e3200e3200e3200f3200f32010320103201232013320153201632018320193201b3201c3201e32020320223202432028320
460e000008150061500815006150071500515007150051500415004150041500415004150041500415004100041000a1000a1000a1000a1000a1000a1000a1000b1000b1000b1000b1000b1000b1000b1000b100
940100000e5501a550125501455017550245501d550205501f5502f550285502b5502d550275502d5502c55033550285502755027550265502f550205502355021550265501f5501a5501d5501b5502455019550
0002000008337093370a3370b3370c3370e3371133715337173371a3371b3371e3372133724337263372a3372d3372f337333373433736337373370f3070d3070b3070a307083070630704307033070230705307
460e00000815006150081500615007150051500715005150091500915009150091500a1500a1500a15004100041000a1000a1000a1000a1000a1000a1000a1000b1000b1000b1000b1000b1000b1000b1000b100
000200002a5172b5172c51728517255172451721517205171f5171d5171c5171a51719517175171b507235071951720517265172851729517295172951729517275172651724517215171f5171d5171b5171b517
000a002026004000040100401004280042d054320042505400004270540c0040c004320543300435004370043b05434004320042f05430004250543000430004310041a054300042d00428004260042600426004
d11400101d1001c1001f1000f150261000f1500f10020150171501b1002d1000e15025100221500d1502c1000c1001a1000e10011100221001e1000a100001001610018100001000e10021100211002610025100
d01400201d3011d301173011730131301303011730119301203011c3012d301243012530125301193012c3011a3011a3010e3011b301223012230102301003011830118301003010030121301213012630125301
460a002026204002040120401204282042d204090042520400204272040c2040c204322043320435204372043b20434204322042f20430204252043020430204312041a204302042d20428204262042620426204
002100202630200302303022d3022a3022d30225302253022230224302203022d30232302283022c302283023b302243022b302343023230236302213022a3022e302323022f3022d30228302363022f30231302
46020000186041a6041c6041c6041f604206042260425604276042a604306043360435604386043a6043b6043c6043c6043c6043a6043860434604316042e6042b60429604286042560423604216041e6041c604
__music__
02 48490809
03 494b4c44
03 4c4d4344
00 42424344

