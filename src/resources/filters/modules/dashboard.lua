-- dashboard.lua
-- Copyright (C) 2020-2022 Posit Software, PBC
local utils = require 'modules/dashboard/utils'
local layout = require 'modules/dashboard/layout'
local card = require 'modules/dashboard/card'
local valuebox = require 'modules/dashboard/valuebox'
local sidebar = require 'modules/dashboard/sidebar'
local page = require 'modules/dashboard/page'
local document = require 'modules/dashboard/document'
local tabset = require 'modules/dashboard/tabset'
local inputpanel = require 'modules/dashboard/inputpanel'


local function isLayoutContainer(el)
  if card.isCard(el) then
    return true
  elseif valuebox.isValueBox(el) then
    return true
  elseif layout.isRowOrColumnContainer(el) then
    return true  elseif sidebar.isSidebar(el) then
    return true
  elseif tabset.isTabset(el) then
    return true
  elseif inputpanel.isInputPanel(el) then
    return true
  end
  return false
end


local function organizer(contents, ignoreClasses) 

  -- ignore any elements which contain these classes
  ignoreClasses = ignoreClasses or pandoc.List()

  local function isIgnored(el)
    if el.classes ~= nil then
      return el.classes:find_if(function(class) 
        return ignoreClasses:includes(class)
      end) 
    end
    return false
  end
  
  -- Make sure everything is in a card
  local layoutContentEls = pandoc.List()
  local looseContentEls = pandoc.List()
  local function flushLooseContent() 
    if #looseContentEls > 0 then
      local cardOptions = card.readOptions(looseContentEls[1])
      
      -- For loose content, mark this as a flow layout
      cardOptions[card.optionKeys.layout] = card.optionValues.flow

      local looseCard = card.makeCard(looseContentEls, {}, cardOptions)
      if looseCard ~= nil then
        layoutContentEls:insert(looseCard)              
      else
        layoutContentEls:extend(looseContentEls)
      end
      looseContentEls = pandoc.List()
      end
  end

  return {
    ensureInLayoutContainers = function()
      for i, v in ipairs(contents) do
        if not isLayoutContainer(v) and not isIgnored(v) then
          looseContentEls:insert(v)
        else
          flushLooseContent()
          layoutContentEls:insert(v)
        end
      end
      flushLooseContent()
      return layoutContentEls
    end
  }
end


return {
  layout = layout,
  card = card,
  valuebox = valuebox,
  sidebar = sidebar,
  page = page,
  tabset = tabset,
  inputpanel = inputpanel,
  document = document,
  layoutContainer = {
    organizer = organizer
  },
  utils = utils
}