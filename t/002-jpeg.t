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

=== TEST 1: output JPEG file
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromJpeg(root .. "/t.jpg")
        assert(im, err)
        local output = root .. "/t_img.jpg"
        local ok, write_err = im:jpeg(output, 100)
        assert(ok, write_err)
        local f = assert(io.open(output, "rb"))
        local blob = f:read("*a")
        assert(f:close())
        assert(os.remove(output))
        assert(#blob > 0)
        assert(not im:jpeg(output, 101))
        assert(not im:jpeg(output, -1))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 2: output JPEG string
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local im, err = gd.createTrueColor(16, 16)
        assert(im and not err)
        local blob, encode_err = im:jpegStr(70)
        assert(blob and not encode_err)
        assert(#blob > 4)
        assert(blob:sub(1, 2) == "\255\216")
        assert(blob:sub(-2) == "\255\217")
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 3: preserve JPEG dimensions through string encoding
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromJpeg(root .. "/t.jpg")
        assert(im, err)
        local x, y = im:sizeXY()
        local blob = assert(im:jpegStr(100))
        local decoded, decode_err = gd.createFromJpegStr(blob)
        assert(decoded, decode_err)
        local x1, y1 = decoded:sizeXY()
        assert(x == x1 and y == y1)
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 4: colorsTotal after JPEG output
--- main_config
env TEST_NGINX_GD_ROOT;
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local root = os.getenv("TEST_NGINX_GD_ROOT") .. "/t/image"
        local im, err = gd.createFromJpeg(root .. "/t.jpg")
        assert(im, err)
        local output = root .. "/t_img.jpg"
        local ok, write_err = im:jpeg(output, 100)
        assert(ok, write_err)
        assert(os.remove(output))
        assert(im:colorsTotal() ~= nil)
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok
