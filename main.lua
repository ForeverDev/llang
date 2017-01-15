local Lexer = dofile "lex.lua"
local Parser = dofile "parse.lua"

local function main()
	local tokens = Lexer.generate_tokens("demo/test.spy")
	local tree = Parser.generate_tree(tokens)
end

main()
