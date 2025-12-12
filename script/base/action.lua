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

action = {}
action.__index = action

function action:new(board, mouse, pad)
	local self = table.meta_new(action, "action")

	self.board = board
	self.mouse = mouse
	self.pad   = pad

	return self
end

function action:press(device, index)
	index = index or 0

	if device == INPUT_DEVICE.BOARD and self.board then
		return laravox.input.board.get_press(self.board)
	elseif device == INPUT_DEVICE.MOUSE and self.mouse then
		return laravox.input.mouse.get_press(self.mouse)
	elseif device == INPUT_DEVICE.PAD and self.pad then
		return laravox.input.pad.get_press(index, self.pad)
	end
end

function action:down(device, index)
	index = index or 0

	if device == INPUT_DEVICE.BOARD and self.board then
		return laravox.input.board.get_down(self.board)
	elseif device == INPUT_DEVICE.MOUSE and self.mouse then
		return laravox.input.mouse.get_down(self.mouse)
	elseif device == INPUT_DEVICE.PAD and self.pad then
		return laravox.input.pad.get_down(index, self.pad)
	end
end

function action:release(device, index)
	index = index or 0

	if device == INPUT_DEVICE.BOARD and self.board then
		return laravox.input.board.get_release(self.board)
	elseif device == INPUT_DEVICE.MOUSE and self.mouse then
		return laravox.input.mouse.get_release(self.mouse)
	elseif device == INPUT_DEVICE.PAD and self.pad then
		return laravox.input.pad.get_release(index, self.pad)
	end
end

function action:up(device, index)
	index = index or 0

	if device == INPUT_DEVICE.BOARD and self.board then
		return laravox.input.board.get_up(self.board)
	elseif device == INPUT_DEVICE.MOUSE and self.mouse then
		return laravox.input.mouse.get_up(self.mouse)
	elseif device == INPUT_DEVICE.PAD and self.pad then
		return laravox.input.pad.get_up(index, self.pad)
	end
end
