-- Copyright (C) Hanada
-- Copyright (C) by Kwanhur Huang


local modulename = "gdInit"
local _M = { _NAME = modulename }

local libgd = require('resty.gd.libgd')
local base = require('resty.gd.base')
local util = require('resty.gd.util')
local image = require('resty.gd.image')
local bit = require('bit')

local ffi = require('ffi')
local ffi_gc = ffi.gc
local ffi_string = ffi.string
local tonumber = tonumber
local type = type
local len = string.len
local open = io.open
local bit_band = bit.band
local pcall = pcall


local function read_file(fname)
    if not fname or type(fname) ~= 'string' then
        return nil, "fname must not be empty"
    end

    local file, err = open(fname, "rb")
    if not file then
        return nil, err
    end

    local blob, read_err = file:read("*a")
    local close_ok, close_err = file:close()
    if not blob then
        return nil, read_err
    end
    if not close_ok then
        return nil, close_err
    end
    return blob
end


local function create_from_file_blob(fname, create_from_str)
    local blob, err = read_file(fname)
    if not blob then
        return nil, err
    end
    return create_from_str(blob)
end


local function gd_ptr_to_string(blob, size)
    if blob == nil then
        return nil, "encode failed"
    end

    local ok, str = pcall(ffi_string, blob, size[0])
    libgd.gdFree(blob)
    if not ok then
        return nil, str
    end
    return str
end


local function gd_char_ptr_to_string(ptr)
    if ptr == nil then
        return nil
    end

    local ok, str = pcall(ffi_string, ptr)
    libgd.gdFree(ptr)
    if not ok then
        return nil
    end
    return str
end


local function get_font(name)
    local ok, font = pcall(function()
        return libgd[name]()
    end)
    if ok then
        return font
    end
    return nil
end


local function get_image_ptr(value, name)
    if value and type(value) == 'cdata' then
        return value
    end
    if value and type(value) == 'table' and type(value.im) == 'cdata' then
        return value.im
    end
    return nil, name .. " must be specified as gd image object or cdata<gdImagePtr>"
end


_M.destroy = function(image)
    if image and image.im then
        local im = image.im
        image.im = nil
        if image._owned ~= false then
            ffi_gc(im, nil)
            libgd.gdImageDestroy(im)
        end
        return true
    end
    return false
end


_M.create = function(sx, sy)
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx <= 0 or sy <= 0 then
        return nil, "sx and sy must be a number greater than 0"
    end
    local im = libgd.gdImageCreate(sx, sy)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createPalette = _M.create

_M.createTrueColor = function(sx, sy)
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx <= 0 or sy <= 0 then
        return nil, "sx and sy must be a number greater than 0"
    end
    local im = libgd.gdImageCreateTrueColor(sx, sy)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromJpeg = function(fname)
    return create_from_file_blob(fname, _M.createFromJpegStr)
end


_M.createFromJpegStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromJpegPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromGif = function(fname)
    return create_from_file_blob(fname, _M.createFromGifStr)
end


_M.createFromGifStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromGifPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromPng = function(fname)
    return create_from_file_blob(fname, _M.createFromPngStr)
end


_M.createFromPngStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromPngPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromGd = function(fname)
    return create_from_file_blob(fname, _M.createFromGdStr)
end


_M.createFromGdStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromGdPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromGd2 = function(fname)
    return create_from_file_blob(fname, _M.createFromGd2Str)
end


_M.createFromGd2Str = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromGd2Ptr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromGd2Part = function(fname, sx, sy, w, h)
    sx, sy, w, h = tonumber(sx), tonumber(sy), tonumber(w), tonumber(h)
    if not sx or not sy or sx < 0 or sy < 0 then
        return nil, "sx and sy must be a number not less than 0"
    end
    if not w or not h or w < 0 or h < 0 then
        return nil, "w and h must be a number not less than 0"
    end

    local blob, err = read_file(fname)
    if not blob then
        return nil, err
    end
    return _M.createFromGd2PartStr(blob, sx, sy, w, h)
end


