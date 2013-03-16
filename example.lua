package.path = './?.lua;' .. package.path

local mustache = require 'mustache'

local env =
{
	template_engine = 'mustache.lua',

    details = { string_fn = 'render()', file_fn = 'renderfile()' },

    numbers = { { num = 1 }, { num = 2 }, { num = 3 } },
	letters = { 'a', 'b', 'c', 'd', 'e', 'f', 'g' },

    done = true
}

print(mustache.renderfile('example.mustache', env))
