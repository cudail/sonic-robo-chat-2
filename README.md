


This mod reads commands from the file `[srb2_path]/luafiles/chat_commands.txt` and executes them. Each new line in the file is taken to be a single command. The mod reads the entire file at once, adds the commands to a queue, and then deletes the contents of the file. Commands consist of an all-caps command name followed by parameters which are delimited by `|` characters. Parameters are case sensitive. Generally command names are uppercase and parameters are lowercase. Commands and parameters are trimmed for spaces (but not other forms of whitespace) when parsed. `CHARACTER|sonic` and ` CHARACTER  |  sonic ` are equivalent.


# Input sanitisation

There is no way to escape pipes or linebreaks for the command parser so any `|`, `\n` and `\r` characterts should be stripped from all user input.

SRB2 can only display ASCII characters. Trying to display non-ASCII characters may have unexpected results. It will probably just result in messed up looking strings or nothing displaying at all, but it might be a good idea to strip all non-ASCII input anyway when writing to the command file.



# Commands

## Object spawning

Spawned objects are intended to display a chat message from whoever spawned them hovering over them. All object spawning commands take a `username`, `message` and `namecolour`.

`username` is intended to be the username of whoever sent the command in chat.

`message` is the message that will be displayed over the spawned object.

`namecolour` is the colour to highlight the user's name in. It can be one of pink, yellow, green, blue, red, grey, orange, sky, purple, aqua, peridot, azure, brown, rosy.



### OBJECT|{username}|{message}|{namecolour}|{objectId}

Spawn a object of with with object type number `objectId` in front of the player. A list of objects and their IDs can be found here: https://wiki.srb2.org/wiki/List_of_Object_types

Probably not a good idea to let people in chat enter an arbitrary object ID to spawn, but if you want to make something specific spawnable you can do it with this.



### BADNIK|{username}|{message}|{namecolour}|[scale]

Spawn a badnik in front of the player. The mod will try to pick one appropriate to the current level.

`scale` is what scale to apply to the badnik. `1` will be normal sized, `0.5` will be half-sized, `2` will be double-sized, etc. Defaults to normal scale if not specified.



### MONITOR|{username}|{message}|{namecolour}|[set]

Spawn an item monitor in front of the player.

`set` is which set of monitors you want to spawn from. Defaults to `allweighted` if not specified. It can be one of the following:

* `all` randomly spawn any monitor
* `allweighted` randomly spawn any monitor, weighted so that shields do not dominate spawns. Default value
* `good` randomly spawns a monitor other than an eggman monitor
* `goodweighted` randomly spawns a monitor other than an eggman monitor, weighted so that shields do not dominate spawns
* `ring` spawn a 10 ring monitor
* `oneup` spawn an extra life monitor
* `eggman` spawn an eggman monitor
* `mystery` spawn a mystery monitor
* `shield` spawn a shield monitor




## Player commands

Commands that affect the player directly. Many have a `duration`. Duration should be an integer representing the number of gameplay ticks the effect will last for. There are 35 ticks a second. E.g. 5 seconds is 175 ticks.


### TURN

Immediately turn the player 180°.


### REVERSE|{duration}

Reverses the player's controls for the given `duration` of gameplay ticks.


### JUMP|{duration}

Forces the player to constantly jump for the given `duration` of gameplay ticks.


### SCALE|{multiply}|{divide}|{duration}

Durations are in in gameplay ticks. 35 ticks = one second.


### CHARACTER|[palette]|[characterName]|[playerId]

`characterName` is the name of the character to change to. E.g. `sonic`, `tails` or `knuckles`. If not specified then a random character other than the player's current one will be chosen.

`palette` is the new colour palette. If not specified the palette will change to the default palette of character being changed to. If it is set to `random` then a random palette will be chosen from the list of all valid palettes. Otherwise it can be one of the following:

white, bone, cloudy, grey, silver, carbon, jet, black, aether, slate, bluebell, pink, yogurt, brown, bronze, tan, beige, moss, azure, lavender, ruby, salmon, red, crimson, flame, ketchup, peachy, quail, sunset, copper, apricot, orange, rust, gold, sandy, yellow, olive, lime, peridot, apple, green, forest, emerald, mint, seafoam, aqua, teal, wave, cyan, sky, cerulean, icy, sapphire, cornflower, blue, cobalt, vapor, dusk, pastel, purple, bubblegum, magenta, neon, violet, lilac, plum, raspberry, rosy

`playerId` is the ID number of the player object to change. If not specified this will target player `0`, i.e. you. If you are start a game with Sonic and Tails you can target Tails/the follower character by setting this to `1` instead. Because this mod doesn't work with online games setting it to any other value will not be useful. You can't spawn an AI player after starting a game so if you want to be able to change the follower character make sure to start a game with Sonic and Tails.

examples:

`CHARACTER` will change the player to a random character with their normal palette
`CHARACTER|gold` will change the player to a random character with a gold palette
`CHARACTER|random` will change the player to a random character with a random palette
`CHARACTER|amy` will change the player to Amy with her normal palette
`CHARACTER|blue|knuckles` will change the player to a blue Knuckles
`CHARACTER|random|tails` will change the player to Tails with a random palette
`CHARACTER|red|sonic|1` will change the follower to a red Sonic


### SUPER|[give_emeralds]
if give_emeralds is true then the player will be granted all emeralds immediately. If the player does not have all the emeralds and give_emeralds is not true then this will have no effect. Can only be used by characters who have a super transformation (Sonic, Knuckles and Metal Sonic)