_M.createFromGd2PartStr = function(blob, sx, sy, w, h)
    sx, sy, w, h = tonumber(sx), tonumber(sy), tonumber(w), tonumber(h)
    if not sx or not sy or sx < 0 or sy < 0 then
        return nil, "sx and sy must be a number not less than 0"
    end
    if not w or not h or w < 0 or h < 0 then
        return nil, "w and h must be a number not less than 0"
    end

    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromGd2PartPtr(len(blob), data, sx, sy, w, h)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromXbm = function(fname)
    if not fname or type(fname) ~= 'string' then
        return nil, "fname must not be empty"
    end
    local im = libgd.gdImageCreateFromFile(util.get_char_ptr(fname))
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromXpm = function(fname)
    if not fname or type(fname) ~= 'string' then
        return nil, "fname must not be empty"
    end
    local im = libgd.gdImageCreateFromXpm(util.get_char_ptr(fname))
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromWebp = function(fname)
    return create_from_file_blob(fname, _M.createFromWebpStr)
end


_M.createFromFile = function(fname)
    if not fname or type(fname) ~= 'string' then
        return nil, "fname must not be empty"
    end
    local im = libgd.gdImageCreateFromFile(util.get_char_ptr(fname))
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromBmp = function(fname)
    return create_from_file_blob(fname, _M.createFromBmpStr)
end


_M.createFromBmpStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromBmpPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromTga = function(fname)
    return create_from_file_blob(fname, _M.createFromTgaStr)
end


_M.createFromTgaStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromTgaPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromWebpStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromWebpPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.createFromTiff = function(fname)
    return create_from_file_blob(fname, _M.createFromTiffStr)
end


_M.createFromTiffStr = function(blob)
    if not blob or type(blob) ~= 'string' or len(blob) <= 0 then
        return nil, "blob could not accept"
    end
    local data = util.get_char_ptr(blob)
    local im = libgd.gdImageCreateFromTiffPtr(len(blob), data)
    if im == nil then
        return nil, "create failed"
    end
    return image:new(im)
end


_M.png = function(im, fname)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:png(fname)
end


_M.pngEx = function(im, fname, compression_level)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:pngEx(fname, compression_level)
end


_M.gif = function(im, fname)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:gif(fname)
end


_M.gd = function(im, fname)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:gd(fname)
end


_M.gd2 = function(im, fname, chunk_size, format)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:gd2(fname, chunk_size, format)
end


_M.wbmp = function(im, foreground, fname)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:wbmp(foreground, fname)
end


_M.copy = function(dst, src, dx, dy, sx, sy, w, h)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    w, h = tonumber(w), tonumber(h)
    if not w or not h or w < 0 or h < 0 then
        return false, "w and h must be a number not less than 0"
    end
    libgd.gdImageCopy(dst_ptr, src_ptr, dx, dy, sx, sy, w, h)
    return true
end


_M.copyResized = function(dst, src, dx, dy, sx, sy, dw, dh, sw, sh)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    dw, dh = tonumber(dw), tonumber(dh)
    if not dw or not dh or dw <= 0 or dh <= 0 then
        return false, "dw and dh must be a positive number"
    end
    sw, sh = tonumber(sw), tonumber(sh)
    if not sw or not sh or sw <= 0 or sh <= 0 then
        return false, "sw and sh must be a positive number"
    end

    libgd.gdImageCopyResized(dst_ptr, src_ptr, dx, dy, sx, sy, dw, dh, sw, sh)
    return true
end


_M.copyResampled = function(dst, src, dx, dy, sx, sy, dw, dh, sw, sh)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    dw, dh = tonumber(dw), tonumber(dh)
    if not dw or not dh or dw <= 0 or dh <= 0 then
        return false, "dw and dh must be a positive number"
    end
    sw, sh = tonumber(sw), tonumber(sh)
    if not sw or not sh or sw <= 0 or sh <= 0 then
        return false, "sw and sh must be a positive number"
    end

    libgd.gdImageCopyResampled(dst_ptr, src_ptr, dx, dy, sx, sy, dw, dh, sw, sh)
    return true
end


_M.copyRotated = function(dst, src, dx, dy, sx, sy, sw, sh, angle)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    sw, sh = tonumber(sw), tonumber(sh)
    if not sw or not sh or sw < 0 or sh < 0 then
        return false, "sw and sh must be a number not less than 0"
    end
    angle = tonumber(angle)
    if not angle then
        return false, "angle must be a number"
    end

    libgd.gdImageCopyRotated(dst_ptr, src_ptr, dx, dy, sx, sy, sw, sh, angle)
    return true
