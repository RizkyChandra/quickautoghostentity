--- @param player LuaPlayer
local function quickghostentity(player)
    -- Get The Area To Check For Ghosts
    local area = { { player.position.x - player.reach_distance, player.position.y - player.reach_distance }, { player.position.x + player.reach_distance, player.position.y + player.reach_distance } }
    -- Get The Entities In The Area
    local ghostList = player.surface.find_entities_filtered { area = area, type = "entity-ghost" }
    local playerInventory = player.get_main_inventory()
    local cursorItemStack = player.cursor_stack
    if not playerInventory then return end

    -- Loop Through The Entities
    for _, ghost in pairs(ghostList) do
        -- Get The Prototype Of The Entity
        local prototype = ghost.ghost_prototype
        -- Guard Clause To Check If The Prototype Exists
        if not prototype then return end
        -- Guard Clause To Check If The Prototype Has Items To Place
        if not prototype.items_to_place_this then return end

        -- Check item needed in inventory match the ghost
        for _, item_to_place in pairs(prototype.items_to_place_this) do
            if cursorItemStack ~= nil and cursorItemStack.valid_for_read and cursorItemStack.name == item_to_place.name then
                if cursorItemStack.count >= item_to_place.count then
                    cursorItemStack.count = cursorItemStack.count - item_to_place.count
                    ghost.revive()
                end
            end
            if playerInventory.get_item_count(item_to_place.name) >= item_to_place.count then
                playerInventory.remove { name = item_to_place.name, count = item_to_place.count }
                ghost.revive()
            end
        end
    end
end


script.on_event("quickghostentity-trigger", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    if player.controller_type == defines.controllers.editor then return end -- in editor.
    if player.controller_type == defines.controllers.god then return end -- in sandbox.
    if player.controller_type == defines.controllers.cutscene then return end -- in cutscene.
    if player.controller_type == defines.controllers.ghost then return end -- in waiting-to-respawn screen.
    if player.controller_type == defines.controllers.spectator then return end -- in spectator mode.
    if player.controller_type == defines.controllers.remote then return end -- Can't move/change items but can build ghosts/change settings.
    quickghostentity(player)
end)
