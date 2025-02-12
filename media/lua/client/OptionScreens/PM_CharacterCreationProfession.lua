-- require('OptionScreens/CharacterCreationProfession');
-- PM_RandomizeTraits = CharacterCreationProfession:derive("PM_RandomizeTraits")

function PM_dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. PM_dump(v) .. ','
        end
        return s .. '} '
    else
       return tostring(o)
    end
end

function CharacterCreationProfession:randomizeTraits() -- {{{
    -- [PM] check the mod works
    print( "Hello world!!! - 1" );

    self:resetBuild();

    -- [PM] select random profession
    local size = #self.listboxProf.items;
    local prof = ZombRand(size)+1;
    self.listboxProf.selected = prof;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    -- [PM] Add initial traits
    local numTraits = ZombRand(5);
    for i=0,numTraits do
        self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
        self:onOptionMouseDown(self.addTraitBtn);
    end

    local numBadTraits = ZombRand(5);
    for i=0,numBadTraits do
        self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
        print( listboxBadTrait.selected );
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

    -- [PM] if unwanted trait is included
    print( "Traits num: ", #self.listboxTraitSelected.items );

    for PM_i=1,#self.listboxTraitSelected.items do
        local PM_item = self.listboxTraitSelected.items[PM_i];
        local PM_item_title = PM_item["text"];
        print( PM_item_title );

        if PM_item_title == "팔 절단" or PM_item_title == "청각 장애" or PM_item_title == "비체계적인" or PM_item_title == "불운" or PM_item_title == "대충대충" then
            print( "!: ", PM_item_title );
            self:randomizeTraits();
        else
            print( "~continue~" );
        end
    end
end