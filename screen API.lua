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
-- You could also use the below code as a reference to what you can set. 




-- Thinking about a refactor.  
-- 1. Components, everything is a component, every component has basic attributes like sizes... probably not rn
-- 2. IDs, everything has an ID that gets set on creation, and references its children, parents, style by ID

-- 0. Canvas object.  This may contain multiple tables, etc, and makes the whole Update thing less awkward
Component = {}
ComponentDefaults = {X=0,Y=0,Width="100%",Height="100%"}

function Component:new()
    o = {}
	setmetatable(o, self)
	self.__index = self

    for k,v in pairs(ComponentDefaults) do
        o[k] = v
    end
    return o
end

Canvas = Component:new()

function Canvas:new()
    o = Component:new()
    setmetatable(o, self)
	self.__index = self

    o.NeedsUpdate = true
    o.UpdatePosition = 1
    o.UpdateJson = ""
    o.OutputData = ""

    o.RenderedComponents = {} -- This holds everything that was directly added to the Canvas for rendering

    o.Components = {} -- This holds everything ever created; it always adds itself here, where its ID = the key
    -- When sending a Canvas, we pass this as part of it, and everything else uses ints to reference values in this
    return o
end

DefaultCanvas = Canvas:new() -- This will be given to anything created without a specified canvas, and you can set it if you want
-- Or just use it

function Canvas:Update(screen)

	local data = {}
	data.SW = system.getMouseWheel() -- Needs scroll wheel data every frame
	
    if self.NeedsUpdate then
        self.UpdatePosition = 1
        self.UpdateJson = serialize({Components=self.Components, RenderedComponents=self.RenderedComponents})
        self.NeedsUpdate = false
        -- We should also probably iterate all of it to make sure everything that should be linked by an ID, is, in case they set something
        -- But that may be a lot of processing.
        system.print("Sending " .. string.len(self.UpdateJson) .. " chars of data")
    end

    local jsonLength = string.len(self.UpdateJson)
	
    if self.UpdatePosition < jsonLength then
        if self.UpdatePosition == 1 then data.S = 1 end -- Flag start of transmission
        -- We always use some chars for transmission data, and don't have the full 1024 chars to work with
        -- Math said I should have 1006 left, but testing said 921.  TODO: Re-test with new methods
        local numAllowed = 921
        
        if jsonLength - self.UpdatePosition < numAllowed then
            data.T = string.sub(self.UpdateJson, self.UpdatePosition)
            data.F = 1
        else -- Since it's inclusive we take from 1 to 920+1, which is 921 entries
            data.T = string.sub(self.UpdateJson, self.UpdatePosition, self.UpdatePosition+numAllowed-1)
        end
        self.UpdatePosition = self.UpdatePosition + numAllowed
    end

	screen.setScriptInput(serialize(data))
	
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
			if self.OnClick then
				self.OnClick(clickedRow)
			end
		end
	end
end

function Canvas:Get(componentID)
    return self.components[component.ID]
end

