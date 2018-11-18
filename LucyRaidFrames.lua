--This is how you make the raid frames even more resizable :) you can also put all this in one line and just use a macro in game.
local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
_G[n.."HeightSlider"],
_G[n.."WidthSlider"]
h:SetMinMaxValues(1,150)
w:SetMinMaxValues(1,150)

local function hideBackgrounds()
  local raidFrameBackgroundAlpha = .4
  local index = 1
  local frame

  repeat
    frame = _G["CompactRaidFrame"..index]
    if frame then
      -- frame.background:Hide()
      frame.background:SetAlpha(raidFrameBackgroundAlpha)
    end
    index = index + 1
  until not frame
end

hideBackgrounds()

hooksecurefunc("CompactRaidFrameContainer_AddUnitFrame", hideBackgrounds)



hooksecurefunc("CompactUnitFrame_SetMaxBuffs", function(frame,numbuffs)

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
  local name = frame.name;
  local playerName = GetUnitName(frame.unit, true);

  hideBackgrounds();

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

local function sortCompactRaidFrameContainer(frame)

  if InCombatLockdown() then
    return;
  end

  if ( not frame.groupMode) then
    return;
  end

  LoadAddOn("CompactRaidFrameContainer");

  -- local amountUnitFrames = 0;
  -- repeat
  --   local frame = _G["CompactRaidFrame"..index]
  --   if frame then
  --     amountUnitFrames = amountUnitFrames + 1
  --   end
  -- until not frame

  local amountUnitFrames = frame:GetNumChildren();

  if (amountUnitFrames < 9) then

    local Sort_GroupAscending_PlayerBottom = function(t1, t2)
      if UnitIsUnit(t1, "player") then
        return false;
      elseif UnitIsUnit(t2, "player") then
        return true;
      else
        return t1 < t2;
      end
    end

    CompactRaidFrameContainer_SetFlowSortFunction(frame, Sort_GroupAscending_PlayerBottom);
    CompactRaidFrameContainer_TryUpdate(frame);
  end


end

-- hooksecurefunc("CompactRaidFrameContainer_UpdateDisplayedUnits", function(frame)
--   sortCompactRaidFrameContainer(frame);
-- end);

hooksecurefunc("CompactRaidFrameContainer_UpdateDisplayedUnits", sortCompactRaidFrameContainer)

hooksecurefunc("CompactUnitFrame_UtilSetDebuff" , function(debuffFrame, unit, index, filter, isBossAura, isBossBuff)
  debuffFrame.count:SetScale(0.8);
end);


sortCompactRaidFrameContainer(CompactRaidFrameContainer);