end


_M.copyMerge = function(dst, src, dx, dy, sx, sy, sw, sh, pct)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    sw, sh = tonumber(sw), tonumber(sh)
    if not sw or not sh or sw < 0 or sh < 0 then
        return false, "sw and sh must be a number not less than 0"
    end
    pct = tonumber(pct)
    if not pct then
        return false, "pct must be a number"
    end

    libgd.gdImageCopyMerge(dst_ptr, src_ptr, dx, dy, sx, sy, sw, sh, pct)
    return true
end


_M.copyMergeGray = function(dst, src, dx, dy, sx, sy, sw, sh, pct)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end

    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy or dx < 0 or dy < 0 then
        return false, "dx and dy must be a number not less than 0"
    end
    sx, sy = tonumber(sx), tonumber(sy)
    if not sx or not sy or sx < 0 or sy < 0 then
        return false, "sx and sy must be a number not less than 0"
    end
    sw, sh = tonumber(sw), tonumber(sh)
    if not sw or not sh or sw < 0 or sh < 0 then
        return false, "sw and sh must be a number not less than 0"
    end
    pct = tonumber(pct)
    if not pct then
        return false, "pct must be a number"
    end

    libgd.gdImageCopyMergeGray(dst_ptr, src_ptr, dx, dy, sx, sy, sw, sh, pct)
    return true
end


_M.polygon = function(im, points, color)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:polygon(points, color)
end


_M.filledPolygon = function(im, points, color)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:filledPolygon(points, color)
end


_M.openPolygon = function(im, points, color)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:openPolygon(points, color)
end


_M.setStyle = function(im, styles)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:setStyle(styles)
end


_M.alphaBlending = function(im, blending)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:alphaBlending(blending)
end


_M.saveAlpha = function(im, save_or_not)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:saveAlpha(save_or_not)
end


_M.interlace = function(im)
    local im_ptr, err = get_image_ptr(im, "im")
    if not im_ptr then
        return false, err
    end

    local gd = image:wrap(im_ptr)
    return gd:interlace()
end


_M.setInterlaced = function(im, interlace_arg)
    local im_ptr, err = get_image_ptr(im, "im")
    if not im_ptr then
        return false, err
    end

    local gd = image:wrap(im_ptr)
    return gd:setInterlaced(interlace_arg)
end
_M.setInterlace = _M.setInterlaced


_M.getClip = function(im)
    if not im or type(im) ~= 'cdata' then
        return false, "im must be specified as cdata<gdImagePtr>"
    end

    local gd = image:wrap(im)
    return gd:getClip()
end


_M.paletteCopy = function(dst, src)
    local dst_ptr, err = get_image_ptr(dst, "dst")
    if not dst_ptr then
        return false, err
    end
    local src_ptr, err = get_image_ptr(src, "src")
    if not src_ptr then
        return false, err
    end
    libgd.gdImagePaletteCopy(dst_ptr, src_ptr)
    return true
end


_M.fontCacheSetup = function()
    return libgd.gdFontCacheSetup() == base.GD_ZERO
end


_M.fontCacheShutdown = function()
    libgd.gdFontCacheShutdown()
end


_M.useFontConfig = function(flag)
    local use = 0
    if flag then
        use = 1
    end
    return libgd.gdFTUseFontConfig(use) ~= base.GD_ZERO
end


_M.stringFT = function(foreground, font, size, ang, x, y, str)
    foreground = tonumber(foreground)
    if not foreground then
        return nil, "foreground must be a number"
    end
    if not font or type(font) ~= 'string' then
        return nil, "font must be a string"
    end
    size = tonumber(size)
    if not size then
        return nil, "size must be a number"
    end
    ang = tonumber(ang)
    if not ang then
        return nil, "ang must be a number"
    end
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x < 0 or y < 0 then
        return false, "x y must be a number not less than 0"
    end
    if not str or type(str) ~= 'string' then
        return nil, "str must be a string"
    end

    local brect = util.get_int_ptr_list(8)
    local err = libgd.gdImageStringFT(nil, brect, foreground, font, size, ang, x, y, str)
    if err == nil then
        return brect[0], brect[1], brect[2], brect[3], brect[4], brect[5], brect[6], brect[7]
    end
    return nil, ffi_string(err)
