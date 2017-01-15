local Parser = {}

function Parser.generate_tree(tokens)

	local state = {}
	state.tokens = tokens
	state.focus = 1
	state.mark = 0

	local keywords = {
		["if"] = true;
		["func"] = true;
		["while"] = true;
		["for"] = true;
		["do"] = true;
		["return"] = true;
		["continue"] = true;
		["break"] = true;
	}

	local function tok()
		return state.tokens[state.focus]
	end

	local function advance(i)
		state.focus = state.focus + (i or 1)
	end

	local function back(i)
		state.focus = state.focus - (i or 1)
	end

	local function peek(i)
		return state.tokens[state.focus + (i or 1)]
	end

	local function space()
		return state.focus <= #state.tokens
	end
	
	local function die(message, ...)
		os.exit()
	end

	local function is_kw(word)
		return keywords[word] ~= nil
	end
	
	-- finds the index of the next 'do' in the tokens
	local function mark_do()
		local index = state.focus
		while index <= #state.tokens do
			local on = state.tokens[index].word
			if on == "do" then
				state.mark = index
				return
			elseif is_kw(on) then
				die("unexpected keyword '%s' when scanning for token 'do'", on)
			end
			index = index + 1
		end
		die("unexpected EOF when scanning for token 'do'")
	end

	local function parse_expression()

		local op_info = {
			[',']		= {1, "left", "binary"};
			['=']		= {2, "right", "binary"};
			["+="]		= {2, "right", "binary"};
			["-="]		= {2, "right", "binary"};
			["*="]		= {2, "right", "binary"};
			["/="]		= {2, "right", "binary"};
			["%="]		= {2, "right", "binary"};
			["&="]		= {2, "right", "binary"};
			["|="]		= {2, "right", "binary"};
			["^="]		= {2, "right", "binary"};
			["&&"]		= {3, "left", "binary"};
			["||"]		= {3, "left", "binary"};
			["=="]		= {4, "left", "binary"};
			["!="]		= {4, "left", "binary"};
			[">"]		= {6, "left", "binary"};
			[">="]		= {6, "left", "binary"};
			["<"]		= {6, "left", "binary"};
			["<="]		= {6, "left", "binary"};
			['|']		= {7, "left", "binary"};
			["<<"]		= {7, "left", "binary"};
			[">>"]		= {7, "left", "binary"};
			["+"]		= {8, "left", "binary"};
			["-"]		= {8, "left", "binary"};
			["*"]		= {9, "left", "binary"};
			["%"]		= {9, "left", "binary"};
			["/"]		= {9, "left", "binary"};
			["@"]		= {10, "right", "unary"};
			["$"]		= {10, "right", "unary"};
			["!"]		= {10, "right", "unary"};
			["."]		= {11, "left", "binary"};
			["++"]		= {11, "left", "unary"};
			["--"]		= {11, "left", "unary"};
		}

		-- expects that the end of the expression is marked
		local exp = {}
		local postfix = {}
		local operators = {}
		while state.focus ~= state.mark do
			table.insert(exp, tok())	
			advance()	
		end
		advance() -- skip mark

		local i = 1
		while i <= #exp do
			local v = exp[i]
			if v.kind == "number" or v.kind == "identifier" then
				table.insert(postfix, v)	
			elseif v.kind == "operator" then
						
			end
			i = i + 1
		end
	end

	local function parse_if()
		local node = {}
		node.kind = "if"
		advance() -- skip token if
		mark_do()
		node.cond = parse_expression()
	end

	while space() do
		local t = tok()
		if t.word == "if" then
			parse_if()
		elseif t.word == "func" then

		end
		advance()
	end

end

return Parser
