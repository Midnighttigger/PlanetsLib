local Public = {}

local tau = 2*math.pi
function Public.Polar_add(P1,P2) -- add 2 polar coords {distance,orientation}
	if P1[1] == 0 then
		return {P2[1],P2[2]%1}
	elseif  P2[1] == 0 then
		return {P1[1],P1[2]%1}
	else
		P1[2] = P1[2]%1
		P2[2] = P2[2]%1
		local z = ((P1[1])^2+(P2[1])^2+2*(P1[1])*(P2[1])*math.cos(((P2[2])-(P1[2]))*2*math.pi))^0.5
		if z == 0 then
			return {0,0}
		elseif (P2[2]-P1[2])%1 > 0.5 then
			local a = ((P1[2])-math.acos(((P1[1])^2+z^2-(P2[1])^2)/(2*(P1[1])*z))/(2*math.pi))%1
			return {z,a}
		else
			local a = ((P1[2])+math.acos(((P1[1])^2+z^2-(P2[1])^2)/(2*(P1[1])*z))/(2*math.pi))%1
			return {z,a}
		end
	end
end

function Public.Coord_add(C1,C2) -- add 2 cartesian coords {x,y}
	return {C1[1]+C2[1],C1[2]+C2[2]}
end

function Public.Coord_scale(C0,m) -- multiplies a cartesian coordinate by an amount
	return {m*C0[1],m*C0[2]}
end

function Public.Coord_multiply(C1,C2) -- multiplies 2 caresian coordinates together {x1*x2,y1*y2}
	return {C1[1]*C2[1],C1[2]*C2[2]}
end

function Public.Polar_to_Coord(P0) -- convert polar coordinates {distance,angle} to cartesian coords {x,y}
	local x = (P0[1])*math.sin((P0[2]%1)*tau)
	local y = (P0[1])*math.cos((P0[2]%1)*tau)
	return {x,y}
end

function MTtrig.Coord_to_Polar(C0) -- convert cartesian coords {x,y} to polar coordinates {distance,angle}
	local z = ((P0[1])^2+(P0[2])^2)^0.5
	local a = (math.atan2(C0[1],C0[2])/tau)%1
	return {z,a}
end

return Public