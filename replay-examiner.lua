local ghostState = 2
local cFrameIndex = 1
local js = {}
local timerFrame = 0

local function getJointStates()
	
	for i = 0, 1 do
		for k = 0, 19 do 
			js[i][k] = get_joint_info(i, k).state
		end
	end
	return 1
end

local function setJointStates()
	for i = 0, 1 do
		for k = 0, 19 do 
			 set_joint_state(i, k,js[i][k])
		end
	end
end

local function getTurnFrames(rplFile)
	file = io.open("replay/".. rplFile, "r", 1)
	
	repeat
		line = file:read()
	until string.sub(line, 1, 7) == "NEWGAME"
	
	local wwords = {} 
	
	for wword in line:gmatch("%S+") do
		table.insert(wwords, wword) 
	end
	local twords = {0}
	gameMatchFrames= string.sub(wwords[2],3,-1)
	
	for tword in wwords[3]:gmatch("%P+") do
		table.insert(twords, tword) 
	end
	
	return twords
end

local function handle2D()
	
	if analzyMode == true and fogMode == true then
	
		 set_color(1, .7, 0, .8)
		 draw_centered_text(tostring(timerFrame), 0, 0)
	 	 if get_world_state().winner ~= -1 then analzyMode = false; set_option("timer", 1) end
	end
end

local function eachFrame()
	local ws = get_world_state()
	
	timerFrame = ws.game_frame - (ws.match_frame +2)
	
end

local function hCommands(c)
	cmd = c
	words = {} 
	numbers = {}
	
	for word in cmd:gmatch("%S+") do
		table.insert(words, string.lower(word)) 
	end
	
	if words[1] == "analyze" then
		tFrames = getTurnFrames(words[2])
		table.remove(tFrames, 1)
		
		run_cmd("lr ".. words[2])
		timerFrame = get_world_state().game_frame 
		cFrameIndex = 0
		keyOff = false
		analzyMode = true
		set_ghost(0)
		freeze_game()
		if words[3]=="-fogoff" then 
			fogMode= false
			set_option("timer", 1)
			count = 1  
		else 
			count = 2
			fogMode= true
			set_option("timer", 0)
		end

		return 1
	end
end

local function keyUp(key)
	
	if analzyMode == true then
		if  key == 32 and keyOff == false then
			
			set_ghost(0)
			
			cFrameIndex = cFrameIndex +1
			if cFrameIndex > #tFrames then cFrameIndex = 1 end
			keyOff = true
			
			run_frames(tFrames[cFrameIndex]-count)
			if count == 2 then count = 1 end
			return 1
			
		end
		if key == 98 then
			if ghostState == 0 then ghostState = 2 else ghostState = 0 end
			set_ghost(ghostState )
			return 1
		end
	end
end

local function endGame()
	echo("end game")
end

local function hFreeze()
	keyOff = false
	set_ghost(ghostState)
end

run_cmd("cl")
echo("type \"/analyze [REPLAY FILE]\" where")
--echo("type \"/analyze [REPLAY FILE] (-fogoff)\" where")
echo("    [REPLAY FILE] is something like \"001.rpl\"")
--echo("    And use \"-fogoff\" if you wante pedictive ghosts")
echo("")


add_hook("command","HandleCommands",hCommands)
   
add_hook("key_up", "HandleKeys", keyUp)
add_hook("enter_freeze", "HandleFreeze", hFreeze)
add_hook("enter_frame", "everyFrame", eachFrame)
add_hook("draw2d", "doTimer", handle2D)
add_hook("end_game", "resetOpt", endGame)