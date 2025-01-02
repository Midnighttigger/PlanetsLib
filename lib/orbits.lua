local Public = {}

function Public.get_absolute_polar_position_from_orbit(orbit)
	local parent = orbit.parent
	assert(parent.type == "planet" or parent.type == "space-location", "Parent types other than planet or space-location are not yet supported")
	local parent_data = data.raw[parent.type][parent.name]
	local parent_distance = parent_data.distance
	local parent_orientation = parent_data.orientation
	if parent_data.orbit and not (parent_distance == 0) then
		parent_distance, parent_orientation = Public.get_absolute_polar_position_from_orbit(parent_data.orbit)
	end
	if orbit.eccentricity and orbit.eccentricity > 0 then
		assert(orbit.periapsis, "If the orbit is elliptical, a periapsis (closest approach orientation) must be provided")
		local polar = trig.Polar_add({parent.distance,parent.orientation},{((1+orbit.eccentricity)*orbit.distance)/(1+orbit.eccentricity*math.cos((orbit.orientation-orbit.periapsis)*2*math.pi)),orbit.orientation})
		return polar[1], polar[2]
	else
		local polar = trig.Polar_add({orbit.distance,orbit.orientation},{parent_distance,parent_orientation})
		return polar[1], polar[2]
	end
end

return Public
