local CONFIG_FILE_NAME = "mhrise-monster-info.json"

local this = {
  status = "Default",
  cfg = json.load_file(CONFIG_FILE_NAME)
}

if not this.cfg then
    this.cfg = {
        font_size = imgui.get_default_font_size() - 2,
        font_name = "Tahoma",
        is_top_bar = true,
    }
end

re.on_config_save(
    function()
        json.dump_file(CONFIG_FILE_NAME, this.cfg)
    end
)

re.on_draw_ui(
    function() 
        if not imgui.collapsing_header("Monster Info") then return end

        local changed, value = imgui.input_text("Font Name", this.cfg.font_name)
        if changed then this.cfg.font_name = value end

        changed, value = imgui.slider_int("Font Size", this.cfg.font_size, 1, 100)
        if changed then this.cfg.font_size = value end

        changed, value = imgui.checkbox("Top Bar", this.cfg.is_top_bar)
        if changed then this.cfg.is_top_bar = value end

        if imgui.button("Save settings") then
            json.dump_file(CONFIG_FILE_NAME, this.cfg)
        end

        if string.len(this.status) > 0 then
            imgui.text("Status: " .. this.status)
        end
    end
)

return this
