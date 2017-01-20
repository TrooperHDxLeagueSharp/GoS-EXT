class "TroopRelia"
 
 --init
function TroopRelia:__init()
    if myHero.charName ~= "Irelia" then return end
    require('DamageLib')
    PrintChat("[TroopRelia] loaded")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add('Tick', function() self:Tick() end)
    Callback.Add('Draw', function() self:Draw() end)
 
end

--SpellLoad
function TroopRelia:LoadSpells()
    Q = {Range = 650}
    W = {Range = 200}
    E = {Range = 425}
    R = {Range = 1000, Delay = 0.25, Radius = 120, Speed = 1600}
end

--MENU
function TroopRelia:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "TroopRelia", name = "trooperhdx - TroopRelia", leftIcon="http://puu.sh/trYUs/449a80b95c.jpg"})
 
    --Combo
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.Menu.Combo:MenuElement({id = "CombQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "CombW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "CombE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "CombR", name = "Use R", value = true})
    self.Menu.Combo:MenuElement({id = "CombMana", name = "Min. Mana to Combo", value = 40, min = 0, max = 100})
 
    --Harass
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.Menu.Harass:MenuElement({id = "HQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HMana", name = "Min. Mana", value = 40, min = 0, max = 100})
 
    --Farm
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "LaneClear"})
    self.Menu.Farm:MenuElement({id = "lcW", name = "Use W", value = true})
    self.Menu.Farm:MenuElement({id = "lcMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --LastHit 
    self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
    self.Menu.LastHit:MenuElement({id = "lhQ", name = "Use Q", value = true})
    self.Menu.LastHit:MenuElement({id = "lhMana", name = "Min. Mana", value = 40, min = 0, max = 100})
 
    --Misc
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
	self.Menu.Misc:MenuElement({id = "IgniteE", name = "Use Ignite", value = true})
end
    self.Menu.Misc:MenuElement({id = "kswithQ", name = "Use Q to ks", value = true})
    self.Menu.Misc:MenuElement({id = "kswithR", name = "Use R to ks", value = true})
 
 
    --Draw
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawSpells", name = "Draw Only Ready Spells", value = true})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})
 
    PrintChat("[TroopRelia] Menu Loaded")
end
--MENU END


--TICK
function TroopRelia:Tick()
 
    local target = self:GetTarget(R.Range)
 
    self:Misc()

    if self:Mode() == "Combo" then
        self:Combo(target)
    elseif self:Mode() == "Harass" then
        self:Harass(target)
    elseif self:Mode() == "Farm" then
        self:Farm()
    elseif self:Mode() == "LastHit" then
        self:LastHit()
 
    end
end
--TICK END


--IMPORTANT
function TroopRelia:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end
 
function TroopRelia:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end
 
function TroopRelia:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end
 
function TroopRelia:GetRange(spell)
  return myHero:GetSpellData(spell).range
end

function TroopRelia:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end
 
function TroopRelia:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end
--IMPORTANT NEEDED


--LHCS
function TroopRelia:GetMinions(team)
    local Minions
    if Minions then return Minions end
    Minions = {}
    for i = 1, Game.MinionCount() do
        local Minion = Game.Minion(i)
        if team then
            if Minion.team == team then
                table.insert(Minions, Minion)
            end
        else
            table.insert(Minions, Minion)
        end
    end
    return Minions
end
--ENDLHCS



--LCCS
function TroopRelia:GetFarmTarget(range)
    local target
    for j = 1,Game.MinionCount() do
        local minion = Game.Minion(j)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end
--END LCCS


--GETTARGET
function TroopRelia:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
            target = hero
            break
        end
    end
    return target
end
--GETTARGET END


--MISC FOR IGNITE + KS
function TroopRelia:Misc()
     for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
        if self:IsValidTarget(Enemy, 650) and Enemy.team ~= myHero.team then
            if self.Menu.Misc.kswithQ:Value() then
                if getdmg("Q", Enemy, myHero) > Enemy.health then
                    self:CastQ(Enemy)
                    return;
                end
            end
        end


        if self:IsValidTarget(Enemy, 1000) and Enemy.team ~= myHero.team then
            if self.Menu.Misc.kswithR:Value() then
                if getdmg("R", Enemy, myHero) > Enemy.health then
                    self:CastR(Enemy)
                    return;
                end
            end
        

             --IGNITE
            if myHero:GetSpellData(5).name == "SummonerDot" and self.Menu.Misc.IgniteE:Value() and self:IsReady(SUMMONER_2) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end

            if myHero:GetSpellData(4).name == "SummonerDot" and self.Menu.Misc.IgniteE:Value() and self:IsReady(SUMMONER_1) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
    end
end
--MISC END



--Harass
function TroopRelia:Harass()
    if (myHero.mana/myHero.maxMana >= self.Menu.Harass.HMana:Value() / 100) then
        local target = self:GetTarget(Q.Range)
        if self.Menu.Harass.HQ:Value() and self:CanCast(_Q) then
            self:CastQ(target)
        end

        local target = self:GetTarget(E.Range)
        if self.Menu.Harass.HE:Value() and self:CanCast(_E) then
            self:CastE(target)
        end
    end
end
--Harass end

--COMBO
function TroopRelia:Combo(target)
    if (myHero.mana/myHero.maxMana >= self.Menu.Combo.CombMana:Value()/100) then

        if self.Menu.Combo.CombQ:Value() and self:CanCast(_Q) and self:IsValidTarget(target, Q.Range) then
            self:CastQ(target)
 
        elseif self.Menu.Combo.CombR:Value() and self:CanCast(_R) and self:IsValidTarget(target, R.Range) and not self:CanCast(_Q) then
           self:CastR(target)

        elseif self.Menu.Combo.CombE:Value() and self:CanCast(_E) and self:IsValidTarget(target, E.Range) then
            self:CastE(target)
 
        elseif self.Menu.Combo.CombE:Value() and self:CanCast(_W) and self:IsValidTarget(target, W.Range) then
           self:CastW()

 
        end
    end
end
--COMBO END

--LANCELCEAR
function TroopRelia:Farm()
    if (myHero.mana/myHero.maxMana >= self.Menu.Farm.lcMana:Value() / 100) then
        local wMinion = self:GetFarmTarget(W.Range)
        if self.Menu.Farm.lcW:Value() and self:CanCast(_W) then
            self:CastW()
        end
    end
end
--LC END

--LASTHIT
function TroopRelia:LastHit()
    if (myHero.mana/myHero.maxMana >= self.Menu.LastHit.lhMana:Value() / 100) then
    	        for _, Minion in pairs(self.GetMinions(200)) do
    	        	if self.Menu.LastHit.lhQ:Value() and getdmg("Q", Minion, myHero) > Minion.health then
                            if self:CanCast(_Q) and self:IsValidTarget(Minion, self:GetRange(_Q), false, myHero.pos) then
                                    self:CastQ()
                            end
                    end
            end
    end 
end

--LASTHIT END

--MODE
function TroopRelia:Mode()
    if Orbwalker["Combo"].__active then
        return "Combo"
    elseif Orbwalker["Harass"].__active then
        return "Harass"
    elseif Orbwalker["Farm"].__active then
        return "Farm"
    elseif Orbwalker["LastHit"].__active then
        return "LastHit"
    end
    return ""
end
--MODE END

--Q W E R CAST

function TroopRelia:CastQ(unit)
    Control.CastSpell(HK_Q, unit)
end
 
 
--W CAST
function TroopRelia:CastW()
    Control.CastSpell(HK_W)
end
 
 
--E CAST
function TroopRelia:CastE(unit)
    Control.CastSpell(HK_E, unit)
end
 
 
--R CAST
function TroopRelia:CastR(Rtarget)
    if Rtarget then
        local castPos = Rtarget:GetPrediction(R.Speed, R.Delay)
        Control.CastSpell(HK_R, castPos)
    end
end

--END Q W E R CAST

--DRAWINGS
function TroopRelia:Draw()
    if myHero.dead then return end
    if self.Menu.Draw.DrawSpells:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
    end
end
--DRAWINGS END
 
 
 
 
function OnLoad()
    TroopRelia()

end
    
