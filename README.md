# {{ mustache.lua }}

## What?

[Mustache](http://mustache.github.com/ "Mustache") is a logic-free templating language

## Why?

BECAUSE MUSTACHES! >:{

## Status

### Done
- {{normal_tags}}
- {{{unescaped}}} {{&tags}}
- {{! comment tags }}
- {{^inverted_sections}}
- {{ . }}
- Dictionaries
- Lists
- Lambdas
- Boolean-True
- Nil/False/Empty-List

### Extensions
- {{?section}}printed only once, even if list{{/section}}

### Todo
- {{>partials}}
- {{= =}} (set delimeters)
- Use Defunkt's Mustache examples for tests

## Usage

Running the included tests:
```bash
 lua tests.lua
```

Rendering a template string:
```lua
	local mustache = require('mustache')

	local template = 'hello {{thing}}!'
	local env = { thing = 'world' }

	print(mustache.render(template, env))
```

Rendering a template file:
```lua
	local mustache = require('mustache')

	print(mustache.renderfile('example.mustache'))
```
