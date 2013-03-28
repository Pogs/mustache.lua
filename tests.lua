package.path = './?.lua;' .. package.path

local mustache = require "mustache"

local tests =
	{
		-- test 1: normal replacement
		{
			tem = '{{x}}',
			env = { x = 'y' },
			res = 'y'
		},
		-- test 2: multiple normal replacement
		{
			tem = '{{x}} < {{y}}',
			env = { x = 1,  y = 2 },
			res = '1 < 2'
		},
		-- test 3: call replacement
		{
			tem = '{{f}}',
			env = { f = function () return 'function' end },
			res = 'function'
		},
		-- test 4: no-op
		{
			tem = 'nothing to replace',
			env = { 1, 2, 3, cat = 'dog' },
			res = 'nothing to replace'
		},
		-- test 5: comments
		{
			tem = 'this is a {{! comment }}',
			env = {},
			res = 'this is a '
		},
		-- test 6: raw + escaped specials
		{
			tem = '{{specials}} | {{{specials}}} | {{&specials}}',
			env = { specials = '&<>' },
			res = '&amp;&lt;&gt; | &<> | &<>',
		},
		-- test 7: dictionary
		{
			tem = '{{#dict}}{{a}} + {{b}} = {{c}}{{/dict}}',
			env = { dict = { a = 1, b = 2, c = 3 } },
			res = '1 + 2 = 3'
		},
		-- test 7: non-empty list
		{
			tem = '{{#list}}fuzz = {{item}}, {{/list}}',
			env = { list = { { item = 'cat'}, { item = 'dog' }, { item = 'mouse' }, { item = 'horse' } } },
			res = 'fuzz = cat, fuzz = dog, fuzz = mouse, fuzz = horse, '
		},
		-- test 8: empty list
		{
			tem = '{{^list}}there are no items!{{/list}}',
			env = { list = {} },
			res = 'there are no items!'
		},
		-- test 9: nil replacement
		{
			tem = '{{#blah}}cat{{/blah}}{{^blah}}dog{{/blah}}',
			env = {},
			res = 'dog'
		},
		-- test 10: false replacement
		{
			tem = '{{#blah}}cat{{/blah}}{{^blah}}dog{{/blah}}',
			env = { blah = false },
			res = 'dog'
		},
		-- test 11: {{ . }}
		{
			tem = '{{#musketeers}}{{ . }} {{/musketeers}}',
			env = { musketeers = { 'Athos', 'Aramis', 'Porthos', "D'Artagnan" } },
			res = "Athos Aramis Porthos D'Artagnan "
		},
		-- test 12: replacement in same env as call
		{
			tem = '{{#bold}}{{text}}{{/bold}}',
			env = { bold = function (s) return string.format('<b>%s</b>', s) end, text = 'hello world!' },
			res = '<b>hello world!</b>'
		},
		-- test 13: render-once for "truth value"
		{
			tem = '{{~someval}}yes!{{/someval}}',
			env = { someval = { 'a', 'b', 'c' } },
			res = 'yes!'
		},
		-- test 14: nested section test
		{
			tem = '{{#x}}{{cat}}{{#y}}{{dog}}{{/y}}{{/x}}',
			env = { x = { cat = 'mouse', y = { dog = 'horse' } } },
			res = 'mousehorse'
		}
		-- Add multiline tests
	}

for i, v in ipairs(tests) do
    print("\n== TEST: " .. i .. " ==")
    print("template =", "'" .. v.tem .. "'")
    local ret = mustache.render(v.tem, v.env)
    print("render   =", "'" .. ret .. "'")
    assert(ret == v.res)
end

print("\n--> All tests passed")
