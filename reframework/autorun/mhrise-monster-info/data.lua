local MMI_STATE = require 'mhrise-monster-info.state'

local sdk = sdk

local enemy_character_base_type_def = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
local get_physical_param_method = enemy_character_base_type_def:get_method("get_PhysicalParam");
local get_stamina_param_method = enemy_character_base_type_def:get_method("get_StaminaParam");
local get_anger_param_method = enemy_character_base_type_def:get_method("get_AngerParam");
local get_damage_param_method = enemy_character_base_type_def:get_method("get_DamageParam");

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
local get_anger_point_method = anger_param_type:get_method("get_AngerPoint");
local get_limit_anger_method = anger_param_type:get_method("get_LimitAnger");

local damage_param_type_def = get_damage_param_method:get_return_type();
local get_condition_param_method = damage_param_type_def:get_method("get_ConditionParam");

local stun_param_field = damage_param_type_def:get_field("_StunParam");
local poison_param_field = damage_param_type_def:get_field("_PoisonParam");
local blast_param_field = damage_param_type_def:get_field("_BlastParam");

local enemy_condition_damage_param_base_type_def = sdk.find_type_definition("snow.enemy.EnemyConditionDamageParamBase");
local get_is_active_method = enemy_condition_damage_param_base_type_def:get_method("get_IsActive");
local get_stock_method = enemy_condition_damage_param_base_type_def:get_method("get_Stock");
local get_limit_method = enemy_condition_damage_param_base_type_def:get_method("get_Limit");
local get_active_timer_method = enemy_condition_damage_param_base_type_def:get_method("get_ActiveTimer");

local system_array_type_def = sdk.find_type_definition("System.Array");
local length_method = system_array_type_def:get_method("get_Length");
local get_value_method = system_array_type_def:get_method("GetValue(System.Int32)");

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
  anger = 0,
  max_anger = 1,
  anger_time = 0,
  is_angry = false,
  poison = 0,
  max_poison = 1,
  poison_time = 0,
  is_poisoned = false,
  stun = 0,
  max_stun = 1,
  stun_time = 0,
  is_stunned = false,
  paralyze = 0,
  max_paralyze = 1,
  paralyze_time = 0,
  is_paralyzed = false,
  sleep = 1,
  max_sleep = 1,
  blast = 0,
  max_blast = 1,
  exhaust = 0, -- ?
  max_exhaust = 1,
  exhaust_time = 0,
  is_exhausted = false,
  ride = 0,
  max_ride = 1,
  water = 0,
  max_water = 1,
  water_time = 0,
  is_water = false,
  fire = 0,
  max_fire = 1,
  fire_time = 0,
  is_fire = false,
  ice = 0,
  max_ice = 1,
  ice_time = 0,
  is_ice = false,
  thunder = 0,
  max_thunder = 1,
  thunder_time = 0,
  is_thunder = false
}

local function get_closest_enemy()
  local enemyman = MMI_STATE.get_enemy_manager()
  if not enemyman then return end

  local playman = MMI_STATE.get_player_manager()
  if not playman then return end

  local me = playman:call("findMasterPlayer")
  if not me then return end

  local gameobj = me:call("get_GameObject")
  if not gameobj then return end

  local transform = gameobj:call("get_Transform")
  if not transform then return end

  local me_pos = transform:call("get_Position")
  if not me_pos then return end

  local closest_enemy = nil
  local closest_dist = 999999

  for i = 0, 4 do
    local enemy = enemyman:call("getBossEnemy", i)
    if not enemy then break end

    local gameobj_enemy = enemy:call("get_GameObject")
    if not gameobj_enemy then break end

    local transform_enemy = gameobj_enemy:call("get_Transform")
    if not transform_enemy then break end

    local enemy_pos = transform_enemy:call("get_Position")
    if not enemy_pos then break end

    local distance = (me_pos - enemy_pos):length()
    if distance < closest_dist then
      closest_dist = distance
      closest_enemy = enemy
    end
  end

  return closest_enemy
end

local function get_enemy_name(enemy)
  local message_manager = MMI_STATE.get_message_manager();
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

local function get_ailment_value_and_limit(param)
  local value = 0
  local limit = 1

	local buildup_array = get_stock_method:call(param);
	local buildup_limit_array = get_limit_method:call(param);

  if buildup_array ~= nil then
		local buildup_array_length = length_method:call(buildup_array);

		if buildup_array_length ~= nil then

			if buildup_array_length > 0 then
				local buildup_valuetype = get_value_method:call(buildup_array, 0);

				if buildup_valuetype ~= nil then
					local _buildup = buildup_valuetype:get_field("mValue");

					if _buildup ~= nil then
						value = _buildup;
					end
				end
			end
		end
	end

	if buildup_limit_array ~= nil then
		local buildup_limit_array_length = length_method:call(buildup_limit_array);

		if buildup_limit_array_length ~= nil then

			if buildup_limit_array_length > 0 then
				local buildup_limit_valuetype = get_value_method:call(buildup_limit_array, 0);

				if buildup_limit_valuetype ~= nil then
					local _buildup_limit = buildup_limit_valuetype:get_field("mValue");

					if _buildup_limit ~= nil then
						limit = _buildup_limit;
					end
				end
			end
		end
	end

  return value, limit
