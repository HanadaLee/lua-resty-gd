-- Copyright (C) by Kwanhur Huang


local ffi = require('ffi')
local pcall = pcall
local error = error

ffi.cdef([[
	struct _IO_FILE;
	typedef struct _IO_FILE FILE;

	typedef struct gdIOCtx *gdIOCtxPtr;
	typedef const char *gdHeifChroma;

	static const unsigned int gdMaxColors = 256;
	static const int gdEffectReplace = 0;
	static const int gdEffectAlphaBlend = 1;
	static const int gdEffectNormal = 2;
	static const int gdEffectOverlay = 3;
	static const int gdEffectMultiply = 4;
	static const int GD_TRUE = 1;
	static const int GD_FALSE = 0;
	static const int gdWebpLossless = 101;

	const char * gdVersionString(void);

	typedef enum {
		GD_QUANT_DEFAULT = 0,
		GD_QUANT_JQUANT = 1,
		GD_QUANT_NEUQUANT = 2,
		GD_QUANT_LIQ = 3
	} gdPaletteQuantizationMethod;

	typedef enum {
		GD_DEFAULT          = 0,
		GD_BELL,
		GD_BESSEL,
		GD_BILINEAR_FIXED,
		GD_BICUBIC,
		GD_BICUBIC_FIXED,
		GD_BLACKMAN,
		GD_BOX,
		GD_BSPLINE,
		GD_CATMULLROM,
		GD_GAUSSIAN,
		GD_GENERALIZED_CUBIC,
		GD_HERMITE,
		GD_HAMMING,
		GD_HANNING,
		GD_MITCHELL,
		GD_NEAREST_NEIGHBOUR,
		GD_POWER,
		GD_QUADRATIC,
		GD_SINC,
		GD_TRIANGLE,
		GD_WEIGHTED4,
		GD_LINEAR,
		GD_LANCZOS3,
		GD_LANCZOS8,
		GD_BLACKMAN_BESSEL,
		GD_BLACKMAN_SINC,
		GD_QUADRATIC_BSPLINE,
		GD_CUBIC_SPLINE,
		GD_COSINE,
		GD_WELSH,
		GD_METHOD_COUNT = 30
	} gdInterpolationMethod;

	typedef enum {
		GD_HEIF_CODEC_UNKNOWN = 0,
		GD_HEIF_CODEC_HEVC,
		GD_HEIF_CODEC_AV1 = 4
	} gdHeifCodec;

	typedef enum {
		GD_PIXELATE_UPPERLEFT,
		GD_PIXELATE_AVERAGE
	} gdPixelateMode;

	/* define struct with name and func ptr and add it to gdImageStruct gdInterpolationMethod interpolation; */

	/* Interpolation function ptr */
	typedef double (* interpolation_method )(double);

	typedef struct gdImageStruct {
		/* Palette-based image pixels */
		unsigned char **pixels;
		int sx;
		int sy;
		/* These are valid in palette images only. See also
		   'alpha', which appears later in the structure to
		   preserve binary backwards compatibility */
		int colorsTotal;
		int red[gdMaxColors];
		int green[gdMaxColors];
		int blue[gdMaxColors];
		int open[gdMaxColors];
		/* For backwards compatibility, this is set to the
		   first palette entry with 100% transparency,
		   and is also set and reset by the
		   gdImageColorTransparent function. Newer
		   applications can allocate palette entries
		   with any desired level of transparency; however,
		   bear in mind that many viewers, notably
		   many web browsers, fail to implement
		   full alpha channel for PNG and provide
		   support for full opacity or transparency only. */
		int transparent;
		int *polyInts;
		int polyAllocated;
		struct gdImageStruct *brush;
		struct gdImageStruct *tile;
		int brushColorMap[gdMaxColors];
		int tileColorMap[gdMaxColors];
		int styleLength;
		int stylePos;
		int *style;
		int interlace;
		/* New in 2.0: thickness of line. Initialized to 1. */
		int thick;
		/* New in 2.0: alpha channel for palettes. Note that only
		   Macintosh Internet Explorer and (possibly) Netscape 6
		   really support multiple levels of transparency in
		   palettes, to my knowledge, as of 2/15/01. Most
		   common browsers will display 100% opaque and
		   100% transparent correctly, and do something
		   unpredictable and/or undesirable for levels
		   in between. TBB */
		int alpha[gdMaxColors];
		/* Truecolor flag and pixels. New 2.0 fields appear here at the
		   end to minimize breakage of existing object code. */
		int trueColor;
		int **tpixels;
		/* Should alpha channel be copied, or applied, each time a
		   pixel is drawn? This applies to truecolor images only.
		   No attempt is made to alpha-blend in palette images,
		   even if semitransparent palette entries exist.
		   To do that, build your image as a truecolor image,
		   then quantize down to 8 bits. */
		int alphaBlendingFlag;
		/* Should the alpha channel of the image be saved? This affects
		   PNG at the moment; other future formats may also
		   have that capability. JPEG doesn't. */
		int saveAlphaFlag;

		/* There should NEVER BE ACCESSOR MACROS FOR ITEMS BELOW HERE, so this
		   part of the structure can be safely changed in new releases. */

		/* 2.0.12: anti-aliased globals. 2.0.26: just a few vestiges after
		  switching to the fast, memory-cheap implementation from PHP-gd. */
		int AA;
		int AA_color;
		int AA_dont_blend;

		/* 2.0.12: simple clipping rectangle. These values
		  must be checked for safety when set; please use
		  gdImageSetClip */
		int cx1;
		int cy1;
		int cx2;
		int cy2;

		/* 2.1.0: allows to specify resolution in dpi */
		unsigned int res_x;
		unsigned int res_y;

		/* Selects quantization method, see gdImageTrueColorToPaletteSetMethod() and gdPaletteQuantizationMethod enum. */
		int paletteQuantizationMethod;
		/* speed/quality trade-off. 1 = best quality, 10 = best speed. 0 = method-specific default.
		   Applicable to GD_QUANT_LIQ and GD_QUANT_NEUQUANT. */
		int paletteQuantizationSpeed;
		/* Image will remain true-color if conversion to palette cannot achieve given quality.
		   Value from 1 to 100, 1 = ugly, 100 = perfect. Applicable to GD_QUANT_LIQ.*/
		int paletteQuantizationMinQuality;
		/* Image will use minimum number of palette colors needed to achieve given quality. Must be higher than paletteQuantizationMinQuality
		   Value from 1 to 100, 1 = ugly, 100 = perfect. Applicable to GD_QUANT_LIQ.*/
		int paletteQuantizationMaxQuality;
		gdInterpolationMethod interpolation_id;
		interpolation_method interpolation;
	}
	gdImage;

	typedef gdImage *gdImagePtr;

	typedef struct {
		double x, y;
	} gdPointF, *gdPointFPtr;

	typedef struct {
		int x, y;
	} gdPoint, *gdPointPtr;

	typedef struct {
		int x, y;
		int width, height;
	} gdRect, *gdRectPtr;

	typedef struct {
		int sub;
		int plus;
		unsigned int num_colors;
		int *colors;
		unsigned int seed;
	} gdScatter, *gdScatterPtr;

	typedef struct {
		/* # of characters in font */
		int nchars;
		/* First character is numbered... (usually 32 = space) */
		int offset;
		/* Character width and height */
		int w;
		int h;
		/* Font data; array of characters, one row after another.
		   Easily included in code, also easily loaded from
		   data files. */
		char *data;
	} gdFont;

	/* Text functions take these. */
	typedef gdFont *gdFontPtr;

	typedef void *va_list;
	typedef void(*gdErrorMethod)(int, const char *, va_list);

	typedef struct {
		int flags;		/* Logical OR of gdFTEX_ values */
		double linespacing;	/* fine tune line spacing for '\n' */
		int charmap;		/* TBB: 2.0.12: may be gdFTEX_Unicode,
					   gdFTEX_Shift_JIS, gdFTEX_Big5,
					   or gdFTEX_Adobe_Custom;
					   when not specified, maps are searched
					   for in the above order. */
		int hdpi;                /* if (flags & gdFTEX_RESOLUTION) */
		int vdpi;		 /* if (flags & gdFTEX_RESOLUTION) */
		char *xshow;             /* if (flags & gdFTEX_XSHOW)
					    then, on return, xshow is a malloc'ed
					    string containing xshow position data for
					    the last string.

					    NB. The caller is responsible for gdFree'ing
					    the xshow string.
					 */
		char *fontpath;	         /* if (flags & gdFTEX_RETURNFONTPATHNAME)
					    then, on return, fontpath is a malloc'ed
					    string containing the actual font file path name
					    used, which can be interesting when fontconfig
					    is in use.

					    The caller is responsible for gdFree'ing the
					    fontpath string.
					 */

	}
	gdFTStringExtra, *gdFTStringExtraPtr;

	void gdSetErrorMethod(gdErrorMethod);
	void gdClearErrorMethod(void);

	int gdAlphaBlend(int dest, int src);
	int gdLayerOverlay(int dest, int src);
	int gdLayerMultiply(int dest, int src);

	void gdImageDestroy(gdImagePtr im);
	void gdFree(void *m);

	gdImagePtr gdImageCreate(int sx, int sy);
	gdImagePtr gdImageCreateTrueColor(int sx, int sy);
	gdImagePtr gdImageCreatePaletteFromTrueColor(gdImagePtr im, int ditherFlag, int colorsWanted);
	int gdImageTrueColorToPalette(gdImagePtr im, int ditherFlag, int colorsWanted);
	int gdImageTrueColorToPaletteSetMethod(gdImagePtr im, int method, int speed);
	void gdImageTrueColorToPaletteSetQuality(gdImagePtr im, int min_quality, int max_quality);
	int gdImagePaletteToTrueColor(gdImagePtr src);
	gdImagePtr gdImageNeuQuant(gdImagePtr im, const int max_color, int sample_factor);
	int gdImageColorMatch(gdImagePtr im1, gdImagePtr im2);

	gdImagePtr gdImageClone(gdImagePtr src);

	gdImagePtr gdImageCreateFromFile(const char *filename);
	int gdSupportsFileType(const char *filename, int writing);

	gdImagePtr gdImageCreateFromJpeg(FILE *infile);
	gdImagePtr gdImageCreateFromJpegEx(FILE *infile, int ignore_warning);
	gdImagePtr gdImageCreateFromJpegCtx(gdIOCtxPtr infile);
	gdImagePtr gdImageCreateFromJpegCtxEx(gdIOCtxPtr infile, int ignore_warning);
	gdImagePtr gdImageCreateFromJpegPtr(int size, void *data);
	gdImagePtr gdImageCreateFromJpegPtrEx(int size, void *data, int ignore_warning);

	gdImagePtr gdImageCreateFromGif(FILE *fd);
	gdImagePtr gdImageCreateFromGifCtx(gdIOCtxPtr in);
	gdImagePtr gdImageCreateFromGifPtr(int size, void *data);

	gdImagePtr gdImageCreateFromPng(FILE *fd);
	gdImagePtr gdImageCreateFromPngCtx(gdIOCtxPtr in);
	gdImagePtr gdImageCreateFromPngPtr(int size, void *data);

	gdImagePtr gdImageCreateFromGd(FILE *in);
	gdImagePtr gdImageCreateFromGdCtx(gdIOCtxPtr in);
	gdImagePtr gdImageCreateFromGdPtr(int size, void *data);

	gdImagePtr gdImageCreateFromGd2(FILE *in);
	gdImagePtr gdImageCreateFromGd2Ctx(gdIOCtxPtr in);
	gdImagePtr gdImageCreateFromGd2Ptr(int size, void *data);

	gdImagePtr gdImageCreateFromGd2Part(FILE *in, int srcx, int srcy, int w, int h);
	gdImagePtr gdImageCreateFromGd2PartCtx(gdIOCtxPtr in, int srcx, int srcy, int w, int h);
	gdImagePtr gdImageCreateFromGd2PartPtr(int size, void *data, int srcx, int srcy, int w, int h);

	gdImagePtr gdImageCreateFromXbm(FILE *in);
	void gdImageXbmCtx(gdImagePtr image, char* file_name, int fg, gdIOCtxPtr out);
	gdImagePtr gdImageCreateFromXpm(char *filename);

	gdImagePtr gdImageCreateFromWBMP(FILE *inFile);
	gdImagePtr gdImageCreateFromWBMPCtx(gdIOCtxPtr infile);
	gdImagePtr gdImageCreateFromWBMPPtr(int size, void *data);

	gdImagePtr gdImageCreateFromWebp(FILE *inFile);
	gdImagePtr gdImageCreateFromWebpPtr(int size, void *data);
	gdImagePtr gdImageCreateFromWebpCtx(gdIOCtxPtr infile);

	gdImagePtr gdImageCreateFromTiff(FILE *inFile);
	gdImagePtr gdImageCreateFromTiffCtx(gdIOCtxPtr infile);
	gdImagePtr gdImageCreateFromTiffPtr(int size, void *data);

	gdImagePtr gdImageCreateFromTga(FILE *fp);
	gdImagePtr gdImageCreateFromTgaCtx(gdIOCtxPtr ctx);
	gdImagePtr gdImageCreateFromTgaPtr(int size, void *data);

	gdImagePtr gdImageCreateFromBmp(FILE *inFile);
	gdImagePtr gdImageCreateFromBmpPtr(int size, void *data);
	gdImagePtr gdImageCreateFromBmpCtx(gdIOCtxPtr infile);

	gdImagePtr gdImageCreateFromHeif(FILE *inFile);
	gdImagePtr gdImageCreateFromHeifPtr(int size, void *data);
	gdImagePtr gdImageCreateFromHeifCtx(gdIOCtxPtr infile);

	gdImagePtr gdImageCreateFromAvif(FILE *inFile);
	gdImagePtr gdImageCreateFromAvifPtr(int size, void *data);
	gdImagePtr gdImageCreateFromAvifCtx(gdIOCtxPtr infile);

	void gdImageJpeg(gdImagePtr im, FILE *out, int quality);
	void gdImageJpegCtx(gdImagePtr im, gdIOCtxPtr out, int quality);
	void *gdImageJpegPtr(gdImagePtr im, int *size, int quality);

	void gdImagePng(gdImagePtr im, FILE *out);
	void gdImagePngEx(gdImagePtr im, FILE *out, int level);
	void gdImagePngCtx(gdImagePtr im, gdIOCtxPtr out);
	void gdImagePngCtxEx(gdImagePtr im, gdIOCtxPtr out, int level);
	void *gdImagePngPtr(gdImagePtr im, int *size);
	void *gdImagePngPtrEx(gdImagePtr im, int *size, int level);

	void gdImageGif(gdImagePtr im, FILE *out);
	void gdImageGifCtx(gdImagePtr im, gdIOCtxPtr out);
	void *gdImageGifPtr(gdImagePtr im, int *size);

	void gdImageGd(gdImagePtr im, FILE *out);
	void *gdImageGdPtr(gdImagePtr im, int *size);

	void gdImageGd2(gdImagePtr im, FILE *out, int cs, int fmt);
	void *gdImageGd2Ptr(gdImagePtr im, int cs, int fmt, int *size);

	void gdImageWBMP(gdImagePtr image, int fg, FILE *out);
	void gdImageWBMPCtx(gdImagePtr image, int fg, gdIOCtxPtr out);
	void *gdImageWBMPPtr(gdImagePtr im, int *size, int fg);

	void gdImageBmp(gdImagePtr im, FILE *outFile, int compression);
	void gdImageBmpCtx(gdImagePtr im, gdIOCtxPtr out, int compression);
	void *gdImageBmpPtr(gdImagePtr im, int *size, int compression);

	void gdImageTiff(gdImagePtr im, FILE *outFile);
	void gdImageTiffCtx(gdImagePtr image, gdIOCtxPtr out);
	void *gdImageTiffPtr(gdImagePtr im, int *size);

	void gdImageWebp(gdImagePtr im, FILE *outFile);
	void gdImageWebpEx(gdImagePtr im, FILE *outFile, int quantization);
	void gdImageWebpCtx(gdImagePtr im, gdIOCtxPtr outfile, int quantization);
	void *gdImageWebpPtr(gdImagePtr im, int *size);
	void *gdImageWebpPtrEx(gdImagePtr im, int *size, int quantization);

	void gdImageHeif(gdImagePtr im, FILE *outFile);
	void gdImageHeifEx(gdImagePtr im, FILE *outFile, int quality, gdHeifCodec codec, gdHeifChroma chroma);
	void gdImageHeifCtx(gdImagePtr im, gdIOCtxPtr outfile, int quality, gdHeifCodec codec, gdHeifChroma chroma);
	void *gdImageHeifPtr(gdImagePtr im, int *size);
	void *gdImageHeifPtrEx(gdImagePtr im, int *size, int quality, gdHeifCodec codec, gdHeifChroma chroma);

	void gdImageAvif(gdImagePtr im, FILE *outFile);
	void gdImageAvifEx(gdImagePtr im, FILE *outFile, int quality, int speed);
	void gdImageAvifCtx(gdImagePtr im, gdIOCtxPtr outfile, int quality, int speed);
	void *gdImageAvifPtr(gdImagePtr im, int *size);
	void *gdImageAvifPtrEx(gdImagePtr im, int *size, int quality, int speed);

	int gdImageFile(gdImagePtr im, const char *filename);

	int gdImageColorAllocate(gdImagePtr im, int r, int g, int b);
	int gdImageColorAllocateAlpha(gdImagePtr im, int r, int g, int b, int a);

	int gdImageColorClosest(gdImagePtr im, int r, int g, int b);
	int gdImageColorClosestAlpha(gdImagePtr im, int r, int g, int b, int a);
	int gdImageColorClosestHWB(gdImagePtr im, int r, int g, int b);

	int gdImageColorExact(gdImagePtr im, int r, int g, int b);
	int gdImageColorExactAlpha(gdImagePtr im, int r, int g, int b, int a);

	int gdImageColorResolve(gdImagePtr im, int r, int g, int b);
	int gdImageColorResolveAlpha(gdImagePtr im, int r, int g, int b, int a);

	int gdImageColorReplace(gdImagePtr im, int src, int dst);
	int gdImageColorReplaceThreshold(gdImagePtr im, int src, int dst, float threshold);
	int gdImageColorReplaceArray(gdImagePtr im, int len, int *src, int *dst);
	typedef int (*gdCallbackImageColor)(gdImagePtr im, int src);
	int gdImageColorReplaceCallback(gdImagePtr im, gdCallbackImageColor callback);

	void gdImageColorDeallocate(gdImagePtr im, int color);

	int gdImageColorsTotal(gdImagePtr im);
	int gdImageRed(gdImagePtr im, int c);
	int gdImageGreen(gdImagePtr im, int c);
	int gdImageBlue(gdImagePtr im, int c);
	int gdImageAlpha(gdImagePtr im, int color);

	int gdImageGetInterlaced(gdImagePtr im);
	int gdImageGetTransparent(gdImagePtr im);
	void gdImageColorTransparent(gdImagePtr im, int c);

	int gdImageSX(gdImagePtr im);
	int gdImageSY(gdImagePtr im);

	int gdImageBoundsSafe(gdImagePtr im, int x, int y);
	int gdImageGetPixel(gdImagePtr im, int x, int y);
	int gdImageGetTrueColorPixel(gdImagePtr im, int x, int y);
	void gdImageSetPixel(gdImagePtr im, int x, int y, int color);

	void gdImageAABlend(gdImagePtr im);

	void gdImageLine(gdImagePtr im, int x1, int y1, int x2, int y2, int c);
	void gdImageDashedLine(gdImagePtr im, int x1, int y1, int x2, int y2, int color);
	void gdImageRectangle(gdImagePtr im, int x1, int y1, int x2, int y2, int c);
	void gdImageFilledRectangle(gdImagePtr im, int x1, int y1, int x2, int y2, int c);

	void gdImagePolygon(gdImagePtr im, gdPointPtr points, int pointsTotal, int color);
	void gdImageFilledPolygon(gdImagePtr im, gdPointPtr points, int pointsTotal, int color);
	void gdImageOpenPolygon(gdImagePtr im, gdPointPtr points, int pointsTotal, int color);

	void gdImageArc(gdImagePtr im, int cx, int cy, int w, int h, int s, int e, int color);
	void gdImageFilledArc(gdImagePtr im, int cx, int cy, int w, int h, int s, int e, int color, int style);
	void gdImageEllipse(gdImagePtr im, int cx, int cy, int w, int h, int color);
	void gdImageFilledEllipse(gdImagePtr im, int cx, int cy, int w, int h, int color);
	void gdImageFill(gdImagePtr im, int x, int y, int color);
	void gdImageFillToBorder(gdImagePtr im, int x, int y, int border, int color);

	void gdImageSetAntiAliased(gdImagePtr im, int c);
	void gdImageSetAntiAliasedDontBlend(gdImagePtr im, int c, int dont_blend);

	void gdImageSetBrush(gdImagePtr im, gdImagePtr brush);
	void gdImageSetTile(gdImagePtr im, gdImagePtr tile);
	void gdImageSetStyle(gdImagePtr im, int *style, int styleLength);
	void gdImageSetThickness(gdImagePtr im, int thickness);
	void gdImageInterlace(gdImagePtr im, int interlaceArg);
	void gdImageAlphaBlending(gdImagePtr im, int alphaBlendingArg);
	void gdImageSaveAlpha(gdImagePtr im, int saveAlphaArg);

	void gdImageString(gdImagePtr im, gdFontPtr font, int x, int y,
	        unsigned char *s, int color);
	void gdImageStringUp(gdImagePtr im, gdFontPtr font, int x, int y,
	        unsigned char *s, int color);
	void gdImageString16(gdImagePtr im, gdFontPtr font, int x, int y,
	        unsigned short *s, int color);
	void gdImageStringUp16(gdImagePtr im, gdFontPtr font, int x, int y,
	        unsigned short *s, int color);
	void gdImageChar(gdImagePtr im, gdFontPtr font, int x, int y,
	            int c, int color);
	void gdImageCharUp(gdImagePtr im, gdFontPtr font, int x, int y,
	            int c, int color);

	void gdImageCopy(gdImagePtr dst, gdImagePtr src, int dstX, int dstY,
	            int srcX, int srcY, int w, int h);
	void gdImageCopyResized(gdImagePtr dst, gdImagePtr src, int dstX,
	            int dstY, int srcX, int srcY, int destW, int destH,
	            int srcW, int srcH);
	void gdImageCopyResampled(gdImagePtr dst, gdImagePtr src, int dstX,
	        int dstY, int srcX, int srcY, int destW, int destH, int srcW,
	        int srcH);
	void gdImageCopyRotated(gdImagePtr dst, gdImagePtr src, double dstX,
	        double dstY, int srcX, int srcY, int srcW, int srcH, int angle);
	void gdImageCopyMerge(gdImagePtr dst, gdImagePtr src, int dstX,
	        int dstY, int srcX, int srcY, int w, int h, int pct);
	void gdImageCopyMergeGray(gdImagePtr dst, gdImagePtr src, int dstX,
	        int dstY, int srcX, int srcY, int w, int h, int pct);
	void gdImagePaletteCopy(gdImagePtr dst, gdImagePtr src);

	void gdImageSquareToCircle(gdImagePtr im, int radius);
	void gdImageSharpen(gdImagePtr im, int pct);
	void gdImageSetClip(gdImagePtr im, int x1, int y1, int x2, int y2);
	void gdImageGetClip(gdImagePtr im, int *x1, int *y1, int *x2, int *y2);
	void gdImageSetResolution(gdImagePtr im, const unsigned int res_x, const unsigned int res_y);

	int gdImagePixelate(gdImagePtr im, int block_size, const unsigned int mode);
	int gdImageScatter(gdImagePtr im, int sub, int plus);
	int gdImageScatterColor(gdImagePtr im, int sub, int plus, int *colors, unsigned int num_colors);
	int gdImageScatterEx(gdImagePtr im, gdScatterPtr s);
	int gdImageSmooth(gdImagePtr im, float weight);
	int gdImageMeanRemoval(gdImagePtr im);
	int gdImageEmboss(gdImagePtr im);
	int gdImageGaussianBlur(gdImagePtr im);
	int gdImageEdgeDetectQuick(gdImagePtr src);
	int gdImageSelectiveBlur(gdImagePtr src);
	int gdImageConvolution(gdImagePtr src, float filter[3][3], float filter_div, float offset);

	int gdFTUseFontConfig(int flag);
	int gdFontCacheSetup(void);
	void gdFontCacheShutdown(void);
	void gdFreeFontCache(void);

	char *gdImageStringFT(gdImage *im, int *brect, int fg, const char *fontlist,
	                                     double ptsize, double angle, int x, int y,
	                                     const char *string);
	char *gdImageStringFTEx(gdImage *im, int *brect, int fg, const char *fontlist,
	                                       double ptsize, double angle, int x, int y,
	                                       const char *string, gdFTStringExtraPtr strex);
	char *gdImageStringTTF(gdImagePtr im, int *brect, int fg, const char *fontlist,
	                                      double ptsize, double angle, int x, int y,
	                                      const char *string);
	char *gdImageStringFTCircle(gdImagePtr im, int cx, int cy, double radius,
	                double textRadius, double fillPortion, char *font,
	                double points, char *top, char *bottom, int fgcolor);

	void gdImageGifAnimBegin(gdImagePtr im, FILE *out, int GlobalCM, int Loops);
	void gdImageGifAnimAdd(gdImagePtr im, FILE *out, int LocalCM, int LeftOfs,
	            int TopOfs, int Delay, int Disposal, gdImagePtr previm);
	void gdImageGifAnimEnd(FILE *out);
	void gdImageGifAnimBeginCtx(gdImagePtr im, gdIOCtxPtr out, int GlobalCM, int Loops);
	void gdImageGifAnimAddCtx(gdImagePtr im, gdIOCtxPtr out, int LocalCM, int LeftOfs, int TopOfs, int Delay, int Disposal, gdImagePtr previm);
	void gdImageGifAnimEndCtx(gdIOCtxPtr out);
	void *gdImageGifAnimBeginPtr(gdImagePtr im, int *size, int GlobalCM, int Loops);
	void *gdImageGifAnimAddPtr(gdImagePtr im, int *size, int LocalCM,
	    int LeftOfs, int TopOfs, int Delay, int Disposal, gdImagePtr previm);
	void *gdImageGifAnimEndPtr(int *size);
]])

local lib_patterns = {
    "%s", "%s.3", "%s.2"
}

local function get_libname()
    local suffix
    if ffi.os == "OSX" then
        suffix = ".dylib"
    elseif ffi.os == "Windows" then
        suffix = ".dll"
    else
        suffix = ".so"
    end
    return "libgd" .. suffix
end

local function load_library()
    for _, pattern in ipairs(lib_patterns) do
        local name = string.format(pattern, get_libname())
        local ok, lib = pcall(ffi.load, name)
        if ok then
            return lib
        end
    end
    return error("Failed to load gd library")
end

local lib = load_library()

return lib