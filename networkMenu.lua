local composer = require( "composer" )
local scene = composer.newScene()
local menuTop =  composer.getVariable( "menuTop" )
local menuLeft = composer.getVariable( "menuLeft" )
local menuItemTexts 
local menuItems
local selectedMenuItem = 0
local gameSettings = composer.getVariable( "gameSettings" )
local previousMenuItem
local menuItemIds = {}
local menuBackground
local arrow
local playerID
local alias
composer.gameNetwork = require( "gameNetwork" )
local strings = composer.getVariable( "strings" )

local function onKeyEvent(event)
  if event.keyName == "back" then
    native.requestExit()
  end
  return true
end 

local function requestLoadPlayersCallback(event)
    composer.setVariable("otherPlayerAlias" , event.data[1].alias)
end

local function beginGame(playerId2, roomID)   
    Runtime:removeEventListener( "key", onKeyEvent );
    local options =
    {
        effect = "fade",
        time = 400
    }
    composer.gameNetwork.request( "loadPlayers",
    {
        playerIDs =
        {
            playerId2
        },
        listener = requestLoadPlayersCallback
    })
    composer.setVariable("otherPlayerId", playerId2)
    composer.setVariable("matchId", roomID)
    --native.showAlert("network","success",{"OK"})
    composer.gotoScene( "multiplayer", options )
end

local function waitingRoomListener(waitingRoomEvent)
    if waitingRoomEvent.data.phase == "start" then
        -- We only need the first player because its a 2 player game
        beginGame(waitingRoomEvent.data[1], waitingRoomEvent.data.roomID)
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
                minPlayers = 2
            })
        end
    end
end

local function menuItemTap (event)
  if selectedMenuItem==event.target.id then
    --"achievements","create","join","leaderboards"

    -- LOADING ACHIEVMENTS
    if event.target.id == "achievements" then
      composer.gameNetwork.show("achievements")

    -- CREATING GAME
    elseif event.target.id=="create" then
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

    -- JOINING A GAME
    elseif event.target.id=="join" then
      local function invitationsListener(invitationsEvent)
        -- This will let the user join a room 
        composer.gameNetwork.request("joinRoom",
        {
          roomID = invitationsEvent.data.roomID,
          listener = roomListener
        })
      end

      -- This will show the invitations screen which shows a list of all the invitations the user has
      composer.gameNetwork.show("invitations", {
        listener = invitationsListener
      })
      composer.isGuest = 1

    -- SHOWING LEADERBOARDS
    elseif event.target.id=="leaderboards" then
      composer.gameNetwork.show("leaderboards")
    elseif event.target.id=="menu" then
      composer.gotoScene("menu")
    end
  else
    previousMenuItem:setFillColor( 1 )
    selectedMenuItem = event.target.id
    previousMenuItem = event.target
    arrow.x = event.target.x - 40
    arrow.y = event.target.y
    event.target:setFillColor( 0.25, 0.168, 0.121  )
  end
end

function scene:create( event )
  local sceneGroup = self.view
  local sceneGroup = self.view
  language = gameSettings.language
  menuItems = strings.menuNetwork
  menuItemTexts = strings[language.."Network"]

  menuBackground = display.newImage( "images/menuBackground.png" )
  menuBackground.x = display.contentCenterX
  menuBackground.y = display.contentCenterY
  sceneGroup:insert(menuBackground)
  -- initialize menu items on display and assign them IDs
  for i=1,#menuItemTexts do
    menuItemIds[i] = display.newEmbossedText( menuItemTexts[i],
      menuLeft,
      menuTop+(i-1)*90,
      native.systemFont, 40 )
      local color = 
        {
          highlight = { r=0.25, g=0.168, b=0.121 },
          shadow = { r=0.25, g=0.168, b=0.121 }
        }
    menuItemIds[i].anchorX = 0
    menuItemIds[i]:setEmbossColor( color )
    menuItemIds[i].id = menuItems[i]
    menuItemIds[i]:addEventListener( "tap", menuItemTap )
    sceneGroup:insert(menuItemIds[i])
    if i>1 then
          local line = display.newLine(sceneGroup, 
            menuLeft,
            menuTop+(i-1)*90-40,
            display.contentWidth - menuLeft, 
            menuTop+(i-1)*90-40)
          line.strokeWidth = 2
          line:setStrokeColor( 1,1,1)
    end
  end
  arrow = display.newImage( sceneGroup, "images/arrow.png")
  arrow.xScale = 1.5
  arrow.yScale = 1.5
  arrow.x = menuLeft-40
  arrow.y = menuTop
  previousMenuItem = menuItemIds[1]
  selectedMenuItem = menuItemIds[1].id
  previousMenuItem:setFillColor( 0.25, 0.168, 0.121 )
end

local function requestLoadLocalPlayerCallback (event)
    playerID = event.data.playerID
    alias = event.data.alias

    composer.setVariable("playerID", playerID)
    composer.setVariable("alias", alias)
    --drawWelcomeScreen()
end

local function requestLoginCallback ( event )
    if composer.gameNetwork.request("isConnected") then
        composer.gameNetwork.request( "loadLocalPlayer", { listener = requestLoadLocalPlayerCallback } )
    else
        native.showAlert("You are not connected","!",{"OK"})
    end

end

local function gameNetworkLoginCallback( event )
   composer.gameNetwork.request( "loadLocalPlayer", { listener=requestLoadLocalPlayerCallback } )
   return true
end

local function gpgsInitCallback(event)
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

local function receivedInvitationListener(event)
        native.showAlert("Invitation Received", "You received an invitation from " .. event.data.alias, {"OK"})
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then

      if ( system.getInfo("platformName") == "Android" ) then
        -- google game play services
        composer.gameNetwork.init( "google", gpgsInitCallback )
      else
        -- apple game center
        composer.gameNetwork.init( "gamecenter", gameNetworkLoginCallback )
      end
      
      --composer.gameNetwork.init("google",initCallback)

      if composer.gameNetwork.request("isConnected") then
    -- This will call the listener whenever the user receives an invitation
        composer.gameNetwork.request("setInvitationReceivedListener", 
        {
         listener = receivedInvitationListener,
        })

        composer.gameNetwork.request("setRoomListener",
        {
          listener = roomListener,
        })
      end

      Runtime:addEventListener( "key", onKeyEvent );

      language = gameSettings.language
      menuItems = strings.menuNetwork
      menuItemTexts = strings[language.."Network"]
      for i=1,#menuItemTexts do
        menuItemIds[i].text = menuItemTexts[i]
      end
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