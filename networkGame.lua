local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local menuTop =  composer.getVariable( "menuTop" )+0
local menuLeft = composer.getVariable( "menuLeft" )+0
local gameSettings = composer.getVariable( "gameSettings" )
local playerID,alias

-- network data
local gameNetwork = require( "gameNetwork" )
--------------------
local function requestCallback2 ( event )

  playerID = event.data.playerID
  alias = event.data.alias
  native.showAlert("player ID = "..playerID..", alias = "..alias, {"OK"})

end

local function requestCallback ( event )
  
    gameNetwork.request( "loadLocalPlayer", { listener=requestCallback2 } )
  
end


local function initCallback( event )
    if not event.isError then
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