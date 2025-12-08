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

INPUT_DEVICE = {
	BOARD = 0,
	MOUSE = 1,
	PAD   = 2
}

INPUT_ACTION = {
	BOARD = {
		NULL         = 0,
		APOSTROPHE   = 39,
		COMMA        = 44,
		MINUS        = 45,
		PERIOD       = 46,
		SLASH        = 47,
		ZERO         = 48,
		ONE          = 49,
		TWO          = 50,
		THREE        = 51,
		FOUR         = 52,
		FIVE         = 53,
		SIX          = 54,
		SEVEN        = 55,
		EIGHT        = 56,
		NINE         = 57,
		SEMICOLON    = 59,
		EQUAL        = 61,
		A            = 65,
		B            = 66,
		C            = 67,
		D            = 68,
		E            = 69,
		F            = 70,
		G            = 71,
		H            = 72,
		I            = 73,
		J            = 74,
		K            = 75,
		L            = 76,
		M            = 77,
		N            = 78,
		O            = 79,
		P            = 80,
		Q            = 81,
		R            = 82,
		S            = 83,
		T            = 84,
		U            = 85,
		V            = 86,
		W            = 87,
		X            = 88,
		Y            = 89,
		Z            = 90,
		L_BRACKET    = 91,
		BACKSLASH    = 92,
		R_BRACKET    = 93,
		GRAVE        = 96,
		SPACE        = 32,
		ESCAPE       = 256,
		ENTER        = 257,
		TAB          = 258,
		BACKSPACE    = 259,
		INSERT       = 260,
		DELETE       = 261,
		RIGHT        = 262,
		LEFT         = 263,
		DOWN         = 264,
		UP           = 265,
		PAGE_UP      = 266,
		PAGE_DOWN    = 267,
		HOME         = 268,
		END          = 269,
		CAPS_LOCK    = 280,
		SCROLL_LOCK  = 281,
		NUMBER_LOCK  = 282,
		PRINT_SCREEN = 283,
		PAUSE        = 284,
		F1           = 290,
		F2           = 291,
		F3           = 292,
		F4           = 293,
		F5           = 294,
		F6           = 295,
		F7           = 296,
		F8           = 297,
		F9           = 298,
		F10          = 299,
		F11          = 300,
		F12          = 301,
		L_SHIFT      = 340,
		L_CONTROL    = 341,
		L_ALT        = 342,
		L_SUPER      = 343,
		R_SHIFT      = 344,
		R_CONTROL    = 345,
		R_ALT        = 346,
		R_SUPER      = 347,
		KB_MENU      = 348,
		PAD_0        = 320,
		PAD_1        = 321,
		PAD_2        = 322,
		PAD_3        = 323,
		PAD_4        = 324,
		PAD_5        = 325,
		PAD_6        = 326,
		PAD_7        = 327,
		PAD_8        = 328,
		PAD_9        = 329,
		PAD_DECIMAL  = 330,
		PAD_DIVIDE   = 331,
		PAD_MULTIPLY = 332,
		PAD_SUBTRACT = 333,
		PAD_ADD      = 334,
		PAD_ENTER    = 335,
		PAD_EQUAL    = 336,
		BACK         = 4,
		MENU         = 5,
		VOLUME_UP    = 24,
		VOLUME_DOWN  = 25
	},
	MOUSE = {
		LEFT    = 0,
		RIGHT   = 1,
		MIDDLE  = 2,
		SIDE    = 3,
		EXTRA   = 4,
		FORWARD = 5,
		BACK    = 6,
	},
	PAD = {
		UNKNOWN = 0,
		L_FACE_UP = 1,
		L_FACE_RIGHT = 2,
		L_FACE_DOWN = 3,
		L_FACE_LEFT = 4,
		R_FACE_UP = 5,
		R_FACE_RIGHT = 6,
		R_FACE_DOWN = 7,
		R_FACE_LEFT = 8,
		L_TRIGGER_1 = 9,
		L_TRIGGER_2 = 10,
		R_TRIGGER_1 = 11,
		R_TRIGGER_2 = 12,
		MIDDLE_LEFT = 13,
		MIDDLE = 14,
		MIDDLE_RIGHT = 15,
		L_THUMB = 16,
		R_THUMB = 17
	}
}

--[[----------------------------------------------------------------]]

vector_2 = {}
vector_2.__index = vector_2

function vector_2:new(x, y)
	local self = setmetatable({ __meta = "vector_2" }, vector_2)

	self:set(x, y)

	return self
