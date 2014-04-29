#Ranks N Kits
Version 0.3
Licence: LGPLv3
Dependencies: none (but the example kit does use default items) 

This is a minetest modification that adds two chat commands and a privilege. 

* ranksnkits privilege allows the player to use the setrank command
* /setrank <player name> <rank name> sets the given players rank to the given rank
* /givekit allows any player with a rank to receive the items related to his rank

# Installation
Download this mod and extract the folder to your minetest/mods folder and enable it in your world's configure menu. Alternatively add it to a minetest/games/[game] folder so all worlds using [game] will have this mod.

# Configure
## Ranks and Their Kits
Each file under the kits sub folder (ranks\_n_kits/kits) with a .kit extension defines both a rank and its related kit. The contents should have a list of items each of which are on a separate line. For example the file noob.kit with the contents

   default:wood_pick
   default:wood_shovel
   default:wood_axe

defines the rank named noob and the set of items above. If a player has the noob rank and calls /givekit he will receive a wood pick, a wood shovel, and a wood axe.

# TODO

* Timers should be added so kits can only be requested on a configured time interval.
* Consider allowing players to "own" multiple ranks and/or allow ranks to have multiple kits.
* Make a setting to define a rank that all new players will automatically receive.
