hooksecurefunc("CompactUnitFrame_SetMaxBuffs", function(frame,numbuffs)

  local buffscale = 1.4;
  local debuffscale = 1.1;
  local maxbuffs = 3;         -- default: 3;

  for i=1, #frame.buffFrames do
    frame.buffFrames[i]:SetScale(buffscale);
  end

  for i=1, #frame.debuffFrames do
    frame.debuffFrames[i]:SetScale(debuffscale);
  end

  frame.maxBuffs = maxbuffs;
end);

hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
  local name = frame.name;

  name:ClearAllPoints();
  name:SetPoint("TOPLEFT", 5, -5);

  if UnitAffectingCombat("player") then
    name:SetAlpha(0.15);
  else
    name:SetAlpha(1);
  end
end);

hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
  local icon = frame.roleIcon;
  if not icon then
    return;
  end

  local iconSize = icon:GetWidth() / 4;

  icon:ClearAllPoints();
  icon:SetPoint("TOPLEFT", -iconSize, iconSize);

  local role = UnitGroupRolesAssigned(frame.unit);

  if (role == "DAMAGER") then
    icon:Hide();
  end

end);
