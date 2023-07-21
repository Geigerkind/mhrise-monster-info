local MMI_CONFIG = require 'mhrise-monster-info.config'
local MMI_STATE = require 'mhrise-monster-info.state'
local MMI_DATA = require 'mhrise-monster-info.data'

local draw = draw

local this = {}

local function format_entry(is_enabled, label, value, max_value, duration, is_duration)
  if not is_enabled or (MMI_CONFIG.cfg.show_if_more_than_0 and (value < 0.1 or is_duration)) then
    return ""
  end

  local str = label .. ": (" .. math.floor(value) .."/" .. math.floor(max_value) .. ")"
  if is_duration then
    str = str .. " ~ " .. math.floor(duration) .. "s"
  end

  return " - " .. str
end

local function format_hp()
  local hp_percent = math.floor(100 * MMI_DATA.hp / MMI_DATA.max_hp)
  return math.floor(MMI_DATA.hp) .. "/" .. math.floor(MMI_DATA.max_hp) .. " (" .. hp_percent .."%)"
end

local function format_text()
  return MMI_DATA.name .. " - "
        .. format_hp()
        .. format_entry(MMI_CONFIG.cfg.show_anger, "ANG", MMI_DATA.anger, MMI_DATA.max_anger, MMI_DATA.anger_time, MMI_DATA.is_angry)
        .. format_entry(MMI_CONFIG.cfg.show_stamina, "STA", MMI_DATA.stamina, MMI_DATA.max_stamina, MMI_DATA.tired_time, MMI_DATA.is_tired)
        .. format_entry(MMI_CONFIG.cfg.show_exhaust, "EXH", MMI_DATA.exhaust, MMI_DATA.max_exhaust, MMI_DATA.exhaust_time, MMI_DATA.is_exhausted)
        .. format_entry(MMI_CONFIG.cfg.show_stun, "STU", MMI_DATA.stun, MMI_DATA.max_stun, MMI_DATA.stun_time, MMI_DATA.is_stunned)
        .. format_entry(MMI_CONFIG.cfg.show_paralyze, "PAR", MMI_DATA.paralyze, MMI_DATA.max_paralyze, MMI_DATA.paralyze_time, MMI_DATA.is_paralyzed)
        .. format_entry(MMI_CONFIG.cfg.show_poison, "POI", MMI_DATA.poison, MMI_DATA.max_poison, MMI_DATA.poison_time, MMI_DATA.is_poisoned)
        .. format_entry(MMI_CONFIG.cfg.show_sleep, "SLE", MMI_DATA.sleep, MMI_DATA.max_sleep, 0, false)
        .. format_entry(MMI_CONFIG.cfg.show_blast, "BLA", MMI_DATA.blast, MMI_DATA.max_blast, 0, false)
        .. format_entry(MMI_CONFIG.cfg.show_ride, "RID", MMI_DATA.ride, MMI_DATA.max_ride, 0, false)
        .. format_entry(MMI_CONFIG.cfg.show_water, "WAT", MMI_DATA.water, MMI_DATA.max_water, MMI_DATA.water_time, MMI_DATA.is_water)
        .. format_entry(MMI_CONFIG.cfg.show_fire, "FIR", MMI_DATA.fire, MMI_DATA.max_fire, MMI_DATA.fire_time, MMI_DATA.is_fire)
        .. format_entry(MMI_CONFIG.cfg.show_ice, "ICE", MMI_DATA.ice, MMI_DATA.max_ice, MMI_DATA.ice_time, MMI_DATA.is_ice)
        .. format_entry(MMI_CONFIG.cfg.show_thunder, "THU", MMI_DATA.thunder, MMI_DATA.max_thunder, MMI_DATA.thunder_time, MMI_DATA.is_thunder)
end

local function read_screen_dimensions()
  local scene_manager_view = MMI_STATE.get_scene_manager_view()
  if scene_manager_view then
	  local size = scene_manager_view:call("get_Size")
    if size then
	    return size:get_field("w"), size:get_field("h")
    end
  end
  return 2560, 1440
end

this.draw_ui = function()
  if not MMI_STATE.is_enabled() then return end
  if not MMI_DATA.enemy_found then return end

  local w = read_screen_dimensions()
  local x = 0
  local y = 0
  local h = 20
  local hp_percent = MMI_DATA.hp / MMI_DATA.max_hp
  local hp_w = w * hp_percent
  local missing_hp_w = w - hp_w

  -- missing hp
	draw.filled_rect(x + hp_w, y, missing_hp_w, h, 0xAA000000)
  -- current hp
  local hp_color = 0xAA228B22
  if MMI_DATA.hp <= MMI_DATA.capture_hp then
    hp_color = 0xAAFF1421
  end
  draw.filled_rect(x, y, hp_w, h, hp_color)

  draw.text(format_text(), x, y, 0xFFFFFFFF)
end

return this
