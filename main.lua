-- made by vndz-Hack.

--[[
 ___      ___ ________  ___   _________  ___     ___    ___      ________  ___   _________        ________  ________  ________   _________  ________  ________  ___          
|\  \    /  /|\   __  \|\  \ |\___   ___\\  \   |\  \  /  /|    |\   __  \|\  \ |\___   ___\     |\   ____\|\   __  \|\   ___  \|\___   ___\\   __  \|\   __  \|\  \         
\ \  \  /  / | \  \|\  \ \  \\|___ \  \_\ \  \  \ \  \/  / /    \ \  \|\  \ \  \\|___ \  \_|     \ \  \___|\ \  \|\  \ \  \\ \  \|___ \  \_\ \  \|\  \ \  \|\  \ \  \        
 \ \  \/  / / \ \  \\\  \ \  \    \ \  \ \ \  \  \ \    / /      \ \   __  \ \  \    \ \  \       \ \  \    \ \  \\\  \ \  \\ \  \   \ \  \ \ \   _  _\ \  \\\  \ \  \       
  \ \    / /   \ \  \\\  \ \  \____\ \  \ \ \  \  /     \/        \ \  \ \  \ \  \____\ \  \       \ \  \____\ \  \\\  \ \  \\ \  \   \ \  \ \ \  \\  \\ \  \\\  \ \  \____  
   \ \__/ /     \ \_______\ \_______\ \__\ \ \__\/  /\   \         \ \__\ \__\ \_______\ \__\       \ \_______\ \_______\ \__\\ \__\   \ \__\ \ \__\\ _\\ \_______\ \_______\
    \|__|/       \|_______|\|_______|\|__|  \|__/__/ /\ __\         \|__|\|__|\|_______|\|__|        \|_______|\|_______|\|__| \|__|    \|__|  \|__|\|__|\|_______|\|_______|
                                                |__|/ \|__|                                                                                                                  
                                                                                                                                                                             
                                                                                                                                                                             
--]]

-- checking version:
--[[
local version = "v1.0.1";
local main_string = "https://raw.githubusercontent.com/vndz-Hack/Voltix-Admin/refs/heads/main/";
local check_version = game:HttpGet(main_string.."version.txt");

if check_version ~= version then
	return loadstring(game:HttpGet(main_string.."main.lua"))();
end
]]--

if getgenv().loaded and getgenv().connections then
	for _, v in next, getgenv().connections do
		if typeof(v) == "thread" then
			task.cancel(v);
		else
			v:Disconnect();
		end
	end

	getgenv().connections = nil;
	getgenv().loaded = nil;

	return;
end

getgenv().loaded = true;

print"loading..";

-- services:
local replicated_storage = game:service"ReplicatedStorage";
local text_chat_service = game:service"TextChatService";
local players = game:service"Players";
local teams = game:service"Teams";

-- utilities / shortcuts
local cf = CFrame.new
local v2 = Vector2.new
local v3 = Vector3.new

-- variables
local prefix = "-"
local local_player = players.LocalPlayer;
local remotes = workspace.Remote;
local items = workspace.Prison_ITEMS;
local criminal_pad = workspace['Criminals Spawn'].SpawnLocation

-- tables:
local commands = {};
local whitelist = {
	-- "vndz";
}
local admins = {
	[418198715] = {toggles = {
		-- will add stuff soon
	}};
};

getgenv().connections = {};

