local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
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
local strings = composer.getVariable( "strings" )

local function saveUserData()
  local dataPath = system.pathForFile( "data.json", system.DocumentsDirectory )
  local json = require("json")
  local fileHandle, errorString = io.open(dataPath,"w")

  if fileHandle then
    local encoded = json.encode( gameSettings )
    fileHandle:write( encoded )
  else
    print("Error writing to file")
  end
  
  io.close( fileHandle )
end

local function menuItemTap (event)
	if selectedMenuItem==event.target.id then
    gameSettings.skin = selectedMenuItem
    composer.setVariable( "gameSettings", gameSettings )
    saveUserData()
    native.showAlert( "TogyzKumalak", "You have to restart the game to see changes", { "OK" }, composer.gotoScene( "menu" ) )
    --composer.gotoScene( "menu" )
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
  language = gameSettings.language
  menuItems = strings.skinMenu
  menuItemTexts = strings[language.."Skins"]

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

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
    	language = gameSettings.language
      menuItems = strings.skinMenu
      menuItemTexts = strings[language.."Skins"]
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
    sceneGroup:removeSelf( )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene