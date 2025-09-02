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

if not game.Loaded then
	game.Loaded:Wait();
end

-- checking version:
local version = "v1.0.1";
local main_string = "https://raw.githubusercontent.com/vndz-Hack/Voltix-Admin/refs/heads/main/";
local check_version = game:HttpGet(main_string.."version.txt");

if check_version ~= version then
	return loadstring(game:HttpGet(main_string.."main.lua"))();
end

if getgenv().loaded then
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

-- services:
local replicated_storage = game:service"ReplicatedStorage";
local text_chat_service = game:service"TextChatService";
local players = game:service"Players";

-- varables:
local local_player = players.LocalPlayer;

local prefix = "-";

-- tables:
local commands = {};
local admins = {
	[418198715] = {toggles = {
		-- will add stuff soon
	}};
};

getgenv().connections = {};

local cf = CFrame.new;
local v2 = Vector2.new;
local v3 = Vector3.new;

-- functions:
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

local player_added = function(player)
	local is_admin = admins[player.UserId];

	if is_admin then
		player.Chatted:connect(function(message)
			on_chatted(message, player);
		end)
	end
end

-- commands:
add_command("chat", function(args, player)
	local message = args;
	table.remove(message, 1);
	message = tostring(table.concat(args, " "));

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

-- signals:
players.PlayerAdded:connect(player_added);

for _, v in next, players:GetPlayers() do
	player_added(v);
end
