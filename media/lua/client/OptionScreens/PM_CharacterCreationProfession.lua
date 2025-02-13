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

function PM_has_value(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true
        end
    end

    return false
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

    -- [PM] pre-selected unwanted traits table
    print( PM_dump( self.listboxTrait.items[#self.listboxTrait.items-4].text ) );
    print( PM_dump( self.listboxTrait.items[#self.listboxTrait.items-4].itemindex ) );
    print( PM_dump( self.listboxTrait.items[#self.listboxTrait.items-8].text ) );
    print( PM_dump( self.listboxTrait.items[#self.listboxTrait.items-8].itemindex ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-1].text ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-1].itemindex ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-3].text ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-3].itemindex ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-11].text ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-11].itemindex ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-43].text ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-43].itemindex ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-44].text ) );
    print( PM_dump( self.listboxBadTrait.items[#self.listboxBadTrait.items-44].itemindex ) );

    -- [PM] 슈퍼 면역, 회피 기동
    local PM_excludedTraits = {
        self.listboxTrait.items[#self.listboxTrait.items-4].itemindex,
        self.listboxTrait.items[#self.listboxTrait.items-8].itemindex
    };
    local PM_excludedBadTraits = {
        self.listboxBadTrait.items[#self.listboxBadTrait.items-1].itemindex, -- [PM] 팔 절단
        self.listboxBadTrait.items[#self.listboxBadTrait.items-3].itemindex, -- [PM] 청각장애
        self.listboxBadTrait.items[#self.listboxBadTrait.items-11].itemindex, -- [PM] 대충대충
        self.listboxBadTrait.items[#self.listboxBadTrait.items-43].itemindex, -- [PM] 비체계적인
        self.listboxBadTrait.items[#self.listboxBadTrait.items-44].itemindex -- [PM] 불운
    };

    print( PM_dump( PM_excludedTraits ) );
    print( PM_dump( PM_excludedBadTraits ) );

    -- [PM] Add initial traits
    local numTraits = ZombRand(5);
    for i=0,numTraits do
        self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
        print( self.listboxTrait.items[self.listboxTrait.selected].itemindex );
        if ( not PM_has_value(PM_excludedTraits, self.listboxTrait.items[self.listboxTrait.selected].itemindex) ) then
            print( "Init: Add good trait - ", self.listboxTrait.items[self.listboxTrait.selected].text );
            self:onOptionMouseDown(self.addTraitBtn);
        else
            print( "Init: Dup good trait - ", self.listboxTrait.items[self.listboxTrait.selected].text );
        end
    end

    local numBadTraits = ZombRand(5);
    for i=0,numBadTraits do
        self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
        print( self.listboxBadTrait.items[self.listboxBadTrait.selected].itemindex );
        if ( not PM_has_value(PM_excludedBadTraits, self.listboxBadTrait.items[self.listboxBadTrait.selected].itemindex) ) then
            print( "Init: Add bad trait - ", self.listboxBadTrait.items[self.listboxBadTrait.selected].text );
            self:onOptionMouseDown(self.addBadTraitBtn);
        else
            print( "Init: Dup bad trait - ", self.listboxBadTrait.items[self.listboxBadTrait.selected].text );
        end
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
                    print( self.listboxBadTrait.items[self.listboxBadTrait.selected].itemindex );
                    if ( not PM_has_value(PM_excludedBadTraits, self.listboxBadTrait.items[self.listboxBadTrait.selected].itemindex) ) then
                        print( "On: Add bad trait - ", self.listboxBadTrait.items[self.listboxBadTrait.selected].text );
                        self:onOptionMouseDown(self.addBadTraitBtn);
                    else
                        print( "On: Dup bad trait - ", self.listboxBadTrait.items[self.listboxBadTrait.selected].text );
                    end
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
                    print( self.listboxTrait.items[self.listboxTrait.selected].itemindex );
                    if ( not PM_has_value(PM_excludedTraits, self.listboxTrait.items[self.listboxTrait.selected].itemindex) ) then
                        print( "On: Add good trait - ", self.listboxTrait.items[self.listboxTrait.selected].text );
                        self:onOptionMouseDown(self.addTraitBtn);
                    else
                        print( "On: Dup good trait - ", self.listboxTrait.items[self.listboxTrait.selected].text );
                    end
                end
            end
        end
    end
end