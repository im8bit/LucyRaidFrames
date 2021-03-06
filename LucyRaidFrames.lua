local AddonName, addon = ...

addon.lrf = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0",  "AceEvent-3.0")
lrf = addon.lrf

AceConfig = LibStub("AceConfig-3.0")
AceDialog = LibStub("AceConfigDialog-3.0")

--------------------
-- EVENT HANDLERS --
--------------------

function lrf:RegisterEvents()
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("PLAYER_LOGIN")
end

function lrf:PLAYER_REGEN_ENABLED()
  CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

function lrf:PLAYER_LOGIN()
  CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

---------------------
-- OTHER FUNCTIONS --
---------------------

function lrf:tryUpdate()
  self:forEveryCRF(lrf.UpdateName)
  self:forEveryCRF(lrf.SetMaxBuffs)
  self:sort(CompactRaidFrameContainer)
end

function lrf:adjustFrameSizeSliders()
  --This is how you make the raid frames even more resizable :) you can also put all this in one line and just use a macro in game.
  local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
  _G[n.."HeightSlider"],
  _G[n.."WidthSlider"]
  h:SetMinMaxValues(1,150)
  w:SetMinMaxValues(1,150)
end

function lrf:setScale(value)
  CompactRaidFrameManager:SetScale(value);
end

function lrf:forEveryCRF(func)
  local index = 1
  local frame
  repeat
    frame = _G["CompactRaidFrame"..index]
    if frame then
      if frame:IsForbidden() then return end --!!!
      func(frame)
    end
    index = index + 1
  until not frame
end

function lrf:hideBackgrounds()
  if (
    GetNumGroupMembers() == 0 or
    addon.db.profile.frame.bgAlpha == 1
  ) then return end
  C_Timer.After(0.3, function()
    lrf:forEveryCRF(function(frame)
      frame.background:SetAlpha(addon.db.profile.frame.bgAlpha)
    end)
  end)
end

lrf.sortings = {
  GroupAscending_PlayerBottom = function(t1, t2)
    if UnitIsUnit(t1, "player") then
      return false;
    elseif UnitIsUnit(t2, "player") then
      return true;
    end
    return t1 < t2;
  end
}

function lrf:sort(frame)
  if (
    GetNumGroupMembers() > 5 or
    frame:IsForbidden() or
    InCombatLockdown() or
    not frame.groupMode or
    not addon.db.profile.sorting.enable
  ) then
    return
  end
  CompactRaidFrameContainer_SetFlowSortFunction(frame, lrf.sortings.GroupAscending_PlayerBottom);
end

------------------------------------
-- BLIZZARD RAIDFRAME ALTERATIONS --
------------------------------------

 lrf.SetMaxBuffs = function(frame)
  if frame:IsForbidden() then return end --!!!

  local buffscale = addon.db.profile.auras.scaling.buffs;
  local debuffscale = addon.db.profile.auras.scaling.debuffs;

  for i=1, #frame.buffFrames do
    frame.buffFrames[i]:SetScale(buffscale);
  end

  for i=1, #frame.debuffFrames do
    frame.debuffFrames[i]:SetScale(debuffscale);
  end

end

lrf.UpdateName = function(frame)
  if frame:IsForbidden() then return end --!!!

  local name = frame.name;
  local playerName = GetUnitName(frame.unit, true);

  if (playerName) then
    if (addon.db.profile.names.hideServerName) then
      local nameWithoutRealm = gsub(playerName, "%-[^|]+", "");
      local ellipsedName = string.sub(nameWithoutRealm, 0, addon.db.profile.names.maxLength)
      name:SetText(ellipsedName);
    end
    name:SetScale(addon.db.profile.names.scale);
    name:ClearAllPoints();
    name:SetPoint(
      addon.db.profile.names.position.anchor,
      addon.db.profile.names.position.x,
      addon.db.profile.names.position.y
    );
  end

  if (addon.db.profile.names.alpha.enable) then
    if InCombatLockdown() then
      name:SetAlpha(addon.db.profile.names.alpha.combat);
    else
      name:SetAlpha(addon.db.profile.names.alpha.noCombat);
    end
  end
end

lrf.UpdateRoleIcon = function(frame)
  if frame:IsForbidden() then return end --!!!

  local icon = frame.roleIcon;
  if not icon then
    return;
  end
  icon:SetScale(0.8);
  local offset = icon:GetWidth() / 4;

  icon:ClearAllPoints();
  icon:SetPoint("TOPLEFT", -offset, offset);

  local role = UnitGroupRolesAssigned(frame.unit);

  if (role == "DAMAGER") then
    icon:Hide();
  end
end

lrf.UtilSetDebuff = function(frame)
  if frame:IsForbidden() then return end --!!!
  frame.count:SetScale(0.7);
end

lrf.CRFContainerOnEvent = function(self, event, ...)
  if ( event == "GROUP_ROSTER_UPDATE" ) then
    lrf:sort(self);
  end
end

lrf.CRFManagerOnEvent = function(self, event, ...)
  if (
    event == "PLAYER_ENTERING_WORLD" or
    event == "PLAYER_TARGET_CHANGED"
  ) then
    lrf:sort(self.container)
    lrf:hideBackgrounds();
    lrf:forEveryCRF(lrf.SetMaxBuffs)
  end
end

function lrf:CRFHooker()
  if (addon.db.profile.auras.scaling.enable) then
    hooksecurefunc("CompactUnitFrame_SetMaxBuffs", lrf.SetMaxBuffs);
  end
  hooksecurefunc("CompactUnitFrame_UpdateName", lrf.UpdateName);
  hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", lrf.UpdateRoleIcon);
  hooksecurefunc("CompactUnitFrame_UtilSetDebuff", lrf.UtilSetDebuff);
  hooksecurefunc("CompactRaidFrameContainer_OnEvent", lrf.CRFContainerOnEvent);
  CompactRaidFrameManager:HookScript("OnEvent", lrf.CRFManagerOnEvent)
end

-----------
-- SETUP --
-----------

function lrf:OnInitialize()
  addon.db = LibStub("AceDB-3.0"):New(AddonName .."DB", addon.defaultSettings, true)
  AceConfig:RegisterOptionsTable(AddonName, addon.options, {"/lrf", "/lucyraidframes"})
  AceDialog:AddToBlizOptions(AddonName, AddonName)
end

function lrf:OnEnable()
  if addon.db.profile.enable  then
    self:RegisterEvents();
    self:adjustFrameSizeSliders();
    self:CRFHooker();
    self:setScale(addon.db.profile.frame.scale)
  end
end

function lrf:OnDisable()
end

