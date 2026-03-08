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
    -- TEST A: boolean option (same format as working options)
    TestBoolean = {
      name = "TEST: Boolean Option",
      tooltip = "This tests if a simple boolean option works here",
      default = true,
      OnApplyMainMenu = onModOptionsApply,
      OnApplyInGame = onModOptionsApply,
    },
    -- TEST B: string values option (same format as trait options)
    TestValues = {
      name = "TEST: Values Option",
      tooltip = "This tests if values/enum format works",
      default = "Normal",
      values = {"Normal", "Exclude", "Preselect"},
      OnApplyMainMenu = onModOptionsApply,
      OnApplyInGame = onModOptionsApply,
    },
  }

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
end
