--[[
-- Copyright (c) 2025 luxreduxdelux
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- Subject to the terms and conditions of this license, each copyright holder
-- and contributor hereby grants to those receiving rights under this license
-- a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable
-- (except for failure to satisfy the conditions of this license) patent license
-- to make, have made, use, offer to sell, sell, import, and otherwise transfer
-- this software, where such license applies only to those patent claims, already
-- acquired or hereafter acquired, licensable by such copyright holder or
-- contributor that are necessarily infringed by:
--
-- (a) their Contribution(s) (the licensed copyrights of copyright holders and
-- non-copyrightable additions of contributors, in source or binary form) alone;
-- or
--
-- (b) combination of their Contribution(s) with the work of authorship to which
-- such Contribution(s) was added by such copyright holder or contributor, if,
-- at the time the Contribution is added, such addition causes such combination
-- to be necessarily infringed. The patent license shall not apply to any other
-- combinations which include the Contribution.
--
-- Except as expressly stated above, no rights or licenses from any copyright
-- holder or contributor is granted under this license, whether expressly, by
-- implication, estoppel or otherwise.
--
-- DISCLAIMER
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

scene = {}
scene.__index = scene

function scene:new(level)
	local self  = table.meta_new(scene, "scene")

	self.system = system:new()
	self.camera = camera_2D:new(vector_2:zero(), vector_2:zero(), 0.0, 1.0)
	self.noise  = { sound = {}, music = {} }
	self.point  = vector_2:zero()
	local level = require(level)

	self.target = laravox.texture_target.new(vector_2:new(level.width * 16.0, level.height * 16.0))

	self.level  = {
		target    = laravox.texture_target.new(vector_2:new(level.width * 16.0, level.height * 16.0)),
		collision = {}
	}

	self.system:set_texture("video/level/base.png")

	self.level.target:begin(function()
		---@type texture
		local texture = self.system:get_texture("video/level/base.png")
		local scale_t = vector_2:new(16.0, 16.0)
		local scale_i = vector_2:new(16.0, 16.0)

		for _, layer in ipairs(level.layers) do
			for i, tile in ipairs(layer.data) do
				i = i - 1
				point = vector_2:new(
					math.floor(i % level.width) * scale_t.x,
					math.floor(i / level.width) * scale_t.y
				)

				if not (tile == 0) then
					tile = tile - 1

					local flip_x = bit.get_at(tile, 31) and -1.0 or 1.0
					local flip_y = bit.get_at(tile, 30) and -1.0 or 1.0

					tile = bit.lshift(tile, 4)
					tile = bit.rshift(tile, 4)

					-- 18.0 (tile-set scale-x)
					tile = vector_2:new(
						math.floor(tile % 18.0),
						math.floor(tile / 18.0)
					)

					texture:draw(
						box_2:new(tile.x * scale_i.x, tile.y * scale_i.y, scale_i.x * flip_x, scale_i.y * flip_y),
						box_2:new(point.x, point.y, scale_t.x, scale_t.y), vector_2:zero(), 0.0,
						color:white()
					)

					if layer.properties.collision then
						table.insert(self.level.collision, point)
					end
				end
			end
		end
	end)

	return self
end

local function scene_action(self, noise_list, asset_get, asset_call, ...)
	for _, noise in pairs(noise_list) do
		local noise = asset_get(self.system, noise.path)
		noise[asset_call](noise, ...)
	end
end

local function scene_remove(self, noise_list, asset_get)
	for i, noise in pairs(noise_list) do
		local noise = asset_get(self.system, noise.path)
		if not noise:get_play() then
			noise_list[i] = nil
		end
	end
end

function scene:clear()
	scene_action(self, self.noise.sound, self.system.get_sound, "stop")
	scene_action(self, self.noise.music, self.system.get_music, "stop")
end

function scene:get_screen_to_world(point)
	return (point - self.point) * (1.0 / self.zoom)
end

function scene:draw(call_camera, call_screen)
	local scale_screen = laravox.window.get_render_scale()
	local scale_target = self.level.target:get_scale()

	self.zoom          = math.min(scale_screen.x / scale_target.x, scale_screen.y / scale_target.y)
	self.point.x       = (scale_screen.x - scale_target.x * self.zoom) * 0.5
	self.point.y       = (scale_screen.y - scale_target.y * self.zoom) * 0.5

	if call_camera or call then
		self.target:begin(function()
			--laravox.screen.wipe(color:new(243, 205, 172, 255))
			laravox.screen.wipe(color:r())

			laravox.screen.draw_2D(function()
				self.level.target:draw(
					box_2:new(0.0, 0.0, scale_target.x, scale_target.y),
					box_2:new(0.0, 0.0, scale_target.x, scale_target.y), vector_2:zero(), 0.0,
					color:white()
				)

				if call_camera then call_camera() end
			end, self.camera)

			if call_screen then call_screen() end
		end)
	end

	local scale = self.target:get_scale()

	self.target:draw(
		box_2:new(0.0, 0.0, scale.x, scale.y),
		box_2:new(
			self.point.x,
			self.point.y,
			scale.x * self.zoom,
			scale.y * self.zoom
		),
		vector_2:zero(), 0.0, color:white()
	)

	scene_remove(self, self.noise.sound, self.system.get_sound)
	scene_remove(self, self.noise.music, self.system.get_music)
	scene_action(self, self.noise.music, self.system.get_music, "update")
end

function scene:play_sound(path)
	local sound = self.system:get_sound(path)

	sound:play()

	if not self.noise.sound[path] then
		self.noise.sound[path] = noise:new(path)
	end
end

--[[----------------------------------------------------------------]]

noise = {}
noise.__index = noise

function noise:new(path)
	local self = table.meta_new(noise, "noise")

	self.path = path

	return self
end
