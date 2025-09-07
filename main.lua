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

local start = tick();

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
end

getgenv().loaded = true;

print"loading";

-- services:
local replicated_storage = game:service"ReplicatedStorage";
local text_chat_service = game:service"TextChatService";
local teleport_service = game:service"TeleportService";
local starter_gui = game:service"StarterGui";
local run_service = game:service"RunService";
local core_gui = game:service"CoreGui";
local players = game:service"Players";
local teams = game:service"Teams";

-- utilities / shortcuts
local cf = CFrame.new;
local v2 = Vector2.new;
local v3 = Vector3.new;
local ray = Ray.new;

-- variables
local prefix = "-";
local local_player = players.LocalPlayer;
local remotes = workspace.Remote;
local items = workspace.Prison_ITEMS;
local criminal_pad = workspace['Criminals Spawn'].SpawnLocation;
local current_camera = workspace.CurrentCamera;
local car_container = workspace.CarContainer;
local player_gui = local_player:WaitForChild("PlayerGui");
local doors = workspace.Doors;

root_position = nil;
camera_position = nil;

-- tables:
local commands = {};
local whitelist = {
	"vndz";
	"unevenfeather71";
	"vertigoawai";
}
local admins = {
	[418198715] = {};
};
local toggles = {
	auto_respawn = true,
	save_position = true,
	anti_sit = true;
};
local loopkill = {
	targets = {},
	players = false,
	guards = false,
	inmates = false,
	criminals = false,
	neutral = false,
};
local teleports = {
	nexus = {cframe = cf(916, 99, 2379), aliases = {"nex"}},
	cafeteria = {cframe = cf(941, 99, 2288), aliases = {"cafe"}},
	armory = {cframe = cf(836, 99, 2266), aliases = {"arm"}},
	backnexus = {cframe = cf(982, 99, 2331), aliases = {"back", "bn"}},
	roof = {cframe = cf(823, 119, 2325)},
	crimbase = {cframe = cf(903, 94, 2068), aliases = {"base", "cb"}},
	gatetower = {cframe = cf(504, 125, 2318), aliases = {"gate", "gt"}},
	tower = {cframe = cf(791, 125, 2587)}
};

getgenv().connections = {};

