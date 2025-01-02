local Public = {}

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

return Public