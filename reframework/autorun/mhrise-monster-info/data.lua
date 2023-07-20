local MMI_CONFIG = require 'mhrise-monster-info.config'

local enemy_character_base_type_def = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
local get_physical_param_method = enemy_character_base_type_def:get_method("get_PhysicalParam");
local get_stamina_param_method = enemy_character_base_type_def:get_method("get_StaminaParam");
local get_anger_param_method = enemy_character_base_type_def:get_method("get_AngerParam");
local get_damage_param_method = enemy_character_base_type_def:get_method("get_DamageParam");
local get_mystery_param_method = enemy_character_base_type_def:get_method("get_MysteryParam");
local get_mario_param_method =  enemy_character_base_type_def:get_method("get_MarioParam");

local physical_param_type = get_physical_param_method:get_return_type();
local get_vital_method = physical_param_type:get_method("getVital");
local get_capture_hp_vital_method = physical_param_type:get_method("get_CaptureHpVital");

local vital_param_type = get_vital_method:get_return_type();
local get_current_method = vital_param_type:get_method("get_Current");
local get_max_method = vital_param_type:get_method("get_Max");

local message_manager_type_def = sdk.find_type_definition("snow.gui.MessageManager");
local get_enemy_name_message_method = message_manager_type_def:get_method("getEnemyNameMessage");
local enemy_type_field = enemy_character_base_type_def:get_field("<EnemyType>k__BackingField");

local stamina_param_type = get_stamina_param_method:get_return_type();
local get_stamina_method = stamina_param_type:get_method("getStamina");
local get_max_stamina_method = stamina_param_type:get_method("getMaxStamina");
local get_remaining_tired_time_method = stamina_param_type:get_method("getStaminaRemainingTime");
local is_tired_method = stamina_param_type:get_method("isTired");

local anger_param_type = get_anger_param_method:get_return_type();
local is_anger_method = anger_param_type:get_method("isAnger");
local get_remaining_anger_time_method = anger_param_type:get_method("getAngerRemainingTime");

local this = {
  enemy_found = false,
  name = "Unknown",
  max_hp = 100,
  hp = 100,
  capture_hp = 25,
  stamina = 0,
  max_stamina = 1,
  tired_time = 0,
  is_tired = false,
  anger_time = 0,
  is_angry = false
}

function get_closest_enemy()
  local enemyman = sdk.get_managed_singleton("snow.enemy.EnemyManager")
  if not enemyman then 
    MMI_CONFIG.status = "No enemy manager"
    return
  end

  local playman = sdk.get_managed_singleton("snow.player.PlayerManager")
  if not playman then 
    MMI_CONFIG.status = "No player manager"
    return
  end

  local me = playman:call("findMasterPlayer")
  if not me then 
    MMI_CONFIG.status = "No local player"
    return
  end

  local gameobj = me:call("get_GameObject")
  if not gameobj then
    MMI_CONFIG.status = "No local player game object"
    return
  end

  local transform = gameobj:call("get_Transform")
  if not transform then
    MMI_CONFIG.status = "No local player transform"
    return
  end

  local me_pos = transform:call("get_Position")
  if not me_pos then 
    MMI_CONFIG.status = "No local player position"
    return
  end

  local closest_enemy = nil
  local closest_dist = 999999

  for i = 0, 4 do
    local enemy = enemyman:call("getBossEnemy", i)
    if not enemy then break end
    
    local gameobj = enemy:call("get_GameObject")
    if not gameobj then break end

    local transform = gameobj:call("get_Transform")
    if not transform then break end

    local enemy_pos = transform:call("get_Position")
    if not enemy_pos then break end

    local distance = (me_pos - enemy_pos):length()
    if distance < closest_dist then
      closest_dist = distance
      closest_enemy = enemy
    end
  end

  return closest_enemy
end

function get_enemy_name(enemy)
  local message_manager = sdk.get_managed_singleton("snow.gui.MessageManager");
	if message_manager ~= nil then 
	  local enemy_type = enemy_type_field:get_data(enemy);
	  if enemy_type ~= nil then
      local enemy_name = get_enemy_name_message_method:call(message_manager, enemy_type);
	    if enemy_name ~= nil then
		    return enemy_name;
	    end
	  end
	end
  return nil
end

this.record_data = function()
    local enemy = get_closest_enemy()
    if not enemy then 
      this.enemy_found = false
      return 
    end

    local physparam = get_physical_param_method:call(enemy)
    if not physparam then return end

    local vitalparam = get_vital_method:call(physparam, 0, 0)
    if not vitalparam then return end

		local stamina_param = get_stamina_param_method:call(enemy);
    if not stamina_param then return end

		local anger_param = get_anger_param_method:call(enemy);
    if not anger_param then return end


    this.enemy_found = true
    this.name = get_enemy_name(enemy) or "Unknown"
    this.hp = get_current_method:call(vitalparam)
    this.max_hp = get_max_method:call(vitalparam)
    this.capture_hp = get_capture_hp_vital_method:call(physparam)
    
	  this.stamina     = get_stamina_method:call(stamina_param);
	  this.max_stamina = get_max_stamina_method:call(stamina_param);
    this.tired_time  = get_remaining_tired_time_method:call(stamina_param);
	  this.is_tired    = is_tired_method:call(stamina_param) or false

    this.is_angry = is_anger_method:call(anger_param) or false
    this.anger_time = get_remaining_anger_time_method:call(anger_param)
end

return this
