
RanksNKits = {
    _users = {}, --keys are users, values are user's rank
    _kits = {},  --keys are rank names, values are a list of items in kit
    
    addRank = function(self, username, rank)
        self._users[username] = rank
    end,
    addKit = function(self, rank, items)
        --kit for rank already exists
        if self._kits[rank] then
            print("[[WARNING]] Kit for rank "..rank.." already exists. Kit not added.")

        --everything is fine, add kit
        else
            self._kits[rank] = items
        end 
    end,
    saveUserRanks = function(self)
         local f, err = io.open(minetest.get_worldpath().."/ranksnkits_users.dat", "w")
         if not err then f:write(minetest.serialize(self._users)) end
    end,
    loadUserRanks = function(self)
         local f, err = io.open(minetest.get_worldpath().."/ranksnkits_users.dat", "r")
         if not err then self._users = minetest.deserialize(f:read("*all")) end
         if not self._users then self._users = {} end
         
    end
}


--save data hourly
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer+dtime
    if timer >= 3600 then
        timer = 0
        RanksNkits:saveUserRanks()
    end
end)

--save on shutdown
minetest.register_on_shutdown(function() RanksNKits:saveUserRanks() end)

--load user data
RanksNKits:loadUserRanks()


--register chat commands and privilege
minetest.register_chatcommand("givekit", {
        params = "",
        description = "Gives the player a set of items based on his/her rank.",
        func = function(player, params)
            if RanksNKits._users[player] then
                for i,v in ipairs(RanksNKits._kits[RanksNKits._users[player]]) do
                    minetest.get_player_by_name(player):get_inventory():add_item('main', v)
                end
            else
                minetest.chat_send_player(player, "Uhoh you don't have a rank... Better bug the moderators.")
            end
        end
})

minetest.register_privilege("kitsnranks", "Allows the user to set another users rank.")

minetest.register_chatcommand("setrank", {
        params = "<name> <rank>",
        privs = {kitsnranks = true},
        description = "Sets the given player's rank allowing him to receive associated items.",
        func = function(player, param)

            name = param:split(" ")[1]
            rank = param:split(" ")[2]
            
            --missing parameters
            if param == "" or not rank then
                minetest.chat_send_player(player, "Please provide a player name and rank.")
            
            --player not online
            elseif not minetest.get_player_by_name(name) then
                minetest.chat_send_player(player, "Given name is not a valid online player name.")

            --kit does not exists
            elseif not RanksNKits._kits[rank] then
                minetest.chat_send_player(player, "Given rank has no kit associated with it. Player's rank not set.")

            --set given player's rank 
            else
                minetest.chat_send_player(player, "Rank "..rank.." given to "..name..".")                
                RanksNKits._users[name] = rank
            end
        end
})


--load kits 
local kits_dir = minetest.get_modpath(minetest.get_current_modname()).."/kits/"
local filenames

--code based off of https://github.com/cornernote/minetest-towntest/blob/master/towntest_chest/init.lua
--its probably linux/mac
if os.getenv('HOME') and kits_dir then
    os.execute('ls "'..kits_dir..'" | grep .kit > "'..kits_dir..'.kits"')
    local file, err = io.open(kits_dir..'.kits', 'rb')
    if not err then
         filenames = file:lines()
    end
    os.execute('rm "'..kits_dir..'.kits"')

--its probably windows
else 
    filenames = io.popon('dir "'..kits_dir..'"'):lines()
end


if not filenames then
    error("[ERROR, RanksNKits] Missing kits folder. Add a kits folder under ranks_n_kits or remove the mod.")

else

    for filename in filenames do
        --pull the rank name from filename and add it
        local rank = filename:split(".")[1]
        RanksNKits:addRank(rank)

        --get items from the kit file and create the new kit
        local contents = io.open(kits_dir..filename, 'r'):read("*all")
        RanksNKits:addKit(rank, contents:split("\n"))
        
    end

end


