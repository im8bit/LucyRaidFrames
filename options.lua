local name, addon = ...

addon.defaultSettings = {
  profile = {
    enable = true
  }
}

addon.options = {
  type = "group",
  args = {
    enable = {
      name = "Enable",
      desc = "Enables / disables the addon",
      type = "toggle",
      set = function(info,val) addon.db.profile.enable = val  end,
      get = function(info) return addon.db.profile.enable end
    },
    moreoptions={
      name = name,
      type = "group",
      args={
        -- more options go here
      }
    }
  }
}

