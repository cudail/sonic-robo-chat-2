

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



