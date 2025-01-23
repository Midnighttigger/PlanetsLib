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
		if parent_data.distance == 0 then --use hardcoded vector circles when available
			planet_data.orbit.sprite = nil
			planet.orbit.sprite = nil
		end
	elseif planet.orbit then
		planet_data.distance, planet_data.orientation = planet.orbit.distance, planet.orbit.orientation
		planet.orbit = nil
		planet_data.orbit = nil
	end
	if planet.background_sprite then -- Allow background sprites
		local pos = trig.Polar_to_Coord(planet.distance*32,planet.orientation)
		for _,sp in pairs(sprite.decay(sprite.manipulate_scale(planet.starmap_icon,pos,planet.magnitude))) do
			table.insert(starmap_layers,sp)
		end
		planet_data = nil
	end
end

--Orbit Sprites and sprite_only planets, placed in order
for _,planet in pairs(loadorder) do
	local planet_data = data.raw[porbit.type][porbit.name]
	if planet.orbit and planet.orbit.parent and planet.orbit.sprite then
		local orbit = planet.orbit
		local parent_data = data.raw[orbit.parent.type][orbit.parent.name]
		if (orbit.eccentricity and orbit.eccentricity == 0) or not orbit.eccentricity then --circular
			local sprite = sprite.decay(sprite.manipulate(orbit.sprite,trig.Polar_to_Coord(parent_data.distance*32,parent_data.orientation),4+64*orbit.distance))
			if sprite.layers then
				for _,layer in pairs(sprite.layers) do
					table.insert(starmap_layers,layer)
				end
			else
				table.insert(starmap_layers,sprite)
			end
			planet_data.draw_orbit = false
		elseif orbit.eccentricity and orbit.eccentricity > 0 then --elliptical
			local sprite = sprite.decay(sprite.manipulate(orbit.sprite,trig.Polar_to_Coord(trig.Polar_add({parent_data.distance*32,parent_data.orientation},{(orbit.distance*32*orbit.eccentricity)/(1-orbit.eccentricity),orbit.periapsis})),(64*orbit.distance*(1-orbit.eccentricity^2)^0.5)/((1-orbit.eccentricity)*(1-(orbit.eccentricity*math.sin(orbit.periapsis*2*math.pi))^2))))
			if sprite.layers then
				for _,layer in pairs(sprite.layers) do
					table.insert(starmap_layers,layer)
				end
			else
				table.insert(starmap_layers,sprite)
			end
			planet_data.draw_orbit = false
		end
	end
	if planet.sprite_only then -- Allow sprites
		local pos = trig.Polar_to_Coord(planet.distance*32,planet.orientation)
		for _,sp in pairs(sprite.decay(sprite.manipulate_scale(planet.starmap_icon,pos,planet.magnitude))) do
			table.insert(starmap_layers,sp)
		end
		planet_data = nil
	end
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