end


_M.stringFTEx = function(foreground, font, size, ang, x, y, str, extr)
    foreground = tonumber(foreground)
    if not foreground then
        return nil, "foreground must be a number"
    end
    if not font or type(font) ~= 'string' then
        return nil, "font must be a string"
    end
    size = tonumber(size)
    if not size then
        return nil, "size must be a number"
    end
    ang = tonumber(ang)
    if not ang then
        return nil, "ang must be a number"
    end
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x < 0 or y < 0 then
        return false, "x y must be a number not less than 0"
    end
    if not str or type(str) ~= 'string' then
        return nil, "str must be a string"
    end
    if not extr or type(extr) ~= 'table' then
        return nil, "extr must be a table"
    end
    local ex = util.get_font_type_extract_ptr(extr)

    local brect = util.get_int_ptr_list(8)
    local err = libgd.gdImageStringFTEx(nil, brect, foreground, font, size, ang, x, y, str, ex)
    if err == nil then
        local has_xshow = bit_band(ex.flags, base.gdFTEX_XSHOW) ~= 0
        local has_fontpath = bit_band(ex.flags, base.gdFTEX_RETURNFONTPATHNAME) ~= 0
        local xshow = has_xshow and gd_char_ptr_to_string(ex.xshow) or nil
        local fontpath = has_fontpath and gd_char_ptr_to_string(ex.fontpath) or nil

        if has_xshow and has_fontpath then
            return brect[0], brect[1], brect[2], brect[3], brect[4], brect[5], brect[6], brect[7], xshow, fontpath
        end
        if has_xshow then
            return brect[0], brect[1], brect[2], brect[3], brect[4], brect[5], brect[6], brect[7], xshow
        end
        if has_fontpath then
            return brect[0], brect[1], brect[2], brect[3], brect[4], brect[5], brect[6], brect[7], nil, fontpath
        end
        return brect[0], brect[1], brect[2], brect[3], brect[4], brect[5], brect[6], brect[7]
    end
    return nil, ffi_string(err)
end


_M.gifAnimEndStr = function()
    local size = util.get_int_ptr_0()
    local blob = libgd.gdImageGifAnimEndPtr(size)
    return gd_ptr_to_string(blob, size)
end


_M.VERSION = base._VERSION

_M.GD_VERSION = base.gdVersion

_M.MAX_COLORS = base.gdMaxColors

_M.GD2_FMT_RAW = base.GD2_FMT_RAW

_M.GD2_FMT_COMPRESSED = base.GD2_FMT_COMPRESSED

_M.ARC = base.gdArc

_M.CHORD = base.gdChord

_M.PIE = base.gdPie

_M.NO_FILL = base.gdNoFill

_M.EDGED = base.gdEdged

_M.ANTI_ALIASED = base.gdAntiAliased

_M.BRUSHED = base.gdBrushed

_M.STYLED = base.gdStyled

_M.STYLED_BRUSHED = base.gdStyledBrushed

_M.TILED = base.gdTiled

_M.TRANSPARENT = base.gdTransparent

--GD_FREETYPE
_M.FTEX_Unicode = base.gdFTEX_Unicode

_M.FTEX_Shift_JIS = base.gdFTEX_Shift_JIS

_M.FTEX_Big5 = base.gdFTEX_Big5

--GD_GIF
_M.DISPOSAL_NONE = base.gdDisposalNone

_M.DISPOSAL_UNKNOWN = base.gdDisposalUnknown

_M.DISPOSAL_RESTORE_BACKGROUND = base.gdDisposalRestoreBackground

_M.DISPOSAL_RESTORE_PREVIOUS = base.gdDisposalRestorePrevious

--standard gd fonts
_M.FONT_TINY = get_font("gdFontGetTiny")

_M.FONT_SMALL = get_font("gdFontGetSmall")

_M.FONT_MEDIUM = get_font("gdFontGetMediumBold")

_M.FONT_LARGE = get_font("gdFontGetLarge")

_M.FONT_GIANT = get_font("gdFontGetGiant")

return _M
