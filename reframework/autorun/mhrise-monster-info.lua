local MMI_STATE = require 'mhrise-monster-info.state'
local MMI_CONFIG = require 'mhrise-monster-info.config'
local MMI_UI = require 'mhrise-monster-info.ui'
local MMI_DATA = require 'mhrise-monster-info.data'

local sdk = sdk
local re = re

local enemy_character_base_type_def = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
local enemy_character_base_update_method = enemy_character_base_type_def:get_method("update");
sdk.hook(enemy_character_base_update_method, function()
	pcall(MMI_DATA.record_data);
end, function(retval)
	return retval;
end);

re.on_frame(MMI_UI.draw_ui)


