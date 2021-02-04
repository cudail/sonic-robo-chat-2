This mod reads commands from the file `[srb2_path]/luafiles/chat_commands.txt` and executes them. Each new line in the file is taken to be a single command. The mod reads the entire file at once, adds the commands to a queue, and then deletes the contents of the file. Commands look like this:

`SPRING|colour^red|orientation^vertical`

First is an all-caps command name followed by a set arguments delimited by a pipecharacter `|`. Each argument consists of a name and value with the latter separated from the former with a caret character `^`. In this example the `SPRING` command is being passed in with the arguments `colour` and `orientation` with values `red` and `vertical` respectively.


# Writing to the command file

The mod attempts to read from the file `[srb2_path]/luafiles/chat_commands.txt` once every second. If it finds any non-empty lines it reads them into a queue and then wipes the file. If it finds nothing take in it won't bother trying to overwrite the command file. The reading in of commands and wiping of the file are two separate operations. They should happen immediately after each other, but it's possible that a command could be written to the file between the read and write operation, which means it would be missed.

The Lua IO library that SRB2 exposes is very limited and cannot put a lock on a file, delete or rename a file. This means options for preventing missed commands are limited. As a way to minimise it I would suggest having the parser client that's writing to the command file not write commands immediately when they come in. Instead add them to a queue. Then periodically check if the command file is empty. If it is not empty then do not write to it and wait until the mod reads from it and wipes it. If it is empty then write all queued commands to it at once.



# Input sanitisation

There is no way to escape pipes or linebreaks for the command parser so any `|`, `\n` and `\r` characterts should be stripped from all user input.

SRB2 can only display ASCII characters. Trying to display non-ASCII characters may have unexpected results. It will probably just result in messed up looking strings or nothing displaying at all, but it might be a good idea to strip all non-ASCII input anyway when writing to the command file.


# Config

The file `[srb2_path]/luafiles/chat_config.cfg` can be used to configure some settings. These are read only when first starting a game, editing mid-game won't have any effect. To change the config mid-game use the `CONFIG` command described below. The format and default values for all the config file are as follows:

```
command_interval 1
parser_interval 35
spawn_distance 300
spawn_radius 200
spawn_safety 30
chat_x_pos 1
chat_y_pos 54
chat_width 120
chat_lines 29
chat_timeout 350
log 0
```

The `command_interval` is how often, in game ticks, a command is pulled from the current command queue to be executed. Increase this to give breathing room between commands executing. 35 ticks is equal to one second.

The `parser_interval` is how often the command file is read and commands are added to the queue. The default value for this is 35 ticks which equals one second.

The `spawn_distance` is how far in front of the player spawned objects like badniks and monitors will appear in in-game units. For reference Sonic is 48 units tall.

The `spawn_radius` is the radius within which spawned objects will appear. Decrease this to make things spawn clustered closer together. Increase it to spread them out. Technically not a radius as it just offsets the X, Y value of the spawn, so objects spawn within a square aligned to the cardinal directions.

The `spawn_safety` defines a radius around the player that if an object attempts to spawn within the command will fail. If this happens the command will get re-added to the end of the queue.

The `chat_x_pos` and `chat_y_pos` are the co-ordinates for where the chat for the `CHAT` command will be achored on screen.

The `chat_width` is the max width in pixels (not characters) for the chat display.

The `chat_lines` is the max number of lines to display for the chat. If the last message is longer than one line it will overflow this a little.

The `chat_timeout` is how long a given message will be diplayed on screen.

The `log` controls debug logging for the mod. The default value of `0` will result in no logging. `1` will log to the in-game console. `2` will log to `luafiles/chat_log.txt`.



# Commands

Each command is shown with all possible arguments it can take. Arguments in sqaure brackets are optional while arguments in curly brackets are manditory for a command to work.

### CONFIG|{setting}|{value}

Set a value for one of the settings `command_interval`, `parser_interval`, `spawn_distance` or `spawn_radius` as described above. This will cause the current config to be written to `chat_config.cfg` so that it will persist next time you play. Both setting and value need to be specified for this command to work.

Example: `CONFIG|setting^chat_timeout|value^35` will set the chat_timeout to 35 ticks.


## Object spawning and user messages

Spawned objects are intended to display a chat message from whoever spawned them hovering over them. Commands that display a user message can take a `username`, `message` and `namecolour`.

`username` is intended to be the username of whoever sent the command in chat. Defaults to a blank string if not set.

`message` is the message that will be displayed over the spawned object. Also defaults to a blank string if not set. Carets should be safe to use in a message but pipes and newlines are not.

`namecolour` is the colour to highlight the user's name in. It can be one of pink, yellow, green, blue, red, grey, orange, sky, purple, aqua, peridot, azure, brown, rosy. Defaults to yellow if not set.

Most object spawning commands can also take a `scale` value. This is a decimal that adjusts the size of the object spawned. `1` will be normal sized, `0.5` will be half-sized, `2` will be double-sized, etc. Defaults to normal scale if not specified.

If an object tries to spawn withing distance `spawn_safety` of the player the spawn will fail and the command will be re-added to the end of the queue.


### CHAT|[username]|[message]|[namecolour]

Displays a message on the the screen. Intended for showing chat in-game. Remember that non-ASCII characters will not work.


### OBJECT|{objectid}|[username]|[message]|[namecolour]|[scale]

Spawn a object of with with object type number `objectId` in front of the player. A list of objects and their IDs can be found here: https://wiki.srb2.org/wiki/List_of_Object_types

