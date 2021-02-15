-----------------------------------------------------------------------------------------
--
-- main.lua
--
--
--
-----------------------------------------------------------------------------------------

--[[

	Ultimate showdown	v0.7
		Made by Samu Härkönen

	todo:
		- Music & Sounds
		- Player force adjustments for in-device testing
		- Non-copyright theming
		- Multiple enemies
		- Multiple stages
		- Character select
		- Better scoring system
		- Improved menus
		- REFACTOR NAMES!!!!
]]--

local physics = require("physics")
local widget = require("widget")
physics.start()
physics.setGravity( 0, 30 )


--// Stage setup //--
local background = display.newImageRect( "backgr.png", 580,340 )
background.x = 250
background.y = 150


--// Player & Enemy setup //--
local nickcage = display.newImageRect( "nick.png", 40, 55 )
nickcage.x = 100
nickcage.y = display.contentCenterY
physics.addBody( nickcage, {bounce=0.8, friction=1.5, density=1.0} )

local powerline = display.newImageRect( "arrow2.png", 150, 20 )
powerline.x = nickcage.x
powerline.y = nickcage.y
powerline.alpha = 0

local boss = display.newImageRect( "boss.png", 40, 55 )
boss.x = 300
boss.y = display.contentCenterY
physics.addBody( boss, {bounce=0.8, friction=1.5, density=1.0} )

--// Stage blocks setup //--
local wallEast = display.newRect( 480, 160, 20, 320 )
wallEast.strokeWidth = 3
wallEast:setFillColor(0.5)
wallEast:setStrokeColor(0)
physics.addBody( wallEast, "static",{density=1, friction=1.0})

local wallwest = display.newRect( 0, 160, 20, 320 )
wallwest.strokeWidth = 3
wallwest:setFillColor(0.5)
wallwest:setStrokeColor(0)
physics.addBody( wallwest, "static",{density=1, friction=1.0})

local wallbottom = display.newRect( 240, 250, 350, 50 )
wallbottom.strokeWidth = 3
wallbottom:setFillColor(255/255,128/255,0)
wallbottom:setStrokeColor(0)
physics.addBody( wallbottom, "static",{density=1, friction=1.0})

local walltopleft = display.newRect( 0, 0, 300, 50 )
walltopleft.strokeWidth = 3
walltopleft:setFillColor(0.5)
walltopleft:setStrokeColor(0)
physics.addBody( walltopleft, "static",{density=1, friction=1.0})

local walltopright = display.newRect( 480, 0, 300, 50 )
walltopright.strokeWidth = 3
walltopright:setFillColor(0.5)
walltopright:setStrokeColor(0)
physics.addBody( walltopright, "static",{density=1, friction=1.0})

--// Scoreboard setup, updated only during restart //--
local scoredisp = display.newText( "SCORE: 0", 250, 250, native.systemFont, 24 )
scoredisp:setFillColor(0)
	
function launch(event)
	--[[
		Function for PLAYER character to slingshot based on touch start
		and end points
	]]--
	if ( event.phase == "began") then
		--// Make powerline visible //--
		powerline.alpha = 1
	elseif (event.phase == "moved") then
		--// Calculate powerline angle and prevent divisions by zero //--
		powerline.horizontal = 0.0001 + (event.x - event.xStart)
		powerline.vertical = 0.0001 + (event.y - event.yStart)

		if (powerline.horizontal < 0) then
			powerline.rotation = math.deg(math.atan( (powerline.vertical/powerline.horizontal)))
		else 
			powerline.rotation = math.deg(math.atan( (powerline.vertical/powerline.horizontal)))+180
		end
	elseif (event.phase == "ended") then
		--// Calculate forces and set in motion and release focus //--
		local xforce = ( event.xStart - event.x )
		local yforce = ( event.yStart - event.y )

		--// MAX limits to prevent randomness in launching //--
		if (xforce > 100) then
				xforce = 100
		end
		if (yforce > 100) then
			yforce = 100
		end
		
		powerline.alpha = 0
		nickcage:setLinearVelocity( xforce*9, yforce*9 )
	end