end

function vector_2:set(x, y)
	if type(x) == "table" then
		self.x = x.x
		self.y = x.y
	else
		self.x = x
		self.y = y
	end
end

function vector_2:copy(other)
	return vector_2:new(other.x, other.y)
end

function vector_2:zero()
	return vector_2:new(0.0, 0.0)
end

function vector_2:one()
	return vector_2:new(1.0, 1.0)
end

function vector_2:x()
	return vector_2:new(1.0, 0.0)
end

function vector_2:y()
	return vector_2:new(0.0, 1.0)
end

function vector_2:scalar(scalar)
	return vector_2:new(scalar, scalar)
end

function vector_2:length(square)
	local sum = self.x * self.x + self.y * self.y

	if square then
		return math.sqrt(sum)
	else
		return sum
	end
end

function vector_2:__add(other)
	return vector_2:new(self.x + other.x, self.y + other.y)
end

function vector_2:__sub(other)
	return vector_2:new(self.x - other.x, self.y - other.y)
end

function vector_2:__mul(other)
	if type(self) == "number" then
		return vector_2:new(self * other.x, self * other.y)
	else
		return vector_2:new(other * self.x, other * self.y)
	end
end

function vector_2:__unm(other)
	return vector_2:new(-other.x, -other.y)
end

--[[----------------------------------------------------------------]]

ray = {}
ray.__index = ray

function ray:new(point, where)
	local self = setmetatable({ __meta = "ray" }, ray)

	self.point = point
	self.where = where

	return self
end

--[[----------------------------------------------------------------]]

color = {}
color.__index = color

function color:new(r, g, b, a)
	local self = setmetatable({ __meta = "color" }, color)

	self.r = r
	self.g = g
	self.b = b
	self.a = a

	return self
end

function color:white()
	return color:new(255, 255, 255, 255)
end

function color:black()
	return color:new(0, 0, 0, 255)
end

function color:r()
	return color:new(255, 0, 0, 255)
end

function color:g()
	return color:new(0, 255, 0, 255)
end

function color:b()
	return color:new(0, 0, 255, 255)
end

function color:scalar(scalar, alpha)
	return color:new(scalar, scalar, scalar, alpha)
end

function color:interpolate(color, amount)
	return color:new(
		math.floor(math.interpolate(self.r, color.r, amount)),
		math.floor(math.interpolate(self.g, color.g, amount)),
		math.floor(math.interpolate(self.b, color.b, amount)),
		math.floor(math.interpolate(self.a, color.a, amount))
	)
end

function color:alpha(alpha)
	return color:new(self.r, self.g, self.b, math.floor(math.clamp(alpha, 0.0, 1.0) * 255.0))
end

--[[----------------------------------------------------------------]]

box_2 = {}
box_2.__index = box_2

function box_2:new(p_x, p_y, s_x, s_y)
	local self = setmetatable({ __meta = "box_2" }, box_2)

	self.p_x   = p_x
	self.p_y   = p_y
	self.s_x   = s_x
	self.s_y   = s_y

	return self
end

function box_2:intersect_point(point)
	return
		(point.x >= self.p_x and point.x <= self.p_x + self.s_x) and
		(point.y >= self.p_y and point.y <= self.p_y + self.s_y)
end

--[[----------------------------------------------------------------]]

function table.in_set(value, object)
	for _, entry in pairs(value) do
		if entry == object then
			return true
		end
	end

	return false
end

function table.apply_meta(value, process)
	if not process then
		process = {}
	end

	if table.in_set(process, value) then
		return
	end

	if type(value) == "table" then
		table.insert(process, value)

		if type(value) == "table" then
			if value.__meta then
				local meta = _G[value.__meta]

				if meta then
					setmetatable(value, meta)
				end
			end
		end

		for key, entry in pairs(value) do
			if type(entry) == "table" then
				table.apply_meta(entry, process)
			end
		end
	end
end

function table.join(target, source)
	for key, entry in pairs(source) do
		target[key] = entry
	end
end

--[[----------------------------------------------------------------]]

function math.clamp(value, min, max)
	if value < min then
		return min
	end

	if value > max then
		return max
	end

	return value
end

function math.snap(value, grid)
	return math.floor(value / grid) * grid
end

function math.interpolate(a, b, amount)
	return a + (b - a) * amount
end

function math.percentage_from_value(value, min, max)
	return (value - min) / (max - min)
end

function math.value_from_percentage(value, min, max)
	return value * (max - min) + min
end
