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
local strings = composer.getVariable( "strings" )

local function menuItemTap (event)
  if selectedMenuItem==event.target.id then
    if event.target.id == "loadGame" then
      composer.setVariable("newGame",false)
      composer.gotoScene("localMultiplayer")
    else
      composer.setVariable("newGame",true)
      composer.gotoScene( event.target.id )
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
  menuItems = strings.gameMenu
  menuItemTexts = strings[language.."GameMenu"]

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
      menuItems = strings.gameMenu
      menuItemTexts = strings[language.."GameMenu"]
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