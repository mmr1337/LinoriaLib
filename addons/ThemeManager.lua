local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	
	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		-- Reset effects when applying theme
		if Options.PulsarToggle then Options.PulsarToggle:SetValue(false) end
		if Options.RGBToggle then Options.RGBToggle:SetValue(false) end
		if Options.NeonToggle then Options.NeonToggle:SetValue(false) end
		
		self.Library.Theme.PulsarEnabled = false
		self.Library.Theme.RGBEnabled = false
		self.Library.Theme.NeonEnabled = false

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			if Options.ThemeManager_ThemeList then
				Options.ThemeManager_ThemeList:SetValue(theme)
			end
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		if not isfolder(self.Folder .. '/themes') then
			makefolder(self.Folder .. '/themes')
		end
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		-- Effects Section
		groupbox:AddDivider()
		groupbox:AddLabel('Visual Effects', true)
		
		-- Pulsar Effect
		local PulsarToggle = groupbox:AddToggle('PulsarToggle', {
			Text = 'Pulsar Effect',
			Default = false,
			Callback = function(Value)
				self.Library.Theme.PulsarEnabled = Value
				if Value then
					if Options.RGBToggle then Options.RGBToggle:SetValue(false) end
					if Options.NeonToggle then Options.NeonToggle:SetValue(false) end
					self.Library.Theme.RGBEnabled = false
					self.Library.Theme.NeonEnabled = false
				else
					self.Library.AccentColor = Options.AccentColor.Value
					self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
					self.Library:UpdateColorsUsingRegistry()
				end
			end
		})
		
		groupbox:AddSlider('PulsarSpeed', {
			Text = 'Pulsar Speed',
			Default = 1,
			Min = 0.5,
			Max = 3,
			Rounding = 1,
			Callback = function(Value)
				self.Library.Theme.PulsarSpeed = Value
			end
		})
		
		-- RGB Effect
		local RGBToggle = groupbox:AddToggle('RGBToggle', {
			Text = 'RGB Effect',
			Default = false,
			Callback = function(Value)
				self.Library.Theme.RGBEnabled = Value
				if Value then
					if Options.PulsarToggle then Options.PulsarToggle:SetValue(false) end
					if Options.NeonToggle then Options.NeonToggle:SetValue(false) end
					self.Library.Theme.PulsarEnabled = false
					self.Library.Theme.NeonEnabled = false
				else
					self.Library.AccentColor = Options.AccentColor.Value
					self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
					self.Library:UpdateColorsUsingRegistry()
				end
			end
		})
		
		groupbox:AddSlider('RGBSpeed', {
			Text = 'RGB Speed',
			Default = 1,
			Min = 0.5,
			Max = 5,
			Rounding = 1,
			Callback = function(Value)
				self.Library.Theme.RGBSpeed = Value
			end
		})
		
		-- Neon Effect
		local NeonToggle = groupbox:AddToggle('NeonToggle', {
			Text = 'Neon Effect',
			Default = false,
			Callback = function(Value)
				self.Library.Theme.NeonEnabled = Value
				if Value then
					if Options.PulsarToggle then Options.PulsarToggle:SetValue(false) end
					if Options.RGBToggle then Options.RGBToggle:SetValue(false) end
					self.Library.Theme.PulsarEnabled = false
					self.Library.Theme.RGBEnabled = false
				else
					self.Library.AccentColor = Options.AccentColor.Value
					self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
					self.Library:UpdateColorsUsingRegistry()
				end
			end
		})
		
		groupbox:AddSlider('NeonIntensity', {
			Text = 'Neon Intensity',
			Default = 0.5,
			Min = 0.1,
			Max = 1,
			Rounding = 1,
			Callback = function(Value)
				self.Library.Theme.NeonIntensity = Value
			end
		})
		
		groupbox:AddButton('Reset Effects', function()
			if Options.PulsarToggle then Options.PulsarToggle:SetValue(false) end
			if Options.RGBToggle then Options.RGBToggle:SetValue(false) end
			if Options.NeonToggle then Options.NeonToggle:SetValue(false) end
			self.Library.Theme.PulsarEnabled = false
			self.Library.Theme.RGBEnabled = false
			self.Library.Theme.NeonEnabled = false
			self.Library.AccentColor = Options.AccentColor.Value
			self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
			self.Library:UpdateColorsUsingRegistry()
			self.Library:Notify('All effects disabled!', 2)
		end)

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_ThemeList and Options.ThemeManager_ThemeList.Value then
				self:SaveDefault(Options.ThemeManager_ThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
			end
		end)

		if Options.ThemeManager_ThemeList then
			Options.ThemeManager_ThemeList:OnChanged(function()
				self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
			end)
		end

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		
		groupbox:AddButton('Save theme', function() 
			if Options.ThemeManager_CustomThemeName and Options.ThemeManager_CustomThemeName.Value then
				self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)
				if Options.ThemeManager_CustomThemeList then
					Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
					Options.ThemeManager_CustomThemeList:SetValue(nil)
				end
			end
		end):AddButton('Load theme', function() 
			if Options.ThemeManager_CustomThemeList and Options.ThemeManager_CustomThemeList.Value then
				self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
			end
		end)

		groupbox:AddButton('Refresh list', function()
			if Options.ThemeManager_CustomThemeList then
				Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
				Options.ThemeManager_CustomThemeList:SetValue(nil)
			end
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList and Options.ThemeManager_CustomThemeList.Value and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		if Options.BackgroundColor then Options.BackgroundColor:OnChanged(UpdateTheme) end
		if Options.MainColor then Options.MainColor:OnChanged(UpdateTheme) end
		if Options.AccentColor then Options.AccentColor:OnChanged(UpdateTheme) end
		if Options.OutlineColor then Options.OutlineColor:OnChanged(UpdateTheme) end
		if Options.FontColor then Options.FontColor:OnChanged(UpdateTheme) end
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			if Options[field] then
				theme[field] = Options[field].Value:ToHex()
			end
		end

		if not isfolder(self.Folder .. '/themes') then
			makefolder(self.Folder .. '/themes')
		end
		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local themesPath = self.Folder .. '/themes'
		if not isfolder(themesPath) then
			makefolder(themesPath)
			return {}
		end
		
		local list = listfiles(themesPath)

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		local parts = {}
		for part in string.gmatch(self.Folder, "[^/\\]+") do
			table.insert(parts, part)
		end
		
		for idx = 1, #parts do
			local path = table.concat(parts, '/', 1, idx)
			table.insert(paths, path)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				local success, err = pcall(makefolder, str)
				if not success then
					warn('Failed to create folder:', str, err)
				end
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
