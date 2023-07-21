local json = json
local imgui = imgui
local re = re

local CONFIG_FILE_NAME = "mhrise-monster-info.json"

local this = {
  cfg = json.load_file(CONFIG_FILE_NAME)
}

if not this.cfg then
    this.cfg = {
      enable_offline = true,
      enable_online = true,
      show_if_more_than_0 = true,
      show_stamina = true,
      show_anger = true,
      show_poison = true,
      show_stun = true,
      show_paralyze = true,
      show_sleep = true,
      show_blast = true,
      show_exhaust = true,
      show_ride = true,
      show_water = true,
      show_fire = true,
      show_ice = true,
      show_thunder = true
    }
end

local function on_config_save()
  json.dump_file(CONFIG_FILE_NAME, this.cfg)
end
re.on_config_save(on_config_save)

local function add_checkbox(label, config_key)
  local changed, value = imgui.checkbox(label, this.cfg[config_key])
  if changed then
    this.cfg[config_key] = value
    on_config_save()
  end
end


local function on_draw_ui()
  if not imgui.collapsing_header("Monster Info") then return end

  add_checkbox("Enable while offline", "enable_offline")
  add_checkbox("Enable while online", "enable_online")
  add_checkbox("Show ailments if > 0", "show_if_more_than_0")
  add_checkbox("Show stamina", "show_stamina")
  add_checkbox("Show anger", "show_anger")
  add_checkbox("Show poison", "show_poison")
  add_checkbox("Show stun", "show_stun")
  add_checkbox("Show paralyze", "show_paralyze")
  add_checkbox("Show sleep", "show_sleep")
  add_checkbox("Show blast", "show_blast")
  add_checkbox("Show exhaust", "show_exhaust")
  add_checkbox("Show wyvern riding", "show_ride")
  add_checkbox("Show water blight", "show_water")
  add_checkbox("Show burn", "show_fire")
  add_checkbox("Show ice blight", "show_ice")
  add_checkbox("Show thunder blight", "show_thunder")
end
re.on_draw_ui(on_draw_ui)

return this
