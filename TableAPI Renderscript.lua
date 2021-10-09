if not init then
	init = true
	json = require("dkjson")
	utils = require("cpml/utils")
	rslib = require("rslib")
	TableData = ""
	Tables = {}
	NamedTables = {}
	
	OutputJson = ""
	OutputPosition = 1
	
	-- Elias' serializer https://github.com/EliasVilld/du-serializer
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
	
	function GetWordWrap(text, font, width)
		return rslib.getTextWrapped(font, tostring(text), width)
	end
	
	function GetColors(colorString)
		colorString = string.gsub(colorString, "#","")
		colors = {}
		local sl = string.len(colorString)
		if sl == 3 or sl == 4 then
			for i=1,sl do
				local digit = string.sub(colorString,i,i)
				colors[i] = tonumber(digit .. digit,16)/255
			end
			if not colors[4] then
				colors[4] = 1 -- Set alpha if they didn't include it
			end
		elseif sl == 6 or sl == 8 then
			for i=1,sl,2 do
				local digits = string.sub(colorString,i,i+1)
				colors[#colors+1] = tonumber(digits,16)/255
			end
			if not colors[4] then
				colors[4] = 1
			end
		end
		
		return colors
	end
	
	
	function SetOutputRow(row)
		if OutputPosition > string.len(OutputJson) then
			-- Fix the data (put the Data back into strings instead of wordwrapped arrays)
			local newData = {}
			for k,stringArray in pairs(row.Data) do
				if type(stringArray) == "table" then
					newData[k] = ""
					for _,s in ipairs(stringArray) do
						newData[k] = newData[k] .. s
					end
				end
			end
			local oldData = row.Data
			row.Data = newData
			OutputJson = serialize(row)
			row.Data = oldData
			OutputPosition = 1
		end
	end
	
	
	function DrawRow(Table, row, x, y, layer, font, cursorReleased, cursorX, cursorY, tabValue)
		-- Each row now has a Height
		-- Only draw rows that are visible
		
		if not tabValue then tabValue = 0 end
		
		if row.Visible then
		
			-- So, if Table.FreezeTopCategory
		
			-- We need to be checking for children.  
			-- We iterate all rows not being shown yet (row y < Table.Y)
			-- And track the last one that had children
			-- If we draw a child of that category, lock that category up top
			
			-- Which is basically, if TabValue > 0... 
			
			
			-- Even better though, would be to always draw all parent categories of rows being shown
			
			-- So we'd track like a CategoryY and just show rows below them
			-- Or rather, just add them to titleLayer
			
			-- But a lot of that sort of requires knowing what you're showing before you show it... so... TODO later
			
			y = y + row.Padding.Top
			if y > Table.Y - row.Height and y < Table.Y + Table.Height then
				
				
				local hovered = false
				local clicked = false
			
				-- Check if it was clicked, and if so, pass the data and set colors
				if cursorX >= x and cursorX <= x + Table.Width - Table.ScrollWidth and cursorY >= y and cursorY <= y + row.Height then
					if cursorReleased then
						clicked = true
						local heightChange = 0
						local isVisible = false
						for i=1, #row.Children do
							heightChange = heightChange + row.Children[i].Height + Table.RowSpacing + row.Children[i].Padding.Top + row.Children[i].Padding.Bottom
							row.Children[i].Visible = not row.Children[i].Visible
							isVisible = row.Children[i].Visible
						end
						
						-- We also need to reduce the height of the table by the heights of those rows
						if isVisible then
							Table.TotalHeight = Table.TotalHeight + heightChange
						else
							Table.TotalHeight = Table.TotalHeight - heightChange
						end
						-- Find the column that was clicked
						local colX = Table.X
						local columnKey = ""
						for _,col in ipairs(Table.Columns) do
							if cursorX >= colX and cursorX <= colX+col.Width then
								columnKey = col.Key
								break
							end
							colX = colX + col.Width + Table.ColumnSpacing
						end
						
						-- Set some identifying info for them
						row.TableName = Table.Name
						row.ColumnKey = columnKey
						-- And pass it to the output as a click
						SetOutputRow(row)
					end
					hovered = true
				end
				
				
				local font = fonts[row.FontName .. row.FontSize] or loadFont(row.FontName, row.FontSize)
				fonts[row.FontName .. row.FontSize] = font
				
				for colNum,column in pairs(Table.Columns) do
					local height = row.Height
					local width = column.Width
					
					-- So, if Y is < Table.Y, Y should be set to it when drawing the box and height should be adjusted
					-- When drawing text, don't draw if Y < Table.Y, assume the header will hide flickering
					
					if colNum == 1 then  -- Tabbing
						width = column.Width - tabValue*Table.CategoryTabAmount
						x = x + tabValue*Table.CategoryTabAmount
					end
					
					-- Set colors for the box
					if clicked then
						local colors = row.ClickFillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					elseif hovered then
						local colors = row.HoverFillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					else
						local colors = row.FillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					end
					
					local sc = row.StrokeColor
					setNextStrokeColor(layer, sc[1], sc[2], sc[3], sc[4])
					setNextStrokeWidth(layer, row.StrokeWidth)
					
					-- Prevent upper overlap
					local boxY = y
					local boxHeight = height
					if y < Table.Y then 
						boxHeight = boxHeight - (Table.Y-y)
						boxY = Table.Y
					end
					
					-- Draw a Box for each column
					addBoxRounded(layer, x, boxY, width, boxHeight, row.BoxRadius)
					-- Draw text
					
					local tc = row.TextColor
					setDefaultFillColor(layer, Shape_Text, tc[1], tc[2], tc[3], tc[4])
					
					local innerY = y
					if row.Data[column.Key] then
						for _,txt in ipairs(row.Data[column.Key]) do
							local tw, th = getTextBounds(font, txt)
							if innerY > Table.Y then
								addText(layer, font, txt, x + Table.TextPadX, innerY + th + Table.TextPadY)
							end
							innerY = innerY + th + Table.TextPadY
						end
					end
					x = x + width + Table.ColumnSpacing
				end
			end
			y = y + row.Height + Table.RowSpacing + row.Padding.Bottom
			x = Table.X
			tabValue = tabValue + 1
			for _,v in ipairs(row.Children) do
				x,y = DrawRow(Table, v, x, y, layer, font, cursorReleased, cursorX, cursorY,tabValue)
			end
		end
		
		return x,y
	end
	
	function SetRowHeight(Table, row, tabValue)
		row.Height = row.MinHeight
		if not tabValue then tabValue = 0 end
		
		local font = fonts[row.FontName .. row.FontSize] or loadFont(row.FontName, row.FontSize)
		fonts[row.FontName .. row.FontSize] = font
		
		for colNum,column in ipairs(Table.Columns) do
			local colKey = column.Key
			if row.Data[colKey] then
				if row.Wrap then
					if colNum > 1 then -- Only tab the first column
						row.Data[colKey] = GetWordWrap(row.Data[colKey], font, column.Width)
					else
						row.Data[colKey] = GetWordWrap(row.Data[colKey], font, column.Width - tabValue*Table.CategoryTabAmount)
					end
				else
					row.Data[colKey] = {row.Data[colKey]}
				end
				local sectionHeight = 0
				for _,txt in ipairs(row.Data[colKey]) do
					local tw, th = getTextBounds(font, txt)
					th = th + Table.TextPadY*2
					sectionHeight = sectionHeight + th
				end
				if sectionHeight > row.Height then
					row.Height = sectionHeight
				end
			end
		end
		Table.TotalHeight = Table.TotalHeight + row.Height + row.Padding.Top + row.Padding.Bottom + Table.RowSpacing
		tabValue = tabValue + 1
		for rn,r in ipairs(row.Children) do
			row.Children[rn] = SetRowHeight(Table, r, tabValue)
		end
		
		row.FillColor = GetColors(row.FillColor)
		row.TextColor = GetColors(row.TextColor)
		row.StrokeColor = GetColors(row.StrokeColor)
		row.HoverFillColor = GetColors(row.HoverFillColor)
		row.ClickFillColor = GetColors(row.ClickFillColor)
		
		return row
	end
	
	
	-- Ex: GetPercentValue(Table.Height, screenHeight)
	function GetSizeFromPercent(textPercent, scalar)
		if type(textPercent) == "number" then
			-- If it's already a number, use it as-is
			return textPercent
		else
			local subbedWidth, _ = string.gsub(textPercent, "%%", "")
			return (tonumber(subbedWidth)/100) * scalar
		end
	end
end





requestAnimationFrame(1)

fonts = {}

screenWidth, screenHeight = getResolution()


local input = deserialize(getInput())

if input.S then
	TableData = ""
end
if input.T then
	TableData = TableData .. input.T
end
if input.F then
	local Table = deserialize(TableData)
	NamedTables[Table.Name] = Table
	-- Initialization here: Convert all percentages to numbers
	-- And convert all text to wrapped
	Table.RowHeights = {}
	Table.TitleHeight = 0
	
	Table.Width = GetSizeFromPercent(Table.Width, screenWidth)
	Table.Height = GetSizeFromPercent(Table.Height, screenHeight)
	Table.ScrollWidth = GetSizeFromPercent(Table.ScrollWidth,Table.Width)
	Table.ScrollButtonHeight = GetSizeFromPercent(Table.ScrollButtonHeight, Table.Height)
	Table.X = GetSizeFromPercent(Table.X, screenWidth)
	Table.Y = GetSizeFromPercent(Table.Y, screenHeight)
	
	local titleFont = fonts[Table.HeaderFontName .. Table.HeaderFontSize] or loadFont(Table.HeaderFontName, Table.HeaderFontSize)
	fonts[Table.HeaderFontName .. Table.HeaderFontSize] = titleFont
	
	Table.HeaderFillColor = GetColors(Table.HeaderFillColor)
	Table.HeaderTextColor = GetColors(Table.HeaderTextColor)
	Table.ScrollActiveColor = GetColors(Table.ScrollActiveColor)
	Table.ScrollInactiveColor = GetColors(Table.ScrollInactiveColor)
	Table.ScrollStrokeColor = GetColors(Table.ScrollStrokeColor)
	Table.HeaderStrokeColor = GetColors(Table.HeaderStrokeColor)
	
	Table.ScrollAmount = 0
	
	for _, column in pairs(Table.Columns) do

		column.Width = GetSizeFromPercent(column.Width, Table.Width) - Table.ColumnSpacing - Table.HeaderStrokeWidth
		column.Name = GetWordWrap(column.Name, titleFont, column.Width)
		
		local colHeight = 0
		for _,txt in ipairs(column.Name) do
			local tw, th = getTextBounds(titleFont, txt)
			th = th + Table.TextPadY*2
			colHeight = colHeight + th
		end
		
		if colHeight > Table.TitleHeight then
			Table.TitleHeight = colHeight
		end
	end
	
	Table.TotalHeight = Table.TitleHeight + Table.RowSpacing*2
	
	for rowNum, row in ipairs(Table.Rows) do
		Table.Rows[rowNum] = SetRowHeight(Table, row)
	end
	
	-- Rebuild our indexed tables list for ordering
	Tables = {}
	for _,v in pairs(NamedTables) do
		Tables[#Tables+1] = v
	end
	
	-- And last, reorder the Tables table, so that the earlier Y values are first
	-- Since that reduces overlap
	table.sort(Tables, function(a,b) return a.Y < b.Y end)
end

for tableName,Table in ipairs(Tables) do
	if Table then
		
		local layer = createLayer()
		local titleLayer = createLayer()
		Table.layer = layer
		Table.titleLayer = titleLayer
		
		local bc = GetColors(Table.BackgroundColor)
		setBackgroundColor(bc[1],bc[2],bc[3])
		
		local titleFont = fonts[Table.HeaderFontName .. Table.HeaderFontSize] or loadFont(Table.HeaderFontName, Table.HeaderFontSize)
		fonts[Table.HeaderFontName .. Table.HeaderFontSize] = titleFont
		
		-- It gets processed in DrawRow, where we handle clicks

		local cursorX, cursorY = getCursor()
		local cursorReleased = getCursorReleased()
		local cursorDown = getCursorDown()
		
		local maxScroll = Table.TotalHeight-Table.Height
		
		if cursorX >= Table.X and cursorX <= Table.X + Table.Width and cursorY >= Table.Y and cursorY <= Table.Y + Table.Height then
			Table.ScrollAmount = utils.clamp(Table.ScrollAmount + input.SW*-20,0,maxScroll)
		end

		-- Before we draw columns, on that same top level layer
		-- We should add four boxes, full screen size, on all sides of the table
		-- The same color as the background
		-- Note that multiple tables with different backgrounds, really won't work
		-- ... Well, they could.  I guess these will technically do it
		
		-- From bottom left of table to bottom of screen, and right of table
		setNextFillColor(titleLayer, bc[1], bc[2], bc[3], 1)
		addBox(titleLayer, Table.X, Table.Y+Table.Height, Table.Width, screenHeight-(Table.Y+Table.Height))
		
		-- The top no longer overlaps
		-- Doing only the bottom means that as long as the tables are in order of Y, everything works out
		
		---- And then at the top
		--setNextFillColor(titleLayer, bc[1], bc[2], bc[3], 1)
		--addBox(titleLayer, Table.X, 0, Table.Width, Table.Y)
		


		-- Draw the columns
		local x = Table.X
		local y = Table.Y - Table.ScrollAmount
		
			
		-- We have pre-parsed widths to be usable, and texts to be wrapped
		for _,column in pairs(Table.Columns) do
			
			local height = Table.TitleHeight
			local width = column.Width
			
			-- The titles are always visible, and use Table.Y
			local tf = Table.HeaderFillColor
			setNextFillColor(titleLayer, tf[1], tf[2], tf[3], tf[4]) -- Column headers always a special fill
			local ts = Table.HeaderStrokeColor
			setNextStrokeColor(titleLayer, ts[1], ts[2], ts[3], ts[4])
			setNextStrokeWidth(titleLayer, Table.HeaderStrokeWidth)
			-- Draw a Box for each column
			addBoxRounded(titleLayer, x, Table.Y, width, height, Table.HeaderRadius)
			
			
			-- Draw text
			local txf = Table.HeaderTextColor
			setDefaultFillColor(titleLayer, Shape_Text, txf[1], txf[2], txf[3], txf[4])
			local innerY = Table.Y
			for _,txt in ipairs(column.Name) do
				local tw, th = getTextBounds(titleFont, txt)
				addText(titleLayer, titleFont, txt, x + Table.TextPadX, innerY + th + Table.TextPadY)
				innerY = innerY + th + Table.TextPadY
			end
			x = x + width + Table.ColumnSpacing
		end
		y = y + Table.TitleHeight + Table.RowSpacing
		x = Table.X
		
		for _,row in pairs(Table.Rows) do
			-- This function iteratively draws each row, and its children, and their children etc
			-- Returns x,y of where to draw the next row
			if y < Table.Y + Table.Height then
				x, y = DrawRow(Table, row, x, y, layer, font, cursorReleased, cursorX, cursorY)
			else
				break -- Stop once we're offscreen
			end
		end
		
		
		
		-- Draw a scrollbar
		x = Table.X + Table.Width - Table.ScrollWidth
		y = Table.Y
		
		local buttonHeight = Table.ScrollButtonHeight
		
		-- First the background piece
		local sic = Table.ScrollInactiveColor
		setNextFillColor(titleLayer, sic[1], sic[2], sic[3], sic[4])
		local ssc = Table.ScrollStrokeColor
		setNextStrokeColor(titleLayer, ssc[1], ssc[2], ssc[3], ssc[4])
		setNextStrokeWidth(titleLayer, Table.ScrollStrokeWidth)
		
		addBox(titleLayer, x, y, Table.ScrollWidth, Table.Height)
		
		-- Buttons at the top
		local sac = Table.ScrollActiveColor
		setNextFillColor(titleLayer, sac[1], sac[2], sac[3], sac[4])
		setNextStrokeColor(titleLayer, ssc[1], ssc[2], ssc[3], ssc[4])
		setNextStrokeWidth(titleLayer, Table.ScrollStrokeWidth)
		
		addBox(titleLayer, x, y, Table.ScrollWidth, buttonHeight)
		
		-- And bottom
		setNextFillColor(titleLayer, sac[1], sac[2], sac[3], sac[4])
		setNextStrokeColor(titleLayer, ssc[1], ssc[2], ssc[3], ssc[4])
		setNextStrokeWidth(titleLayer, Table.ScrollStrokeWidth)
		
		addBox(titleLayer, x, Table.Y+Table.Height-buttonHeight, Table.ScrollWidth, buttonHeight)
		
		-- Now make a bar
		setNextFillColor(titleLayer, sac[1], sac[2], sac[3], sac[4])
		setNextStrokeColor(titleLayer, ssc[1], ssc[2], ssc[3], ssc[4])
		setNextStrokeWidth(titleLayer, Table.ScrollStrokeWidth)
		-- Determine bar size.  This is hard.
		-- We need to know how many 'pages' there are, or rather
		-- First need to know the total height of the table with all rows (Table.TotalHeight)
		-- Then compare our current ScrollAmount (which is in pixels) to that height
		
		-- maxScroll defined earlier
		local scrollPercent = Table.ScrollAmount/maxScroll
		
		-- Then, we need to figure out what percentage the bar is...
		-- Which is related to the ratio of TotalHeight/screenHeight.  In fact, just 1/TotalHeight/screenHeight should do it
		
		
		local heightPercent = 1 / (Table.TotalHeight/Table.Height)
		local scrollHeight = (Table.Height - buttonHeight*2) * heightPercent
		
		-- And then, figure out how to place it.  
		-- I think we basically place it at scrollPercent*availableSpace-ScrollHeight from the top
		y = Table.Y + buttonHeight + (Table.Height - buttonHeight*2 - scrollHeight)*scrollPercent
		
		addBox(titleLayer, x, y, Table.ScrollWidth, scrollHeight)
		
		-- And, check for clicks and drags
		--local cursorX, cursorY = getCursor()
		--local cursorReleased = getCursorReleased()
		
		if cursorX >= x and cursorX <= screenWidth then
			if cursorY >= y and cursorY <= y + scrollHeight then
				-- The bar itself is being hovered
				
				if getCursorPressed() then -- Should this be changed to cursorDown?
					Table.ScrollDragging = true
					Table.ScrollOffsetX = cursorX - x
					Table.ScrollOffsetY = cursorY - y
				end
			elseif cursorY >= Table.Y and cursorY <= Table.Y+buttonHeight then
				-- Hovering the up button
				if cursorDown then -- cursorDown lets it re-trigger if you hold it
					Table.ScrollAmount = utils.clamp(Table.ScrollAmount-20,0,maxScroll)
				end
			elseif cursorY >= Table.Y+Table.Height-buttonHeight and cursorY <= Table.Y+Table.Height then
				-- Hovering the down button
				if cursorDown then
					Table.ScrollAmount = utils.clamp(Table.ScrollAmount+20,0,maxScroll)
				end
			elseif cursorY >= Table.Y and cursorY <= Table.Y + Table.Height then
				-- Somewhere on the inactive part of the bar, the elses filter the rest
				-- Use the same logic as when dragging to determine where to put it
				if cursorDown then
					Table.ScrollDragging = true
					Table.ScrollOffsetX = Table.ScrollWidth/2
					Table.ScrollOffsetY = scrollHeight/2
				end
			end
		end
		
		if not cursorDown then
			Table.ScrollDragging = false
		end
		
		-- Don't use off-screen -1's
		if Table.ScrollDragging and cursorX ~= -1 and cursorY ~= -1 and cursorY > Table.Y + buttonHeight and cursorY < Table.Y + Table.Height - buttonHeight then
			-- Figure out what ScrollPercent or Amount we'd be at if we moved the bar to their offset cursor
			
			-- so ScrollOffsetY is probably negative, let's say -50 if we're 50 units below the top of the bar
			-- cursorY + ScrollOffsetY should get us to where the bar's top should be
			
			
			
			--y = Table.Y + buttonHeight + (screenHeight - buttonHeight*2 - scrollHeight)*scrollPercent
			
			local newScrollPercent = (cursorY-Table.ScrollOffsetY-buttonHeight-Table.Y)/(Table.Height-buttonHeight*2-scrollHeight)
			Table.ScrollAmount = newScrollPercent * (Table.TotalHeight-Table.Height)
		end
		
	end
end

local jsonLength = string.len(OutputJson)
if OutputPosition < jsonLength then
	data = {}
	if OutputPosition == 1 then
		data.S = 1
	end
	
	if jsonLength - OutputPosition < 950 then -- Being inclusive makes this weird
		data.T = string.sub(OutputJson, OutputPosition)
		data.F = 1
	else -- Since it's inclusive we take from 1 to 1005+1, which is 1006 entries
		data.T = string.sub(OutputJson, OutputPosition, OutputPosition+949)
	end
	OutputPosition = OutputPosition + 950
	
	setOutput(serialize(data))
else
	setOutput("")
end
