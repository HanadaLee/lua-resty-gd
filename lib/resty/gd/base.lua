-- Copyright (C) Hanada
-- Copyright (C) by Kwanhur Huang


local modulename = "gdBase"
local _M = { _VERSION = '2.3.3.2', _NAME = modulename }

local ffi = require('ffi')
local libgd = require('resty.gd.libgd')

local tonumber = tonumber
local ffi_str = ffi.string

_M.gdVersion = ffi_str(libgd.gdVersionString())

_M.gdMaxColors = tonumber(libgd.gdMaxColors)

_M.GD2_FMT_RAW = 1

_M.GD2_FMT_COMPRESSED = 2

_M.gdArc = 0

_M.gdChord = 1

_M.gdPie = _M.gdArc

_M.gdNoFill = 2

_M.gdEdged = 4

_M.gdAntiAliased = -7

_M.gdBrushed = -3

_M.gdStyled = -2

_M.gdStyledBrushed = -4

_M.gdTiled = -5

_M.gdTransparent = -6

_M.gdFTEX_Unicode = 0

_M.gdFTEX_Shift_JIS = 1

_M.gdFTEX_Big5 = 2

_M.gdDisposalNone = 1

_M.gdDisposalUnknown = 0

_M.gdDisposalRestoreBackground = 2

_M.gdDisposalRestorePrevious = 3

_M.MY_GD_FONT_TINY = 4

_M.MY_GD_FONT_SMALL = 0

_M.MY_GD_FONT_MEDIUM_BOLD = 2

_M.MY_GD_FONT_LARGE = 1

_M.MY_GD_FONT_GIANT = 3

_M.GD_IMAGE_PTR_TYPENAME = "gdImagePtr_handle"

_M.gdFTEX_XSHOW = 16

_M.gdFTEX_RETURNFONTPATHNAME = 128

_M.GD_OK = 1

_M.GD_ERR = -1

_M.GD_ZERO = 0

--New in GD 2.1.0+: palette quantization methods
_M.GD_QUANT_DEFAULT = 0
_M.GD_QUANT_JQUANT = 1
_M.GD_QUANT_NEUQUANT = 2
_M.GD_QUANT_LIQ = 3

--New in GD 2.1.0+: alpha blending effects
_M.gdEffectReplace = 0
_M.gdEffectAlphaBlend = 1
_M.gdEffectNormal = 2
_M.gdEffectOverlay = 3
_M.gdEffectMultiply = 4

--New in GD 2.3.0+: pixelate modes
_M.GD_PIXELATE_UPPERLEFT = 0
_M.GD_PIXELATE_AVERAGE = 1

--New in GD 2.3.0+: WebP lossless threshold
_M.gdWebpLossless = 101

--New in GD 2.3.0+: HEIF codec
_M.GD_HEIF_CODEC_UNKNOWN = 0
_M.GD_HEIF_CODEC_HEVC = 1
_M.GD_HEIF_CODEC_AV1 = 4

--New in GD 2.1.0+: boolean
_M.GD_TRUE = 1
_M.GD_FALSE = 0

return _M