end

this.record_data = function()
    if not MMI_STATE.is_enabled() then return end

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

    local damage_param = get_damage_param_method:call(enemy);
    if not damage_param then return end

	  local stun_param = stun_param_field:get_data(damage_param);
    if not stun_param then return end

    local poison_param = poison_param_field:get_data(damage_param);
    if not poison_param then return end

    local blast_param = blast_param_field:get_data(damage_param);
    if not blast_param then return end

    local condition_param_array = get_condition_param_method:call(damage_param);
    if not condition_param_array then return end

    local paralyze_param = get_value_method:call(condition_param_array, 0);
    if not paralyze_param then return end

    local sleep_param = get_value_method:call(condition_param_array, 1);
    if not sleep_param then return end

    local exhaust_param = get_value_method:call(condition_param_array, 6);
    if not exhaust_param then return end

    local ride_param = get_value_method:call(condition_param_array, 7);
    if not ride_param then return end

    local water_param = get_value_method:call(condition_param_array, 8);
    if not water_param then return end

    local fire_param = get_value_method:call(condition_param_array, 9);
    if not fire_param then return end

    local ice_param = get_value_method:call(condition_param_array, 10);
    if not ice_param then return end

    local thunder_param = get_value_method:call(condition_param_array, 11);
    if not thunder_param then return end

    this.enemy_found = true
    this.name = get_enemy_name(enemy) or "Unknown"
    this.hp = get_current_method:call(vitalparam)
    this.max_hp = get_max_method:call(vitalparam)
    this.capture_hp = get_capture_hp_vital_method:call(physparam)

	  this.stamina     = get_stamina_method:call(stamina_param);
	  this.max_stamina = get_max_stamina_method:call(stamina_param);
    this.tired_time  = get_remaining_tired_time_method:call(stamina_param);
	  this.is_tired    = is_tired_method:call(stamina_param) or false

    this.anger = get_anger_point_method:call(anger_param)
    this.max_anger = get_limit_anger_method:call(anger_param)
    this.is_angry = is_anger_method:call(anger_param) or false
    this.anger_time = get_remaining_anger_time_method:call(anger_param)

    this.poison, this.max_poison = get_ailment_value_and_limit(poison_param)
    this.poison_time = get_active_timer_method:call(poison_param)
    this.is_poisoned = get_is_active_method:call(poison_param)

    this.stun, this.max_stun = get_ailment_value_and_limit(stun_param)
    this.stun_time = get_active_timer_method:call(stun_param)
    this.is_stunned = get_is_active_method:call(stun_param)

    this.blast, this.max_blast = get_ailment_value_and_limit(blast_param)

    this.paralyze, this.max_paralyze = get_ailment_value_and_limit(paralyze_param)
    this.paralyze_time = get_active_timer_method:call(paralyze_param)
    this.is_paralyzed = get_is_active_method:call(paralyze_param)

    this.sleep, this.max_sleep = get_ailment_value_and_limit(sleep_param)

    this.exhaust, this.max_exhaust = get_ailment_value_and_limit(exhaust_param)
    this.exhaust_time = get_active_timer_method:call(exhaust_param)
    this.is_exhausted = get_is_active_method:call(exhaust_param)

    this.ride, this.max_ride = get_ailment_value_and_limit(ride_param)

    this.water, this.max_water = get_ailment_value_and_limit(water_param)
    this.water_time = get_active_timer_method:call(water_param)
    this.is_water = get_is_active_method:call(water_param)

    this.fire, this.max_fire = get_ailment_value_and_limit(fire_param)
    this.fire_time = get_active_timer_method:call(fire_param)
    this.is_fire = get_is_active_method:call(fire_param)

    this.ice, this.max_ice = get_ailment_value_and_limit(ice_param)
    this.ice_time = get_active_timer_method:call(ice_param)
    this.is_ice = get_is_active_method:call(ice_param)

    this.thunder, this.max_thunder = get_ailment_value_and_limit(thunder_param)
    this.thunder_time = get_active_timer_method:call(thunder_param)
    this.is_thunder = get_is_active_method:call(thunder_param)
end

return this