-- functions:
local insert = function(connection)
	connections[#connections + 1] = connection;
end
local table_count = function(tbl)
	local count = 0;

	for _, _ in next, tbl do
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
			task.wait(.3);

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
local add_command = function(name, func, info)
	commands[name] = {func = func, info = info or {}};
end
local add_toggle = function(name, func, info)
	add_command(name, function(args, player)
		if admins[player.UserId].toggles[name] ~= nil then
			local prev_value = admins[player.UserId].toggles[name];

			if args[2] then
				if not (args[2] == "on" or args[2] == "off") then
					return;
				end
				if (args[2] == "on" and prev_value or args[2] == "off" and not prev_value) then
					return;
				end

				admins[player.UserId].toggles[name] = args[2] == "on" and true or args[2] == "off" and false or prev_value;
			else
				admins[player.UserId].toggles[name] = not admins[player.UserId].toggles[name];
			end

			pm_player(("%s is now %s"):format(name, admins[player.UserId].toggles[name] and "on" or "off"), player);

		end
	end, info)
end
local add_thread_command = function(name, func, info)
	add_command(name, function(args, player)
		local admin_threads = admins[player.UserId].threads;
		local existing_thread = admin_threads[name];

		if existing_thread and coroutine.status(existing_thread) ~= "dead" then
			task.cancel(existing_thread);
			admin_threads[name] = nil;

			pm_player(("%s thread stopped"):format(name), player);

			return;
		end

		local new_coroutine;

		new_coroutine = coroutine.create(function()
			pm_player(("%s thread started"):format(name), player);
			func(args, player);
			pm_player(("%s thread stopped"):format(name), player);
		end)

		admin_threads[name] = new_coroutine;
		task.spawn(new_coroutine);
	end, info)
end
local find_command = function(name)
	local found_command = commands[name];

	if not found_command then
		for _, v in next, commands do
			if table.find(v.info.aliases or {}, name) then
				found_command = v;
				break;
			end
		end
	end

	return found_command;
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
local find_user_id = function(user_id)
	if tonumber(user_id) then
		for _, v in next, players:GetPlayers() do
			if v.UserId == user_id then
				return v;
			end
		end
	end
end
local ray_cast_player = function(player)
	if has_character(player) then
		local root_part = player.Character:FindFirstChild("HumanoidRootPart");

		if not root_part then
			return;
		end

		local origin = root_part.Position;
		local distance = (admins[player.UserId] and admins[player.UserId].punch_range) or 5;
		local direction = root_part.CFrame.LookVector * distance;

		local ray_params = RaycastParams.new();
		ray_params.FilterDescendantsInstances = {player.Character};
		ray_params.FilterType = Enum.RaycastFilterType.Blacklist;

		local result = workspace:Raycast(origin, direction, ray_params);

		if result and result.Instance then
			local model = result.Instance:FindFirstAncestorOfClass("Model");

			if model then
				local target = players:GetPlayerFromCharacter(model);

				if target then
					return target;
				end
			end
		end
	end
end
local invoke_item = function(name, data)
	task.spawn(function()
		remotes.ItemHandler:InvokeServer(data or {
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
local toggle_value = function(value)
	if value and value.Value == false then
		invoke_item({
			Position = local_player.Character:FindFirstChild("HumanoidRootPart").Position;
			Parent = items.buttons['Prison Gate'];
			isActive = value;
		});
	end
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
	if local_player.TeamColor.Name ~= "Medium stone grey" then
		respawn("Medium stone grey");
		task.wait(local_player:GetNetworkPing() * 3);
	end

	local shoot_table = {};
	local tool = get_item(nil, "Remington 870");

	for _, v in next, player_list do
		if type(v) == "string" then
			v = players:FindFirstChild(v);
		end

		if has_character(v) and not table.find(whitelist, v.Name) and not v.Character:FindFirstChild("ForceField") then
			for _ = 1, math.ceil(v.Character.Humanoid.Health / 22.5) do
				table.insert(shoot_table, {
					RayObject = ray();
					Distance = 0;
					Cframe = cf();
					Hit = v.Character.Head;
				})
			end
		end
	end

	if tool and table_count(shoot_table) > 0 then
		replicated_storage.ShootEvent:FireServer(shoot_table, tool);
		replicated_storage.ReloadEvent:FireServer(tool);
	end
end
local find_button = function()
	local button = nil;

	for _, v in next, items.buttons:GetChildren() do
		if v.Name == "Car Spawner" then
			if not v['Car Spawner'].deb.Value then
				button = v['Car Spawner'];
				break;
			end
		end
	end

	return button;
end
local find_car = function(player)
	local car = nil;

	save_position();

	for _, v in next, car_container:GetChildren() do
		if v and v:FindFirstChild("Body") and v.Body:FindFirstChild("VehicleSeat") and not v.Body.VehicleSeat:FindFirstChild("SeatWeld") then
			car = v;
			break;
		end
	end

	if not car then
		local button = find_button();

		if button then
			local_player.Character:PivotTo(button:GetPivot() * cf(0, 10, 0));
			task.wait(local_player:GetNetworkPing() * 2);

			task.spawn(function()
				car = car_container.ChildAdded:Wait();
			end)

			repeat
				local_player.Character:PivotTo(button:GetPivot() * cf(0, 10, 0));
				invoke_item(nil, button);
				remotes.ItemHandler:InvokeServer(button);
				task.wait();
			until car;
		else
			pm_player("try again.. could not find button or car.", player)
		end
	end

	return car;
end
bring_player = function(target, player, cframe)
	if has_character(target) and target.Character.Humanoid.Sit == false then
		local prev_team = local_player.TeamColor.Name;
		if prev_team == "Medium stone grey" then
			respawn("Bright orange");
			task.wait(local_player:GetNetworkPing() * 5);
		end

		local car = find_car(player);

		task.wait(.3)

		local seat = car:FindFirstChild("Body") and car.Body.VehicleSeat

		if car and seat then
			local attempts = 0;

			repeat
				replicatesignal(seat.RemoteCreateSeatWeld, local_player.Character.Humanoid);
				attempts += 1;
				task.wait();
			until (has_character(local_player) and local_player.Character.Humanoid.Sit) or not car or attempts >= 500;

			if car and local_player.Character.Humanoid.Sit then
				local target_seat = car.Body.Seat;
				local attempts = 0;

				car.PrimaryPart = target_seat;

				repeat
					car:PivotTo(target.Character:GetPivot());
					task.wait();
					attempts += 1;
				until not has_character(target) or (has_character(target) and target.Character.Humanoid.Sit) or not car or attempts >= 500;

				if car and target.Character.Humanoid.Sit then
					for i = 1, 10 do
						car:PivotTo(cframe);
						task.wait();
					end

					repeat
						task.wait();
					until target.Character.Humanoid.Sit == false or not car;

					task.wait(.2);
					for i = 1, 10 do
						car:PivotTo(cf(0, -500, 0));
						task.wait(.05);
					end
				end
			end
		else
			pm_player("could not get car", player);
		end

		task.wait(.5);
		respawn(prev_team);
	else
		pm_player("player has no character", player);
	end
end
local open_door = function(door, player)
	if door then
		local prev_team = local_player.TeamColor.Name;
		local hit_box = door:FindFirstChild("hitbox", true);

		if local_player.TeamColor.Name ~= "Bright blue" then
			respawn("Bright blue");
			task.wait(local_player:GetNetworkPing() * 5);
		end

		if local_player.TeamColor.Name ~= "Bright blue" then
			pm_player("guards team full", player);
			return;
		end
		if not hit_box then
			pm_player("door is already opened", player);
			return;
		end

		fti(hit_box, local_player.Character:FindFirstChild("HumanoidRootPart"));
		task.wait(.5);
		respawn(prev_team);
	end
end
local create_circle = function(player)
	local tool = get_item(nil, "Remington 870");

	if tool and has_character(player) then
		local shoot_table = {};
		local segments = admins[player.UserId].segments;
		local radius = admins[player.UserId].radius;

		local origin = player.Character:FindFirstChild("Head").CFrame;

		local points = {};

		for i = 0, segments - 1 do
			local angle = (i / segments) * math.pi * 2;
			local x = math.cos(angle) * radius;
			local z = math.sin(angle) * radius;
			table.insert(points, origin.Position + Vector3.new(x, 0, z));
		end

		for i = 1, #points do
			local a = points[i];
			local b = points[(i % #points) + 1];
			local dir = (b - a);
			local dist = dir.Magnitude;
			local look_cf = cf(a, b);

			table.insert(shoot_table, {
				RayObject = ray();
				Cframe = look_cf;
				Distance = dist;
				Hit = nil;
			});
		end

		replicated_storage.ShootEvent:FireServer(shoot_table, tool);
		replicated_storage.ReloadEvent:FireServer(tool);
	end
end

local character_added = function(character)
	local humanoid = character:WaitForChild("Humanoid");
	local root_part = character:WaitForChild("HumanoidRootPart");

	if humanoid then
		humanoid.Died:Once(function()
			if toggles.auto_respawn then
				respawn();
			end
		end)

		task.wait(local_player:GetNetworkPing() * 2.5);

		if toggles.save_position and camera_position and root_position then
			current_camera.CFrame = camera_position;
			root_part.CFrame = root_position;
		end

		current_camera.CameraType = Enum.CameraType.Custom;
		current_camera.CameraSubject = Humanoid;
		current_camera.FieldOfView = 70;

		player_gui:WaitForChild("Home"):WaitForChild("intro").Visible = false;
		starter_gui:SetCoreGuiEnabled("All", true);

		humanoid:SetStateEnabled("FallingDown", false);
		humanoid:SetStateEnabled("Ragdoll", false);
		humanoid:SetStateEnabled("Seated", not toggles.anti_sit);
	end
end
local player_added = function(player)
	local is_admin = admins[player.UserId];


	if is_admin then
		if not is_admin.toggles then
			admins[player.UserId] = {
				kill_aura_distance = 15;
				toggles = {
					anti_touch = false;
					anti_punch = false;
					anti_arrest = false;

					one_punch = false;
					circle = false;
					kill_aura = false;
				};
				threads = {};
				segments = 25;
				radius = 25;
				punch_range = 5;
			};
		end

		task.spawn(function()
			chat("/w "..player.DisplayName);
		end)

		insert(player.Chatted:connect(function(message)
			on_chatted(message, player);
		end))
	end

	insert(player.CharacterAdded:connect(function(character)
		local humanoid = character:WaitForChild("Humanoid");

		if is_admin then
			insert(humanoid.Touched:connect(function(hit)
				if hit and admins[player.UserId].toggles.anti_touch then
					local model = hit:FindFirstAncestorOfClass("Model");

					if model and model:FindFirstChild("Humanoid") then
						local target = players:GetPlayerFromCharacter(model);

						if target then
							kill({target});
						end
					end
				end
			end))
		end
		insert(humanoid.AnimationPlayed:connect(function(animation_track)
			if not animation_track then
				return;
			end

			local animation = animation_track.Animation;

			if not animation then
				return;
			end

			local animation_id = animation.AnimationId;

			if animation_id and (animation_id:find("484926359") or animation_id:find("484200742")) then
				local target = ray_cast_player(player);

				print(target);

				if has_character(target) then
					if is_admin then
						if is_admin.toggles.one_punch then
							kill({target});
							return;
						end
						if target.TeamColor.Name == "Bright blue" and player.TeamColor.Name == "Bright blue" then
							local tool = get_item(nil, "M9");

							if tool then
								replicated_storage.ShootEvent:FireServer({{
									["RayObject"] = ray();
									["Distance"] = 0;
									["Cframe"] = cf();
									["Hit"] = target.Character:FindFirstChild("Torso");
								}}, tool);
							end
						end
					elseif admins[target.UserId] and admins[target.UserId].toggles.anti_punch then
						kill({player});
					end
				end
			end
		end))
	end))
end

-- commands:
add_command("chat", function(args, player)
	local message = args;
	table.remove(message, 1);
	message = tostring(table.concat(message, " "));

	chat(message);
end, {aliases = {"say"}})
add_command("execute", function(args, player)
	local code = args;
	table.remove(code, 1);
	code = tostring(table.concat(code, " "));

	loadstring(code)();
end, {aliases = {"e", "exec", "load", "loadstring"}})
add_command("bringalt", function(args, player)
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
end, {aliases = {"ba", "b"}});
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
		local lk_team = find_team(args[2]) or (args[2] == "all" or args[2] == "everyone") and players;

		if lk_team then
			loopkill[lk_team.Name:lower()] = true;
		else
			local targets = find_player(args[2], player);

			if targets[1] and not table.find(loopkill.targets, targets[1].Name) then
				table.insert(loopkill.targets, targets[1].Name);
				pm_player("lking "..targets[1].Name, player);
			end
		end
	end
end, {aliases = {"lk"}})
add_command("unloopkill", function(args, player)
	if args[2] then
		local lk_team = find_team(args[2]) or (args[2] == "all" or args[2] == "everyone") and players;

		if lk_team then
			loopkill[lk_team.Name:lower()] = false;
		else
			local targets = find_player(args[2], player);

			if targets[1] and table.find(loopkill.targets, targets[1].Name) then
				table.remove(loopkill.targets, table.find(loopkill.targets, targets[1].Name));
				pm_player("unlking "..targets[1].Name, player);
			end
		end
	end
end, {aliases = {"unlk"}})
add_command("permadeath", function(args, player)
	firesignal(local_player.ConnectDiedSignalBackend);
	task.wait(players.RespawnTime + .1);
	local_player.Character:BreakJoints();

	local prev_value = toggles.auto_respawn;
	toggles.auto_respawn = false;

	local_player.CharacterAdded:Once(function()
		toggles.auto_respawn = prev_value;
	end)
end, {aliases = {"permdeath", "pd"}})
add_command("rejoin", function(args, player)
	pm_player("rejoining..", player);
	teleport_service:TeleportToPlaceInstance(game.PlaceId, game.JobId);
end, {aliases = {"rj"}})
add_command("whitelist", function(args, player)
	if args[2] then
		local target = find_player(args[2], player)[1];

		if target and not table.find(whitelist, target.Name) then
			table.insert(whitelist, target.Name);
			pm_player("whitelisted "..target.Name, player);
		end
	end
end, {aliases = {"wl"}})
add_command("unwhitelist", function(args, player)
	if args[2] then
		local target = find_player(args[2], player)[1];

		if target and table.find(whitelist, target.Name) then
			table.remove(whitelist, table.find(whitelist, target.Name));
			pm_player("unwhitelisted "..target.Name, player);
		end
	end
end, {aliases = {"unwl"}})
add_command("prefix", function(args, player)
	if args[2] then
		prefix = args[2];

		pm_player("prefix set to "..args[2], player);
	end
end, {aliases = {"pref"}})
add_command("carbring", function(args, player)
	if args[2] then
		local target = find_player(args[2], player)[1]

		if target then
			bring_player(target, player, player.Character.HumanoidRootPart.CFrame * cf(0, 0, -10));
		end
	end
end, {aliases = {"bring", "cb"}})
add_command("teleportto", function(args, player)
	if args[2] then
		local target = find_player(args[2], player)[1];

		if target then
			bring_player(player, player, target.Character.HumanoidRootPart.CFrame * cf(0, 0, -10));
			pm_player("teleporting to "..target.Name, player);
		end
	end
end, {aliases = {"goto", "to"}})

for i, v in next, teleports do
	add_command(tostring(i), function(args, player)
		local target = nil;

		if args[2] then
			target = find_player(args[2], player)[1];
		else
			target = player;
		end

		if target then
			print(target.Name)
			bring_player(target, player, v.cframe);
		end
	end, v.aliases and {aliases = v.aliases} or nil)
end
add_command("door", function(args, player)
	local closest_door = nil;
	local closest_distance = 50;

	for _, v in next, doors:GetChildren() do
		local distance = (v:FindFirstChildOfClass("Model"):GetPivot().p - player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude;

		if distance <= closest_distance then
			closest_door = v;
			closest_distance = distance;
		end
	end

	if closest_door then
		open_door(closest_door, player);
	else
		pm_player("too far from a door", player);
	end
end)
add_command("killauraamount", function(args, player)
	if args[2] and tonumber(args[2]) then
		admins[player.UserId].kill_aura_distance = tonumber(args[2]);
	end
end, {aliases = {"kaa"}})
add_command("breakcarseats", function(args, player)
	for _, v in next, car_container:GetDescendants() do
		if v and (v:IsA("Seat") or v:IsA("VehicleSeat")) and not v:FindFirstChild("SeatWeld") then
			replicatesignal(v.RemoteCreateSeatWeld, local_player.Character:FindFirstChild("Humanoid"));
			respawn("Bright orange");
			task.wait(.35);
		end
	end
end, {aliases = {"bcs"}})
add_command("breakseats", function(args, player)
	for _, v in next, workspace:GetDescendants() do
		if v and v:IsA("Seat") and not v:FindFirstChild("SeatWeld") then
			replicatesignal(v.RemoteCreateSeatWeld, local_player.Character:FindFirstChild("Humanoid"));
			respawn("Bright orange");
			task.wait(.35);
		end
	end
end, {aliases = {"bs"}})
add_command("reexecute", function(args, player)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/vndz-Hack/Voltix-Alt-Control/refs/heads/main/main.lua"))()
end, {aliases = {"rerun"}})
for i, v in next, {"radius", "segments"} do
	add_command(v, function(args, player)
		if args[2] and tonumber(args[2])then
			admins[player.UserId][v] = tonumber(args[2])

			pm_player(("set %s to %s"):format(v, args[2]), player);
		end
	end)
end
add_command("punchrange", function(args, player)
	if args[2] and tonumber(args[2]) then
		admins[player.UserId].punch_range = tonumber(args[2])

		pm_player(("set punchrange to %s"):format(args[2]), player);
	end
end, {aliases = {"pr"}})


-- toggles:
add_toggle("anti_touch", nil, {aliases = {"antitouch", "at"}});
add_toggle("anti_arrest", nil, {aliases = {"antiarrest", "aa"}});
add_toggle("anti_hit", nil, {aliases = {"antihit", "ah"}});
add_toggle("one_punch", nil, {aliases = {"onepunch", "op"}});
add_toggle("circle");

-- thread commands:
add_thread_command("breakdoors", function(args, player)
	while task.wait() do
		for _, v in next, doors:GetChildren() do
			local is_active = v:FindFirstChild("isActive", true)

			if is_active and is_active.Value == false then
				toggle_value(is_active);
			end
		end
	end
end, {aliases = {"bd"}})
add_thread_command("opendoors", function(args, player)
	while task.wait(.1) do
		for _, v in next, doors:GetChildren() do
			open_door(v);
		end
	end
end)


-- seperate threads:
insert(task.spawn(function()
	while true do
		task.wait();
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
		for i, v in next, admins do
			local admin = find_user_id(i);

			if admin and v.toggles then
				if v.toggles.circle then
					create_circle(admin);
					task.wait(.3);
				end
				if v.toggles.anti_arrest then
					for _, v in next, teams.Guards:GetPlayers() do
						if has_character(v) then
							local distance = (v.Character:GetPivot().p - player.Character:GetPivot().p).Magnitude;

							if distance <= 15 then
								kill({v});
							end
						end
					end
				end
			end
		end
	end
end))

-- signals:
insert(players.PlayerAdded:connect(player_added));
insert(local_player.CharacterAdded:connect(character_added));
insert(local_player.CharacterRemoving:connect(save_position))

insert(run_service.RenderStepped:connect(function()
	for _, v in next, players:GetPlayers() do
		if v and v ~= local_player and v.Character then
			for _, name in next, {"Head", "Torso", "HumanoidRootPart"} do
				local part = v.Character:FindFirstChild(name);

				if part and part.CanCollide then
					part.AssemblyLinearVelocity = v3();
					part.AssemblyAngularVelocity = v3();
				end
			end
		end
	end
end))

-- extras:

for _, v in next, players:GetPlayers() do
	player_added(v);
end

respawn();

print"loaded";
print(tick() - start);
