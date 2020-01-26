local name, addon = ...

local anchorOptions = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["CENTER"] = "CENTER",

}

addon.defaultSettings = {
  profile = {
		enable = true,
		auras = {
			scaling = {
				enable = true,
				buffs = 1.25,
				debuffs = 1.1
			},
			amount = {
				enable = false,
				buffs = 3,
				debuffs = 3
			}
		},
		names = {
			alpha = {
				enable = true,
				combat = 0.15,
				noCombat = 1
			},
			position = {
				enable = true,
				anchor = "TOPLEFT",
				x = 5,
				y = -5
			}
		}
  }
}

addon.options = {
  type = "group",
  args = {
		generalGroup = {
			type = "group",
			name = "General",
			order = 1,
			inline = true,
			args = {
				enable = {
					order = 1,
					name = "Enable",
					desc = "Enables / disables all functionality",
					type = "toggle",
					set = function(info,val) addon.db.profile.enable = val  end,
					get = function(info) return addon.db.profile.enable end
				},
				save = {
					order = 2,
					type = "execute",
					name = "Save & reload",
					desc = "Reloads UI",
					func = function() ReloadUI() end,
				},
				reset = {
					order = 3,
					type = "execute",
					name = "Reset settings",
					desc = "Resets all your settings",
					confirm = true,
					func = function()
							addon.db:ResetDB("Default")
							ReloadUI()
					end,
				}
			}
		},
		aurasGroup = {
			type = "group",
			name = "Auras",
			order = 2,
			inline = true,
			args = {
				scalingHeader = {
					type = "header",
					name = "Scaling",
					order = 1,
				},
				enableScaling = {
					type = "toggle",
					name = "Enable",
					order = 1.1,
					desc = "Enables / disables scaling of buffs & debuffs",
					set = function(info,val) addon.db.profile.auras.scaling.enable = val  end,
					get = function(info) return addon.db.profile.auras.scaling.enable end
				},
				buffScale = {
					order = 1.2,
					type = "range",
					name = "Buffs",
					desc = "Buffs",
					min = 0,
					max = 2,
					step = 0.01,
					isPercent = true,
					get = function() return addon.db.profile.auras.scaling.buffs end,
					set = function(_, val) addon.db.profile.auras.scaling.buffs = val end,
					disabled = function() return not addon.db.profile.auras.scaling.enable end
				},
				debuffScale = {
					order = 1.3,
					type = "range",
					name = "Debuffs",
					desc = "",
					min = 0,
					max = 2,
					step = 0.01,
					isPercent = true,
					get = function() return addon.db.profile.auras.scaling.debuffs end,
					set = function(_, val) addon.db.profile.auras.scaling.debuffs = val end,
					disabled = function() return not addon.db.profile.auras.scaling.enable end
				},
				amountHeader = {
					type = "header",
					name = "Amount (WIP)",
					order = 2,
				},
				enableAmount = {
					type = "toggle",
					name = "Enable",
					order = 2.1,
					desc = "Modify the max amount of buffs/debuffs shown",
					set = function(info,val) addon.db.profile.auras.amount.enable = val  end,
					get = function(info) return addon.db.profile.auras.amount.enable end
				},
				buffAmount = {
					order = 2.2,
					type = "range",
					name = "Buffs",
					desc = "Not yet implemented",
					min = 0,
					max = 10,
					step = 1,
					get = function() return addon.db.profile.auras.amount.buffs end,
					set = function(_, val) addon.db.profile.auras.amount.buffs = val end,
					disabled = function() return not addon.db.profile.auras.amount.enable end
				},
				debuffAmount = {
					order = 2.3,
					type = "range",
					name = "Debuffs",
					desc = "Not yet implemented",
					min = 0,
					max = 10,
					step = 1,
					get = function() return addon.db.profile.auras.amount.debuffs end,
					set = function(_, val) addon.db.profile.auras.amount.debuffs = val end,
					disabled = function() return not addon.db.profile.auras.amount.enable end
				}
			}
		},
		nameGroup = {
			type = "group",
			name = "Character Name",
			order = 2,
			inline = true,
			args = {
				alphaHeader = {
					type = "header",
					name = "Alpha",
					order = 1,
				},
				alphaEnable = {
					type = "toggle",
					name = "Enable",
					order = 1.1,
					desc = "Set an alpha fade on character names",
					set = function(info,val) addon.db.profile.names.alpha.enable = val  end,
					get = function(info) return addon.db.profile.names.alpha.enable end
				},
				alphaNoCombat = {
					order = 1.2,
					type = "range",
					name = "Out of combat",
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					get = function() return addon.db.profile.names.alpha.noCombat end,
					set = function(_, val) addon.db.profile.names.alpha.noCombat = val end,
					disabled = function() return not addon.db.profile.names.alpha.enable end
				},
				alphaCombat = {
					order = 1.3,
					type = "range",
					name = "In combat",
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					get = function() return addon.db.profile.names.alpha.combat end,
					set = function(_, val) addon.db.profile.names.alpha.combat = val end,
					disabled = function() return not addon.db.profile.names.alpha.enable end
				},
				positionHeader = {
					type = "header",
					name = "Position",
					order = 2,
				},
				positionAnchor = {
					name = "Anchor",
					type = "select",
					style = "dropdown",
					order = 2.1,
					values = anchorOptions,
					get = function() return addon.db.profile.names.position.anchor end,
					set = function(_, val) addon.db.profile.names.position.anchor = val; print("anchor " .. val) end
				},
				positionX = {
					order = 2.2,
					type = "range",
					name = "X",
					min = -200,
					max = 200,
					step = 1,
					get = function() return addon.db.profile.names.position.x end,
					set = function(_, val) addon.db.profile.names.position.x = val end,
					disabled = function() return not addon.db.profile.names.position.enable end
				},
				positionY = {
					order = 2.3,
					type = "range",
					name = "Y",
					min = -200,
					max = 200,
					step = 1,
					get = function() return addon.db.profile.names.position.y end,
					set = function(_, val) addon.db.profile.names.position.y = val end,
					disabled = function() return not addon.db.profile.names.position.enable end
				},
			}
		}
  }
}

