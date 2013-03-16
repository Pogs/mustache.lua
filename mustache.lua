--
-- mustache.lua
--
-- external function: render(template, environment)
--

DEBUG = false

_ENV = setmetatable({}, { __index = _G })

---------------------
-- pattern section --
---------------------

local otag = '{{'
local ctag = '}}'

-- "Names (also called identifiers) in Lua can be any string of letters, digits, and underscores,
-- not beginning with a digit. Identifiers are used to name variables, table fields, and labels."
-- ^ extended to v to also match {{ . }} and {{ ! this is a comment }}
local identifier = '[%a_%.][%g_ ]-'
local mods       = '&!=>'

-- tag modifiers: '&'=no escape, '!'=comment, '{'=no escape
-- not implemented: '='=change delimiter, '>'=partials
local tag_pattern = '(' .. otag .. '%s*([{' .. mods .. ']?)%s*(' .. identifier .. ')%s*}?' .. ctag .. ')'

-- sect modifiers: '#'=open, '/'=close, '^'=invert
local sect_pattern = '(' .. otag .. '%s*([#^])%s*(' .. identifier .. ')%s*}?' .. ctag ..  '(.-)' ..  otag .. '%s*/%s*%3%s*}?' .. ctag ..')'

--------------------
-- util functions --
--------------------

-- print debug messages
local debug =
	function (prefix, ...)
		if DEBUG then
			local cout = io.output()

			cout:write(prefix, '\t', ...)
			cout:write('\r\n')
		end
	end

-- escape characters '&', '>' and '<' for HTML
local escape =
	function (s)
		if type(s) ~= 'string' then return s end

		return
			s:gsub
			(
				'[&<>]',
				{
					['&'] = '&amp;',
					['<'] = '&lt;',
					['>'] = '&gt;'
				}
			)
	end

local callable =
	function (x)
		local tmp = type(x)

		if tmp == 'function' then
			return true
		end

		tmp = getmetatable(tmp)

		if tmp and tmp.__call then
			return true
		end

		return false
	end

-- finds a tag in an environment; functions are called
local get_variable =
	function (tag, env)
		if tag == '.' then
			return env
		end

		local tmp = env[tag]

		return callable(tmp) and tmp() or tmp or ''
	end


local is_dict =
	function (t)
		if type(t) ~= 'table' then
			return false
		end

		for k in pairs(t) do
			if type(k) ~= 'number' then
				return true
			end
		end

		return false
	end

-----------------------------
-- tag rendering functions --
-----------------------------

local render_normal       = function (tag, env) debug('[debug]',                       'normal tag found') return escape(get_variable(tag, env)) end
local render_comment      = function (tag, env) debug('[debug]',                      'comment tag found') return ''                             end
local render_unescaped    = function (tag, env) debug('[debug]',                    'unescaped tag found') return get_variable(tag, env)         end
local render_partial      = function (tag, env) debug('[debug-error]',         'partials not implemented') return ''                             end
local render_change_delim = function (tag, env) debug('[debug-error]', 'change delimiter not implemented') return ''                             end

local modifiers =
{
	['' ] = render_normal,
	['!'] = render_comment,
	['&'] = render_unescaped,
	['{'] = render_unescaped,
	['>'] = render_partial,
	['='] = render_change_delim
}

---------------------------------
-- overall rendering functions --
---------------------------------

local render_tags =
	function (template, env)
		return
			template:gsub
			(
				tag_pattern,
				function (tag, tagmod, tagname)
					debug('[debug-loop]', 'template = ', "'", template, "'")
					debug('[debug-loop]', 'tag      = ', "'", tag,      "'")
					debug('[debug-loop]', 'tagmod   = ', "'", tagmod,   "'")
					debug('[debug-loop]', 'tagname  = ', "'", tagname,  "'")

					local replacement = modifiers[tagmod](tagname, env)

					debug("[debug-loop]", 'replace  = ', "'", replacement, "'")
				
					return replacement
				end
			)
	end

local render_sections = nil

render_sections =
	function (template, env)
		return
			template:gsub
			(
				sect_pattern,
				function (tag, tagmod, tagname, content)
					debug('[debug-loop]', 'template = ', "'", template, "'")
					debug('[debug-loop]', 'tag      = ', "'", tag,      "'")
					debug('[debug-loop]', 'tagmod   = ', "'", tagmod,   "'")
					debug('[debug-loop]', 'tagname  = ', "'", tagname,  "'")
					debug('[debug-loop]', 'content  = ', "'", content,  "'")

					content = content:gsub('^\r?\n%s*', '')

			        local x = env[tagname]
			        local replacement = ''

					if tagmod == '#' then
						-- handle boolean-true
						if x == true then
							replacement = content

						-- handle callable objects
						elseif callable(x) then
							local tmp = x(content)

							if type(tmp) == 'string' then
								replacement = tmp
							end

						-- handle tables
						elseif type(x) == 'table' then
							-- we need to treat every #section as if it has an
							-- associated array of environments to go with it
							if is_dict(x) then
								x = { x }
							end

							for _, sub_env in ipairs(x) do
								replacement = replacement .. render(content, sub_env)
							end
						end

						-- boolean-false and all other object types replace with nothing

					else -- tagmod == '^'
						if not x or (type(x) == 'table' and #x == 0 and not is_dict(x)) then
							replacement = content
						end
					end
    
					debug('[debug-loop]', 'replace  = ', "'", replacement, "'")

					return replacement:gsub('\r?\n%s*$', '')
				end
			)
	end

render =
	function (template, env)
	    debug('[debug]', 'render called')
		debug('[debug]', 'template = ', "'", template, "'")

		env = env or {}

		template = render_sections(template, env)
		template = render_tags    (template, env)

		return template
	end

renderfile =
	function (filename, env)
		local tmp = assert(io.open(filename))

		local text = tmp:read('*a')

		io.close(tmp)

		return render(text, env)
	end

return _ENV
