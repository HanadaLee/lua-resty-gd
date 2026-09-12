use strict;
use warnings;
BEGIN {
    use Cwd qw(abs_path getcwd);
    my $root = abs_path(getcwd());
    $ENV{TEST_NGINX_GD_ROOT} = $root;
    $ENV{TEST_NGINX_RESTY_LUALIB} = "$root/lib";
    my $lua_root = $root;
    $lua_root =~ s/\\/\\\\/g;
    $lua_root =~ s/"/\\"/g;
    $ENV{TEST_NGINX_INIT_BY_LUA} =
        qq{package.path = "$lua_root/lib/?.lua;$lua_root/lib/?/init.lua;" .. package.path};
}
use Test::Nginx::Socket::Lua;

repeat_each(1);
plan tests => repeat_each() * blocks() * 2;
no_long_string();
run_tests();

__DATA__

=== TEST 1: create palette image
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local im, err = gd.create(1, 1)
        assert(im and type(im) == "table" and type(im.im) == "cdata", err)
        assert(not gd.create(-1, 1))
        assert(not gd.create(1, -1))
        assert(not gd.create(0, 0))
        assert(not gd.create(0, 1))
        assert(not gd.create(1, 0))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 2: create true color image
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local im, err = gd.createTrueColor(1, 1)
        assert(im and type(im) == "table" and type(im.im) == "cdata", err)
        assert(im:colorAllocate(0, 0, 0) == 0)
        assert(not gd.createTrueColor(-1, 1))
        assert(not gd.createTrueColor(1, -1))
        assert(not gd.createTrueColor(0, 0))
        assert(not gd.createTrueColor(0, 1))
        assert(not gd.createTrueColor(1, 0))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 3: create from JPEG file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromJpeg(root .. "/t.jpg")
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromJpeg(root .. "/not_found.jpg"))
        local f = assert(io.open(root .. "/t.jpg", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromJpegStr(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromJpegStr(nil))
        assert(not gd.createFromJpegStr(""))
        assert(not gd.createFromJpegStr("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 4: create from GIF file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromGif(root .. "/t.gif")
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromGif(root .. "/not_found.gif"))
        local f = assert(io.open(root .. "/t.gif", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromGifStr(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromGifStr(nil))
        assert(not gd.createFromGifStr(""))
        assert(not gd.createFromGifStr("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 5: create from PNG file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromPng(root .. "/gdtest.png")
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromPng(root .. "/not_found.png"))
        local f = assert(io.open(root .. "/gdtest.png", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromPngStr(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromPngStr(nil))
        assert(not gd.createFromPngStr(""))
        assert(not gd.createFromPngStr("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 6: create from GD2 file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromGd2(root .. "/gdtest.gd2")
        if not im then
            ngx.log(ngx.WARN, "GD2 support unavailable: ", tostring(err))
            ngx.say("skipped")
            return
        end
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromGd2(root .. "/not_found.gd2"))
        local f = assert(io.open(root .. "/gdtest.gd2", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromGd2Str(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromGd2Str(nil))
        assert(not gd.createFromGd2Str(""))
        assert(not gd.createFromGd2Str("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body_like
^(?:ok|skipped)$

=== TEST 7: create from XBM file
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromXbm(root .. "/x10_basic_read.xbm")
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromXbm(root .. "/not_found.xbm"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 8: create from WebP file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromWebp(root .. "/4917851556.webp")
        assert(im and type(im.im) == "cdata", err)
        local f = assert(io.open(root .. "/4917851556.webp", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromWebpStr(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromWebpStr(nil))
        assert(not gd.createFromWebpStr(""))
        assert(not gd.createFromWebpStr("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 9: create from TIFF file and string
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromTiff(root .. "/2033418828.tiff")
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromTiff(root .. "/not_found.tiff"))
        local f = assert(io.open(root .. "/2033418828.tiff", "rb"))
        local blob = f:read("*a")
        assert(f:close())
        im, err = gd.createFromTiffStr(blob)
        assert(im and type(im.im) == "cdata", err)
        assert(not gd.createFromTiffStr(nil))
        assert(not gd.createFromTiffStr(""))
        assert(not gd.createFromTiffStr("kwa"))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok
