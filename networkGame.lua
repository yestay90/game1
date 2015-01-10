local composer = require( "composer" )
local scene = composer.newScene()

local widget = require("widget")
local gameSettings = composer.getVariable( "gameSettings" )

-- network data
composer.gameNetwork = require( "gameNetwork" )
local playerID
local alias
local thisGroup
local texts = {}
local friends = {}
local menuBackground
local scrollView
local menuTop =  composer.getVariable( "menuTop" )
local menuLeft = composer.getVariable( "menuLeft" )
--------------------
local function handleBackBtn(event)
    if ("ended"==event.phase) then
        composer.gotoScene("menu")
    end
end

local function requestLoadFriendsCallback(event)
    friends = event.data
    local newText = display.newText(thisGroup,tostring(#friends),100,20,native.systemFontBold,40)
    local paragraphs = {}
    local paragraph

    scrollView = widget.newScrollView
    {
        top = 140,
        left = 10,
        width = display.contentWidth-0,
        height = display.contentHeight-300,
        scrollWidth = display.contentWidth-50,
        scrollHeight =10000,
        hideBackground = true
    }
    local options = {
        text = "",
        left = 10,
        width = display.contentWidth-50,
        font = native.systemFontBold,
        fontSize = 40,
        align = "left"
    }
    local yOffset = 10

    if #friends>0 then
        for i=1,#friends do
            paragraph = friends[i].alias
            options.text = paragraph.."\n"
            paragraphs[#paragraphs+1] = display.newText( options )
            paragraphs[#paragraphs].anchorX = 0
            paragraphs[#paragraphs].anchorY = 0
            paragraphs[#paragraphs].x = 10
            paragraphs[#paragraphs].y = yOffset
            paragraphs[#paragraphs]:setFillColor( 1,1,1 )
            scrollView:insert( paragraphs[#paragraphs] )
            yOffset = yOffset + paragraphs[#paragraphs].height
        end
        
    end
    thisGroup:insert(scrollView)
end

local function waitingRoomListener(waitingRoomEvent)
    if waitingRoomEvent.data.phase == "start" then
        -- We only need the first player because its a 2 player game
        --beginGame(waitingRoomEvent.data[1], waitingRoomEvent.data.roomID)
        native.showAlert("Staring the game! with "..waitingRoomEvent.data[1])
    end
end

local function roomListener(event)
    if event.type == "joinRoom" or event.type == "createRoom" then
        if event.data.isError then 
            native.showAlert("Room Error", "Sorry there was an error when trying to create/join a room")
        else
            composer.gameNetwork.show("waitingRoom", {
                listener = waitingRoomListener,
                roomID = event.data.roomID,
                minPlayers = 0
            })
        end
    end
end


local function buttonTap(event)
    local function selectPlayersListener(selectPlayerEvent)
                        -- Create a room with only the first selection
        local array = {selectPlayerEvent.data[1]}
        composer.gameNetwork.request("createRoom", {
                listener = roomListener,
                playerIDs = array
            })
    end
    composer.gameNetwork.show("selectPlayers", {
        listener = selectPlayersListener,
        minPlayers = 1,
        maxPlayers = 1
    })
    composer.isHost = 1
end

local function drawWelcomeScreen()
    menuBackground = display.newImage( "images/rules_bg.png")
    menuBackground.x = display.contentCenterX
    menuBackground.y = display.contentCenterY
    thisGroup:insert(menuBackground)

    local backBtn = widget.newButton{
            top = 35,
            left = 240,
            defaultFile = "images/back.png",
            overFile = "images/back.png",
            onEvent = handleBackBtn
        }
    thisGroup:insert(backBtn)

    local createText = display.newEmbossedText( "Create game",
      menuLeft,
      menuTop+90,
      native.systemFont, 40 )
      local color = 
        {
          highlight = { r=0.25, g=0.168, b=0.121 },
          shadow = { r=0.25, g=0.168, b=0.121 }
        }
    createText.anchorX = 0
    createText:setEmbossColor( color )
    createText.id = 1
    createText:addEventListener( "tap", buttonTap )
    thisGroup:insert(createText)
    arrow = display.newImage( thisGroup, "images/arrow.png")
    arrow.xScale = 1.5
    arrow.yScale = 1.5
    arrow.x = menuLeft-40
    arrow.y = menuTop
    --composer.gameNetwork.request( "loadFriends", { listener=requestLoadFriendsCallback } )
    
end

local function requestLoadLocalPlayerCallback (event)
    playerID = event.data.playerID
    alias = event.data.alias
    local msg = "Welcome, "..alias.."!"
    composer.playerID = playerID
    composer.alias = alias
    drawWelcomeScreen()
end

local function requestLoginCallback ( event )
    if composer.gameNetwork.request("isConnected") then
        composer.gameNetwork.request( "loadLocalPlayer", { listener = requestLoadLocalPlayerCallback } )
    else
        native.showAlert("You are not connected","!",{"OK"})
    end

end


local function initCallback( event )
    if not event.isError then

        composer.gameNetwork.request( "login",
          {

            userInitiated = true,
            listener = requestLoginCallback
        }
        )
    else
        native.showAlert( "Failed!", event.errorMessage, { "OK" } )
    end
end

local function onSystemEvent( event )
    -- body
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
        composer.gameNetwork.init("google",initCallback)
    elseif phase == "did" then
        
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        for i=1,sceneGroup.numChildren do
            if sceneGroup[i]~=nil then 
                sceneGroup[i]:removeSelf()
            end
        end
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