end

nickcage:addEventListener( "touch", launch )



--// HACK METHOD!! FIX THIS! //--
local ending = nil
local button1 = nil
local starting = nil
local button2 = nil
--// Multi-function usable variables to allow removeSelf(), bad method //--

--// Trackable variables //--
local score = 0 -- Scoreboard counter
local counter = 0 -- GameLoop counter, 30 == 1 second
local gamestate = "start" -- State-machine for gameloop and end conditions. {"start","paused","running","win","lose"}


local function Begin(event)
	--[[
		Function to remove the start-image
		and the start-button and begin
		the AI-counter
	]]--
	if event.phase == "ended" then
		starting:removeSelf( )
		button2:removeSelf( )
		gamestate = "running"
		--// SetFocus on the PLAYER to allow slingshots anywhere on the screen //--
		display.getCurrentStage( ):setFocus( nickcage )
	end
end

local function Restart(event)
	--[[
		Function to restart character positiong and 0-set their speeds and other
		changed variables. Updates Score.

		Also removes the restart-screen and button
	]]--
    if "began" == event.phase then
        --code here when touch begin
    elseif "moved" == event.phase then
        --code here when  move
    elseif "ended" == event.phase or "cancelled" == event.phase then
    	powerline.alpha = 0
        nickcage.x = 100
		nickcage.y = display.contentCenterY
		boss.x = 300
		boss.y = display.contentCenterY
		nickcage:setLinearVelocity( 0,0 )
		boss:setLinearVelocity( 0,0)
		counter = 0
		gamestate = "running"
		ending:removeSelf( )
		button1:removeSelf( )
		scoredisp.text = ("SCORE: " .. score)
		--// Reset focus after button press //--
		display.getCurrentStage( ):setFocus( nickcage )
    end
end

local function startscreen(gamestate)
	--[[
		Function to create & display the starting image and
		the related button when the GameLoop calls for it
	]]--
	if (gamestate == "start") then
		starting = display.newImageRect( "startscreen.jpg", 580, 320 )
		starting.x = display.contentCenterX
		starting.y = display.contentCenterY
	end

button2 = widget.newButton{
    left = 350,
    top = 20,
    id = "button1",
    defaultFile = "start.png",
    overFile = "start.png",
    onEvent = Begin
}
end

local function endscreen(gamestate)
	--[[
		Function to create & display the proper ending image and
		the related button when the GameLoop calls for it
	]]--
	--// Disable focus to allow button presses //--
	display.getCurrentStage( ):setFocus( nil )
	if (gamestate == "win") then
		ending = display.newImageRect( "endingwin.png", 580, 320 )
		ending.x = display.contentCenterX
		ending.y = display.contentCenterY
		score = score +1
	elseif (gamestate == "lose") then
		ending = display.newImageRect( "endinglose.png", 580, 320 )
		ending.x = display.contentCenterX
		ending.y = display.contentCenterY
		score = score -1
	end

button1 = widget.newButton{
    left = 100,
    top = 200,
    id = "button1",
    defaultFile = "reset.png",
    overFile = "reset.png",
    onEvent = Restart
}
end



local function gameLoop(event)
	powerline.x = nickcage.x
	powerline.y = nickcage.y
	if (gamestate == "start") then
			startscreen(gamestate)
			gamestate = "paused"		
	elseif (gamestate == "running") then
		counter = counter + 1
		if (counter == 45) then
			--// The ENEMY will launch itself at PLAYERS X-position with random height 1.5second intervals //--
			boss:setLinearVelocity( (nickcage.x-boss.x)*5, math.random( -100, 50 )*5 )
			counter = 0
		end

		--// Check for game-ending if either PLAYER or ENEMY is outside the screens dimensions //--
		if (nickcage.y > 400 or nickcage.y < -20) then
			gamestate = "lose"
			endscreen(gamestate)
		elseif (boss.y > 400 or boss.y < -20) then
			gamestate = "win"
			endscreen(gamestate)
		end
	end
end

Runtime:addEventListener("enterFrame", gameLoop)