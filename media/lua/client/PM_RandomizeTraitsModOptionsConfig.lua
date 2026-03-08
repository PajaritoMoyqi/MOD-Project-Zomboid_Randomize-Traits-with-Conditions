PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.settings or {};
PM_RandomizeTraits.traitSettings = {};

PM_RandomizeTraits.settings.Preselect = true;
PM_RandomizeTraits.settings.HardPreselect = true;
PM_RandomizeTraits.settings.AutoReRandomize = true;

if ModOptions and ModOptions.getInstance then
  -- Build trait settings inside OnGameBoot (TraitFactory is available here)
  Events.OnGameBoot.Add(function()
    local OPTIONS = {
      Preselect = true,
      HardPreselect = true,
      AutoReRandomize = true,
    }

    -- Add all traits as dropdown options (default = 1 = Normal)
    local traitInfos = {}
    local allTraits = TraitFactory.getTraits()
    if allTraits then
      for i = 0, allTraits:size() - 1 do
        local trait = allTraits:get(i)
        local traitID = trait:getType()
        OPTIONS["Trait_" .. traitID] = 1  -- 1 = Normal
        table.insert(traitInfos, { id = traitID, label = trait:getLabel() })
      end
    end

    local settings = ModOptions:getInstance(OPTIONS, "PM_RandomizeTraits", "Randomize Traits")

    -- Read OPTIONS table into PM_RandomizeTraits settings
    local function applySettings()
      PM_RandomizeTraits.settings.Preselect = OPTIONS.Preselect
      PM_RandomizeTraits.settings.HardPreselect = OPTIONS.HardPreselect
      PM_RandomizeTraits.settings.AutoReRandomize = OPTIONS.AutoReRandomize

      for _, traitInfo in ipairs(traitInfos) do
        local val = OPTIONS["Trait_" .. traitInfo.id]
        if val == 1 then
          PM_RandomizeTraits.traitSettings[traitInfo.id] = "Normal"
        elseif val == 2 then
          PM_RandomizeTraits.traitSettings[traitInfo.id] = "Exclude"
        elseif val == 3 then
          PM_RandomizeTraits.traitSettings[traitInfo.id] = "Preselect"
        end
      end
    end

    -- Configure basic option names/tooltips + callbacks
    local preselect = settings:getData("Preselect")
    preselect.name = getText("UI_PM_RandomizeTraits_Options_Preselect")
    preselect.tooltip = getText("UI_PM_RandomizeTraits_Options_Preselect_ToolTip")
    preselect.OnApplyMainMenu = applySettings
    preselect.OnApplyInGame = applySettings

    local hardPreselect = settings:getData("HardPreselect")
    hardPreselect.name = getText("UI_PM_RandomizeTraits_Options_HardPreselect")
    hardPreselect.tooltip = getText("UI_PM_RandomizeTraits_Options_HardPreselect_ToolTip")
    hardPreselect.OnApplyMainMenu = applySettings
    hardPreselect.OnApplyInGame = applySettings

    local autoReRandomize = settings:getData("AutoReRandomize")
    autoReRandomize.name = getText("UI_PM_RandomizeTraits_Options_AutoReRandomize")
    autoReRandomize.tooltip = getText("UI_PM_RandomizeTraits_Options_AutoReRandomize_ToolTip")
    autoReRandomize.OnApplyMainMenu = applySettings
    autoReRandomize.OnApplyInGame = applySettings

    -- Configure dropdown choices for each trait + callbacks
    for _, traitInfo in ipairs(traitInfos) do
      local drop = settings:getData("Trait_" .. traitInfo.id)
      drop[1] = "Normal"
      drop[2] = "Exclude"
      drop[3] = "Preselect"
      drop.name = traitInfo.label
      drop.tooltip = getText("UI_PM_RandomizeTraits_TraitSetting_ToolTip")
      drop.OnApplyMainMenu = applySettings
      drop.OnApplyInGame = applySettings
    end

    -- Expose applySettings so it can be called before randomizing
    PM_RandomizeTraits.applySettings = applySettings

    -- Apply saved settings immediately (OPTIONS was updated by loadFile)
    applySettings()

    -- Also apply on map load
    Events.OnPreMapLoad.Add(applySettings)
  end)
end
