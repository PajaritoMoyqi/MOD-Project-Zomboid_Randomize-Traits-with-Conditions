function PM_has_value(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end

    return false
end

-- Build excluded/preselected trait lists from ModOptions (PM_RandomizeTraits.traitSettings)
-- Setting values: "Normal" / "Exclude" / "Preselect"
local function PM_buildTraitLists()
    local PM_excludedTraits = {}
    local PM_preselectedTraits = {}
    local PM_excludedBadTraits = {}
    local PM_preselectedBadTraits = {}

    -- [1] Preselect master toggle: if OFF, all traits are Normal
    if not PM_RandomizeTraits.settings.Preselect then
        return PM_excludedTraits, PM_preselectedTraits, PM_excludedBadTraits, PM_preselectedBadTraits
    end

    local allTraits = TraitFactory.getTraits()
    for i = 0, allTraits:size() - 1 do
        local trait = allTraits:get(i)
        local traitID = trait:getType()
        local setting = PM_RandomizeTraits.traitSettings[traitID] or "Normal"

        if setting == "Exclude" then
            if trait:getCost() >= 0 then
                table.insert(PM_excludedTraits, traitID)
            else
                table.insert(PM_excludedBadTraits, traitID)
            end
        elseif setting == "Preselect" then
            if trait:getCost() >= 0 then
                table.insert(PM_preselectedTraits, traitID)
            else
                table.insert(PM_preselectedBadTraits, traitID)
            end
        end
    end

    return PM_excludedTraits, PM_preselectedTraits, PM_excludedBadTraits, PM_preselectedBadTraits
end

-- Flag to prevent recursion when AutoReRandomize is enabled
local PM_isRandomizing = false

-- Core trait randomization logic (without profession selection)
local function PM_doTraitRandomization(self)
    local PM_excludedTraits, PM_preselectedTraits, PM_excludedBadTraits, PM_preselectedBadTraits = PM_buildTraitLists()

    -- [PM] Add preselected good traits
    local PM_i = 0;
    while PM_i < #self.listboxTrait.items do
        local numOfTraits = #self.listboxTrait.items;

        self.listboxTrait.selected = #self.listboxTrait.items - PM_i;
        if ( PM_has_value(PM_preselectedTraits, self.listboxTrait.items[self.listboxTrait.selected].item:getType()) ) then
            self:onOptionMouseDown(self.addTraitBtn);
        end

        PM_i = PM_i + 1 - (numOfTraits - #self.listboxTrait.items);
        if ( PM_i < 0 ) then
            PM_i = 0;
        end
    end

    -- [PM] Add preselected bad traits
    PM_i = 0;
    while PM_i < #self.listboxBadTrait.items do
        local numOfBadTraits = #self.listboxBadTrait.items;

        self.listboxBadTrait.selected = #self.listboxBadTrait.items - PM_i;
        if ( PM_has_value(PM_preselectedBadTraits, self.listboxBadTrait.items[self.listboxBadTrait.selected].item:getType()) ) then
            self:onOptionMouseDown(self.addBadTraitBtn);
        end

        PM_i = PM_i + 1 - (numOfBadTraits - #self.listboxBadTrait.items);
        if ( PM_i < 0 ) then
            PM_i = 0;
        end
    end

    -- [PM] Add initial random good traits
    local numTraits = ZombRand(5);
    for i=0,numTraits do
        self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
        local traitType = self.listboxTrait.items[self.listboxTrait.selected].item:getType();
        if ( not PM_has_value(PM_excludedTraits, traitType) ) then
            self:onOptionMouseDown(self.addTraitBtn);
        else
            self.listboxTrait.selected = -1;
        end
    end

    -- [PM] Add initial random bad traits
    local numBadTraits = ZombRand(5);
    for i=0,numBadTraits do
        self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
        local traitType = self.listboxBadTrait.items[self.listboxBadTrait.selected].item:getType();
        if ( not PM_has_value(PM_excludedBadTraits, traitType) ) then
            self:onOptionMouseDown(self.addBadTraitBtn);
        else
            self.listboxBadTrait.selected = -1;
        end
    end

    -- [PM] Balance points
    -- [2] HardPreselect: if ON, preselected traits are never removed during balancing
    local hardPreselect = PM_RandomizeTraits.settings.HardPreselect
    local rescue = 1000;
    while rescue > 0 do
        rescue = rescue - 1;
        if self:PointToSpend() >= 0 and self:PointToSpend() <= 3 then
            rescue = 0;
        else
            if self:PointToSpend() < 0 then
                -- Points are negative, try to increase
                if ZombRand(2) == 0 then
                    -- remove a good trait
                    local rescue2 = 5;
                    while rescue2 > 0 do
                        local i = ZombRand(#self.listboxTraitSelected.items)+1;
                        local traitItem = self.listboxTraitSelected.items[i].item;
                        if traitItem:getCost() > 0 and math.abs(traitItem:getCost()) <= math.abs(self:PointToSpend()) then
                            if not (hardPreselect and PM_has_value(PM_preselectedTraits, traitItem:getType())) then
                                self.listboxTraitSelected.selected = i;
                                self:onOptionMouseDown(self.removeTraitBtn);
                            end
                        end
                        rescue2 = rescue2 - 1;
                    end
                else
                    -- add a bad trait
                    self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
                    local traitType = self.listboxBadTrait.items[self.listboxBadTrait.selected].item:getType();
                    if ( not PM_has_value(PM_excludedBadTraits, traitType) ) then
                        self:onOptionMouseDown(self.addBadTraitBtn);
                    else
                        self.listboxBadTrait.selected = -1;
                    end
                end
            else
                -- Points are too positive, try to decrease
                if ZombRand(2) == 0 then
                    -- remove a bad trait
                    local rescue2 = 5;
                    while rescue2 > 0 do
                        local i = ZombRand(#self.listboxTraitSelected.items)+1;
                        local traitItem = self.listboxTraitSelected.items[i].item;
                        if traitItem:getCost() < 0 and math.abs(traitItem:getCost()) <= math.abs(self:PointToSpend()) then
                            if not (hardPreselect and PM_has_value(PM_preselectedBadTraits, traitItem:getType())) then
                                self.listboxTraitSelected.selected = i;
                                self:onOptionMouseDown(self.removeTraitBtn);
                            end
                        end
                        rescue2 = rescue2 - 1;
                    end
                else
                    -- add a good trait
                    self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
                    local traitType = self.listboxTrait.items[self.listboxTrait.selected].item:getType();
                    if ( not PM_has_value(PM_excludedTraits, traitType) ) then
                        self:onOptionMouseDown(self.addTraitBtn);
                    else
                        self.listboxTrait.selected = -1;
                    end
                end
            end
        end
    end
end

function CharacterCreationProfession:randomizeTraits() -- {{{
    PM_isRandomizing = true;

    self:resetBuild();

    -- [PM] select random profession
    local size = #self.listboxProf.items;
    local prof = ZombRand(size)+1;
    self.listboxProf.selected = prof;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    PM_doTraitRandomization(self);

    PM_isRandomizing = false;
end

-- [3] AutoReRandomize: re-randomize traits when user manually selects a profession
local PM_original_onSelectProf = CharacterCreationProfession.onSelectProf
function CharacterCreationProfession:onSelectProf(item)
    PM_original_onSelectProf(self, item)
    if PM_RandomizeTraits.settings.AutoReRandomize and not PM_isRandomizing then
        PM_isRandomizing = true;
        PM_doTraitRandomization(self);
        PM_isRandomizing = false;
    end
end

-- Print all available trait IDs to console (for discovering new trait IDs)
function PM_PrintAllTraitIDs()
    local allTraits = TraitFactory.getTraits()
    print("=== All Available Trait IDs ===")
    for i=0, allTraits:size()-1 do
        local trait = allTraits:get(i)
        print(trait:getType() .. " | " .. trait:getLabel() .. " | cost: " .. trait:getCost())
    end
end
