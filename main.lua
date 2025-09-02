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
local teleport_service = game:service"TeleportService";
local players = game:service"Players";
local teams = game:service"Teams";

-- utilities / shortcuts
local cf = CFrame.new;
local v2 = Vector2.new;
local v3 = Vector3.new;

-- variables
local prefix = "-";
local local_player = players.LocalPlayer;
local remotes = workspace.Remote;
local items = workspace.Prison_ITEMS;
local criminal_pad = workspace['Criminals Spawn'].SpawnLocation;
local current_camera = workspace.CurrentCamera;

root_position = nil;
camera_position = nil;

-- tables:
local commands = {};
local whitelist = {
	"vndz";
	"unevenfeather71";
}
local admins = {
	[418198715] = {toggles = {
		-- will add stuff soon
	}};
};
local toggles = {
	auto_respawn = true,
	save_position = true,
};
local loopkill = {
	targets = {},
	players = false,
	guards = false,
	inmates = false,
	criminals = false,
	neutral = false,
}

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

			return pm_player(string, player);
		end

		whisper_channel:SendAsync(string);
	end
end
local save_position = function()
	if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") and local_player.Character.HumanoidRootPart.Position.Y > 0 then
		root_position = local_player.Character.HumanoidRootPart.CFrame;
		camera_position = current_camera.CFrame;
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
local kill = function(player_list)
	local shoot_table = {};
	local tool = get_item(nil, "Remington 870");

	for _, v in next, player_list do
		if type(v) == "string" then
			print("string.. converting to a player");
			v = players:FindFirstChild(v);
		end

		if has_character(v) and not table.find(whitelist, v.Name) and not v.Character:FindFirstChild("ForceField") then
			for _ = 1, math.ceil(v.Character.Humanoid.Health / 22.5) do
				table.insert(shoot_table, {
					RayObject = Ray.new(),
					Distance = 0,
					Cframe = cf(),
					Hit = v.Character.Head,
				})
			end
		end
	end

	if tool and table_count(shoot_table) > 0 then
		replicated_storage.ShootEvent:FireServer(shoot_table, tool);
		replicated_storage.ReloadEvent:FireServer(tool);
	end
end

local character_added = function(character)
	local humanoid = character:WaitForChild("Humanoid");
	local rootpart = character:WaitForChild("HumanoidRootPart");

	if humanoid then
		humanoid.Died:once(function()
			if toggles.auto_respawn then
				respawn();
			end
		end)

		if toggles.save_position then
			task.wait(local_player:GetNetworkPing() * 3);
			current_camera.CFrame = camera_position;
			rootpart.CFrame = root_position;
		end
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

		if team then
			respawn(team.TeamColor.Name);
		end
	end
end, {aliases = {"t"}});
add_command("respawn", function(args, player)
	respawn();
end, {aliases = {"re", "refresh"}})
add_command("kill", function(args, player)
	if args[2] then
		local targets = find_player(args[2], player);

		if targets and table_count(targets) > 0 then
			kill(targets);
		end
	end
end, {aliases = {"k"}})
add_command("loopkill", function(args, player)
	if args[2] then
		local lk_team = find_team(args[2]) or args[2] == "all" and players or args[2] == "everyone" and players

		if lk_team then
			loopkill[lk_team.Name:lower()] = true;
		else
			local targets = find_player(args[2], player);

			if targets[1] then
				table.insert(loopkill.targets, targets[1]);
			end
		end
	end
end, {aliases = {"lk"}})
add_command("unloopkill", function(args, player)
	if args[2] then
		local lk_team = find_team(args[2]) or args[2] == "all" and players or args[2] == "everyone" and players

		if lk_team then
			loopkill[lk_team.Name:lower()] = false;
		else
			local targets = find_player(args[2], player);

			if targets[1] then
				table.remove(loopkill.targets, table.find(loopkill.targets, targets[1]));
				pm_player("unlking "..targets[1].Name, player);
			end
		end
	end
end, {aliases = {"unlk"}})
add_command("permadeath", function(args, player)
	firesignal(local_player.ConnectDiedSignalBackend);
	task.wait(players.RespawnTime + .1);
	local_player:BreakJoints();

	local prev_value = toggles.auto_respawn;
	toggles.auto_respawn = false;

	local_player.CharacterAdded:once(function()
		toggles.auto_respawn = prev_value;
	end)
end, {aliases = {"permdeath", "pd"}})
add_command("rejoin", function(args, player)
	pm_player("rejoining..", player);
	teleport_service:TeleportToPlaceInstance(game.PlaceId, game.JobId);
end, {aliases = {"rj"}})


-- seperate threads:

task.spawn(function()
	while task.wait(.1) do
		if table_count(loopkill.targets) > 0 then
			kill(loopkill.targets);
		end

		for i, v in next, loopkill do
			if type(v) == "boolean" and v == true then
				local team = i == "players" and players or find_team(i);

				if team then
					kill(team:GetPlayers());
				end
			end
		end
	end
end)

-- signals:
insert(players.PlayerAdded:connect(player_added));
insert(local_player.CharacterAdded:connect(character_added));

-- extras:

for _, v in next, players:GetPlayers() do
	player_added(v);
end

character_added(local_player.Character);