function Canvas:Add(component)
    self.RenderedComponents[#self.RenderedComponents+1] = component.ID
end



Column = { Width="20%", Name="", Key=""}

function Column:new(name, width, key, canvas)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.Name = name or ""
	o.Key = key or o.Name
    o.Width = width or "20%"

    local c = canvas or DefaultCanvas
    o.ID = #c.Components+1
    c.Components[o.ID] = o

	return o
end


Style = {}
-- Modifying this sets the defaults when creating a new Style
StyleDefaults = {Visible = true, FillColor="#ADADFF", TextColor="#000", StrokeColor="#FFF", FontName="Play", FontSize=20, BoxRadius = 10, HoverFillColor="#EEE", ClickFillColor="#FFF", MinHeight=0, StrokeWidth=1, PaddingTop = 2, PaddingBottom=2, Wrap=true}
function Style:new(canvas)
    o = {}
	setmetatable(o, self)
	self.__index = self
    -- These need to be fully qualified to defaults
    for k,v in pairs(StyleDefaults) do
        o[k] = v
    end

    local c = canvas or DefaultCanvas
    o.ID = #c.Components+1
    c.Components[o.ID] = o

    return o
end

DefaultStyle = Style:new() -- Modifying this sets the default Style used when creating other components


Row = {}

function Row:new(data, style, parent, canvas)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.Data = data or {}
	o.Children = {}
    if style then o.Style = style.ID else o.Style = DefaultStyle.ID end
    o.Visible = true

	local c = canvas or DefaultCanvas
    o.ID = #c.Components+1
    c.Components[o.ID] = o

	if parent then
		parent.Children[#parent.Children+1] = o.ID
        o.Parent = parent.ID
	end
	return o
end

function Row:AddRow(newRow) 
	self.Children[#self.Children+1] = newRow.ID
    newRow.Parent = self.ID
end

function Row:SetStyle(style)
    o.Style = style.ID
end


-- You should set NeedsUpdate = true whenever you change the data and need it to re-send to the screen
-- It will automatically set this to false once the data has been sent

-- WARNING: ALL References to Rows, Columns, Styles, should be given only via their ID, or using the appropriate functions
Table = {}
TableDefaults = { Type="Table", HeaderStyle = DefaultStyle.ID, ColumnSpacing = 5, RowSpacing = 5, TextPadX = 5, TextPadY = 5, BackgroundColor = "#000", ScrollWidth="5%", ScrollButtonHeight="5%", ScrollActiveColor = "#999", ScrollInactiveColor = "#444", ScrollStrokeColor = "#000", ScrollStrokeWidth = 1, CategoryTabAmount = 20, FreezeTopRows = true}


-- TODO: I can solve the ID requirements by proxying the table.  
-- Basically, what I return to them is a blank table, but has __index and __newindex set
-- These methods then make sure they're setting a number, or pull out the ID for them, before setting the value in something like Table.Values
-- That also means we only add Table.Values to Canvas.Components, not the thing we give to them which has functions in it

-- We'll try it after I see what this current refactor broke

function Table:new(canvas)
	o = Component:new()
	setmetatable(o, self)
	self.__index = self

    o.Columns = {}
    o.Rows = {} -- Copying these from TableDefaults just pointed the reference at them.  I think tables are the only thing this applies to

	for k,v in pairs(TableDefaults) do
        o[k] = v
    end

    local c = canvas or DefaultCanvas
    o.ID = #c.Components+1
    c.Components[o.ID] = o

	return o
end

function Table:SetHeaderStyle(style)
    o.HeaderStyle = style.ID
end

function Table:AddRow(row)
	self.Rows[#self.Rows+1] = row.ID
end

function Table:AddColumns(columns)
    for k,v in pairs(columns) do
        self.Columns[#self.Columns+1] = v.ID
    end
end

function Table:AddColumn(column)
    self.Columns[#self.Columns+1] = column.ID
end






-- You can edit from here on out, this is all example past here




-- Assume we have some RecipeData that we're parsing, a small example export from hyperion, or whatever you're using
local _items1 = {
    {
        FullName = "Shield Generator XS",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "Shield Generators"
    },
    {
        FullName = "Shield Generator S",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "Shield Generators"
    },
    {
        FullName = "Shield Generator M",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "Shield Generators"
    },
    {
        FullName = "Shield Generator L",
        Tier = 3,
        Description = "Shield Generatorsa will protect your constructs from hostile weapon damage until they are depleted. Shield generators can only be deployed on Dynamic Constructs.",
        GroupId = "Shield Generators"
    },
    {
        FullName = "Deep Space Asteroid Tracker",
        Tier = 3,
        Description = "The Deep Space Asteroid Tracker can be used to track and locate minable asteroirds in the System.",
        GroupId = "Asteroid Trackers"
    },
    {
        FullName = "Black Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Dark Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Green Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Ice Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Light Gray Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Military Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Orange Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Purple Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Red Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Sky Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Yellow Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "White Steel Panel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Painted Yellow Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Painted White Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Painted Red Steel",
        Tier = 1,
        Description = "Honeycomb materials are a material type used for construction. They are a lightweight and hollow form of their original material that retain their strength and other properties.",
        GroupId = "Steel"
    },
    {
        FullName = "Advanced Precision Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Rare Precision Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Exotic Precision Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Advanced Agile Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Rare Agile Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Exotic Agile Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Advanced Defense Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Rare Defense Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Exotic Defense Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Advanced Heavy Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Exotic Heavy Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Advanced Precision Railgun S",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    }
}
local _items2 = {
    {
        FullName = "Rare Precision Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Exotic Precision Railgun S",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Rare Heavy Railgun S",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns S"
    },
    {
        FullName = "Exotic Heavy Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Rare Heavy Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Advanced Heavy Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Exotic Defense Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Advanced Precision Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Rare Precision Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Exotic Precision Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Advanced Agile Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Rare Agile Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Agile Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Advanced Defense Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Rare Defense Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Defense Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Heavy Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Advanced Heavy Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Heavy Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Advanced Precision Missile L",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Rare Precision Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Precision Missile L",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Advanced Agile Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Rare Agile Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Exotic Agile Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Advanced Defense Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Rare Defense Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Rare Heavy Missile L",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles L"
    },
    {
        FullName = "Exotic Defense Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Rare Heavy Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Exotic Defense Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Advanced Precision Laser M",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers M"
    },
    {
        FullName = "Rare Precision Laser M",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers M"
    },
    {
        FullName = "Exotic Precision Laser M",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers M"
    },
    {
        FullName = "Advanced Agile Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Rare Agile Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Exotic Agile Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Advanced Defense Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Rare Defense Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Exotic Defense Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Advanced Heavy Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Advanced Heavy Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Exotic Heavy Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Advanced Precision Laser S",
        Tier = 3,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Rare Precision Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Exotic Precision Laser S",
        Tier = 5,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Advanced Agile Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Rare Agile Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Exotic Agile Missile XS",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Advanced Defense Missile XS",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Rare Defense Missile XS",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles XS"
    },
    {
        FullName = "Rare Heavy Laser S",
        Tier = 4,
        Description = "Lasers are a medium-range balanced weapon type capable of producing electromagnetic and thermic damage types.",
        GroupId = "Lasers S"
    },
    {
        FullName = "Advanced Heavy Missile M",
        Tier = 3,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Exotic Heavy Missile M",
        Tier = 5,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Advanced Precision Railgun XS",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns XS"
    },
    {
        FullName = "Rare Precision Railgun XS",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns XS"
    },
    {
        FullName = "Exotic Precision Railgun XS",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns XS"
    },
    {
        FullName = "Advanced Agile Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Rare Agile Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Exotic Agile Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Advanced Defense Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Rare Defense Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Exotic Defense Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Exotic Heavy Railgun XS",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns XS"
    },
    {
        FullName = "Advanced Heavy Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Exotic Heavy Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Advanced Precision Railgun L",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Rare Precision Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Exotic Precision Railgun L",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Advanced Agile Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Rare Agile Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Exotic Agile Railgun M",
        Tier = 5,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Advanced Defense Railgun M",
        Tier = 3,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Rare Defense Railgun M",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns M"
    },
    {
        FullName = "Rare Heavy Railgun L",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns L"
    },
    {
        FullName = "Rare Heavy Missile M",
        Tier = 4,
        Description = "Missile Pods are a close range high-damage weapon type able to fire antimatter and kinetic damage types.",
        GroupId = "Missiles M"
    },
    {
        FullName = "Rare Heavy Railgun XS",
        Tier = 4,
        Description = "Railguns are a long-range weapon type able to fire antimatter and electromagnetic damage types.",
        GroupId = "Railguns XS"
    }
}


rslib = require("rslib")


-- Example usage:
-- This would all go in Unit.Start

-- We are only writing to one screen, so we don't need to define a Canvas.
-- If I wanted to write to a second screen, after setting up the first one, I'd save a `canvas1 = DefaultCanvas`, then `DefaultCanvas = Canvas:new()`
-- After setting up the second canvas, I'd save it as canvas2, then in Update call both canvas1:Update(screen1) and canvas2:Update(screen2)
-- You could also just create a canvas2 and pass it to every creation method, but that's awkward

-- Setup some styles for both tables we're about to create
local headerStyle = Style:new()
headerStyle.BoxRadius = 0
headerStyle.FillColor = "#FFF"
headerStyle.StrokeWidth = 2
headerStyle.FontName = "Play-Bold"
headerStyle.FontSize = 30
headerStyle.StrokeColor = "#000"

TableDefaults.HeaderStyle = headerStyle.ID -- Set this as the default style when making a new table
-- Note that for now you have to just remember to only set IDs, never nest objects, or use the functions (but they don't exist on DefaultTable...)
-- Later I might be able to intercept and fix it and let you do it however

-- Set some more defaults (you could always set these on the table after making it)
TableDefaults.ScrollButtonHeight = "10%"
TableDefaults.Height = "45%"
TableDefaults.ColumnSpacing = 0 -- Keep this 0 so we can 'merge' our category rows
TableDefaults.RowSpacing = 0
TableDefaults.CategoryTabAmount = 40

-- Setup some styles for our rows
local rowStyle = Style:new()
rowStyle.StrokeColor="#000"

local categoryStyle = Style:new()
categoryStyle.FontSize = 25
categoryStyle.FillColor = "#DDFFDD"
categoryStyle.HoverFillColor = "#0F0"
categoryStyle.FontName = "Play-Bold"
categoryStyle.BoxRadius = 0
categoryStyle.StrokeWidth = 0
categoryStyle.PaddingBottom = 2
categoryStyle.Wrap = false



-- Create table
screenTable = Table:new() 
screenTable.Y = "50%"


-- Add our columns
screenTable:AddColumns({
	Column:new("Name", "35%", "FullName"),
	Column:new("Tier", "10%"),
	Column:new("Description", "50%")
})

local groups = {}

-- Dynamically generate 'categories' via GroupId of our data
for k,v in ipairs(_items1) do
	if not groups[v.GroupId] then
		local category = Row:new({FullName=v.GroupId}) -- Create proxy row for category
		category:SetStyle(categoryStyle) -- Set style
		groups[v.GroupId] = category -- Setup map
		screenTable:AddRow(category) -- Add to table
	end
	groups[v.GroupId]:AddRow(Row:new(v, rowStyle)) -- Create and add a new row to mapped category, with data v from _items1, using rowStyle
end

table2 = Table:new() -- Second table, for second set of data

table2:AddColumns({
	Column:new("Name", "35%", "FullName"),
	Column:new("Tier", "10%"),
	Column:new("Description", "50%")
})

groups = {}

for k,v in ipairs(_items2) do
	if not groups[v.GroupId] then
		local category = Row:new({FullName=v.GroupId})
		category:SetStyle(categoryStyle)
		groups[v.GroupId] = category
		table2:AddRow(category)
	end
	groups[v.GroupId]:AddRow(Row:new(v, rowStyle))
end


DefaultCanvas.OnClick = function(clickedRow)
	system.print(clickedRow.Data.FullName)
end

-- Now just add them both to the canvas
DefaultCanvas:Add(screenTable)
DefaultCanvas:Add(table2)
-- Note that each object in the canvas gets its own layer - you should use large, nested objects, because you can only have 8 layers
-- And tables currently use two layers each (can be reduced later)
-- May later add a layer parameter here so you can sort of define them yourself
