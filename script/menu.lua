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
	local self  = setmetatable({ __meta = "menu" }, menu)

	self.system = system:new()
	self.window = window:new()
	self.layout = LAYOUT_WHICH.LOGO
	self.close  = false
	self.user   = user:new()

	self.system:set_texture("data/level/level.png")

	return self
end

function menu:draw()
	---@type texture
	local texture = self.system:get_texture("data/level/level.png")
	local scale   = texture:get_scale()
	local ratio   = laravox.window.get_render_scale().x / scale.x

	texture:draw(
		box_2:new(0.0, 0.0, scale.x, scale.y),
		box_2:new(0.0, 32.0, scale.x * ratio, scale.y * ratio), vector_2:zero(), 0.0, color:scalar(66, 255)
	)

	self.layout(self)
end

local function menu_return(self, target)
	if self.window:is_return() then
		self.layout = target
	end
end

local function menu_main(self)
	self.window:draw(function()
		if self.window:button(self.user:language("PLAY_LOCAL")):is_click() then
			self.layout = LAYOUT_WHICH.PLAY_LOCAL
		end
		if self.window:button(self.user:language("PLAY_WORLD")):is_click() then
			self.layout = LAYOUT_WHICH.PLAY_WORLD
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
			self.user.video.rate, 30.0, 300.0, 1.0)

		if cache:is_change() then
			print("rate change")
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
	LOGO               = menu_main,
	MAIN               = menu_main,
	PLAY_LOCAL         = menu_main,
	PLAY_WORLD         = menu_main,
	PLAY_WORLD_CONNECT = menu_main,
	PLAY_WORLD_LOBBY   = menu_main,
	CONFIGURATION      = menu_configuration,
	ABOUT              = menu_about,
	CLOSE              = menu_close,
}
