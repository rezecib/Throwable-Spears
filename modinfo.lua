--The name of the mod displayed in the 'mods' screen.
name = "Throwable Spears"

--A description of the mod.
description = "Allows you to throw spears with right-click."

--Who wrote this awesome mod?
author = "rezecib"

--A version number so you can ask people if they are running an old version of your mod.
version = "1.8.2"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 10

--Compatible with both the base game and Reign of Giants
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true
client_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {"throwable spears"}

icon_atlas = "spearthrow-icon.xml"
icon = "spearthrow-icon.tex"

forumthread = ""

--[[
Credits:
    
    
]]

configuration_options =
{
	{
		name = "SMALL_MISS_CHANCE",
		label = "Miss Small Creatures",
		options =	{
						{description = "100%", data = 2},
						{description = "90%", data = 0.9},
						{description = "80%", data = 0.8},
						{description = "70%", data = 0.7},
						{description = "60%", data = 0.6},
						{description = "50%", data = 0.5},
						{description = "40%", data = 0.4},
						{description = "30%", data = 0.3},
						{description = "20%", data = 0.2},
						{description = "10%", data = 0.1},
						{description = "0%", data = 0},
					},

		default = 2,
	
	},
	{
		name = "LARGE_USES",
		label = "# Uses on Large",
		options =	{
						{description = "2", data = 2},
						{description = "3", data = 3},
						{description = "5", data = 5},
						{description = "10", data = 10},
						{description = "15", data = 15},
						{description = "25", data = 25},
						{description = "30", data = 30},
						{description = "50", data = 50},
						{description = "75", data = 75},
						{description = "150", data = 150},
					},

		default = 75,
	},
	{
		name = "SMALL_USES",
		label = "# Uses on Small",
		options =	{
						{description = "2", data = 2},
						{description = "3", data = 3},
						{description = "5", data = 5},
						{description = "10", data = 10},
						{description = "15", data = 15},
						{description = "25", data = 25},
						{description = "30", data = 30},
						{description = "50", data = 50},
						{description = "75", data = 75},
						{description = "150", data = 150},
					},

		default = 5,
	},
	{
		name = "RANGE_CHECK",
		label = "Check Range",
		options =	{
						{description = "yes", data = true},
						{description = "no", data = false},
					},

		default = true,
	},
}