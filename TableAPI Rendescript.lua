if not init then
	init = true
	json = require("dkjson")
	utils = require("cpml/utils")
	rslib = require("rslib")
	TableData = ""
	Table = nil
	ScrollAmount = 0
	
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
		-- Returns an array of strings
		
		-- So... basically, recursively...
		-- 1. Measure if string fits in width
		-- 2. If not, split string in half and remeasure both
		-- 3. Repeat, splitting each in half until it fits
		
		-- Also, we should try to split on spaces or dashes
		-- Which would involve marking the position of each space and dash
		-- And then picking the one closest to the center when we split
		
		local w,h = getTextBounds(font, text)
		w = w + Table.TextPadX*2
		if w > width then
			-- Find all spaces and dashes to try to split on
			local splitPositions = {}
			for i = 1, #text do
				local val = string.sub(text, i, i)
				if val == " " or val == "-" then
					splitPositions[#splitPositions+1] = i
				end
			end
			
			local textMid = math.floor(string.len(text)/2)
			local nearest = textMid
			
			if #splitPositions > 0 then
				nearest = splitPositions[1]
				local nearestDiff = math.abs(splitPositions[1]-textMid)
				for _,v in ipairs(splitPositions) do
					local ad = math.abs(v-textMid)
					if ad < nearestDiff then
						nearest = v
						nearestDiff = ad
					end
				end
				-- Construct the new strings
				local firstHalf = string.sub(text, 1, nearest-1)
				local secondHalf = string.sub(text, nearest+1)
				
				firstHalf = GetWordWrap(firstHalf, font, width)
				secondHalf = GetWordWrap(secondHalf, font, width)
				local result = {}
				for _,v in ipairs(firstHalf) do
					result[#result+1] = v
				end
				for _,v in ipairs(secondHalf) do
					result[#result+1] = v
				end
				return result
			else
				-- There are no dashes or spaces, just split on the center and add one
				local firstHalf = string.sub(text, 1, textMid-1)
				local secondHalf = string.sub(text, textMid)
				
				firstHalf = GetWordWrap(firstHalf, font, width)
				secondHalf = GetWordWrap(secondHalf, font, width)
				local result = {}
				for _,v in ipairs(firstHalf) do
					result[#result+1] = v
				end
				for _,v in ipairs(secondHalf) do
					result[#result+1] = v
				end
				return result
			end
		else
			return {text}
		end
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
				newData[k] = ""
				for _,s in ipairs(stringArray) do
					newData[k] = newData[k] .. s
				end
			end
			local oldData = row.Data
			row.Data = newData
			OutputJson = serialize(row)
			row.Data = oldData
			OutputPosition = 1
		end
	end
	
	
	function DrawRow(row, x, y, layer, font, cursorReleased, cursorX, cursorY, tabValue)
		-- Each row now has a Height
		-- Only draw rows that are visible
		
		if not tabValue then tabValue = 0 end
		
		if row.Visible then
			if y > Table.Y - row.Height and y < screenHeight then
			
				local hovered = false
				local clicked = false
			
				-- Check if it was clicked, and if so, pass the data and set colors
				if cursorX >= x and cursorX <= x + Table.Width - Table.ScrollWidth and cursorY >= y and cursorY <= y + row.Height then
					if cursorReleased then
						clicked = true
						AnyRowsClicked = true -- Ugly but it works
						for i=1, #row.Children do
							row.Children[i].Visible = not row.Children[i].Visible
						end
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
					
					-- Draw a Box for each column
					addBoxRounded(layer, x, y, width, height, row.BoxRadius)
					-- Draw text
					
					local tc = row.TextColor
					setNextFillColor(layer, tc[1], tc[2], tc[3], tc[4])
					
					local innerY = y
					if row.Data[column.Key] then
						for _,txt in ipairs(row.Data[column.Key]) do
							local tw, th = getTextBounds(font, txt)
							addText(layer, font, txt, x + Table.TextPadX, innerY + th + Table.TextPadY)
							innerY = innerY + th + Table.TextPadY
						end
					end
					x = x + width + Table.ColumnSpacing
				end
			end
			y = y + row.Height + Table.RowSpacing
			x = Table.X
			tabValue = tabValue + 1
			for _,v in ipairs(row.Children) do
				x,y = DrawRow(v, x, y, layer, font, cursorReleased, cursorX, cursorY, tabValue)
			end
		end
		
		return x,y
	end
	
	function SetRowHeight(row, tabValue)
		row.Height = row.MinHeight
		if not tabValue then tabValue = 0 end
		
		local font = fonts[row.FontName .. row.FontSize] or loadFont(row.FontName, row.FontSize)
		fonts[row.FontName .. row.FontSize] = font
		
		for colNum,column in ipairs(Table.Columns) do
			local colName = column.Key
			if row.Data[colName] then
				if colNum > 1 then -- Only tab the first column
					row.Data[colName] = GetWordWrap(row.Data[colName], font, column.Width)
				else
					row.Data[colName] = GetWordWrap(row.Data[colName], font, column.Width - tabValue*Table.CategoryTabAmount)
				end
				local sectionHeight = 0
				for _,txt in ipairs(row.Data[colName]) do
					local tw, th = getTextBounds(font, txt)
					th = th + Table.TextPadY*2
					sectionHeight = sectionHeight + th
				end
				if sectionHeight > row.Height then
					row.Height = sectionHeight
				end
			end
		end
		Table.TotalHeight = Table.TotalHeight + row.Height
		tabValue = tabValue + 1
		for rn,r in ipairs(row.Children) do
			row.Children[rn] = SetRowHeight(r, tabValue)
		end
		
		row.FillColor = GetColors(row.FillColor)
		row.TextColor = GetColors(row.TextColor)
		row.StrokeColor = GetColors(row.StrokeColor)
		row.HoverFillColor = GetColors(row.HoverFillColor)
		row.ClickFillColor = GetColors(row.ClickFillColor)
		
		return row
	end
end




requestAnimationFrame(1)

layer = createLayer()
titleLayer = createLayer()

fonts = {}

setDefaultFillColor(layer, Shape_Text, 0, 0, 0, 1) -- Black text
setDefaultStrokeColor(layer, Shape_Text, 0,0,0,1) -- What is this like if you change it?
setDefaultStrokeColor(layer, Shape_BoxRounded, 1,1,1,1) -- White border
setDefaultFillColor(layer, Shape_BoxRounded, 150/255, 150/255, 200/255, 1) -- Grey boxes

setDefaultFillColor(titleLayer, Shape_Text, 0, 0, 0, 1) -- Black text
setDefaultStrokeColor(titleLayer, Shape_Text, 0,0,0,1) -- What is this like if you change it?
setDefaultStrokeColor(titleLayer, Shape_BoxRounded, 1,1,1,1) -- White border
setDefaultFillColor(titleLayer, Shape_BoxRounded, 150/255, 150/255, 200/255, 1) -- Grey boxes

screenWidth, screenHeight = getResolution()


local input = deserialize(getInput())

if input.S then
	TableData = ""
end
if input.T then
	TableData = TableData .. input.T
end
if input.F then
	Table = deserialize(TableData)
	-- Initialization here: Convert all percentages to numbers
	-- And convert all text to wrapped
	Table.RowHeights = {}
	Table.TitleHeight = 0
	
	local subbedTableWidth, _ = string.gsub(Table.Width, "%%", "")
	local tableWidthPercent = tonumber(subbedTableWidth)/100
	Table.Width = screenWidth * tableWidthPercent
	
	local subbedTableHeight, _ = string.gsub(Table.Height, "%%", "")
	local tableHeightPercent = tonumber(subbedTableHeight)/100
	Table.Height = screenHeight * tableHeightPercent
	
	local subbedScrollWidth, _ = string.gsub(Table.ScrollWidth, "%%", "")
	local scrollWidthPercent = tonumber(subbedScrollWidth)/100
	Table.ScrollWidth = screenWidth * tableWidthPercent * scrollWidthPercent
	
	local subbedScrollHeight, _ = string.gsub(Table.ScrollButtonHeight, "%%", "")
	local scrollHeightPercent = tonumber(subbedScrollHeight)/100
	Table.ScrollButtonHeight = screenHeight * tableHeightPercent * scrollHeightPercent
	
	titleFont = loadFont(Table.HeaderFontName, Table.HeaderFontSize)
	
	Table.HeaderFillColor = GetColors(Table.HeaderFillColor)
	Table.HeaderTextColor = GetColors(Table.HeaderTextColor)
	Table.ScrollActiveColor = GetColors(Table.ScrollActiveColor)
	Table.ScrollInactiveColor = GetColors(Table.ScrollInactiveColor)
	Table.ScrollStrokeColor = GetColors(Table.ScrollStrokeColor)
	Table.HeaderStrokeColor = GetColors(Table.HeaderStrokeColor)
	
	for _, column in pairs(Table.Columns) do
		local subbedColWidth, _ = string.gsub(column.Width, "%%", "")
		
		local colWidthPercent = tonumber(subbedColWidth)/100
		local width = screenWidth * tableWidthPercent * colWidthPercent - Table.ColumnSpacing
		column.Width = width
		
		column.Name = GetWordWrap(column.Name, titleFont, width)
		
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
	
	Table.TotalHeight = Table.TitleHeight
	
	for rowNum, row in ipairs(Table.Rows) do
		Table.Rows[rowNum] = SetRowHeight(row)
	end
	
end



if Table then
	
	local bc = GetColors(Table.BackgroundColor)
	setBackgroundColor(bc[1],bc[2],bc[3])
	
	titleFont = loadFont(Table.HeaderFontName, Table.HeaderFontSize)
	
	AnyRowsClicked = false -- If none are clicked, we clear our output at the end
	-- It gets processed in DrawRow, where we handle clicks

	local cursorX, cursorY = getCursor()
	local cursorReleased = getCursorReleased()
	
	ScrollAmount = utils.clamp(ScrollAmount + input.SW*-20,0,Table.TotalHeight-screenHeight+Table.TitleHeight)

	-- Draw the columns
	local x = Table.X
	local y = Table.Y - ScrollAmount
	
		
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
		addBoxRounded(titleLayer, x, Table.Y, width, height, 10)
		
		
		-- Draw text
		local txf = Table.HeaderTextColor
		setNextFillColor(titleLayer, txf[1], txf[2], txf[3], txf[4])
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
		if y < screenHeight then
			x, y = DrawRow(row, x, y, layer, font, cursorReleased, cursorX, cursorY)
		else
			break -- Stop once we're offscreen
		end
	end
	
	--if not AnyRowsClicked then
	--	setOutput("")
	--end
	
	
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
	
	addBox(titleLayer, x, y, Table.ScrollWidth, screenHeight)
	
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
	
	addBox(titleLayer, x, Table.Y+screenHeight-buttonHeight, Table.ScrollWidth, buttonHeight)
	
	-- Now make a bar
	setNextFillColor(titleLayer, sac[1], sac[2], sac[3], sac[4])
	setNextStrokeColor(titleLayer, ssc[1], ssc[2], ssc[3], ssc[4])
	setNextStrokeWidth(titleLayer, Table.ScrollStrokeWidth)
	-- Determine bar size.  This is hard.
	-- We need to know how many 'pages' there are, or rather
	-- First need to know the total height of the table with all rows (Table.TotalHeight)
	-- Then compare our current ScrollAmount (which is in pixels) to that height
	
	-- This weird math is how much we can actually scroll without scrolling past the edge of table
	-- I don't quite understand how TitleHeight is involved, it's already part of TotalHeight
	-- But this is what works
	local scrollPercent = ScrollAmount/(Table.TotalHeight-screenHeight+Table.TitleHeight)
	-- As for the size of the bar, it is related to the amount of screens we can fit
	-- If only 1 screen, i.e. TotalHeight+TitleHeight-screenHeight == 0, it is 100% 
	-- If 2 screens, ie all that == screenHeight*2, it is 50%
	
	-- So the height% = 1 - (TotalHeight+TitleHeight-screenHeight)/screenHeight
	local heightPercent = 1 - (Table.TotalHeight+Table.TitleHeight-screenHeight)/screenHeight
	local scrollHeight = (screenHeight - buttonHeight*2) * heightPercent
	
	-- And then, figure out how to place it.  
	-- I think we basically place it at scrollPercent*availableSpace-ScrollHeight from the top
	y = Table.Y + buttonHeight + (screenHeight - buttonHeight*2 - scrollHeight)*scrollPercent
	
	addBox(titleLayer, x, y, Table.ScrollWidth, scrollHeight)
	
	-- And, check for clicks and drags
	--local cursorX, cursorY = getCursor()
	--local cursorReleased = getCursorReleased()
	
	if cursorX >= x and cursorX <= screenWidth and cursorY >= y and cursorY <= y + scrollHeight then
		-- The bar itself is being hovered
		
		if getCursorPressed() then
			ScrollDragging = true
			ScrollOffsetX = cursorX - x
			ScrollOffsetY = cursorY - y
		end
	end
	
	if cursorReleased then
		ScrollDragging = false
	end
	
	if ScrollDragging then
		-- Figure out what ScrollPercent or Amount we'd be at if we moved the bar to their offset cursor
		
		-- so ScrollOffsetY is probably negative, let's say -50 if we're 50 units below the top of the bar
		-- cursorY + ScrollOffsetY should get us to where the bar's top should be
		
		
		
		--y = Table.Y + buttonHeight + (screenHeight - buttonHeight*2 - scrollHeight)*scrollPercent
		
		local newScrollPercent = (cursorY-ScrollOffsetY-buttonHeight)/(Table.Y+screenHeight-buttonHeight*2-scrollHeight)
		ScrollAmount = newScrollPercent * (Table.TotalHeight-screenHeight+Table.TitleHeight)
	end
	
end

local jsonLength = string.len(OutputJson)
if OutputPosition < jsonLength then
	data = {}
	if OutputPosition == 1 then
		data.S = 1
	end
	
	if jsonLength - OutputPosition < 1000 then -- Being inclusive makes this weird
		data.T = string.sub(OutputJson, OutputPosition)
		data.F = 1
	else -- Since it's inclusive we take from 1 to 1005+1, which is 1006 entries
		data.T = string.sub(OutputJson, OutputPosition, OutputPosition+999)
	end
	OutputPosition = OutputPosition + 1000
	
	setOutput(serialize(data))
else
	setOutput("")
end