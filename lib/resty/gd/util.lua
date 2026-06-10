-- Copyright (C) Hanada
-- Copyright (C) by Kwanhur Huang


local modulename = "gdUtil"
local _M = { _NAME = modulename }

local ffi = require('ffi')
local ffi_new = ffi.new
local ffi_copy = ffi.copy

local tonumber = tonumber
local type = type


_M.get_char_ptr = function(str)
    local char_ptr = ffi_new("char[?]", #str + 1)
    ffi_copy(char_ptr, str)
    return char_ptr
end


_M.get_int_ptr_0 = function()
    return ffi_new("int[1]", 0)
end


_M.get_int_ptr = function(num)
    return ffi_new("int[1]", num)
end


_M.get_int_ptr_list = function(size)
    return ffi_new("int[?]", size)
end


_M.get_point_list = function(points)
    local i = 1
    local size = #points
    local plist = ffi_new("gdPoint[?]", size)
    while i <= size do
        local point = points[i]
        if not point or type(points) ~= 'table' or #point ~= 2 then
            return nil, "points format could not acceptable"
        end
        local x, y = tonumber(point[1]), tonumber(point[2])
        if not x or not y then
            return nil, "point's x y must be a number"
        end
        local p = ffi_new("gdPoint")
        p.x, p.y = x, y

        plist[i - 1] = p
        i = i + 1
    end
    return plist
end


_M.get_style_list = function(styles)
    local i = 1
    local size = #styles
    local slist = _M.get_int_ptr_list(size)
    while i <= size do
        local style = tonumber(styles[i])
        if not style then
            return false, "style must be a number"
        end
        slist[i - 1] = style
        i = i + 1
    end
    return slist
end


_M.get_font_type_extract_ptr = function(extr)
    local ex = ffi_new("gdFTStringExtra")
    if extr.flags then ex.flags = extr.flags end
    if extr.linespacing then ex.linespacing = extr.linespacing end
    if extr.charmap then ex.charmap = extr.charmap end
    if extr.hdpi then ex.hdpi = extr.hdpi end
    if extr.vdpi then ex.vdpi = extr.vdpi end
    if extr.xshow then ex.xshow = extr.xshow end
    if extr.fontpath then ex.fontpath = extr.fontpath end
    return ex
end


return _M
