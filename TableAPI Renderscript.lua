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

	function tryDeserialize(s)
        local f=load('t='..s)
        if f then
			f()
            return true, t
        else
            return false    
        end
     end
	
	function GetWordWrap(text, font, width)
		if type(text) == "table" then -- We already wrapped it
			return text
		end
		return rslib.getTextWrapped(font, tostring(text), width)
	end
	
	function GetColors(colorString)
		if type(colorString) == "table" then -- We already converted it
			return colorString
		end
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
	
	
	function DrawRow(Table, row, x, y, layer, font, cursorReleased, cursorX, cursorY, tabValue, drawChildren)
		-- Each row now has a Height
		-- Only draw rows that are visible

		if drawChildren == nil then drawChildren = true end
		
		if not tabValue then tabValue = 0 end
		
		if row.Visible then

			local style = Get(row.Style)

			y = y + style.PaddingTop

			-- This is used for freezing rows
			-- Also if it's parents row would fully cover it, don't tag it, wait for the next one

			local firstVisible = false

			if not Table.FirstVisibleRow and y+row.Height > Table.Y + Table.TitleHeight then
				Table.FirstVisibleRow = row -- It's fine to tag if it doesn't have a parent
				firstVisible = true
			end

			-- If this is FirstVisibleRow and it has children, don't draw it, but still increase the Y values and etc

			-- and not (firstVisible and #row.Children > 0)
			if y > Table.Y - row.Height and y < Table.Y + Table.Height then

				local hovered = false
				local clicked = false
			
				-- Check if it was clicked, and if so, pass the data and set colors
				if cursorX >= x and cursorX <= x + Table.Width - Table.ScrollWidth and cursorY >= y and cursorY <= y + row.Height then
					if cursorReleased then
						clicked = true
						-- If Table.OutputRows already contains this row, we don't want to do this again
						-- Which occurs if the frozen one is overtop the regular one
						local skip = false
						for k,v in ipairs(Table.OutputRows) do
							if v.ID == row.ID then
								skip = true
							end
						end

						if not skip then
							local heightChange = 0
							local isVisible = false
							for i=1, #row.Children do
								local child = Get(row.Children[i])
								local childStyle = Get(child.Style)
								local modifier = child.Height + Table.RowSpacing + childStyle.PaddingTop + childStyle.PaddingBottom
								child.Visible = not child.Visible
								if not child.Visible then
									heightChange = heightChange - modifier
								else
									heightChange = heightChange + modifier
								end
							end
							
							Table.TotalHeight = Table.TotalHeight + heightChange
							
							-- Find the column that was clicked
							local colX = Table.X
							local columnKey = ""
							for _,colID in ipairs(Table.Columns) do
								local col = Get(colID)
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
							Table.OutputRows[#Table.OutputRows+1] = row
						end
						--SetOutputRow(row)
					end
					hovered = true
				end
				
				local font = fonts[style.FontName .. style.FontSize] or loadFont(style.FontName, style.FontSize)
				fonts[style.FontName .. style.FontSize] = font
				
				for colNum,columnID in pairs(Table.Columns) do

					local column = Get(columnID)

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
						local colors = style.ClickFillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					elseif hovered then
						local colors = style.HoverFillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					else
						local colors = style.FillColor
						setNextFillColor(layer, colors[1], colors[2], colors[3], colors[4])
					end
					
					local sc = style.StrokeColor
					setNextStrokeColor(layer, sc[1], sc[2], sc[3], sc[4])
					setNextStrokeWidth(layer, style.StrokeWidth)
					
					-- Prevent upper overlap
					local boxY = y
					local boxHeight = height
					if y < Table.Y then 
						boxHeight = boxHeight - (Table.Y-y)
						boxY = Table.Y
					end
					
					-- Draw a Box for each column
					addBoxRounded(layer, x, boxY, width, boxHeight, style.BoxRadius)
					-- Draw text
					
					local tc = style.TextColor
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
			y = y + row.Height + Table.RowSpacing + style.PaddingBottom
			x = Table.X
			if drawChildren then
				tabValue = tabValue + 1
				for _,id in ipairs(row.Children) do
					x,y = DrawRow(Table, Get(id), x, y, layer, font, cursorReleased, cursorX, cursorY,tabValue)
				end
			end
		end
		
		return x,y
	end
	
	function SetRowHeight(Table, row, tabValue, oldData)

		local style = Get(row.Style)

		row.Height = style.MinHeight

		if not tabValue then tabValue = 0 end

		if oldData then
			-- Figure out tabValue for an update
			tabValue = 0
			local parent = row.Parent
			while parent ~= nil do
				local p = Get(parent)
				if p and p.Type == "Table" then
					break
				end
				tabValue = tabValue + 1
				parent = p.Parent -- This could throw if the ID doesn't exist and the Get fails, which should never happen... 
			end
		end
		
		local font = fonts[style.FontName .. style.FontSize] or loadFont(style.FontName, style.FontSize)
		fonts[style.FontName .. style.FontSize] = font
		
		for colNum,columnID in ipairs(Table.Columns) do
			local column = Get(columnID)
			local colKey = column.Key
			if row.Data[colKey] then
				if style.Wrap then
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
		if oldData then
			local oldStyle = style
			if oldData[style.ID] then
				oldStyle = oldData[style.ID]
			end
			Table.TotalHeight = Table.TotalHeight - oldData[row.ID].Height - oldStyle.PaddingTop - oldStyle.PaddingBottom - Table.RowSpacing
		end
		Table.TotalHeight = Table.TotalHeight + row.Height + style.PaddingTop + style.PaddingBottom + Table.RowSpacing
		tabValue = tabValue + 1

		if not oldData then
			for rn,rID in ipairs(row.Children) do
				SetRowHeight(Table, Get(rID), tabValue)
			end
		end
		
		style.FillColor = GetColors(style.FillColor)
		style.TextColor = GetColors(style.TextColor)
		style.StrokeColor = GetColors(style.StrokeColor)
		style.HoverFillColor = GetColors(style.HoverFillColor)
		style.ClickFillColor = GetColors(style.ClickFillColor)

		--Canvas.Components[row.ID] = row
		--Canvas.Components[style.ID] = style
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

	function Get(ID)
		return Canvas.Components[ID]
	end

	function FixColumn(column, Table, titleFont, titleStyle)
		column.Width = GetSizeFromPercent(column.Width, Table.Width) - Table.ColumnSpacing - titleStyle.StrokeWidth
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

	function FixTable(Table)

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
		

		local titleStyle = Get(Table.HeaderStyle)
		local titleFont = fonts[titleStyle.FontName .. titleStyle.FontSize] or loadFont(titleStyle.FontName, titleStyle.FontSize)
		fonts[titleStyle.FontName .. titleStyle.FontSize] = titleFont
		
		titleStyle.FillColor = GetColors(titleStyle.FillColor)
		titleStyle.TextColor = GetColors(titleStyle.TextColor)
		titleStyle.StrokeColor = GetColors(titleStyle.StrokeColor)

		Table.ScrollActiveColor = GetColors(Table.ScrollActiveColor)
		Table.ScrollInactiveColor = GetColors(Table.ScrollInactiveColor)
		Table.ScrollStrokeColor = GetColors(Table.ScrollStrokeColor)
		
		Table.ScrollAmount = 0

		for _, columnID in pairs(Table.Columns) do

			local column = Get(columnID)

			FixColumn(column, Table, titleFont, titleStyle)
		end
		
		Table.TotalHeight = Table.TitleHeight + Table.RowSpacing*2
		
		for rowNum, rowID in ipairs(Table.Rows) do
			SetRowHeight(Table, Get(rowID))
		end
	end

	function GetParentTable(component)
		local parent = component.Parent
		while parent ~= nil do
			local p = Get(parent)
			if p and p.Type == "Table" then
				break
			end
			parent = p.Parent -- This could throw if the ID doesn't exist and the Get fails, which should never happen... 
		end

		return Get(parent)
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

	local success, input = tryDeserialize(TableData)
	
	if input and input.Update and Canvas then
		-- We should already have a Canvas, and we just need to update these components
		for k,v in pairs(input.Update) do
			
			local oldComp = Get(k)
			-- Set values (and values of values? TODO: Make this recursive)
			for k2, v2 in pairs(oldComp) do
				if v[k2] then oldComp[k2] = v[k2] end
			end

			if oldComp.Type == "Row" then
				-- Resizing should be done, but isn't because I can't figure out how to compare newsize to oldsize without deepcopying the old object
				-- Just word wrap data
				for k2, v2 in pairs(oldComp.Data) do
					local style = Get(oldComp.Style)
					local font = fonts[style.FontName .. style.FontSize] or loadFont(style.FontName, style.FontSize)
					fonts[style.FontName .. style.FontSize] = font
					local table = GetParentTable(oldComp)
					-- Jesus fucking christ this is so annoying
					local column = nil
					for k3, v3 in pairs(table.Columns) do
						v3 = Get(v3)
						if v3.Key == k2 then column = v3 break end
					end
					-- And the fucking tab value too, jesus fucking christ why 
					tabValue = 0
					local parent = oldComp.Parent
					while parent ~= nil do
						local p = Get(parent)
						if p and p.Type == "Table" then
							break
						end
						tabValue = tabValue + 1
						parent = p.Parent -- This could throw if the ID doesn't exist and the Get fails, which should never happen... 
					end
					if column then
						oldComp.Data[k2] = GetWordWrap(v2, font, column.Width - tabValue * table.CategoryTabAmount)
					end
					-- And now we would probably compare the number of lines in this WordWrap, vs the number in original
					-- And adjust height accordingly... 
				end
			end
			--Canvas.Components[k] = v
		end
		-- We update them all, then update our calculated values
		--for k,v in pairs(input.Update) do

			-- And then parse everything that needs parsing...
			-- Like rows will need to recalc size, and adjust Table.TotalHeight based on their new size
			-- Columns and rows will need their words wrapped
			-- And tables will need to redo the entire sequence we have below

			-- I don't think FixEtc is going to work right
		--	if v.Type == "Row" then
				-- For a row, we just need to adjust Table.TotalHeight for it, and Row.Height
				-- We can determine its TabValue by how many nested parents it has...

				-- We also need to ensure everything is set before we start adjusting
				-- Because this row may have a new Style update that we wouldn't get until later...

				-- Though also, we need to find its table

		--		local parent = GetParentTable(v)

		--		if parent then
		--			SetRowHeight(parent, v, 0, oldData)
		--		end
		--		logMessage(rslib.toString(v))
		--	elseif v.Type == "Style" then
		--		-- We need to find all rows using this style and recalc their heights
		--		for k2,v2 in ipairs(Canvas.Components) do
		--			if v2.Type == "Row" and v2.Style == v.ID then
		--				local parent = GetParentTable(v2)
		--				SetRowHeight(parent, v2, 0, oldData)
		--			end
		--		end

		--	elseif v.Type == "Table" then
				-- This one's easy, we can just FixTable
		--		FixTable(v)
		--	end

		--end

	elseif input then -- If it's not an update it's a full set
		Canvas = input
		-- Unsure if I want a Type on every component, but for now, Tables have one
		for k,v in ipairs(Canvas.RenderedComponents) do
			local component = Canvas.Components[v]
			if component.Type and component.Type == "Table" then
				local Table = component

				FixTable(Table)
			end
		end
	end
	-- And last, reorder the RenderedComponents, so that the earlier Y values are first
	-- Since that reduces overlap
	if Canvas then
		table.sort(Canvas.RenderedComponents, function(a,b) return Get(a).Y < Get(b).Y end)
	end
	
end

if Canvas then
	for _,TableID in ipairs(Canvas.RenderedComponents) do
		local component = Canvas.Components[TableID]
		if component.Type and component.Type == "Table" then
			local Table = component
		
			
			local layer = createLayer()
			local titleLayer = createLayer()
			Table.layer = layer
			Table.titleLayer = titleLayer
			
			local bc = GetColors(Table.BackgroundColor)
			setBackgroundColor(bc[1],bc[2],bc[3])
			
			local titleStyle = Get(Table.HeaderStyle)

			local titleFont = fonts[titleStyle.FontName .. titleStyle.FontSize] or loadFont(titleStyle.FontName, titleStyle.FontSize)
			fonts[titleStyle.FontName .. titleStyle.FontSize] = titleFont
			
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
			for _,columnID in pairs(Table.Columns) do
				
				local column = Get(columnID)

				local height = Table.TitleHeight
				local width = column.Width
				
				-- The titles are always visible, and use Table.Y
				local tf = titleStyle.FillColor
				setNextFillColor(titleLayer, tf[1], tf[2], tf[3], tf[4]) -- Column headers always a special fill
				local ts = titleStyle.StrokeColor
				setNextStrokeColor(titleLayer, ts[1], ts[2], ts[3], ts[4])
				setNextStrokeWidth(titleLayer, titleStyle.StrokeWidth)
				-- Draw a Box for each column
				addBoxRounded(titleLayer, x, Table.Y, width, height, titleStyle.BoxRadius)
				
				
				-- Draw text
				local txf = titleStyle.TextColor
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

			-- Each table stores a .FirstVisibleRow, tracking the first row that passes the title
			-- And we just always draw the parents of that, if it has them, after drawing all the rest
			Table.FirstVisibleRow = nil
			Table.OutputRows = {} -- This catches things if multiple rows were clicked (with our overlapping frozen rows)

			for _,rowID in pairs(Table.Rows) do
				-- This function iteratively draws each row, and its children, and their children etc
				-- Returns x,y of where to draw the next row
				if y < Table.Y + Table.Height then -- It filters the ones above
					local row = Get(rowID)

					x, y = DrawRow(Table, row, x, y, layer, font, cursorReleased, cursorX, cursorY)
				else
					break -- Stop once we're offscreen
				end
			end
			
			-- Draw frozen rows on top - frozen rows are all parents of Table.FirstVisibleRow

			if Table.FreezeTopRows and Table.FirstVisibleRow then -- If there are no rows, FirstVisibleRow could still be nil
				-- Find all parents of FirstVisibleRow... 
				local parents = {} -- Will be a collection of the IDs
				local parent = Table.FirstVisibleRow.Parent
				while(parent) do
					parents[#parents+1] = parent
					parent = Get(parent).Parent
				end
				-- Also, if it has children, draw itself?  Only if they're visible... TODO: Check if any are visible?  Or assume all match the first?
				if #Table.FirstVisibleRow.Children > 0 and Get(Table.FirstVisibleRow.Children[1]).Visible then
					parents[#parents+1] = Table.FirstVisibleRow.ID
				end

				-- Set y to start drawing these just below the title
				y = Table.Y + Table.TitleHeight + Table.RowSpacing

				-- Iterate in reverse order to draw highest order parents first
				for i=#parents, 1, -1 do
					x,y = DrawRow(Table, Get(parents[i]), x, y, titleLayer, font, cursorReleased, cursorX, cursorY, 0, false) -- This false means don't draw children
				end
			end

			-- Now check Table.OutputRows - if any have children, return that one, otherwise return the first
			-- This ensures we don't trigger things that are underneath the categories if they click a frozen category
			local rowWithChildren = nil
			for k,v in ipairs(Table.OutputRows) do
				if #v.Children > 0 then
					rowWithChildren = v
					break
				end
			end
			if rowWithChildren then SetOutputRow(rowWithChildren) elseif #Table.OutputRows > 0 then SetOutputRow(Table.OutputRows[1]) end
			
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
			
			-- Button at the top
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
			-- Include Scrollstrokes because they extend beyond the usual bounds and it can look awkward when they sortof overlap eachother
			-- Clamp to prevent scrollbar from being large than scrollbar area
			local scrollBarArea = Table.Height - buttonHeight*2 - Table.ScrollStrokeWidth*4
			local scrollHeight = math.min(scrollBarArea * heightPercent, scrollBarArea)
			
			-- And then, figure out how to place it.  
			-- I think we basically place it at scrollPercent*availableSpace-ScrollHeight from the top
			y = Table.Y + buttonHeight + Table.ScrollStrokeWidth*2 + (scrollBarArea - scrollHeight)*scrollPercent
			
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
				
				local newScrollPercent = (cursorY-Table.ScrollOffsetY-buttonHeight-Table.Y)/(scrollBarArea-scrollHeight)
				Table.ScrollAmount = newScrollPercent * (Table.TotalHeight-Table.Height)
			end
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
