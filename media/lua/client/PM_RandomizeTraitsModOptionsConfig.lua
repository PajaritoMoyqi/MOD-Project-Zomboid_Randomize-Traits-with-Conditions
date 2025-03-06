PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.SETTINGS or {};

PM_RandomizeTraits.settings.Preselect = true;
PM_RandomizeTraits.settings.HardPreselect = false;
PM_RandomizeTraits.settings.AutoReRandomize = false;

if ModOptions and ModOptions.getInstance then
  local function onModOptionsApply(optionValues)
    PM_RandomizeTraits.settings.Preselect = optionValues.settings.options.Preselect;
    PM_RandomizeTraits.settings.Preselect = optionValues.settings.options.HardPreselect;
    PM_RandomizeTraits.settings.AutoReRandomize = optionValues.settings.options.AutoReRandomize;
  end
  local SETTINGS = {
    options_data = {
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