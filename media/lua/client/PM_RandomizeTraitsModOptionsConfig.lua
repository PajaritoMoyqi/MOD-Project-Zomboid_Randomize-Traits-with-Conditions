PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.settings or {};
PM_RandomizeTraits.traitSettings = {};

PM_RandomizeTraits.settings.Preselect = true;
PM_RandomizeTraits.settings.HardPreselect = false;
PM_RandomizeTraits.settings.AutoReRandomize = false;

if ModOptions and ModOptions.getInstance then
  local function onModOptionsApply(optionValues)
    PM_RandomizeTraits.settings.Preselect = optionValues.settings.options.Preselect;
    PM_RandomizeTraits.settings.HardPreselect = optionValues.settings.options.HardPreselect;
    PM_RandomizeTraits.settings.AutoReRandomize = optionValues.settings.options.AutoReRandomize;

    -- Read per-trait settings dynamically
    for key, value in pairs(optionValues.settings.options) do
      if type(key) == "string" and key:sub(1, 6) == "Trait_" then
        local traitID = key:sub(7)
        PM_RandomizeTraits.traitSettings[traitID] = value
      end
    end
  end

  -- Initialize ModOptions with all traits inside OnGameBoot
  -- (TraitFactory is not populated at file load time)
  Events.OnGameBoot.Add(function()
    local options_data = {
      Preselect = {
        name = "UI_PM_RandomizeTraits_Options_Preselect",
        tooltip = "UI_PM_RandomizeTraits_Options_Preselect_ToolTip",
        default = true,
        OnApplyMainMenu = onModOptionsApply,
        OnApplyInGame = onModOptionsApply,
      },
      HardPreselect = {
        name = "UI_PM_RandomizeTraits_Options_HardPreselect",
        tooltip = "UI_PM_RandomizeTraits_Options_HardPreselect_ToolTip",
        default = false,
        OnApplyMainMenu = onModOptionsApply,
        OnApplyInGame = onModOptionsApply,
      },
      AutoReRandomize = {
        name = "UI_PM_RandomizeTraits_Options_AutoReRandomize",
        tooltip = "UI_PM_RandomizeTraits_Options_AutoReRandomize_ToolTip",
        default = false,
        OnApplyMainMenu = onModOptionsApply,
        OnApplyInGame = onModOptionsApply,
      },
    }

    -- Dynamically add all traits from TraitFactory
    local allTraits = TraitFactory.getTraits()
    if allTraits then
      for i = 0, allTraits:size() - 1 do
        local trait = allTraits:get(i)
        local traitID = trait:getType()
        options_data["Trait_" .. traitID] = {
          name = trait:getLabel(),
          tooltip = "UI_PM_RandomizeTraits_TraitSetting_ToolTip",
          default = "Normal",
          values = {"Normal", "Exclude", "Preselect"},
          OnApplyMainMenu = onModOptionsApply,
          OnApplyInGame = onModOptionsApply,
        }
        PM_RandomizeTraits.traitSettings[traitID] = "Normal"
      end
    end

    local SETTINGS = {
      options_data = options_data,
      mod_id = 'PM_RandomizeTraits',
      mod_shortname = 'Randomize Traits',
      mod_fullname = 'Randomize Traits with Conditions',
    }
    ModOptions:getInstance(SETTINGS)
    ModOptions:loadFile()

    Events.OnPreMapLoad.Add(function()
      onModOptionsApply({ settings = SETTINGS })
    end)
  end)
end
