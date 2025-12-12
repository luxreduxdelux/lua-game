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

require("data/script/base/main")
require("data/script/constant")
require("data/script/scene")
require("data/script/world")
require("data/script/user")
require("data/script/menu")

--[[--------------------------------------------------------------------------------]]

game = {}

function game:info()
	local user = user:new()

	return {
		title  = "Laravox",
		scale  = user.video.full and { 0.0, 0.0 } or { 1024.0, 768.0 },
		sync   = user.video.sync,
		full   = user.video.full,
		border = false,
	}
end

function game:main()
	laravox.window.set_frame_rate(144.0)
	laravox.window.set_exit_key()

	self.menu = menu:new()
	--self.menu.layout = nil
	--self.world       = world:new()

	while not laravox.window.get_exit() and not self.menu.close do
		laravox.screen.draw(function()
			laravox.screen.wipe(color:black())

			if self.world then
				self.world:draw(self)
			end

			self.menu:draw(self)
		end)

		if laravox.input.board.get_press(INPUT_ACTION.BOARD.F1) then
			self.menu.user:save()
			return true
		end
	end

	self.menu.user:save()

	return false
end

function game:fail(message)
	local font = laravox.font.new("data/video/font.ttf", 32)

	while not laravox.window.get_exit() do
		laravox.screen.draw(function()
			laravox.screen.wipe(color:new(255, 255, 255, 255))
			font:draw(message, vector_2:new(8.0, 8.0), 32.0, 1.0, color:new(0, 0, 0, 255))
			font:draw("[F1] Restart", vector_2:new(8.0, 320.0), 32.0, 1.0, color:new(0, 0, 0, 255))
		end)

		if laravox.input.board.get_press(INPUT_ACTION.BOARD.F1) then
			return true
		end
	end

	return false
end

return game
