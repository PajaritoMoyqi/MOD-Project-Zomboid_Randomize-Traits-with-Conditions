PM_RandomizeTraits = PM_RandomizeTraits or {};
PM_RandomizeTraits.settings = PM_RandomizeTraits.settings or {};
PM_RandomizeTraits.traitSettings = {};

PM_RandomizeTraits.settings.Preselect = true;
PM_RandomizeTraits.settings.HardPreselect = false;
PM_RandomizeTraits.settings.AutoReRandomize = false;

-- DEBUG: Check what's available at file load time
print("[PM_RandomizeTraits] === FILE LOADED ===")
print("[PM_RandomizeTraits] TraitFactory = " .. tostring(TraitFactory))
if TraitFactory then
  local ok, result = pcall(TraitFactory.getTraits)
  print("[PM_RandomizeTraits] getTraits pcall ok=" .. tostring(ok) .. " result=" .. tostring(result))
  if ok and result then
    print("[PM_RandomizeTraits] trait count = " .. tostring(result:size()))
  end
end

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
  }

  -- Try to add traits at file load time
  local allTraits = TraitFactory.getTraits()
  if allTraits and allTraits:size() > 0 then
    print("[PM_RandomizeTraits] Adding " .. tostring(allTraits:size()) .. " traits at FILE LOAD TIME")
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
  else
    print("[PM_RandomizeTraits] TraitFactory EMPTY at file load time, traits will NOT appear in ModOptions")
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
end
