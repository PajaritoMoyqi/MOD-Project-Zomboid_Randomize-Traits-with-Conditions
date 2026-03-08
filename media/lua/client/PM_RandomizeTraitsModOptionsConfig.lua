PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.settings or {};
PM_RandomizeTraits.traitSettings = {};

PM_RandomizeTraits.settings.Preselect = true;
PM_RandomizeTraits.settings.HardPreselect = false;
PM_RandomizeTraits.settings.AutoReRandomize = false;

if ModOptions and ModOptions.getInstance then
  -- Build trait settings inside OnGameBoot (TraitFactory is available here)
  Events.OnGameBoot.Add(function()
    local OPTIONS = {
      Preselect = true,
      HardPreselect = false,
      AutoReRandomize = false,
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

    -- Configure basic option names/tooltips
    local preselect = settings:getData("Preselect")
    preselect.name = getText("UI_PM_RandomizeTraits_Options_Preselect")
    preselect.tooltip = getText("UI_PM_RandomizeTraits_Options_Preselect_ToolTip")

    local hardPreselect = settings:getData("HardPreselect")
    hardPreselect.name = getText("UI_PM_RandomizeTraits_Options_HardPreselect")
    hardPreselect.tooltip = getText("UI_PM_RandomizeTraits_Options_HardPreselect_ToolTip")

    local autoReRandomize = settings:getData("AutoReRandomize")
    autoReRandomize.name = getText("UI_PM_RandomizeTraits_Options_AutoReRandomize")
    autoReRandomize.tooltip = getText("UI_PM_RandomizeTraits_Options_AutoReRandomize_ToolTip")

    -- Configure dropdown choices for each trait
    for _, traitInfo in ipairs(traitInfos) do
      local drop = settings:getData("Trait_" .. traitInfo.id)
      drop[1] = "Normal"
      drop[2] = "Exclude"
      drop[3] = "Preselect"
      drop.name = traitInfo.label
      drop.tooltip = getText("UI_PM_RandomizeTraits_TraitSetting_ToolTip")
      PM_RandomizeTraits.traitSettings[traitInfo.id] = "Normal"
    end

    -- Apply callback to read settings
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

    Events.OnPreMapLoad.Add(applySettings)
  end)
end
