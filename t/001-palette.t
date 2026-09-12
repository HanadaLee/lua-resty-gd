use strict;
use warnings;
BEGIN {
    use Cwd qw(abs_path getcwd);
    my $root = abs_path(getcwd());
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

=== TEST 1: createPaletteFromTrueColor
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local im, err = gd.createTrueColor(1, 1)
        assert(im and type(im.im) == "cdata", err)
        local converted = im:createPaletteFromTrueColor(true, 256)
        assert(converted and type(converted.im) == "cdata")
        converted = im:createPaletteFromTrueColor(false, 256)
        assert(converted and type(converted.im) == "cdata")
        assert(not im:createPaletteFromTrueColor(true, 0))
        assert(not im:createPaletteFromTrueColor(true, -1))
        assert(not im:createPaletteFromTrueColor(true, 256.1))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok

=== TEST 2: trueColorToPalette
--- config
location /t {
    content_by_lua_block {
        local gd = require "resty.gd"
        local im, err = gd.createTrueColor(1, 1)
        assert(im and type(im.im) == "cdata", err)
        assert(im:trueColorToPalette(true, 256))
        assert(im:trueColorToPalette(false, 256))
        assert(not im:trueColorToPalette(true, 0))
        assert(not im:trueColorToPalette(true, -1))
        assert(not im:trueColorToPalette(true, 256.1))
        ngx.say("ok")
    }
}
--- request
GET /t
--- response_body
ok
