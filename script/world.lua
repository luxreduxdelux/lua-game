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

world = {}
world.__index = world

function world:new()
	local self   = table.meta_new(world, "world")

	self.entity  = {}
	self.scene   = scene:new("data/level/level")
	self.time    = 0.0
	self.step    = 0.0
	local player = player:new(self)

	return self
end

function world:tick(game)
	self.step = self.step + laravox.window.get_frame_time()

	while self.step >= TICK_STEP do
		for _, entity in ipairs(self.entity) do
			if entity.tick then
				entity:tick(game, self)
			end
		end

		self.time = self.time + TICK_STEP
		self.step = self.step - TICK_STEP
	end
end

function world:draw(game)
	local call_camera = nil
	local call_screen = nil

	if not game.menu.layout then
		self:tick(game)

		call_camera = function()
			for _, entity in ipairs(self.entity) do
				if entity.draw then
					entity:draw(game, self)
				end
			end
		end

		call_screen = function()
			for _, entity in ipairs(self.entity) do
				if entity.main then
					entity:main(game, self)
				end
			end
		end
	end

	self.scene:draw(call_camera, call_screen)
end

function world:entity_attach(entity)
	table.insert(self.entity, entity)
end

--[[----------------------------------------------------------------]]

entity = {}
entity.__index = entity

function entity:new(world)
	local self = table.meta_new(entity, "entity")

	self.point = vector_2:new(0.0, 0.0)
	self.speed = vector_2:new(0.0, 0.0)

	world:entity_attach(self)

	return self
end

--[[----------------------------------------------------------------]]

player = table.meta_new(entity, "entity")
player.__index = player

function player:new(world)
	local self = entity:new(world)
	table.meta_save(self, player, "player")

	self.camera_point = vector_2:copy(self.point)

	world.scene.system:set_texture("video/player.png")
	world.scene.system:set_texture("video/weapon.png")
	world.scene.system:set_texture("video/interface.png")

	world.player = self

	return self
end

function player:draw(game, world)
	local texture = world.scene.system:get_texture("video/player.png")

	--[[]]

	-- DRAW PLAYER

	local scale = vector_2:copy(laravox.screen.get_world_to_screen(self.point, world.scene.camera))
	local mouse = world.scene:get_screen_to_world(vector_2:copy(laravox.input.mouse.get_point()))
	local angle = (mouse - scale):normal()
	local flip  = angle.x >= 0.0 and 1.0 or -1.0
	local cycle = 0.0

	if self.speed:length() >= 16.0 then
		cycle = math.floor((world.time * 10.0) % 2.0) * 24.0
	end

	texture:draw(box_2:new(cycle, 0.0, 24.0 * flip, 24.0),
		box_2:new(self.point.x - 10.0, self.point.y - 16.0, 24.0, 24.0),
		vector_2:zero(),
		0.0,
		color:white())

	--[[]]

	-- DRAW WEAPON

	local point = self.point + vector_2:new(8.0, 8.0)
	local point_screen = vector_2:copy(laravox.screen.get_world_to_screen(point, world.scene.camera))
	local angle = (mouse - point_screen):normal()
	local angle = math.radian_to_degree(math.atan2(angle.y, angle.x))
	local texture = world.scene.system:get_texture("video/weapon.png")

	texture:draw(box_2:new(48.0, 0.0, 24.0, 24.0 * flip),
		box_2:new(point.x, point.y, 24.0, 24.0),
		vector_2:new(12.0, 12.0),
		angle,
		color:white())
end

function player:main(game, world)
	-- DRAW MOUSE CURSOR
	local mouse   = world.scene:get_screen_to_world(vector_2:copy(laravox.input.mouse.get_point()))
	local texture = world.scene.system:get_texture("video/weapon.png")

	texture:draw(box_2:new(0.0, 72.0, 24.0, 24.0),
		box_2:new(mouse.x - 12.0, mouse.y - 12.0, 24.0, 24.0),
		vector_2:zero(),
		0.0,
		color:white())

	--[[]]

	-- DRAW HEALTH

	local texture = world.scene.system:get_texture("video/interface.png")

	texture:draw(box_2:new(208.0, 114.0, 64.0, 12.0),
		box_2:new(4.0, 4.0, 64.0, 12.0),
		vector_2:zero(),
		0.0,
		color:white())
end

function player:tick(game, world)
	local MOVE_SPEED      = 128.0
	local STOP_SPEED      = 1.0
	local MOVE_DECELERATE = 10.0
	local MOVE_ACCELERATE = 12.0
	local movement        = vector_2:new(0.0, 0.0)

	--[[]]

	movement.y = laravox.input.board.get_down(INPUT_ACTION.BOARD.W) and -1.0 or movement.y
	movement.y = laravox.input.board.get_down(INPUT_ACTION.BOARD.S) and 1.0 or movement.y
	movement.x = laravox.input.board.get_down(INPUT_ACTION.BOARD.A) and -1.0 or movement.x
	movement.x = laravox.input.board.get_down(INPUT_ACTION.BOARD.D) and 1.0 or movement.x

	--[[]]

	move_speed   = (movement * MOVE_SPEED):length()
	move_where   = (movement * MOVE_SPEED):normal()

	local length = self.speed:length()

	if length >= 0.0 then
		if length < STOP_SPEED then
			length = 1.0 - TICK_STEP * (STOP_SPEED / length) * MOVE_DECELERATE
		else
			length = 1.0 - TICK_STEP * MOVE_DECELERATE
		end

		if length < 0.0 then
			self.speed:set(0.0, 0.0)
		else
			self.speed = self.speed * length
		end
	end

	length = move_speed - self.speed:length()

	if length > 0.0 then
		self.speed = self.speed + move_where * math.min(length, MOVE_ACCELERATE * move_speed * TICK_STEP)
	end

	local point = self.point + self.speed * TICK_STEP

	self.point  = point

	local scale = vector_2:copy(world.scene.target:get_scale()) * 0.5

	--[[]]

	self.camera_point = self.camera_point +
		(self.point - self.camera_point) * laravox.window.get_frame_time() * 16.0

	--[[]]

	world.scene.camera.point = scale
	world.scene.camera.shift = self.camera_point
end
