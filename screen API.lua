-- Serializer - By Elias Villd and EasternGamer
-- https://github.com/EliasVilld/du-serializer
--Localize functions.
local concat = table.concat
local sFormat=string.format
--For internal iteration, functions slightly different from the ordinary serialize and only returns the counter variable
local function internalSerialize(v,tC,t)
  local check = type(v)
  local intSerial=internalSerialize
  if check=='table' then
    t[tC]='{'
    local tempC=tC+1
    if #v==0 then
      for k,e in pairs(v) do
        if type(k)~='number' then
          t[tempC]=k
          t[tempC+1]='='
          tempC=tempC+2
        else
          t[tempC]='['
          t[tempC+1]=k
          t[tempC+2]=']='
          tempC=tempC+3
        end
        tempC=intSerial(e,tempC,t)
        t[tempC]=','
        tempC=tempC+1
      end
    else
      for k,e in pairs(v) do
        tempC=intSerial(e,tempC,t)
        t[tempC]=','
        tempC=tempC+1
      end
    end
    if tempC==(tC+1) then
      t[tempC]='}'
      return tempC+1
    else
      t[tempC-1]='}'
      return tempC
    end
  elseif check=='string' then
    t[tC]=sFormat("%q",v)
    return tC+1
  elseif check=='number' then
    t[tC]=tostring(v)
    return tC+1
  else
    t[tC]=v and 'true' or 'false'
    return tC+1
  end
  return tC
end
function serialize(v)
    local t={}
    local tC=1
    local check = type(v)
    local intSerial=internalSerialize
    if check=='table' then
        t[tC]='{'
        tC=tC+1
        local tempC=tC
        if #v==0 then
            for k,e in pairs(v) do
              if type(k)~='number' then
                t[tempC]=k
                t[tempC+1]='='
                tempC=tempC+2
              else
                t[tempC]='['
                t[tempC+1]=k
                t[tempC+2]=']='
                tempC=tempC+3
              end
                tempC=intSerial(e,tempC,t)
                t[tempC]=','
                tempC=tempC+1
            end
        else
            for k,e in pairs(v) do
                tempC=intSerial(e,tempC,t)
                t[tempC]=','
                tempC=tempC+1
            end
        end
        if tempC==tC then
            t[tempC]='}'
        else
            t[tempC-1]='}'
        end
    elseif check=='string' then
        t[tC]=sFormat("%q",v)
    elseif check=='number' then
        t[tC]=tostring(v)
    else
        t[tC]=v and 'true' or 'false'
    end

    return concat(t)
end

-- Deserialize a string to a table
function deserialize(s)
    local f=load('t='..s)
    f()
    return t
end




-- Screen Table API
-- By Dimencia



-- DO NOT EDIT anything below, use your own code to set defaults.  I mean, I guess you can.
-- You should also use the below code as a reference to what you can set. 

Column = { Width="20%", Name="", Key=""}

function Column:new(name, width, key)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.Name = name or ""
	o.Key = key or self.Name
    o.Width = width or "20%"
	return o
end


Row = {Data={}, Children={}, Visible = true, FillColor="#ADADFF", TextColor="#000", StrokeColor="#FFF", FontName="Play", FontSize=20, BoxRadius = 10, HoverFillColor="#EEE", ClickFillColor="#FFF", MinHeight=0, StrokeWidth=1}

