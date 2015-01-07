local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local menuTop =  composer.getVariable( "menuTop" )+0
local menuLeft = composer.getVariable( "menuLeft" )+0
local gameSettings = composer.getVariable( "gameSettings" )

-- network data
local gameNetwork = require( "gameNetwork" )
local playerID = ""
local alias = ""
local thisGroup
local int = 1
    local table = {}
    local texts = {}
    local msg = ""
--------------------

local function requestCallback ( event )
    
    if event.isError then
        native.showAlert( "Login failed" ,"Login failed" ,{ "OK" })
    else
        
        if (event.data ~= nil) then 
            table = event.data
        else 
            native.showAlert("data table is nil", "data table is nil", {"OK"} )
        end
        for k, v in pairs( table ) do
            msg = k.. v
            texts[i] = display.newText( thisGroup, msg, 
                100, 100*int, native.systemFont, 50 )
            int = int + 1
            texts[i].x = 100
            texts[i].y = 100*int
            texts[i]:setTextColor( 1, 1, 1 )
        end
    end
end


local function initCallback( event )
    if not event.isError then
        playerID = event.data.playerID
        alias = event.data.alias
        gameNetwork.request( "login",
          {
            userInitiated = true,
            listener = requestCallback
          }
        )
    else
        native.showAlert( "Failed!", event.errorMessage, { "OK" } )
    end
end

--------------------------------------------


function scene:create( event )
  local sceneGroup = self.view
  
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    thisGroup = sceneGroup
    if phase == "will" then
        gameNetwork.init("google",initCallback)
    elseif phase == "did" then
        
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
    elseif phase == "did" then
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

   	sceneGroup:removeSelf()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene