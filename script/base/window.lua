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

local FONT_SCALE        = 32.0
local FONT_SPACE        = 1.0

local INPUT_BIND        = {
	ACCEPT = action:new(INPUT_ACTION.BOARD.ENTER, INPUT_ACTION.MOUSE.LEFT, INPUT_ACTION.PAD.R_FACE_DOWN),
	RETURN = action:new(INPUT_ACTION.BOARD.ESCAPE, INPUT_ACTION.MOUSE.RIGHT, INPUT_ACTION.PAD.R_FACE_RIGHT),
	MOVE_A = action:new(INPUT_ACTION.BOARD.UP, nil, INPUT_ACTION.PAD.L_FACE_UP),
	MOVE_B = action:new(INPUT_ACTION.BOARD.DOWN, nil, INPUT_ACTION.PAD.L_FACE_DOWN),
	SIDE_A = action:new(INPUT_ACTION.BOARD.LEFT, nil, INPUT_ACTION.PAD.L_FACE_LEFT),
	SIDE_B = action:new(INPUT_ACTION.BOARD.RIGHT, nil, INPUT_ACTION.PAD.L_FACE_RIGHT),
}

local INPUT_SHEET       = {
	BOARD = {
		ACCEPT = vector_2:new(7.0, 4.0),
		RETURN = vector_2:new(2.0, 9.0),
		MOVE_A = vector_2:new(0.0, 12.0),
		MOVE_B = vector_2:new(7.0, 13.0),
		SIDE_A = vector_2:new(11.0, 13.0),
		SIDE_B = vector_2:new(14.0, 13.0),
	},
	MOUSE = {
		ACCEPT = vector_2:new(3.0, 1.0),
		RETURN = vector_2:new(7.0, 1.0),
	},
	PAD = {
		ACCEPT = vector_2:new(5.0, 10.0),
		RETURN = vector_2:new(5.0, 10.0),
		MOVE_A = vector_2:new(2.0, 8.0),
		MOVE_B = vector_2:new(5.0, 9.0),
		SIDE_A = vector_2:new(9.0, 9.0),
		SIDE_B = vector_2:new(0.0, 8.0),
	}
}

local WIDGET_SCALE      = vector_2:new(256.0, 32.0)
local WIDGET_COLOR_GREY = color:scalar(127, 255)

--[[----------------------------------------------------------------]]

window = {}
window.__index = window

function window:new()
	local self = setmetatable({ __meta = "window" }, window)

	self.system = system:new()
	self.point = vector_2:zero()
	self.mouse = vector_2:zero()
	self.scale = vector_2:zero()
	self.glyph = false
	self.frame = 0.0
	self.index = 0
	self.focus = nil
	self.input = { which = INPUT_DEVICE.BOARD, index = 0 }
	self.cache = {}

	self.system:set_font("video/font.ttf")
	self.system:set_texture("video/window/board-mouse.png")
	self.system:set_texture("video/window/pad-0.png")
	self.system:set_sound("audio/click-a.ogg")
	self.system:set_sound("audio/click-b.ogg")
	self.system:set_sound("audio/switch-a.ogg")
	self.system:set_sound("audio/switch-b.ogg")
	self.system:set_sound("audio/tap-a.ogg")
	self.system:set_sound("audio/tap-b.ogg")

	return self
end

local function window_begin(self)
	self.point:set(8.0, 8.0)
	self.mouse:set(laravox.input.mouse.get_point())
	self.scale:set(laravox.window.get_render_scale())
	self.glyph      = false
	self.glyph_draw = nil
	self.frame      = laravox.window.get_frame_time()
	self.index      = 0

	--[[]]

	local delta          = vector_2:copy(laravox.input.mouse.get_delta())
	local board_activity = laravox.input.board.get_last_press()
	local mouse_activity = laravox.input.mouse.get_last_press() or delta:length() > 0.0
	local pad_activity   = laravox.input.pad.get_last_press()

	if board_activity then
		if not (self.input.which == INPUT_DEVICE.BOARD) then
			laravox.input.mouse.show_cursor(true)
		end

		self.input.which = INPUT_DEVICE.BOARD
	elseif mouse_activity then
		if not (self.input.which == INPUT_DEVICE.MOUSE) then
			laravox.input.mouse.show_cursor(true)
		end

		self.input.which = INPUT_DEVICE.MOUSE
	elseif pad_activity then
		if not (self.input.which == INPUT_DEVICE.PAD) then
			laravox.input.mouse.show_cursor(false)
		end

		self.input.which = INPUT_DEVICE.PAD
	end
end

local function window_close(self)
	if self.glyph_draw then
		self.glyph_draw()
	end

	if INPUT_BIND.MOVE_A:press(self.input.which) then
		self.input.index = self.input.index - 1
	elseif INPUT_BIND.MOVE_B:press(self.input.which) then
		self.input.index = self.input.index + 1
	end

	self.input.index = math.clamp(self.input.index, 0, self.index - 1)
end

local function window_glyph(self, cache, draw)
	if cache:is_hover() then
		local label = self.system:get_font("video/font.ttf")
		local sheet = "video/window/board-mouse.png"
		local input = "BOARD"

		if self.input.which == INPUT_DEVICE.MOUSE then
			input = "MOUSE"
		elseif self.input.which == INPUT_DEVICE.PAD then
			input = "PAD"
			sheet = "video/window/pad-0.png"
		end

		local sheet = self.system:get_texture(sheet)
		local entry = draw[string.lower(input)]
		local point = vector_2:new(8.0, self.scale.y - 48.0)

		if self.glyph then
			table.join(entry, {
				[#entry + 1] = "RETURN",
				[#entry + 2] = "Return"
			})
		end

		self.glyph_draw = function()
			for i, entry in ipairs(entry) do
				local texture = INPUT_SHEET[input][entry]

				if texture then
					sheet:draw(
						box_2:new(texture.x * 64.0, texture.y * 64.0, 64.0, 64.0),
						box_2:new(point.x, point.y - 8.0, 48.0, 48.0),
						vector_2:zero(),
						0.0,
						color:white()
					)
					point.x = point.x + 48.0
				else
					local measure = label:measure(entry, FONT_SCALE, FONT_SPACE)
					label:draw(entry, point, FONT_SCALE, FONT_SPACE, color:white())
					point.x = point.x + measure.x + 4.0
				end
			end
		end
	end
end

local function window_area(window, box)
	if not window.area then
		return true
	end

	return window.area:intersect_box(box)
end

function window:set_point(point)
	self.point = point
end

function window:set_focus(focus)
	if focus then
		self.focus = self.index
	else
		self.focus = nil
	end
end

function window:draw(call)
	window_begin(self)
	call(self)
	window_close(self)
end

function window:is_return()
	if not self.focus then
		self.glyph = true

		if INPUT_BIND.RETURN:press(self.input.which) then
			self.system:get_sound("audio/switch-a.ogg"):play()
			return true
		end
	end

	return false
end

function window:scroll(scale, call)
	self.area   = box_2:new(self.point.x, self.point.y, scale.x, scale.y)
	local cache = cache:update(self, "scroll", self.area)
	local point = self.point.y
	local delta = 0.0

	if cache:is_hover() then
		delta = laravox.input.mouse.get_wheel().y
	end

	laravox.screen.draw_box_2(self.area, vector_2:zero(), 0.0, color:scalar(33, 255))

	if cache.scroll_view >= 0.0 then
		cache.scroll = math.clamp(cache.scroll + delta * 8.0, -cache.scroll_view, 0.0)

		self.hover   = nil
		self.point.y = point + cache.scroll

		laravox.screen.draw_scissor(call, self.area)

		if self.hover then
			if not self.hover:intersect_box(self.area) then
				local scroll = point + cache.scroll + scale.y - self.hover.p_y - self.hover.s_y

				if scroll >= 0.0 then
					cache.scroll = point + cache.scroll - self.hover.p_y
				else
					cache.scroll = point + cache.scroll + scale.y - self.hover.p_y - self.hover.s_y
				end
			end
		end
	else
		call()
	end

	cache.scroll_view = self.point.y - cache.scroll - point - scale.y

	--[[]]

	self.point.y = point + scale.y
	self.area = nil

	return cache
end

function window:text(label)
	local font = self.system:get_font("video/font.ttf")

	font:draw(label, self.point, FONT_SCALE, FONT_SPACE, color:white())

	--[[]]

	self.point.y = self.point.y + FONT_SCALE

	return cache
end

function window:button(label)
	local font  = self.system:get_font("video/font.ttf")
	local box   = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.x, WIDGET_SCALE.y)
	local cache = cache:update(self, label, box)

	if window_area(self, box) then
		font:draw(label, self.point, FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))
	end

	window_glyph(self, cache, {
		board = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Interact"
		},
		mouse = {
			"ACCEPT",
			"Interact"
		},
		pad = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Interact"
		}
	})

	--[[]]

	self.point.y = self.point.y + FONT_SCALE
	self.index   = self.index + 1

	return cache
end

function window:toggle(label, value)
	local font  = self.system:get_font("video/font.ttf")
	local box_a = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.x, WIDGET_SCALE.y)
	local box_b = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.y, WIDGET_SCALE.y)
	local cache = cache:update(self, label, box_a)

	if window_area(self, box_a) then
		if value then
			laravox.screen.draw_box_2(box_b, vector_2:zero(), 0.0, color:g())
		end

		font:draw(label, self.point + vector_2:new(box_b.s_x + 4.0, 0.0), FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))

		--[[]]

		if cache:is_click() then
			value        = not value
			cache.change = true
		end
	end

	window_glyph(self, cache, {
		board = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Toggle"
		},
		mouse = {
			"ACCEPT",
			"Toggle"
		},
		pad = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Toggle"
		}
	})

	--[[]]

	self.point.y = self.point.y + box_a.s_y
	self.index   = self.index + 1

	return value, cache
end

function window:slider(label, value, min, max, step)
	local font   = self.system:get_font("video/font.ttf")
	local box    = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.x, WIDGET_SCALE.y)
	local cache  = cache:update(self, label, box)
	local scale  = font:measure(string.format("%.2f", value), FONT_SCALE, FONT_SPACE)
	local former = value

	if window_area(self, box) then
		font:draw(label, self.point + vector_2:new(box.s_x + 4.0, 0.0), FONT_SCALE,
			FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))
		font:draw(string.format("%.2f", value), self.point + vector_2:new((box.s_x - scale.x) / 2.0, 0.0), FONT_SCALE,
			FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))

		--[[]]

		if self.input.which == INPUT_DEVICE.MOUSE then
			if cache:is_focus() then
				if INPUT_BIND.ACCEPT:release(self.input.which) then
					self:set_focus(false)
				end

				local input = math.percentage_from_value(self.mouse.x, box.p_x, box.p_x + box.s_x)
				local input = math.value_from_percentage(math.clamp(input, 0.0, 1.0), min, max)
				value = math.snap(input, step)
			else
				if cache:is_click() then
					self:set_focus(true)
				end
			end
		else
			if cache:is_side_a() then
				value = value - step
			elseif cache:is_side_b() then
				value = value + step
			end
		end

		value = math.clamp(value, min, max)

		cache.change = not (value == former)
	end

	window_glyph(self, cache, {
		board = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"SIDE_A",
			"SIDE_B",
			"Modify"
		},
		mouse = {
			"ACCEPT",
			"Modify"
		},
		pad = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"SIDE_A",
			"SIDE_B",
			"Modify"
		}
	})

	--[[]]

	self.point.y = self.point.y + box.s_y
	self.index   = self.index + 1

	return value, cache
end

function window:switch(label, value, choice)
	local font   = self.system:get_font("video/font.ttf")
	local box    = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.x, WIDGET_SCALE.y)
	local cache  = cache:update(self, label, box)
	local scale  = font:measure(choice[value], FONT_SCALE, FONT_SPACE)
	local former = value

	if window_area(self, box) then
		font:draw(label, self.point + vector_2:new(box.s_x + 4.0, 0.0), FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))
		font:draw(choice[value], self.point + vector_2:new((box.s_x - scale.x) / 2.0, 0.0), FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))

		--[[]]

		if self.input.which == INPUT_DEVICE.MOUSE then
			if cache:is_click() then
				value = value + 1
			end

			value = math.fmod(value, #choice + 1)
		else
			if cache:is_side_a() then
				value = value - 1
			elseif cache:is_side_b() then
				value = value + 1
			end
		end

		value = math.clamp(value, 1, #choice)

		cache.change = not (value == former)
	end

	window_glyph(self, cache, {
		board = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"SIDE_A",
			"SIDE_B",
			"Modify"
		},
		mouse = {
			"ACCEPT",
			"Modify"
		},
		pad = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"SIDE_A",
			"SIDE_B",
			"Modify"
		}
	})

	--[[]]

	self.point.y = self.point.y + box.s_y
	self.index   = self.index + 1

	return value, cache
