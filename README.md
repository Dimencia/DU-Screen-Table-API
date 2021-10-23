# DU-Screen-Table-API

A library allowing easy creation of tables to be displayed on screens, using the new DU screen API


# Basic Usage Instructions

1. Copy the contents of `screen API.lua` to Unit.Start.  It includes examples at the end - remove these if making your own table
2. Copy the contents of `TableAPIRenderscript.lua` to the screen you wish to use
3. Add this line to System.Update: `DefaultCanvas:Update(screen)`, where `screen` is the screen's slot (even if using only one Table, put it into a lua table for this function).  You don't have to use the DefaultCanvas, but if you have only one screen, it is easiest

## Creating Tables

Check the end of `screen API.lua` for an example of constructing tables, categories, and rows

More info coming soon

## Defaults

You can change any of these variables on an instance.  You can change the defaults when initializing a new instance by editing the static `TableDefaults` or `StyleDefaults`.  You can set the default Style or Canvas to use for new instances by setting `DefaultStyle` and `DefaultCanvas` to the style or canvas you want


## Canvas

The Canvas is a new wrapper object meant to encapsulate the contents of one Screen.  You may add multiple Tables to a Canvas (currently only Tables are supported).  
This new implementation allows us to use an ID system, greatly reducing the amount of characters transmitted to the screen

If you are only writing to one screen, you can ignore this - it creates and uses a `DefaultCanvas` for everything by default.  If you wish to write to multiple screens, create and setup two `Canvas` objects, and either set them into `DefaultCanvas` while you write on each one, or pass them as arguments when creating other objects

### Variables

`Canvas.NeedsUpdate` - (bool) Default: True - Indicates Table data has been changed and should be sent to the screen.  Set this to True after modifying data.  If this is true, it is still sending the previous data, and your implementation should wait until it's false before triggering it again

`DefaultCanvas` - (Canvas) Default: New Canvas - This is the Canvas used if you create an object without specifying a Canvas.  You may set this to the Canvas you are currently building so that newly created Tables, Rows, etc are all tied to this Canvas.  

### Functions

`Canvas:new()` - Creates a new Canvas.  The canvas can be passed into any constructor, or set into `DefaultCanvas` so that all new objects are part of the Canvas

`yourCanvas:Update(screen)` - Meant to be called in System.Update, updates the screen with mousewheel information.  If Canvas.NeedsUpdate is true, also sends updated table data

`yourCanvas:Add(component)` - Adds `component` to the Canvas's list of `RenderedComponents`.  If you wish to add this manually, be sure you add the ID of the component, not the component itself

`yourCanvas:Get(componentID)` - Gets a component from the given `componentID`.  Equivalent to `yourCanvas.Components[componentID]`

## Style

The Style is another new object that helps reduce information transmission.  Rather than sending a full set of Style data with every row, you simply create a Style once, and then the row references that Style by ID

Be careful not to set row.Style = someStyle; always use the function `Row:SetStyle`, or set `row.Style = someStyle.ID` directly

Currently only a Row and Table.HeaderStyle can accept a Style, but others may use Styles later

### Variables

`ID` - (Number) Default: ? - A unique ID that is assigned upon creation.  This can be used with `yourCanvas:get` to retrieve the object if you have only the ID

`DefaultStyle` - (Style) Default: StyleDefaults - All new non-Style objects created that can accept a Style will use this Style by default.  You may set this to the Style of your choice so that new objects have it automatically.  

`StyleDefaults` - (Style) Default: See Below - All new Style objects created will use these values.  This variable may be modified so that new Styles have your values automatically

`TextColor` - (hex string) Default: "#000" - The color of text for this object

`FillColor` - (hex string) Default: "#ADADFF" - The color of the background for this object

`StrokeColor` - (hex string) Default: "#FFF" - The color of the stroke around the background box for this object

`StrokeWidth` - (number) Default: 1 - The width of the stroke around the background box for this object

`FontName` - (string) Default: "Play" - The name of the font to use in this object.  See [Valid Fonts] below

`FontSize` - (number) Default: 20 - The size of the font to use in this object

`BoxRadius` - (number) Default: 10 - The radius of the curve on the Rounded Box for the object - 0 for square edges

`HoverFillColor` - (hex string) Default: "#EEE" - The color of the background for this row when hovered over

`ClickFillColor` - (hex string) Default: "#FFF" - The color of the background for this row on the tick that it is clicked

`MinHeight` - (number) Default: 0 - The minimum height for this row (if the contents are not this tall, it will be this tall anyway)

`Padding` - (table) Default: Top=2,Bottom=2 - Padding to apply between this row and adjacent ones

`Wrap` - (bool) Default: True - Whether or not to wrap text in this row (useful for 'merged' categories)



## Column
### Variables

`ID` - (Number) Default: ? - A unique ID that is assigned upon creation.  This can be used with `yourCanvas:get` to retrieve the object if you have only the ID

`Name` - (string) The display name of the column

`Width` - (string/percent) Default: "20%" The width, in percent of table size, of the column

`Key` - (any) The key, used in row.Data[key], to identify the data to display in this column


## Row
### Variables

`ID` - (Number) Default: ? - A unique ID that is assigned upon creation.  This can be used with `yourCanvas:get` to retrieve the object if you have only the ID

