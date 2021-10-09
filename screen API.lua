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
	o.Key = key or o.Name
    o.Width = width or "20%"
	return o
end


Row = {Data={}, Children={}, Visible = true, FillColor="#ADADFF", TextColor="#000", StrokeColor="#FFF", FontName="Play", FontSize=20, BoxRadius = 10, HoverFillColor="#EEE", ClickFillColor="#FFF", MinHeight=0, StrokeWidth=1, Padding={Top=2,Bottom=2}, Wrap=true} --Left/right pad don't make sense on a row

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
	o.Padding = self.Padding
	o.Wrap = self.Wrap
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
Table = { Columns = {}, X="0%", Y="0%", Width="100%", Height="100%", Rows = {}, NeedsUpdate = true, UpdatePosition = 1, UpdateJson = "", ColumnSpacing = 5, RowSpacing = 5, TextPadX = 5, TextPadY = 5, BackgroundColor = "#000", HeaderFillColor = "#FFF", HeaderTextColor = "#000", HeaderFontName = "Play-Bold", HeaderFontSize = 30, HeaderRadius = 10, HeaderStrokeColor = "#222", HeaderStrokeWidth=2, OutputData = "", ScrollWidth="5%", ScrollButtonHeight="5%", ScrollActiveColor = "#999", ScrollInactiveColor = "#444", ScrollStrokeColor = "#000", ScrollStrokeWidth = 1, CategoryTabAmount = 20}

function Table:new(name)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.Name = name
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


