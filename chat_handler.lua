-- admin handler:

-- variables:
local command_count = 0;

-- tables:
local module = {};
local command_table = {};

-- functions:
function module.notification(self, string, player)
	-- print(string, player);
end
function module:add_command(name, func, info)
	if command_table[name] then
		return;
	end

	command_count += 1;

	command_table[name] = {func = func or function() end; info = info or {}};
end
function module:command_amount()
	return command_count;
end
function module:toggle_command(name, admin_table, global_table, func, info)
	self:add_command(name, function(args, player)
		local toggle_tbl = (admin_table[player.UserId] and admin_table[player.UserId].toggles) or global_table;

		if not toggle_tbl then
			return self:notification("No toggle table found", player);
		end 

		local toggle = toggle_tbl[name];

		if toggle == nil then
		    return self:notification(("toggle %s does not exist"):format(name), player)
		end

		toggle_tbl[name] = not toggle_tbl[name];
		self:notification(("%s is now %s"):format(toggle_tbl[name] and "on" or "off"), player);
			
		if func then
			func(args, player);
		end
	end, info);
end
function module:thread_command(name, thread_tbl, func, info)
	self:add_command(name, function(args, player)
		local existing_thread = thread_tbl[name]
		if existing_thread and coroutine.status(existing_thread) ~= "dead" then
			task.cancel(existing_thread);
			thread_tbl[name] = nil;
			return self:notification(name.." has stopped", player);
		end

		local new_thread = coroutine.create(function()
			self:notification(name.." has started", player);
			while true do
				func(args, player);
				task.wait();
			end
		end)

		thread_tbl[name] = new_thread

		-- monitor thread fr i'm so awesome :eggplant::splurttt:
		task.spawn(function()
			task.spawn(new_thread);
			repeat
				task.wait();
			until not new_thread or coroutine.status(new_thread) == "dead";
			self:notification(name.." has naturally stopped", player);
			thread_tbl[name] = nil;
		end)
	end, info);
end
function module:find_command(name)
	local command = command_table[name]

	if not command then
		for _, v in next, command_table do
			if table.find(v.info.aliases or {}, name) then
				command = v;
				break;
			end
		end
	end

	return command;
end
function module:on_chatted(message, player, prefix)
	if message == "" then
		return;
	end
	if message == prefix then
		return;
	end
	if message:sub(1, #prefix) ~= prefix then
		return;
	end

	local args = message:split(" ");
	local command_name = args[1]:sub(#prefix + 1);
	local command = self:find_command(command_name);

	if not command then
		return self:notification(command_name.." is not a valid command", player);
	end

	local success, result = pcall(function()
		command.func(args, player);
	end)

	if not success and result then
		return self:notification(result, player);
	end
end


return module;