-- functions:
local insert = function(connection)
	connections[#connections + 1] = connection;
end
local table_count = function(table)
	local count = 0;

	for _, _ in next, table do
		count += 1;
	end

	print(count);
	return count;
end
local chat = function(string)
	local text_channels = text_chat_service:WaitForChild("TextChannels");

	if text_channels then
		local rbx_general = text_channels:FindFirstChild("RBXGeneral");

		if rbx_general then
			rbx_general:SendAsync(string, "you spying :3?");
		end
	end
end
pm_player = function(string, player)
	local text_channels = text_chat_service:WaitForChild("TextChannels");

	if text_channels then
		local whisper_channel = nil;

		for _, v in next, text_channels:GetChildren() do
			if v.Name:find("RBXWhisper") and v.Name:find(player.UserId) and v.Name:find(local_player.UserId) then
				whisper_channel = v;
				break;
			end
		end

		if not whisper_channel then
			chat("/w "..player.DisplayName);
			task.wait(.1);

			return pm_player(string, player)
		end
	end
end
local find_command = function(name)
	local found_command = commands[name];

	if not found_command then
		for _, v in next, commands do
			if v.info and table.find(v.info.aliases, name) then
				found_command = v;
				break;
			end
		end
	end

	return found_command;
end
local add_command = function(name, func, info)
	commands[name] = {func = func, info = info or {}};
end
local add_toggle = function(name, func, info)
	add_command(name, function(args, player)
		local admin_toggles = admins[player.UserId].toggles;

		if admin_toggles[name] ~= nil then
			local prev_value = admin_toggles[name];

			if args[2] then
				if not (args[2] == "on" or args[2] == "off") then
					return;
				end
				if (args[2] == "on" and prev_value or args[2] == "off" and not prev_value) then
					return;
				end

				admin_toggles[name] = args[2] == "on" and true or args[2] == "off" and false or prev_value
			else
				admin_toggles[name] = not admin_toggles[name];
			end

		end
	end, info or {})
end
local on_chatted = function(string, player)
	if string == "" then
		return;
	end
	if #string == #prefix then
		return;
	end
	if string:sub(1, #prefix) ~= prefix then
		return;
	end

	local args = string.split(string, " ");
	local split = args[1]:sub(#prefix + 1);
	local command = find_command(split);

	if not command then
		return pm_player(("%s is not a valid command"):format(split), player);
	end

	local success, result = pcall(function()
		command.func(args, player);
	end)

	if not success and result then
		return pm_player(result, player);
	end
end
local has_character = function(player)
	return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart");
end
local fti = function(part, part2)
	if part and part2 then
		local old_cc = part.CanCollide;
		local old_t = part.Transparency;
		local old_cf = part.CFrame;

		part.CanCollide = false;
		part.Transparency = 1;

		for _ = 1, 3 do
			part.CFrame = part2.CFrame;
			task.wait();
		end

		part.CFrame = old_cf;
		part.CanCollide = old_cc;
		part.Transparency = old_t;
	end
end
local find_team = function(string)
	for _, v in next, teams:GetChildren() do
		if v.Name:lower():find(string:lower()) then
			return v;
		end
	end
end
local find_player = function(string, player)
	if string and string ~= "" then
		local targets = {};

		string = string:lower();

		if string == "me" then
			targets = {player};
		elseif string == "all" or string == "everyone" then
			targets = players:GetPlayers();
		elseif find_team(string) then
			targets = find_team(string):GetPlayers();
		else
			for _, v in next, players:GetPlayers() do
				if v.Name:lower():find(string) or v.DisplayName:lower():find(string) then
					table.insert(targets, v);
				end
			end
		end

		print(targets);
		return targets;
	end
end
local invoke_item = function(name)
	task.spawn(function()
		remotes.ItemHandler:InvokeServer({
			Position = local_player.Character:FindFirstChild("HumanoidRootPart").Position;
			Parent = items:FindFirstChild(name, true);
		});
	end)
end
local fire_melee = function(player, amount)
	for _ = 1, amount or 1 do
		replicated_storage.meleeEvent:FireServer(player, {Name = "Crude Knife"});
	end
end
local fire_team = function(color)
	remotes.TeamEvent:FireServer(color);
end
local get_item = function(list, return_item)
	if list and table_count(list) > 0 then
		for _, v in next, list do
			if items:FindFirstChild(v, true) then
				invoke_item(v);
			end
		end
	end

	if return_item then
		local tool = local_player.Character:FindFirstChild(return_item) or local_player.Backpack:FindFirstChild(return_item);

		if not tool then
			repeat
				invoke_item(return_item);
				tool = local_player.Character:FindFirstChild(return_item) or local_player.Backpack:FindFirstChild(return_item);
				task.wait();
			until tool;
		end

		return tool;
	end
end
respawn = function(color)
	if not color then
		color = local_player.TeamColor.Name;
	end

	if color then
		if color == "Bright orange" or color == "Medium stone grey" then
			fire_team(color);
		elseif color == "Bright blue" then
			if #teams.Guards:GetPlayers() == 8 then
				fire_team("Bright orange");

				if local_player.TeamColor.Name == color then
					fire_team("Bright orange");
				end
			end

			fire_team(color);
		elseif color == "Really red" then
			respawn("Bright blue");

			repeat
				fti(criminal_pad, local_player.Character:FindFirstChild("HumanoidRootPart"));
				task.wait(.1)
			until local_player.TeamColor.Name == color;
		end
	end
end
local kill = function(player_list, method)
	local shoot_table = {};
	local tool = nil;

	for _, v in next, player_list do
		if type(v) == "string" then
			v = players:FindFirstChild(v);
		end

		if has_character(v) and not table.find(whitelist, v.Name) then
			tool = get_item(nil, "Remington 870");

			print(math.ceil(v.Character.Humanoid.Health / 22.5));

			for _ = 1, math.ceil(v.Character.Humanoid.Health / 22.5) do
				table.insert(shoot_table, {
					RayObject = Ray.new(),
					Cframe = cf(),
					Distance = 0,
					Hit = v.Head,
				})
			end
		end
	end

	if tool and table_count(shoot_table) > 0 then
		replicated_storage.ShootEvent:FireServer(shoot_table, tool);
		replicated_storage.ReloadEvent:FireServer(tool);
	end
end

local player_added = function(player)
	local is_admin = admins[player.UserId];

	if is_admin then
		insert(player.Chatted:connect(function(message)
			on_chatted(message, player);
		end))
	end
end

-- commands:
add_command("chat", function(args, player)
	local message = args;
	table.remove(message, 1);
	message = tostring(table.concat(message, " "));

	chat(message);
end, {aliases = {"say"}})
add_command("bring", function(args, player)
	if has_character(player) then
		if not has_character(local_player) then
			return pm_player("local player is dead", player);
		end

		local player_root = player.Character:FindFirstChild("HumanoidRootPart");
		local local_root = local_player.Character:FindFirstChild("HumanoidRootPart");

		if player_root and local_root then
			local new_cf = player_root.CFrame * cf(0, 0, -6);
			local_root.CFrame = cf(new_cf.Position, new_cf.Position + player_root.CFrame.LookVector);
		end
	end
end, {aliases = {"b"}});
add_command("team", function(args, player)
	if args[2] then
		local team = find_team(args[2])

		print(team);

		if team then
			respawn(team.TeamColor.Name);
		end
	end
end, {aliases = {"t"}});
add_command("kill", function(args, player)
	if args[2] then
		local targets = find_player(args[2], player);

		for _, v in next, targets do
			print(v);
		end

		if targets and table_count(targets) > 0 then
			kill(targets);
		end
	end
end, {aliases = {"k"}})


-- signals:
insert(players.PlayerAdded:connect(player_added));

for _, v in next, players:GetPlayers() do
	player_added(v);
end

print"loaded";