function UpdateScreenForTables(screen, tables) 
	-- Accepts a table of our Tables
	
	local data = {}
	data.SW = system.getMouseWheel() -- Needs scroll wheel data every frame
	
	local dataFull = false
	for tableName, tableValue in pairs(tables) do
		if tableValue.NeedsUpdate and not dataFull then
			tableValue.UpdatePosition = 1
			tableValue.UpdateJson = serialize(tableValue)
			tableValue.NeedsUpdate = false
		end
		local jsonLength = string.len(tableValue.UpdateJson)
	
		if tableValue.UpdatePosition < jsonLength and not dataFull then
			if tableValue.UpdatePosition == 1 then data.S = 1 system.print(tableValue.Name .. " start") end -- Flag start of transmission
			-- We always use some chars for transmission data, and don't have the full 1024 chars to work with
			-- Math said I should have 1006 left, but testing said 921.
			local numAllowed = 921 - string.len(tableName) - 4
			data.N = tableName
			
			if jsonLength - tableValue.UpdatePosition < numAllowed then
				data.T = string.sub(tableValue.UpdateJson, tableValue.UpdatePosition)
				data.F = 1
				system.print(tableValue.Name .. " done")
			else -- Since it's inclusive we take from 1 to 920+1, which is 921 entries
				data.T = string.sub(tableValue.UpdateJson, tableValue.UpdatePosition, tableValue.UpdatePosition+numAllowed-1)
			end
			tableValue.UpdatePosition = tableValue.UpdatePosition + numAllowed
			dataFull = true -- Only allow one table's json per update
		end
	end
	screen.setScriptInput(serialize(data))
	
	-- TODO: Get data about which table was clicked and call that one's onClick
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
local _items1 = {
    {
        FullName = "Shield Generator XS",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "08d983f2-4c45-4042-837d-73282f0eaffc"
    },
    {
        FullName = "Shield Generator S",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "08d983f2-4c45-4042-837d-73282f0eaffc"
    },
    {
        FullName = "Shield Generator M",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "08d983f2-4c45-4042-837d-73282f0eaffc"
    },
    {
        FullName = "Shield Generator L",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "08d983f2-4c45-4042-837d-73282f0eaffc"
    },
    {
        FullName = "Deep Space Asteroid Tracker",
        Tier = 3,
        Description = "The Deep Space Asteroid Tracker can be used to track and locate minable asteroirds in the System.",
        GroupId = "08d983ea-8716-40ad-8aa8-24e2786fb1a6"
    },
    {
        FullName = "Black Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Dark Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Green Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Ice Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Light Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Military Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Orange Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Purple Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Red Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Sky Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Yellow Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "White Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Painted Yellow Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Painted White Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Painted Red Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "08d8a31f-5093-4a63-8094-82f837fb04f3"
    },
    {
        FullName = "Advanced Precision Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Rare Precision Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Exotic Precision Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Advanced Agile Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Rare Agile Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Exotic Agile Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Advanced Defense Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Rare Defense Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Exotic Defense Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Advanced Heavy Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Exotic Heavy Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Advanced Precision Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    }
}
local _items2 = {
    {
        FullName = "Rare Precision Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Exotic Precision Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Rare Heavy Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f97-48b1-8404-6c28d83f17c6"
    },
    {
        FullName = "Exotic Heavy Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Rare Heavy Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Advanced Heavy Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Exotic Defense Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Advanced Precision Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Rare Precision Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Exotic Precision Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Advanced Agile Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Rare Agile Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Agile Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Advanced Defense Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Rare Defense Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Defense Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Heavy Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Advanced Heavy Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Heavy Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Advanced Precision Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Rare Precision Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Precision Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Advanced Agile Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Rare Agile Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Exotic Agile Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Advanced Defense Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Rare Defense Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Rare Heavy Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f91-4a97-875b-4c3b0238a44e"
    },
    {
        FullName = "Exotic Defense Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Rare Heavy Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Exotic Defense Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Advanced Precision Laser M",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f61-4484-81b6-b3ecf3927f86"
    },
    {
        FullName = "Rare Precision Laser M",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f61-4484-81b6-b3ecf3927f86"
    },
    {
        FullName = "Exotic Precision Laser M",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f61-4484-81b6-b3ecf3927f86"
    },
    {
        FullName = "Advanced Agile Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Rare Agile Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Exotic Agile Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Advanced Defense Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Rare Defense Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Exotic Defense Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Advanced Heavy Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Advanced Heavy Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Exotic Heavy Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Advanced Precision Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Rare Precision Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Exotic Precision Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Advanced Agile Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Rare Agile Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Exotic Agile Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Advanced Defense Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Rare Defense Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f90-418c-8267-cb319724d97c"
    },
    {
        FullName = "Rare Heavy Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "08d8a31f-4f62-42ba-8729-4ac5979dc3b4"
    },
    {
        FullName = "Advanced Heavy Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Exotic Heavy Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Advanced Precision Railgun XS",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
    },
    {
        FullName = "Rare Precision Railgun XS",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
    },
    {
        FullName = "Exotic Precision Railgun XS",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
    },
    {
        FullName = "Advanced Agile Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Rare Agile Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Exotic Agile Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Advanced Defense Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Rare Defense Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Exotic Defense Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Exotic Heavy Railgun XS",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
    },
    {
        FullName = "Advanced Heavy Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Exotic Heavy Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Advanced Precision Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Rare Precision Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Exotic Precision Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Advanced Agile Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Rare Agile Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Exotic Agile Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Advanced Defense Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Rare Defense Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4c89-8e0c-9250ebb84159"
    },
    {
        FullName = "Rare Heavy Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f96-4091-805d-53511d91cd09"
    },
    {
        FullName = "Rare Heavy Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "08d8a31f-4f92-4ba5-88f6-61969b8ccce1"
    },
    {
        FullName = "Rare Heavy Railgun XS",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
    }
}





-- Example usage:
-- This would all go in Unit.Start

-- Set some default values for both tables we're about to create
Table.HeaderRadius = 0
Table.ScrollButtonHeight = "10%"
Table.Height = "45%"
Table.ColumnSpacing = 0 -- Keep this 0 so we can 'merge' our category rows
Table.RowSpacing = 0
Table.CategoryTabAmount = 40

screenTable = Table:new("Table1") -- A unique name, for multi-table support
screenTable.Y = "50%"

-- Set some defaults for our rows to have the appearance of spacing
Row.StrokeColor="#000"

screenTable.Columns = {
	Column:new("Name", "35%", "FullName"),
	Column:new("Tier", "10%"),
	Column:new("Description", "50%")
}

local groups = {}

-- Dynamically generate 'categories' via GroupId of our data
for k,v in ipairs(_items1) do
	if not groups[v.GroupId] then
		local category = Row:new({FullName=v.GroupId})
		category.FontSize = 25
		category.FillColor = "#DDFFDD"
		category.HoverFillColor = "#0F0"
		category.FontName = "Play-Bold"
		category.BoxRadius = 0
		category.StrokeWidth = 0
		category.Padding.Bottom = 2
		groups[v.GroupId] = category
		screenTable:AddRow(category)
	end
	groups[v.GroupId]:AddRow(v)
end

table2 = Table:new("Table2") -- A unique name, for multi-table support

table2.Columns = {
	Column:new("Name", "35%", "FullName"),
	Column:new("Tier", "10%"),
	Column:new("Description", "50%")
}

groups = {}

for k,v in ipairs(_items2) do
	if not groups[v.GroupId] then
		local category = Row:new({FullName=v.GroupId})
		category.FontSize = 25
		category.FillColor = "#DDFFDD"
		category.FontName = "Play-Bold"
		category.StrokeWidth = 0
		category.BoxRadius = 0
		category.HoverFillColor = "#0F0"
		category.Padding.Bottom=2
		groups[v.GroupId] = category
		table2:AddRow(category)
	end
	groups[v.GroupId]:AddRow(v)
end


Table.OnClick = function(self, clickedRow)
	system.print(clickedRow.Data.FullName)
end

Tables = {screenTable, table2}

-- Data looks like this: 
--{
--	FullName = "Rare Heavy Railgun XS",
--	Tier = 4,
--	Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
--	GroupId = "08d8a31f-4f95-4404-84e5-b689b441fd9d"
--}
