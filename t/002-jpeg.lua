-- Copyright (C) by Kwanhur Huang


describe("jpeg", function()

    local path = require('path')
    local image_path = path.new('/')
    local image_dir = image_path.join(path.currentdir(), "t", "image")
    local md5 = require('md5')
    local gd = require("resty.gd")

    it("outputJpeg", function()
        local gdImage, err = gd.createFromJpeg(image_dir .. "/t.jpg")
        assert.is_true(gdImage ~= nil)

        local fname = image_dir .. "/t_img.jpg"
        local ok, err = gdImage:jpeg(fname, 100)
        assert.is_true(ok)

        local f = io.open(fname)
        local blob = f:read("*a")
        f:close()
        os.remove(fname)
        assert.is_true(md5.sumhexa(blob) ~= "")

        local ok, err = gdImage:jpeg(fname, 101)
        assert.is_false(ok)
        local ok, err = gdImage:jpeg(fname, -1)
        assert.is_false(ok)
    end)

    it("outputJpegStr", function()
        local gdImage, err = gd.createTrueColor(16, 16)
        assert.is_nil(err)

        local blob
        blob, err = gdImage:jpegStr(70)
        assert.is_nil(err)
        assert.is_true(#blob > 4)
        assert.are_equal("\255\216", blob:sub(1, 2))
        assert.are_equal("\255\217", blob:sub(-2))
    end)

    it("sizeXY", function()
        local gdImage, err = gd.createFromJpeg(image_dir .. "/t.jpg")
        assert.is_true(gdImage ~= nil)

        local fname = image_dir .. "/t_img.jpg"
        local ok, err = gdImage:jpeg(fname, 100)
        assert.is_true(ok)

        local f = io.open(fname)
        local blob = f:read("*a")
        f:close()
        os.remove(fname)

        assert.is_true(string.len(blob) > 0)
        local x, y = gdImage:sizeXY()

        gdImage, err = gd.createFromJpegStr(blob)
        assert.is_true(gdImage ~= nil)
        local x1, y1 = gdImage:sizeXY()
        assert.is_true(x == x1)
        assert.is_true(y == y1)
    end)

    it("colorsTotal", function()
        local gdImage, err = gd.createFromJpeg(image_dir .. "/t.jpg")
        assert.is_true(gdImage ~= nil)

        local fname = image_dir .. "/t_img.jpg"
        local ok, err = gdImage:jpeg(fname, 100)
        assert.is_true(ok)
        assert.is_true(gdImage:colorsTotal() ~= nil)
    end)
end)
