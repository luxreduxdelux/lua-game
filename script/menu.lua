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

menu = {}
menu.__index = menu

function menu:new()
	local self  = table.meta_new(menu, "menu")

	self.system = system:new()
	self.window = window:new()
	self.layout = LAYOUT_WHICH.LOGO
	self.close  = false
	self.delta  = 0.0
	self.scene  = scene:new("data/level/level")
	self.lobby  = nil
	self.time   = 0.0
	self.user   = user:new()

	self.system:set_texture("video/logo.png")
	self.system:set_font("video/logo.ttf", 64)

	--self.scene.system:set_sound("audio/logo.ogg")
	--self.scene:play_sound("audio/logo.ogg")

	return self
end

function menu:draw(game)
	local toggle = laravox.input.board.get_press(INPUT_ACTION.BOARD.ESCAPE)

	self.time = self.time + laravox.window.get_frame_time()

	if game.world and self.window:is_return() then
		if self.layout == LAYOUT_WHICH.MAIN then
			self.layout = nil
		else
			self.layout = LAYOUT_WHICH.MAIN
		end
	end

	if self.layout then
		if not (self.layout == LAYOUT_WHICH.LOGO) then
			local scale = laravox.window.get_render_scale()

			if not game.world then
				self.scene:draw()
			end

			laravox.screen.draw_box_2(box_2:new(0.0, 0.0, scale.x, scale.y), vector_2:zero(), 0.0, color:scalar(0, 160))
		end

		self:layout(game)
	end
end

local function fade(time, fade_a, fade_b)
	if time >= fade_b + fade_a then
		return 0.0
	elseif time >= fade_b then
		local c = math.percentage_from_value(time, fade_b, fade_b + fade_a);
		local s = math.pi * 0.5 + (math.pi * 0.5) * c;

		return math.sin(s)
	elseif time >= fade_a then
		return 1.0
	else
		local c = math.percentage_from_value(time, 0.0, fade_a);
		local s = math.pi * 0.5 * c;

		return math.sin(s)
	end
end

local function menu_return(self, target)
	if self.window:is_return() then
		self.layout = target
		return true
	end

	return false
end

local function menu_logo(self)
	local image     = self.system:get_texture("video/logo.png")
	local label     = self.system:get_font("video/logo.ttf")
	local scale     = vector_2:copy(laravox.window.get_render_scale()) * 0.5
	local frame_t_a = (self.time * 5.0) % 10.0
	local frame_p_a = vector_2:new(
		math.floor(frame_t_a % 4.0),
		math.floor(frame_t_a / 4.0)
	)
	--local frame_t_b = (self.time + 1.0) % 10.0
	--local frame_p_b = vector_2:new(
	--	math.floor(frame_t_b % 4.0),
	--	math.floor(frame_t_b / 4.0)
	--)
	--local alpha     = math.ease_in_out_quad(frame_t_b - math.modf(frame_t_b))
	local black     = fade(math.max(self.time - 1.0, 0.0), 2.0, 8.0)

	image:draw(
		box_2:new(frame_p_a.x * 256.0, frame_p_a.y * 256.0, 256.0, 256.0),
		box_2:new(scale.x - 128.0, scale.y - 224.0, 256.0, 256.0), vector_2:zero(), 0.0,
		color:white()
	)

	--[[
	image:draw(
		box_2:new(frame_p_b.x * 256.0, frame_p_b.y * 256.0, 256.0, 256.0),
		box_2:new(scale.x - 128.0, scale.y - 224.0, 256.0, 256.0), vector_2:zero(), 0.0,
		color:white():alpha(alpha)
	)
	--]]

	local measure = vector_2:copy(label:measure("land\nmine\ncat.", 64.0, 8.0)) * 0.5

	label:draw("land\nmine\ncat.", scale - measure + vector_2:new(-8.0, 72.0), 64.0, 8.0, color:white())

	laravox.screen.draw_box_2(box_2:new(0.0, 0.0, scale.x * 2.0, scale.y * 2.0), vector_2:zero(), 0.0,
		color:black():alpha(1.0 - black))

	if self.time >= 0.5 and laravox.input.board.get_last_press() or laravox.input.mouse.get_last_press() or laravox.input.pad.get_last_press() or self.time >= 12.0 then
		self.scene:clear()
		self.layout = LAYOUT_WHICH.MAIN
	end
end

local function menu_main(self, game)
	self.window:draw(function()
		if self.window:button("Play"):is_click() then
			self.layout = nil
			game.world  = world:new()
		end
		if self.window:button(self.user:language("CONFIGURATION")):is_click() then
			self.layout = LAYOUT_WHICH.CONFIGURATION
		end
		if self.window:button(self.user:language("ABOUT")):is_click() then
			self.layout = LAYOUT_WHICH.ABOUT
		end
		if self.window:button(self.user:language("CLOSE")):is_click() then
			self.layout = LAYOUT_WHICH.CLOSE
		end
	end)
end

local function menu_configuration(self)
	self.window:draw(function()
		menu_return(self, LAYOUT_WHICH.MAIN)

		local cache = nil

		self.user.video.name = self.window:record(self.user:language("PLAYER_NAME"),
			self.user.video.name)
		self.user.video.sync = self.window:toggle(self.user:language("FRAME_SYNC"),
			self.user.video.sync)
		self.user.video.full, cache = self.window:toggle(self.user:language("VIDEO_FULL"),
			self.user.video.full)

		if cache:is_change() then
			print("mode change")
		end

		self.user.video.glyph = self.window:switch(self.user:language("CONTROLLER_GLYPH"),
			self.user.video.glyph, { "PlayStation", "Xbox", "Steam" })
		self.user.video.language = self.window:switch(self.user:language("LANGUAGE"),
			self.user.video.language, LANGUAGE.CHOICE_TABLE)
		self.user.video.rate, cache = self.window:slider(self.user:language("FRAME_RATE"),
			self.user.video.rate, 10.0, 300.0, 1.0)

		if cache:is_change() then
			laravox.window.set_frame_rate(self.user.video.rate)
		end

		self.user.video.shake = self.window:slider(self.user:language("SCREEN_SHAKE"),
			self.user.video.shake, 0.0, 2.0, 0.1)
		self.user.audio.sound = self.window:slider(self.user:language("VOLUME_SOUND"),
			self.user.audio.sound, 0.0, 1.0, 0.1)
		self.user.audio.music = self.window:slider(self.user:language("VOLUME_MUSIC"),
			self.user.audio.music, 0.0, 1.0, 0.1)
	end)
end

local function menu_about(self)
	self.window:draw(function()
		menu_return(self, LAYOUT_WHICH.MAIN)

		self.window:text("fetse - art, level design")
		self.window:text("luxreduxdelux - code, level design")

		if self.window:button("Return"):is_click() then
			self.layout = LAYOUT_WHICH.MAIN
		end
	end)
end

local function menu_close(self)
	self.window:draw(function()
		menu_return(self, LAYOUT_WHICH.MAIN)

		self.window:text("Close?")

		if self.window:button("Accept"):is_click() then
			self.close = true
		end
		if self.window:button("Return"):is_click() then
			self.layout = LAYOUT_WHICH.MAIN
		end
	end)
end

LAYOUT_WHICH = {
	LOGO          = menu_logo,
	MAIN          = menu_main,
	CONFIGURATION = menu_configuration,
	ABOUT         = menu_about,
	CLOSE         = menu_close,
}
