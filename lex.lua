local Lexer = {}

local function printf(format, ...)
	io.write(string.format(format, ...))
end

function Lexer.generate_tokens(filename) 

	local state = {}
	state.line = 1
	state.filename = filename
	state.handle = nil
	state.source = nil -- to be read into
	state.index = 1
	state.tokens = {}
	
	state.handle = io.open(filename, "rb")
	if not state.handle then
		printf("couldn't open '%s' for reading", filename)
		os.exit(1)
	end

	state.source = state.handle:read("*all")

	local function die(format, ...)
		printf("** LEX ERROR **\n\tline: %d\n\tmessage: %s\n", state.line, string.format(format, ...))
		os.exit(1)
	end 

	local function char()
		return state.source:sub(state.index, state.index)
	end

	local function space()
		return state.index <= state.source:len()
	end

	local function advance(i)
		state.index = state.index + (i or 1)
	end

	local function back(i)
		state.index = state.index - (i or 1)
	end

	local function peek(i)
		i = i or 1
		return state.source:sub(state.index + i, state.index + i)
	end

	local function matches_number()
		return char():match("%d") ~= nil
	end

	local function matches_id()
		return char():match("%w") ~= nil
	end

	local function matches_op() 
		return char():match("%p") ~= nil
	end

	local function append(t)
		t.line = state.line
		table.insert(state.tokens, t)
	end

	local double_ops = {
		[">="] = true;
		["<="] = true;
		["=="] = true;
		["+="] = true;
		["-="] = true;
		["*="] = true;
		["/="] = true;
		["%="] = true;
		["&="] = true;
		["|="] = true;
		["^="] = true;
	}

	while space() do
		local c = char()
		if c == " " or c == "\t" then
			
		elseif c == "\n" then
			state.line = state.line + 1
		elseif matches_number() then
			local num = ""
			local found_dig = false
			while c:match("%d") or (not found_dig and c == ".") do
				if c == "." then
					found_dig = true
				end
				num = num .. c
				advance()
				c = char()
			end
			back()
			append({
				kind = "number";
				word = num;
				n = tonumber(num);	
			})
		elseif matches_id() then
			local id = ""
			while c:match("%w") do
				id = id .. c
				advance()
				c = char()
			end
			back()
			append({
				kind = "identifier";
				word = id;
			})
		elseif matches_op() then
			local nxt = peek()
			local is_dub = false
			local op = ""
			if nxt then
				is_dub = double_ops[c .. nxt] ~= nil
			end
			if is_dub then
				op = c .. nxt
				advance()
			else
				op = c
			end
			append({
				kind = "operator";
				word = op;
			})
		else
			die("unknown token '%s'", char())
		end
		advance()
	end

	io.close(state.handle)
	return state.tokens

end

return Lexer
