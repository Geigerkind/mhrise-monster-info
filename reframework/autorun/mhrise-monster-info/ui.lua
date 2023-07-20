local MMI_DATA = require 'mhrise-monster-info.data'
local MMI_CONFIG = require 'mhrise-monster-info.config'

local this = {}

local function format_stamina()
  local str = "EX: (" .. math.floor(MMI_DATA.stamina) .."/" .. math.floor(MMI_DATA.max_stamina) .. ")"
  if MMI_DATA.is_tired then
    str = str .. " ~ " .. math.floor(MMI_DATA.tired_time) .. "s"
  end

  return str
end

local function format_hp()
  local hp_percent = math.floor(100 * MMI_DATA.hp / MMI_DATA.max_hp)
  return math.floor(MMI_DATA.hp) .. "/" .. math.floor(MMI_DATA.max_hp) .. " (" .. hp_percent .."%)"
end

local function format_anger()
  if MMI_DATA.is_angry then
    return " ~ " .. math.floor(MMI_DATA.anger_time) .. "s"
  end
  return ""
end

local function format_text()
  return MMI_DATA.name
         .. format_anger() .. " - "
         .. format_hp() .. " - "
         .. format_stamina()
end

this.draw_ui = function()
  if not MMI_DATA.enemy_found then return end

  local x = 0
  local y = 0
  local w = 2560
  local h = 20
  local hp_percent = MMI_DATA.hp / MMI_DATA.max_hp
  local hp_w = w * hp_percent
  local missing_hp_w = w - hp_w

  -- missing hp
	draw.filled_rect(x + hp_w, y, missing_hp_w, h, 0xAA000000)
  -- current hp
  if MMI_DATA.hp <= MMI_DATA.capture_hp then
    draw.filled_rect(x, y, hp_w, h, 0xAAFF1421)
  else
	  draw.filled_rect(x, y, hp_w, h, 0xAA228B22)
  end
  draw.text(format_text(), x, y, 0xFFFFFFFF)

  MMI_CONFIG.status = "Drawn"
end

return this
