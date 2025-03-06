PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.SETTINGS or {};

PM_RandomizeTraits.settings.Test = false;

if ModOptions and ModOptions.getInstance then
  local function onModOptionsApply(optionValues)
    PM_RandomizeTraits.settings.Test = optionValues.settings.options.Test;
  end
  local SETTINGS = {
    options_data = {
      Test = {
        name = "UI_PM_RandomizeTraits_Options_Test",
        tooltip = "UI_PM_RandomizeTraits_Options_Test_ToolTip",
        default = false,
        OnApplyMainMenu = onModOptionsApply,
        OnApplyInGame = onModOptionsApply,
      },
    },
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