end

function window:record(label, value, choice)
	local font  = self.system:get_font("video/font.ttf")
	local box   = box_2:new(self.point.x, self.point.y, WIDGET_SCALE.x, WIDGET_SCALE.y)
	local cache = cache:update(self, label, box)

	if window_area(self, box) then
		font:draw(label, self.point + vector_2:new(box.s_x + 4.0, 0.0), FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))
		font:draw(value, self.point + vector_2:new(0.0, 0.0), FONT_SCALE, FONT_SPACE,
			cache:get_color(self):interpolate(WIDGET_COLOR_GREY, 1.0 - cache.alpha))

		--[[]]

		if cache:is_focus() then
			if cache:is_click() then
				self:set_focus(false)
			end

			local character = laravox.input.board.get_last_character()

			if laravox.input.board.get_press(INPUT_ACTION.BOARD.BACKSPACE) or laravox.input.board.get_press_repeat(INPUT_ACTION.BOARD.BACKSPACE) then
				value = string.sub(value, 0, #value - 1)
			elseif character then
				value = value .. string.char(character)
			end
		else
			if cache:is_click() then
				self:set_focus(true)
			end
		end
	end

	window_glyph(self, cache, {
		board = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Interact"
		},
		mouse = {
			"ACCEPT",
			"Interact"
		},
		pad = {
			"MOVE_A",
			"MOVE_B",
			"Browse",
			"ACCEPT",
			"Interact"
		}
	})

	--[[]]

	self.point.y = self.point.y + box.s_y
	self.index   = self.index + 1

	return value, cache
end

--[[--------------------------------------------------------------------------------]]

cache = {}
cache.__index = cache

function cache:new()
	local self       = setmetatable({ __meta = "cache" }, cache)

	self.alpha       = 0.0
	self.scroll      = 0.0
	self.scroll_view = 0.0
	self.sound       = false
	self.focus       = false
	self.hover       = false
	self.click       = false
	self.side_a      = false
	self.side_b      = false
	self.change      = false

	return self
end

function cache:update(window, label, box)
	local label   = label .. window.index
	local i_cache = window.cache[label]

	if not i_cache then
		i_cache = cache:new()
		window.cache[label] = i_cache
	end

	i_cache.focus = (window.focus and window.focus == window.index)

	if i_cache.focus then
		i_cache.hover = true
	else
		if not window.focus then
			if window.input.which == INPUT_DEVICE.MOUSE then
				if (not window.area) or window.area:intersect_point(window.mouse) then
					i_cache.hover = box:intersect_point(window.mouse)
					--window.input.index = window.index
				else
					i_cache.hover = false
				end
			else
				i_cache.hover = window.input.index == window.index
			end
		end
	end

	i_cache.click  = i_cache.hover and INPUT_BIND.ACCEPT:press(window.input.which)
	i_cache.side_a = i_cache.hover and INPUT_BIND.SIDE_A:press(window.input.which)
	i_cache.side_b = i_cache.hover and INPUT_BIND.SIDE_B:press(window.input.which)

	if i_cache.click or i_cache.side_a or i_cache.side_b then
		window.system:get_sound("audio/switch-a.ogg"):play()
	end

	if i_cache.hover then
		if not i_cache.sound then
			window.system:get_sound("audio/click-b.ogg"):play()
			i_cache.sound = true
		end

		window.hover  = box
		i_cache.alpha = i_cache.alpha + window.frame * 8.0
	else
		i_cache.sound = false
		i_cache.alpha = i_cache.alpha - window.frame
	end

	i_cache.alpha  = math.clamp(i_cache.alpha, 0.25, 1.0)
	i_cache.change = false

	return i_cache
end

function cache:get_color(window)
	if window.focus then
		if window.focus == window.index then
			return color:white()
		else
			return color:scalar(33, 255)
		end
	else
		return color:white()
	end
end

function cache:is_focus()
	return self.focus
end

function cache:is_hover()
	return self.hover
end

function cache:is_click()
	return self.click
end

function cache:is_side_a()
	return self.side_a
end

function cache:is_side_b()
	return self.side_b
end

function cache:is_change()
	return self.change
end