Example: `OBJECT|objectid^61|username^robotnik|message^get a load of this|namecolour^orange|scale^2.5` will spawn the Egg Mobile (boss of Green Flower Zone) two and a half times larger than normal


### BADNIK|[username]|[message]|[namecolour]|[scale]

Spawn a badnik in front of the player. The mod will try to pick one appropriate to the current level.


### MONITOR|[username]|[message]|[namecolour]|[scale]|[set]

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


### DESPAWN

Destroys everything that was spawned via the chat commands. Can be used to clear things up if something that was spawned is causing problems.


### SPRING|[colour]|[orientation]|[direction]

Spawns a spring directly on top of a player. Springs despawn after one second and don't display any message.

`colour` is the type of spring to spawn. The three options are, in order of least to greatest force, `blue`, `yellow` and `red`. Defaults to `yellow`.

`orientation` can be `horizontal`, `vertical` or `diagonal`. Diagonal springs are angled upwards. Defaults to `vertical`.

`direction` is the direction the spring will point relative to the player. `forward` springs push the player in direction they were already facing, `back` in the opposite direction and `left` and `right` push a player orthogonal to their original facing. Defaults to `forward`.



## Player commands

Commands that affect the player directly. Many have a `duration`. Duration should be an integer representing the number of gameplay ticks the effect will last for. There are 35 ticks a second. E.g. 5 seconds is 175 ticks.


### TURN

Immediately turn the player 180°.


### REVERSE|{duration}

Reverses the player's controls for the given `duration` of gameplay ticks.


### FORCE_JUMP|{duration}

Forces the player to constantly jump for the given `duration` of gameplay ticks.


### POISON|{duration}

Drains one ring per second from the player for the given `duration` of gameplay ticks.


### SPEED_STATS|{scale}|{duration}

Scales the player's speed and acceleration stats by factor `scale` for the `duration` of gameplay ticks.

### JUMP_STATS|{scale}|{duration}

Scales the player's jump height by factor `scale` for the `duration` of gameplay ticks.


### SCALE|{scale}|{duration}

Scale the player character's size by factor `scale` for `duration` of gameplay ticks. Scale is a decimal value.


### CHARACTER|[palette]|[characterName]|[playerid]

`characterName` is the name of the character to change to. E.g. `sonic`, `tails` or `knuckles`. If not specified then a random character other than the player's current one will be chosen.

`palette` is the new colour palette. If not specified the palette will change to the default palette of character being changed to. If it is set to `random` then a random palette will be chosen from the list of all valid palettes. Otherwise it can be one of the following:

white, bone, cloudy, grey, silver, carbon, jet, black, aether, slate, bluebell, pink, yogurt, brown, bronze, tan, beige, moss, azure, lavender, ruby, salmon, red, crimson, flame, ketchup, peachy, quail, sunset, copper, apricot, orange, rust, gold, sandy, yellow, olive, lime, peridot, apple, green, forest, emerald, mint, seafoam, aqua, teal, wave, cyan, sky, cerulean, icy, sapphire, cornflower, blue, cobalt, vapor, dusk, pastel, purple, bubblegum, magenta, neon, violet, lilac, plum, raspberry, rosy

`playerid` is the ID number of the player object to change. If not specified this will target player `0`, i.e. you. If you are start a game with Sonic and Tails you can target Tails/the follower character by setting this to `1` instead. Because this mod doesn't work with online games setting it to any other value will not be useful. You can't spawn an AI player after starting a game so if you want to be able to have a follower follower character make sure to start a game with Sonic and Tails.

examples:

`CHARACTER` will change the player to a random character with their normal palette
`CHARACTER|colour^gold` will change the player to a random character with a gold palette
`CHARACTER|colour^random` will change the player to a random character with a random palette
`CHARACTER|character^amy` will change the player to Amy with her normal palette
`CHARACTER|colour^blue|character^knuckles` will change the player to a blue Knuckles
`CHARACTER|colour^random|character^tails` will change the player to Tails with a random palette
`CHARACTER|colour^red|character^sonic|playerid^1` will change the follower to a red Sonic


### SWAP

If the player has a follower it swaps the player and follower characters.


### SUPER|[giveemeralds]

Force the player into super mode. All of the usual restrictions for turning super are in place: The player must be playing a character who can turn super (e.g. Sonic can and Tails cannot) and the player must already have all Chaos Emeralds.

If giveemeralds is true then the player will be granted all emeralds immediately to allow them to do a super transformation. If the player is currently a character who cannot normally turn super then giveemeralds will also fail.


### RING

Give the player a ring.


### UNRING

Remove a ring from the player.


### 1UP

Give the player and extra life.


### AIR

Give the player air. All player momentum is stopped, the player is forced into the gasping for air state and the drowning timer is reset. This works regardless of whether the player is underwater or not. It doesn't actually spawn an air bubble, it just manipulates the player state directly. Could be used to harm the player by e.g. using it to stop all player momentum while they're travelling over a bottomless pit.


### SOUND|{sound}

Play a sound given its ID number from. List: https://wiki.srb2.org/wiki/List_of_sounds

Example: `SOUND|sound^21` will play the player skidding sound


### MUSIC|{track}

Play the given music track. The normal stage music will resume from where it left off after the track has finished playing. If an invalid name is passed in then it will cut off the normal stage music momnetarily before it resumes.

List of music: https://wiki.srb2.org/wiki/List_of_music

Example: `MUSIC|track^_DROWN` will play the drowning music. Very evil.
