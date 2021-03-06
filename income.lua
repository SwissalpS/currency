local players_income = {}

-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

local income_enabled = minetest.settings:get_bool("currency.income_enabled", true)
local income_item = minetest.settings:get("currency.income_item") or "currency:minegeld_10"
local income_count = tonumber(minetest.settings:get("currency.income_count")) or 1
local income_period = tonumber(minetest.settings:get("currency.income_period")) or 720

if income_enabled then
	local timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime;
		if timer >= income_period then
			timer = 0
			for _, player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				players_income[name] = income_count
				minetest.log("info", "[Currency] "..S("basic income for @1", name))
			end
		end
	end)

	local function earn_income(player)
		if not player or player.is_fake_player then return end
		local name = player:get_player_name()

		local income_count = players_income[name]
		if income_count and income_count > 0 then
			local inv = player:get_inventory()
			inv:add_item("main", {name=income_item, count=income_count})
			players_income[name] = nil
			minetest.log("info", "[Currency] "..S("added basic income for @1 to inventory", name))
		end
	end

	minetest.register_on_dignode(function(pos, oldnode, digger) earn_income(digger) end)
	minetest.register_on_placenode(function(pos, node, placer) earn_income(placer) end)
	minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv) earn_income(player) end)
end
