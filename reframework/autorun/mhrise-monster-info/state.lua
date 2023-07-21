local MMI_CONFIG = require 'mhrise-monster-info.config'

local sdk = sdk

local this = {
  scene = nil,
  scene_manager_type = nil,
  scene_manager_view = nil,
  enemy_manger = nil,
  player_manager = nil,
  message_manager = nil,
  lobby_manager = nil,
}

this.get_scene = function()
  if not this.scene then
    this.scene = sdk.get_native_singleton("via.SceneManager")
  end
  return this.scene
end

this.get_scene_manager_type = function()
  if not this.scene_manager_type then
    this.scene_manager_type = sdk.find_type_definition("via.SceneManager")
  end
  return this.scene_manager_type
end

this.get_scene_manager_view = function()
  if not this.scene_manager_view then
    this.scene_manager_view = sdk.call_native_func(this.get_scene(), this.get_scene_manager_type(), "get_MainView")
  end
  return this.scene_manager_view
end

this.get_lobby_manager = function()
  if not this.lobby_manager then
    this.lobby_manager = sdk.get_managed_singleton("snow.LobbyManager")
  end
  return this.lobby_manager
end

this.get_enemy_manager = function()
  if not this.enemy_manger then
    this.enemy_manger = sdk.get_managed_singleton("snow.enemy.EnemyManager")
  end
  return this.enemy_manger
end

this.get_player_manager = function()
  if not this.player_manager then
    this.player_manager = sdk.get_managed_singleton("snow.player.PlayerManager")
  end
  return this.player_manager
end

this.get_message_manager = function()
  if not this.message_manager then
    this.message_manager = sdk.get_managed_singleton("snow.gui.MessageManager")
  end
  return this.message_manager
end

this.is_online = function()
  return this.get_lobby_manager():call("IsQuestOnline") or false
end

this.is_enabled = function()
  local is_online = this.is_online()
  return (is_online and MMI_CONFIG.cfg.enable_online) or (not is_online and MMI_CONFIG.cfg.enable_offline)
end

return this