`Visible` - (bool) Default: True -  Whether or not to display this row when drawing

`Data` - (key/value pairs) Default: {} - The data used in the row, where the keys match the keys of Columns in the Table


### Functions

`Row:new(data, parent)` - Creates a new row, where `data` is a table whose keys map to Columns you have defined.  Ex: `Row:new({Name="Main"})`, assuming you have a column with key `"Main"`.  A parent row can be passed, so that childrens row can be collapsed/expanded when the parent is clicked.  This row inherits all attributes from the static Row object at time of creation

`someRow:AddRow(data)` - Creates and adds a new row to the specified parent row `someRow` with the specified data.  A shortcut for Row:new

`someRow:SetStyle(style)` - Sets the Style of a Row.  Be sure to use this function - if you wish to set the Style directly, set `someRow.Style = style.ID`

## Table
### Variables

`ID` - (Number) Default: ? - A unique ID that is assigned upon creation.  This can be used with `yourCanvas:get` to retrieve the object if you have only the ID

`X` - (number) Default: 0 - The X coordinate on the screen for where the top-left of the table should begin

`Y` - (number) Default: 0 - The Y coordinate on the screen for where the top-left of the table should begin

`Width` - (string/percent) Default: "100%" - The width of the table, in percentage of screen width

`Height` - (string/percent) Default: "100%" - The height of the table, in percentage of screen height

`ColumnSpacing` - (number) Default: 5 - Number of pixels between all columns (horizontally)

`RowSpacing` - (number) Default: 5 - Number of pixels between all rows (vertically)

`TextPadX` - (number) Default: 5 - Number of pixels between text and the edges of the cells (horizontally)

`TextPadY` - (number) Default: 5 - Number of pixels between text and the edges of cells (vertically)

`BackgroundColor` - (hex string) Default: "#000" - Background color of the screen on which the table is drawn

`HeaderStyle` - (hex string) Default: Default Style - The Style to use for the Table Header

`ScrollWidth` - (string/percent) Default: "5%" - The width of the scrollbar in percentage of table width

`ScrollActiveColor` - (hex string) Default: "#999" - The color of the active parts of the scrollbar (the buttons and bar itself)

`ScrollInactiveColor` - (hex string) Default: "#444" - The color of the inactive parts of the scrollbar (the background)

`ScrollStrokeColor` - (hex string) Default: "#000" - The color of the outline around the scrollbar and buttons

`ScrollStrokeWidth` - (number) Default: 1 - The width of the outline around the scrollbar and buttons

`ScrollButtonHeight` - (string/percent) Default: "5%" - The height of the top/bottom scroll buttons on the scrollbar, in percentage of table height

`CategoryTabAmount` - (number) Default: 20 - The number of pixels to indent the first column of each row beneath a category (stacks for multiple sub-categories)


### Functions

`Table:new()` - Creates a new instance of Table, with default values referenced from the static Table object

`yourTable:Update(screen)` - Intended to be called from within System.Update or a Timer Tick, this function sends information to the screen's input about the mousewheel state, and sends table data if `yourTable.NeedsUpdate` is true

`yourTable:SetHeaderStyle(style)` - Sets the Style of the Table.  If you wish to set this directly use `yourTable.Style = style.ID`

`yourTable:AddColumns(columns)` - Adds the collection `columns` to the list of Columns for the Table.  If you wish to add columns directly, ensure you are only adding `column.ID`, not the entire column object

`yourTable:AddColumn(column)` - Adds a single `column` to the list of Columns for the Table.  If you wish to add columns directly, ensure you are only adding `column.ID`, not the entire column object

`yourTable:AddRow(row)` - Adds a row to the Table's list of rows.  If you wish to add rows directly, ensure you are only adding `row.ID`, not the entire row object


### Valid Fonts
```
FiraMono
FiraMono-Bold
Montserrat 
Montserrat-Light 
Montserrat-Bold 
Play 
Play-Bold 
RefrigeratorDeluxe 
RefrigeratorDeluxe-Light 
RobotoCondensed
RobotoMono
RobotoMono-Bold
```


### Theory

So, what's up with Styles and Canvas, and how does it work?

As I was building this, I ran into issues with large datasets and a lot of time spent waiting for the PB/Screen to communicate, at a max of 1024 characters per tick.  Each Row had its own huge set of data about colors and fonts, and drawing multiple tables on a screen was messy

To consolidate, I created a Canvas object, which can hold any amount of RenderedComponents.  Any new objects created will automatically add themselves to DefaultCanvas.Components (if no other canvas is specified), using the ID in that table as the ID of the new object.  
So now, all references to other objects are done via ID.  Rather than having a list of Tables, each containing a list of Rows, instead we have single-depth tables at all steps, and the size of data being sent to screens is greatly minimized

Styles also helped with this; most Tables really only have 2-3 different styles that they use between various types of rows, headers, etc - it was crazy to send the full style with every Row.  Instead, by requiring the user to create a Style first, we only transmit that data once ever, instead of once per row.  Each row only contains a small number ID linking it to the Styles.  Each Style is just another Component, so they exist in canvas.Components and can be looked up like anything else

Eventually, this can all be expanded to be much more generic, allowing users to create simple objects as well as Tables, using these same Styles
