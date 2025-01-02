local Public = {}

function Public.manipulate(spr0,ccpos,size) -- for simplicity for irregular shapes, size is to be taken as the width of the whole sprite, ccpos is assumed to be scaled already
	local sprite = table.deepcopy(spr0)
	if sprite.layers then
		local xlength = {0,0}
		for _,spr in pairs(sprite.layers) do
			if not spr.width then
				spr.width = spr.size
			end
			if not spr.scale then
				spr.scale = 1
			end
			if not spr.shift then
				spr.shift = {0,0}
			end
			if (spr.shift[1]-(spr.scale*spr.width*0.5)) < xlength[1] then
				xlength[1] = (spr.shift[1]-(spr.scale*spr.width*0.5))
			end
			if (spr.shift[1]+(spr.scale*spr.width*0.5)) > xlength[2] then
				xlength[2] = (spr.shift[1]+(spr.scale*spr.width*0.5))
			end
		end
		sprite.size = xlength[1]-xlength[2]
		sprite.scale = (size/sprite.size)
		for _,spr in pairs(sprite.layers) do
			if not spr.shift then
				spr.shift = {0,0}
			end
			spr.scale = spr.scale*sprite.scale
			spr.shift = MTtrig.Cadd(MTtrig.CmulS(spr.shift,sprite.scale),MTtrig.Cmul(ccpos,{1,-1}))
		end
		return sprite
	else
		if not sprite.width then
			sprite.width = sprite.size
		end
		if not sprite.shift then
			sprite.shift = {0,0}
		end
		sprite.scale = (size/sprite.width)
		sprite.shift = MTtrig.Cadd(MTtrig.CmulS(sprite.shift,sprite.scale),MTtrig.Cmul(ccpos,{1,-1}))
		return sprite
	end
end
function Public.manipulate_scale(spr0,ccpos,scale) -- for simplicity for irregular shapes, ccpos is assumed to be scaled already, takes scale
	local sprite = table.deepcopy(spr0)
	if sprite.layers then
		for _,spr in pairs(sprite.layers) do
			if not spr.shift then
				spr.shift = {0,0}
			end
			spr.scale = spr.scale*scale
			spr.shift = MTtrig.Cadd(MTtrig.CmulS(spr.shift,spr.scale),MTtrig.Cmul(ccpos,{1,-1}))
		end
		return sprite
	else
		if not sprite.shift then
			sprite.shift = {0,0}
		end
		sprite.scale = scale
		sprite.shift = MTtrig.Cadd(MTtrig.CmulS(sprite.shift,scale),MTtrig.Cmul(ccpos,{1,-1}))
		return sprite
	end
end

return Public