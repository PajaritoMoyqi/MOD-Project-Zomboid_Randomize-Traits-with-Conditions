-- require('OptionScreens/CharacterCreationProfession');
-- PM_RandomizeTraits = CharacterCreationProfession:derive("PM_RandomizeTraits")

function CharacterCreationProfession:randomizeTraits() -- {{{
    -- [PM] check the mod works
    print( "Hello world!!! - 1" );

    self:resetBuild();

    local size = #self.listboxProf.items;
    local prof = ZombRand(size)+1;
    self.listboxProf.selected = prof;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    local numTraits = ZombRand(5);
    for i=0,numTraits do
        self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
        self:onOptionMouseDown(self.addTraitBtn);
    end

    local numBadTraits = ZombRand(5);
    for i=0,numBadTraits do
        self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
        self:onOptionMouseDown(self.addBadTraitBtn);
    end

    -- [PM] Athletic, Strong (if I use MoreTraits)
    self.listboxTrait.selected = #self.listboxTrait.items - 3;
    self:onOptionMouseDown(self.addTraitBtn);
    self.listboxTrait.selected = #self.listboxTrait.items - 1;
    self:onOptionMouseDown(self.addTraitBtn);

    -- [PM] Burn Ward Patient (if I use MoreTraits)
    self.listboxBadTrait.selected = #self.listboxBadTrait.items;
    self:onOptionMouseDown(self.addBadTraitBtn);

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
                        if self.listboxTraitSelected.items[i].item:getCost() > 0 and math.abs(self.listboxTraitSelected.items[i].item:getCost()) <= math.abs(self:PointToSpend()) then
                            self.listboxTraitSelected.selected = i;
                            self:onOptionMouseDown(self.removeTraitBtn);
                        end
                        rescue2 = rescue2 - 1;
                    end
                else
                    -- add a bad trait
                    self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
                    self:onOptionMouseDown(self.addBadTraitBtn);
                end
            else
                -- Points are too positive, try to decrease
                if ZombRand(2) == 0 then
                    -- remove a bad trait
                    local rescue2 = 5;
                    while rescue2 > 0 do
                        local i = ZombRand(#self.listboxTraitSelected.items)+1;
                        if self.listboxTraitSelected.items[i].item:getCost() < 0 and math.abs(self.listboxTraitSelected.items[i].item:getCost()) <= math.abs(self:PointToSpend()) then
                            self.listboxTraitSelected.selected = i;
                            self:onOptionMouseDown(self.removeTraitBtn);
                        end
                        rescue2 = rescue2 - 1;
                    end
                else
                    -- add a good trait
                    self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
                    self:onOptionMouseDown(self.addTraitBtn);
                end
            end
        end
    end
end