function Row:new(data, parent)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.Data = data or {}
	o.Children = {}
	o.Visible = self.Visible
	o.TextColor = self.TextColor
	o.FillColor = self.FillColor
	o.StrokeColor = self.StrokeColor
	o.FontName = self.FontName
	o.FontSize = self.FontSize
	o.BoxRadius = self.BoxRadius
	o.HoverFillColor = self.HoverFillColor
	o.ClickFillColor = self.ClickFillColor
	o.MinHeight = self.MinHeight
	o.StrokeWidth = self.StrokeWidth
	if parent then
		parent.Children[#parent.Children+1] = o
	end
	return o
end

function Row:AddRow(data)
	return Row:new(data, self)
end


-- You should set NeedsUpdate = true whenever you change the data and need it to re-send to the screen
-- It will automatically set this to false once the data has been sent

-- Do not modify UpdateJson or UpdatePosition, and make sure Rows and Columns only contain their appropriate types
Table = { Columns = {}, X=0, Y=0, Width="100%", Height="100%", Rows = {}, NeedsUpdate = true, UpdatePosition = 1, UpdateJson = "", ColumnSpacing = 5, RowSpacing = 5, TextPadX = 5, TextPadY = 5, BackgroundColor = "#000", HeaderFillColor = "#FFF", HeaderTextColor = "#000", HeaderFontName = "Play-Bold", HeaderFontSize = 30, HeaderRadius = 10, HeaderStrokeColor = "#222", HeaderStrokeWidth=2, OutputData = "", ScrollWidth="5%", ScrollButtonHeight="5%", ScrollActiveColor = "#999", ScrollInactiveColor = "#444", ScrollStrokeColor = "#000", ScrollStrokeWidth = 1, CategoryTabAmount = 20 }

function Table:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.Columns = {}
	o.X = self.X
	o.Y = self.Y
	o.Width = self.Width
	o.Height = self.Height
	o.Rows = {}
	o.NeedsUpdate = self.NeedsUpdate
	o.UpdatePosition = self.UpdatePosition
	o.UpdateJson = self.UpdateJson
	o.ColumnSpacing = self.ColumnSpacing
	o.RowSpacing = self.RowSpacing
	o.TextPadX = self.TextPadX
	o.TextPadY = self.TextPadY
	o.HeaderFillColor = self.HeaderFillColor
	o.HeaderTextColor = self.HeaderTextColor
	o.HeaderFontName = self.HeaderFontName
	o.HeaderFontSize = self.HeaderFontSize
	o.HeaderRadius = self.HeaderRadius
	o.OutputData = self.OutputData
	o.ScrollWidth = self.ScrollWidth
	o.HeaderStrokeColor = self.HeaderStrokeColor
	o.HeaderStrokeWidth = self.HeaderStrokeWidth
	o.BackgroundColor = self.BackgroundColor
	o.ScrollActiveColor = self.ScrollActiveColor
	o.ScrollInactiveColor = self.ScrollInactiveColor
	o.ScrollStrokeColor = self.ScrollStrokeColor
	o.ScrollStrokeWidth = self.ScrollStrokeWidth
	o.CategoryTabAmount = self.CategoryTabAmount
	o.ScrollButtonHeight = self.ScrollButtonHeight
	return o
end

function Table:AddRow(row)
	self.Rows[#self.Rows+1] = row
end

function Table:Update(screen)
	local data = {}
	data.SW = system.getMouseWheel() -- Needs scroll wheel data every frame
	
	if self.NeedsUpdate then
		self.UpdatePosition = 1
		self.UpdateJson = serialize(self)
		self.NeedsUpdate = false
		data.S = 1 -- Flag start of transmission
	end
	
	local jsonLength = string.len(self.UpdateJson)
	
	if self.UpdatePosition < jsonLength then
		-- We always use some chars for transmission data, and don't have the full 1024 chars to work with
		-- Math said I should have 1006 left, but testing said 921.
		if jsonLength - self.UpdatePosition < 921 then
			data.T = string.sub(self.UpdateJson, self.UpdatePosition)
			data.F = 1
		else -- Since it's inclusive we take from 1 to 920+1, which is 921 entries
			data.T = string.sub(self.UpdateJson, self.UpdatePosition, self.UpdatePosition+920)
		end
		self.UpdatePosition = self.UpdatePosition + 921
	end
	screen.setScriptInput(serialize(data))
	
	-- Now, get the script output and trigger OnClick if it indicates one
	local output = screen.getScriptOutput()	
	if output and output ~= "" then
		local outputData = deserialize(output)
		if outputData.S then
			self.OutputData = ""
		end
		if outputData.T then
			self.OutputData = self.OutputData .. outputData.T
		end
		if outputData.F then
			local clickedRow = deserialize(self.OutputData)
			if Table.OnClick then
				Table.OnClick(self,clickedRow)
			end
		end
	end
end









-- You can edit from here on out, this is all example past here




-- Assume we have some RecipeData that we're parsing, a small example export from hyperion, or whatever you're using
local shields = {
    ["shield_0_1"] = {
        Name = "Shield Generator XS",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 5400,
        Mass = 670
    },
    ["shield_1_1"] = {
        Name = "Shield Generator S",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 21600,
        Mass = 3300
    },
    ["shield_2_1"] = {
        Name = "Shield Generator M",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 86400,
        Mass = 17000
    },
    ["shield_3_1"] = {
        Name = "Shield Generator L",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 345600,
        Mass = 92000
    }
}
local trackers = {
    ["tracker_1_1"] = {
        Name = "Deep Space Asteroid Tracker",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 260928,
        Mass = 115000
    }
}
local voxels = {
    ["hcSteelPanelBlack"] = {
        Name = "Black Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelDarkGray"] = {
        Name = "Dark Gray Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelGray"] = {
        Name = "Gray Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelGreen"] = {
        Name = "Green Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelIce"] = {
        Name = "Ice Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelLightGray"] = {
        Name = "Light Gray Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelMilitary"] = {
        Name = "Military Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelOrange"] = {
        Name = "Orange Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelPurple"] = {
        Name = "Purple Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    },
    ["hcSteelPanelRed"] = {
        Name = "Red Steel Panel",
        BuyPrice = nil,
        SellPrice = nil,
        CraftingTime = 1,
        Mass = 80.5
    }
}




-- Example usage:
-- This would all go in Unit.Start
screenTable = Table:new()

screenTable.BackgroundColor = "#222"

-- The first argument is display name, then width, then the Key Name, which should map to whatever data you're using (i.e. they match the keys in my example data above)

-- Note that by default, the scrollbar takes up 5% of width, so we only have 95% to work with
screenTable.Columns = {
	Column:new("Recipe Name", "45%", "Name"),
	Column:new("Buy Price", "10%", "BuyPrice"),
	Column:new("Sell Price", "10%", "SellPrice"),
	Column:new("Crafting Time", "10%", "CraftingTime"),
	Column:new("Mass", "10%", "Mass"),
	Column:new("Count", "10%", "Count") -- I made this up to show the number of items in each category, just as an example of what you can do with it
}
-- Note that my data structure looks like this:
--["hcSteelPanelRed"] = {
--        Name = "Red Steel Panel",
--        BuyPrice = nil,
--        SellPrice = nil,
--        CraftingTime = 1,
--        Mass = 80.5
--    }

-- Which is where those Keys came from
-- I have my data in vars named `shields`, `trackers`, and `voxels`, just some random components of each type



-- Any row can have parents and children, for your categories
-- So first, we should build a 'category' row

-- Here's a main category.  We mimic the data structure of our columns
-- In this case I'm just setting the first column, which we've defined with the key "Name"
-- And I'm setting the Count column, in this case 3 sub categories.  Purely optional, of course
mainCategory = Row:new({Name="Main",Count=3})
mainCategory.MinHeight = 40
mainCategory.FontSize = 25
mainCategory.FillColor = "#DDFFDD"
mainCategory.FontName = "Play-Bold"
mainCategory.StrokeColor = "#000"

-- Or, you can modify the default Row with these values (and put them back later)
Row.MinHeight = 20
Row.FillColor = "#DDFFDD"
Row.FontName = "Play-Bold"
Row.StrokeColor = "#CCCCCC"

-- Now add some sub-categories, which are again, just rows
shieldCategory = mainCategory:AddRow({Name="Shields",Count=4})
-- Or you could do it like this, both do the same thing
trackersCategory = Row:new({Name="Trackers",Count=1}, mainCategory)
voxelCategory = Row:new({Name="Voxels",Count=10}, mainCategory)



screenTable:AddRow(mainCategory)

-- Let's setup styling for the remaining rows
Row.MinHeight = 0
Row.FillColor = "#ADADFF"
Row.FontName = "Play"
Row.HoverColor = "#AAAAFF"
Row.StrokeColor = "#FFF"

-- The others are already part of mainCategory, and don't need to be added to the table themselves
-- They'll draw if mainCategory is expanded/visible

-- And we add rows directly to those categories/rows
for k,v in pairs(shields) do
	shieldCategory:AddRow(v)
end
for k,v in pairs(trackers) do
	trackersCategory:AddRow(v)
end
for k,v in pairs(voxels) do
	voxelCategory:AddRow(v)
end

-- Now we add an OnClick function for the table
Table.OnClick = function(self, clickedRow)
	-- You now have your clickedRow, which contains clickedRow.Data (what you gave it), as well as clickedRow.Visible and other data
	-- And self is the screenTable that triggered it, in case you need to differentiate
	
	-- So then do whatever you want with that information
	system.print(clickedRow.Data["Name"])
	
	-- Note that it could be a category that they clicked
	if #clickedRow.Children == 0 then
		-- This indicates that it wasn't, do what you want here
	end
	
	-- Also, rows with children (i.e. categories) automatically hide/show those children when clicked
end


--local trackers = {
--    ["tracker_1_1"] = {
--        Name = "Deep Space Asteroid Tracker",
--        BuyPrice = nil,
--        SellPrice = nil,
--        CraftingTime = 260928,
--        Mass = 115000
--    }
--}