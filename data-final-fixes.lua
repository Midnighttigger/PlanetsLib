local orbits = require("lib.orbits")

-- Force-set the position of planets and moons, in case other mods moved them:
for _, p in pairs(data.raw.planet) do
	if p.orbit then
		local distance, orientation = orbits.get_absolute_polar_position_from_orbit(p.orbit)
		p.distance = distance
		p.orientation = orientation
	end
end
for _, p in pairs(data.raw["space-location"]) do
	if p.orbit then
		local distance, orientation = orbits.get_absolute_polar_position_from_orbit(p.orbit)
		p.distance = distance
		p.orientation = orientation
	end
end

require("prototypes.override-final.starmap")

for _, p in pairs(data.raw.planet) do
	if p.sprite_only then
		data.raw.planet[p.name] = nil
	end
end
for _, p in pairs(data.raw["space-location"]) do
	if p.sprite_only then
		data.raw["space-location"][p.name] = nil
	end
end

local gas_list = { "oxygen", "nitrogen", "carbon-dioxide", "argon" }
local enforce_percentage = settings.startup["PlanetsLib-enforce-gas-percentage"].value --Whether code should assert that combined gas contents add up to less than 100%.

for _, p in pairs(data.raw.planet) do
	if p.surface_properties and enforce_percentage then
		local gas_content = 0
		for _, gas in pairs(gas_list) do
			if p.surface_properties[gas] then
				gas_content = gas_content + p.surface_properties[gas]
			end
		end
		assert(
			gas_content <= 100,
			"Combined gas contents of planet "
				.. p.name
				.. ' exceed 100%. To override this assertion, add \'data.raw["bool-setting"]["PlanetsLib-enforce-gas-percentage"].forced_value = false\' to data-updates.lua.'
		)
	end
end
