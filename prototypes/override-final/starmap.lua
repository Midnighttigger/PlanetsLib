local orbits = require("lib.orbits")
local trig = require("lib.trig")
local sprite = require("lib.sprite")


local Public = {}
local starmap_layers = {}

--Finds loadorder
local planetlist = {}
for _,planettype in pairs({"space-location"},{"planet"}) do
	for _,planet in pairs(data.raw[planettype]) do
		table.insert(planetlist,planet)
	end
end
local loadorder = {}
while planetlist[1] do
	for _,planet in pairs(planetlist) do
		if planet.orbit and planet.orbit.parent then
			assert(planet.orbit.parent.type and planet.orbit.parent.name, planet.type..": "..planet.name.." doesn't have properly defined parent")
			assert(parent.type == "planet" or parent.type == "space-location","Parent types other than planet or space-location are not yet supported")
			assert(data.raw[planet.orbit.parent.type][planet.orbit.parent.name],planet.type..": "..planet.name.." has an orbit around a parent which doesn't exist")
			local found = false
			for _,loaded in pairs(loadorder) do
				if loaded.type == planet.orbit.parent.type and loaded.name == planet.orbit.parent.name then
					found = true
				end
			end
			if found then
				table.insert(loadorder,planet)
				planet = nil
			end
		else
			table.insert(loadorder,planet)
			planet = nil
		end
	end
end

--Sets starmap position's
for _,planet in pairs(loadorder) do
	local planet_data = data.raw[planet.type][planet.name]
	if planet.orbit and planet.orbit.parent then
		planet_data.distance, planet_data.orientation = orbits.get_quick_position(planet.orbit)
		local parent_data = data.raw["planet.orbit.parent.type"]["planet.orbit.parent.name"]
		if parent_data.distance == 0 and settings.startup["PlanetsLib-optimize-orbits"].value and not planet.force_sprite then --use hardcoded vector circles when available
			planet_data.orbit.sprite = nil
			planet.orbit.sprite = nil
		end
	elseif planet.orbit then
		planet_data.distance, planet_data.orientation = planet.orbit.distance, planet.orbit.orientation
		planet.orbit = nil
		planet_data.orbit = nil
	end
	if planet.background_sprite then -- Allow background sprites
		local pos_x = 32*planet.distance*math.sin(planet.orientation*2*math.pi)
		local pos_y = 32*planet.distance*math.cos(planet.orientation*2*math.pi)
		for _,sp in pairs(sprite.decay(sprite.manipulate_scale(planet.starmap_icon,{pos_x,pos_y},planet.magnitude))) do
			table.insert(starmap_layers,sp)
		end
		planet_data = nil
		planet = nil
	end
end

--Orbit Sprites and sprite_only planets
for _,planet in pairs(loadorder) do
	
end

function Public.update_starmap_layers(planet)
	local orbit = planet.orbit
	if not orbit then
		return
	end
	local parent = planet.orbit.parent

	assert(parent.type == "planet" or parent.type == "space-location","Parent types other than planet or space-location are not yet supported")
	
	local orbit_distance, orbit_orientation = orbits.get_absolute_polar_position_from_orbit(orbit)
	
	local parent_data = data.raw[parent.type][parent.name]
	local parent_orbit = parent_data.orbit

	assert(parent_orbit, "Parent " .. parent.name .. " has no orbit")

	local parent_distance, parent_orientation = orbits.get_absolute_polar_position_from_orbit(parent_orbit)

	if orbit.eccentricity and orbit.eccentricity > 0 then
		assert(orbit.periapsis, "If the orbit is elliptical, a periapsis (closest approach orientation) must be provided")
		local central_distance,central_orientation = trig.Polar_add({parent_distance,parent_orientation},{(orbit_distance*orbit.eccentricity)/(1-orbit.eccentricity),orbit.periapsis+0.5})
		local central_x = central_distance*math.sin(central_orientation*2*math.pi)
		local central_y = central_distance*math.cos(central_orientation*2*math.pi)
		if orbit.sprite then
			if orbit.sprite.layers then
				for _, layer in pairs(orbit.sprite.layers) do
					Public.update_starmap_from_sprite(layer, 32*central_x, -32*central_y)
				end
			else
				Public.update_starmap_from_sprite(orbit.sprite, 32*central_x, -32*central_y)
			end
		end
	else
		local central_x = parent_distance*math.sin(parent_orientation*2*math.pi)
		local central_y = parent_distance*math.cos(parent_orientation*2*math.pi)
		if orbit.sprite then
			if orbit.sprite.layers then
				for _, layer in pairs(orbit.sprite.layers) do
					Public.update_starmap_from_sprite(layer, 32*central_x, -32*central_y)
				end
			else
				Public.update_starmap_from_sprite(orbit.sprite, 32*central_x, -32*central_y)
			end
		end
	end

	planet.draw_orbit = false

	if planet.sprite_only then
		local central_x = orbit_distance*math.sin(orbit_orientation*2*math.pi)
		local central_y = orbit_distance*math.cos(orbit_orientation*2*math.pi)
		table.insert(starmap_layers, {
			filename = planet.starmap_icon,
			size = planet.starmap_icon_size,
			scale = (planet.magnitude*32)/planet.starmap_icon_size,
			shift = {32*central_x,-32*central_y},
		})
	end
end

function Public.update_starmap_from_sprite(sprite, x, y)
	local sprite_copy = util.table.deepcopy(sprite)
	sprite_copy.shift = {
		(sprite_copy.shift and sprite_copy.shift[1] or 0) + x,
		(sprite_copy.shift and sprite_copy.shift[2] or 0) + y,
	}
	table.insert(starmap_layers, sprite_copy)
end

--todo: what if a sprite of layers have different scales in the subsprites?
--todo: elliptical orbit sprite creation documentation
--todo: test ellptical orbit
for _, planet in pairs(data.raw["planet"]) do
	Public.update_starmap_layers(planet)
end
for _, space_location in pairs(data.raw["space-location"]) do
	Public.update_starmap_layers(space_location)
end

local starmap = data.raw["utility-sprites"]["default"].starmap_star
if starmap.layers then
	for _,starmap_layer in pairs(starmap_layers) do
		table.insert(starmap.layers,starmap_layer)
	end
else
	starmap = {layers=starmap_layers}
end

return Public
