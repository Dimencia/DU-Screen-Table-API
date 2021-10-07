# DU-Screen-Table-API
A library allowing easy creation of tables to be displayed on screens, using the new DU screen API


# Basic Usage Instructions

1. Copy the contents of `screen API.lua` to Unit.Start.  It includes examples at the end - remove these if making your own table
2. Copy the contents of `TableAPIRenderscript.lua` to the screen you wish to use
3. Add this line to System.Update: `screenTable:Update(screen)`, where `screenTable` is the Table you've created with Table:new, and `screen` is the screen's slot

## Creating Tables

Check the end of `screen API.lua` for an example of constructing tables, categories, and rows

More info coming soon

## Variables

You can change any of these on an instance.  You can change the defaults when initializing a new instance by editing the static `Table`, `Row`, or `Column`

## Column
### Variables
`Name` - (string) The display name of the column
`Width` - (string/percent) Default: "20%" The width, in percent of table size, of the column
`Key` - (any) The key, used in row.Data[key], to identify the data to display in this column

## Row
### Variables
`Visible` - (bool) Default: True -  Whether or not to display this row when drawing
`TextColor` - (hex string) Default: "#000" - The color of text in this row
`FillColor` - (hex string) Default: "#ADADFF" - The color of the background for this row
`StrokeColor` - (hex string) Default: "#FFF" - The color of the stroke around the background box for this row
`StrokeWidth` - (number) Default: 1 - The width of the stroke around the background box for this row
`FontName` - (string) Default: "Play" - The name of the font to use in this row.  See [Valid Fonts] below
`FontSize` - (number) Default: 20 - The size of the font to use in this row
`BoxRadius` - (number) Default: 10 - The radius of the curve on the Rounded Box for each cell in the row - 0 for square edges
`HoverFillColor` - (hex string) Default: "#EEE" - The color of the background for this row when hovered over
`ClickFillColor` - (hex string) Default: "#FFF" - The color of the background for this row on the tick that it is clicked
`MinHeight` - (number) Default: 0 - The minimum height for this row (if the contents are not this tall, it will be this tall anyway)

### Functions
`Row:new(data, parent)` - Creates a new row, where `data` is a table whose keys map to Columns you have defined.  Ex: `Row:new({Name="Main"})`, assuming you have a column with key `"Main"`.  A parent row can be passed, so that childrens row can be collapsed/expanded when the parent is clicked.  This row inherits all attributes from the static Row object at time of creation
`someRow:AddRow(data)` - Creates and adds a new row to the specified parent row `someRow` with the specified data.  A shortcut for Row:new


## Table
### Variables
`X` - (number) Default: 0 - The X coordinate on the screen for where the top-left of the table should begin
`Y` - (number) Default: 0 - The Y coordinate on the screen for where the top-left of the table should begin
`Width` - (string/percent) Default: "100%" - The width of the table, in percentage of screen width
`Height` - (string/percent) Default: "100%" - The height of the table, in percentage of screen height
`NeedsUpdate` - (bool) Default: True - Indicates row data has been changed and should be sent to the screen.  Set this to True after modifying data.  If this is true, it is still sending the previous data, and your implementation should wait until it's false before triggering it again
`ColumnSpacing` - (number) Default: 5 - Number of pixels between all columns (horizontally)
`RowSpacing` - (number) Default: 5 - Number of pixels between all rows (vertically)
`TextPadX` - (number) Default: 5 - Number of pixels between text and the edges of the cells (horizontally)
`TextPadY` - (number) Default: 5 - Number of pixels between text and the edges of cells (vertically)
`BackgroundColor` - (hex string) Default: "#000" - Background color of the screen on which the table is drawn
`HeaderFillColor` - (hex string) Default: "#FFF" - Background color of the cells in the header of the table where columns are listed
`HeaderTextColor` - (hex string) Default: "#000" - Text color for the header of the table where columns are listed
`HeaderStrokeColor` - (hex string) Default: "#222" - The color of the border of the cells in the header
`HeaderStrokeWidth` - (number) Default: 1 - The width of the border of the cells in the header
`HeaderFontName` - (string) Default: "Play-Bold" - Font name of header text where columns are listed.  See [Valid Fonts] below
`HeaderFontSize` - (number) Default: 20 - Size of font for header text where columns are listed
`HeaderRadius` - (number) Default: 10 - The radius of the curve on the Rounded Box for each cell in the header
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
