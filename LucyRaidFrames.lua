LucyRaidFrames = LibStub("AceAddon-3.0"):NewAddon("LucyRaidFrames", "AceConsole-3.0",  "AceEvent-3.0")

function LucyRaidFrames:OnInitialize()
  self:Print('it initialized');

end

function LucyRaidFrames:OnEnable()
  --This is how you make the raid frames even more resizable :) you can also put all this in one line and just use a macro in game.
  local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
  _G[n.."HeightSlider"],
  _G[n.."WidthSlider"]
  h:SetMinMaxValues(1,150)
  w:SetMinMaxValues(1,150)

  self:Print('it enabled')
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function LucyRaidFrames:OnDisable()
  self:Print('it disabled')
end

function LucyRaidFrames:PLAYER_REGEN_ENABLED(event)
  CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

local function hideBackgrounds()
  if GetNumGroupMembers() == 0 then return end
  C_Timer.After(0.3, function()
    local raidFrameBackgroundAlpha = .4
    local index = 1
    local frame
    repeat
      frame = _G["CompactRaidFrame"..index]
      if frame then
        if frame:IsForbidden() then return end --!!!
        -- frame.background:Hide()
        frame.background:SetAlpha(raidFrameBackgroundAlpha)
      end
      index = index + 1
    until not frame
  end)
end

hooksecurefunc("CompactUnitFrame_SetMaxBuffs", function(frame, numbuffs)
  if frame:IsForbidden() then return end --!!!

  local buffscale = 1.25;
  local debuffscale = 1.1;

  for i=1, #frame.buffFrames do
    frame.buffFrames[i]:SetScale(buffscale);
  end

  for i=1, #frame.debuffFrames do
    frame.debuffFrames[i]:SetScale(debuffscale);
  end

end);

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  if frame:IsForbidden() then return end --!!!

  local name = frame.name;
  local playerName = GetUnitName(frame.unit, true);

  if (playerName) then
    local nameWithoutRealm = gsub(playerName, "%-[^|]+", "");
    name:SetText(nameWithoutRealm);
    name:SetScale(0.9);
  end

  if InCombatLockdown() then
    name:SetAlpha(0.15);
  else
    name:ClearAllPoints();
    name:SetPoint("TOPLEFT", 5, -5);

    name:SetAlpha(1);
  end

end);

hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
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

end);

local function Sort_GroupAscending_PlayerBottom(t1, t2)
  if UnitIsUnit(t1, "player") then
    return false;
  elseif UnitIsUnit(t2, "player") then
    return true;
  end
  return t1 < t2;
end


function LucyRaidFrames_Sort(frame)
  if (
    GetNumGroupMembers() > 5 or
    frame:IsForbidden() or
    InCombatLockdown() or
    not frame.groupMode
  ) then
    return
  end
  CompactRaidFrameContainer_SetFlowSortFunction(frame, Sort_GroupAscending_PlayerBottom);
end

hooksecurefunc("CompactUnitFrame_UtilSetDebuff" , function(frame, unit, index, filter, isBossAura, isBossBuff)
  if frame:IsForbidden() then return end --!!!
  frame.count:SetScale(0.8);
end);


hooksecurefunc("CompactRaidFrameContainer_OnEvent", function(self, event, ...)
  if ( event == "GROUP_ROSTER_UPDATE" ) then
    LucyRaidFrames_Sort(self);
  end
end);

CompactRaidFrameManager:HookScript("OnEvent", function(self, event, ...)
  if (
    event == "PLAYER_ENTERING_WORLD" or
    event == "PLAYER_TARGET_CHANGED"
  ) then
    LucyRaidFrames_Sort(self.container)
    hideBackgrounds();
  end
end)

