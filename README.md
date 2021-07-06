# Sonic Robo Chat 2

This mod is one half of a system for allowing Twitch chat participation in
Sonic Robo Blast 2. With it you can stream Sonic Robo Blast 2 and allow your
chat to change your character, spawn enemies and other objects, give or take
rings, and more.

This mod will not work with network games. Don't try to use it with multiplayer.


## Installation

Download and install [Sonic Robo Blast 2].

Download the chat control WAD file. See the Sonic Robo Blast 2 wiki for [how to
load a WAD file].

Download the [chat control client] and follow the instructions for configuring
and running it. You can see what chat commands are available there.

[Sonic Robo Blast 2]: https://www.srb2.org/
[how to load a WAD file]: https://wiki.srb2.org/wiki/WAD_file#Loading_WAD_files
[chat control client]: https://github.com/oakreef/sonic-robo-chat-2-client


## Configuration

The file `%srb2_path%/luafiles/chat_config.cfg` can be used to configure some settings. These are read only when first starting a game, editing mid-game won't have any effect. To change the config mid-game you need to use the `config` chat command described in the client's readme. The format and default values for all the config file are as follows:

```
command_interval 1
parser_interval 35
spawn_distance 300
spawn_radius 200
spawn_safety 30
stat_print_delay 35
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

The `spawn_radius` is the radius within which spawned objects will appear. Decrease this to make things spawn clustered closer together. Increase it to spread them out.

The `spawn_safety` defines a radius around the player that if an object attempts to spawn within the command will fail. If this happens the command will get re-added to the end of the queue.

The `chat_x_pos` and `chat_y_pos` are the co-ordinates for where the chat for the `CHAT` command will be achored on screen.

The `chat_width` is the max width in pixels (not characters) for the chat display.

The `chat_lines` is the max number of lines to display for the chat. If the last message is longer than one line it will overflow this a little.

The `chat_timeout` is how long a given message will be diplayed on screen.

The `log` controls debug logging for the mod. The default value of `0` will result in no logging. `1` will log to the in-game console. `2` will log to `luafiles/chat_log.txt`.


## Making your own chat client

If you want to use the mod with your own client see the [Developer's Guide].

[Developer's Guide]: developer-guide.md
