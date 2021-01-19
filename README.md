


This mod reads commands from the file `[srb2_path]/luafiles/chat_commands.txt` and executes them. Each new line in the file is taken to be a single command. The mod reads the entire file at once, adds the commands to a queue, and then deletes the contents of the file. Commands consist of an all-caps command name followed by parameters which are delimited by `|` characters. Parameters are case sensitive. Generally command names are uppercase and parameters are lowercase. Commands and parameters are trimmed for spaces (but not other forms of whitespace) when parsed. `CHARACTER|sonic` and ` CHARACTER  |  sonic ` are equivalent.


# Input sanitisation

There is no way to escape `|` or linebreaks for the command parser so any pipes, `\n` and `\r` characterts should be stripped from all user input.

SRB2 can only display ASCII characters. Trying to display non-ASCII characters may have unexpected results. It will probably just result in messed up looking strings or nothing displaying at all, but it might be a good idea to strip all non-ASCII input anyway when writing to the command file.



# Commands

## BADNIK|{username}|{message}|{namecolour}

namecolour is one of:
pink, yellow, green, blue, red, grey, orange, sky, purple, aqua, peridot, azure, brown, rosy


##SCALE|{multiply}|{divide}|{duration}

Durations are in in gameplay ticks. 35 ticks = one second.


## CHARACTER|[palette]|[name]

`name` is the name of the character to change to. E.g. `sonic`, `tails`, `knuckles`, `amy`, `fang` or `metalsonic`. If not specified then a random character other than the player's current one will be chosen.

`palette` is the new colour palette. If not specified the palette will change to the default palette of character being changed to. If it is set to `random` then a random palette will be chosen from the list of all valid palettes. Otherwise it can be one of the following:

white, bone, cloudy, grey, silver, carbon, jet, black, aether, slate, bluebell, pink, yogurt, brown, bronze, tan, beige, moss, azure, lavender, ruby, salmon, red, crimson, flame, ketchup, peachy, quail, sunset, copper, apricot, orange, rust, gold, sandy, yellow, olive, lime, peridot, apple, green, forest, emerald, mint, seafoam, aqua, teal, wave, cyan, sky, cerulean, icy, sapphire, cornflower, blue, cobalt, vapor, dusk, pastel, purple, bubblegum, magenta, neon, violet, lilac, plum, raspberry, rosy or random

examples:

`CHARACTER` will change to a random character with their normal palette
`CHARACTER|gold` will change to a random character with a gold palette
`CHARACTER|random` will change to a random character with a random palette
`CHARACTER|amy` will change to Amy with her normal palette
`CHARACTER|blue|knuckles` will change to a blue Knuckles
`CHARACTER|random|tails` will change to Tails with a random palette


## SUPER|[give_emeralds]
if give_emeralds is true then the player will be granted all emeralds immediately. If the player does not have all the emeralds and give_emeralds is not true then this will have no effect. Can only be used by characters who have a super transformation (Sonic, Knuckles and Metal Sonic)



