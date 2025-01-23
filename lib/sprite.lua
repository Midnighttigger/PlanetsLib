local trig = require("lib.trig")
local Public = {}

function Public.manipulate(spr0,ccpos,size) -- for simplicity for irregular shapes, size is to be taken as the width of the whole sprite, ccpos is assumed to be scaled already
	local sprite = table.deepcopy(spr0)
	if sprite.layers then
		local xlength = {0,0}
		for _,spr in pairs(sprite.layers) do
			if not spr.width then
				spr.width = spr.size
				spr.height = spr.size
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
			spr.shift = trig.Coord_add(trig.Coord_scale(spr.shift,sprite.scale),trig.Coord_multiply(ccpos,{1,-1}))
		end
		return sprite
	else
		if not sprite.width then
			sprite.width = sprite.size
			sprite.height = sprite.size
		end
		if not sprite.shift then
			sprite.shift = {0,0}
		end
		sprite.scale = (size/sprite.width)
		sprite.shift = trig.Coord_add(trig.Coord_scale(sprite.shift,sprite.scale),trig.Coord_multiply(ccpos,{1,-1}))
		return sprite
	end
end
function Public.manipulate_scale(spr0,ccpos,scale) -- similar to Public.manipulate but with scale
	local sprite = table.deepcopy(spr0)
	if sprite.layers then
		for _,spr in pairs(sprite.layers) do
			if not spr.shift then
				spr.shift = {0,0}
			end
			spr.scale = spr.scale*scale
			spr.shift = trig.Coord_add(trig.Coord_scale(spr.shift,scale),trig.Coord_multiply(ccpos,{1,-1}))
		end
		return sprite
	else
		if not sprite.shift then
			sprite.shift = {0,0}
		end
		sprite.scale = scale
		sprite.shift = trig.Coord_add(trig.Coord_scale(sprite.shift,scale),trig.Coord_multiply(ccpos,{1,-1}))
		return sprite
	end
end
local imglimit = 4096 -- is there a way to find out procederally?
function Public.decay(spr) -- splits a sprite until its within the image limit, not implemented yet
	if spr.layers then
		local sprite = table.deepcopy(spr)
	else
		local sprite = {layers=table.deepcopy(spr)}
	end
	for _,layer in pairs(sprite.layers) do
		if not layer.width then
			layer.width = layer.size
			layer.height = layer.size
		end
		if not layer.shift then
			layer.shift = {0,0}
		end
		if layer.width > imglimit then
				if layer.height > imglimit then
					table.insert(sprite.layers,{type=sprite,filename=layer.filename,size=imglimit,shift=trig.Coord_add(layer.shift,{layer.width*0.5-imglimit,layer.height*0.5+imglimit}),x=(layer.x or 0),y=(layer.y or 0)}) -- top left
					local checklist = {layers={}}
					table.insert(checklist.layers,{type=sprite,filename=layer.filename,width=layer.width-imglimit,height=imglimit,shift=trig.Coord_add(layer.shift,{layer.width*0.5+imglimit,layer.height*0.5+imglimit}),x=((layer.x or 0)+imglimit),y=(layer.y or 0)}) -- top right
					table.insert(checklist.layers,{type=sprite,filename=layer.filename,width=imglimit,height=layer.height-imglimit,shift=trig.Coord_add(layer.shift,{layer.width*0.5-imglimit,layer.height*0.5-imglimit}),x=(layer.x or 0),y=((layer.y or 0)+imglimit)}) -- bottom left
					table.insert(checklist.layers,{type=sprite,filename=layer.filename,width=layer.height-imglimit,width=layer.width-imglimit,shift=trig.Coord_add(layer.shift,{layer.width*0.5-imglimit,layer.height*0.5+imglimit}),x=((layer.x or 0)+imglimit),y=((layer.x or 0)+imglimit)}) -- bottom right
					for _,sp in pairs(Public.decay(checklist).layers) do
						table.insert(sprite.layers,sp)
					end
					layer = nil
				else
					table.insert(sprite.layers,{type=sprite,filename=layer.filename,width=imglimit,height=layer.height,shift=trig.Coord_add(layer.shift,{layer.width*0.5-imglimit,0}),x=(layer.x or 0),y=(layer.y or 0)}) -- left
					local checklist = {layers={}}
					table.insert(checklist.layers,{type=sprite,filename=layer.filename,width=layer.width-imglimit,height=layer.height,shift=trig.Coord_add(layer.shift,{layer.width*0.5+imglimit,0}),x=((layer.x or 0)+imglimit),y=(layer.y or 0)}) -- right
					for _,sp in pairs(Public.decay(checklist).layers) do
						table.insert(sprite.layers,sp)
					end
					layer = nil
				end
		elseif layer.height > imglimit then
			table.insert(sprite.layers,{type=sprite,filename=layer.filename,width=layer.width,height=imglimit,shift=trig.Coord_add(layer.shift,{0,layer.height*0.5+imglimit}),x=(layer.x or 0),y=(layer.y or 0)}) -- top
			local checklist = {layers={}}
			table.insert(checklist.layers,{type=sprite,filename=layer.filename,width=layer.width,height=layer.height-imglimit,shift=trig.Coord_add(layer.shift,{0,layer.height*0.5-imglimit}),x=(layer.x or 0),y=((layer.y or 0)+imglimit)}) -- bottom
			for _,sp in pairs(Public.decay(checklist).layers) do
				table.insert(sprite.layers,sp)
			end
			layer = nil
		end
	end
	return sprite
end
return Public