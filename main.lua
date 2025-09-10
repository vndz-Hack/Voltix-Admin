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
local version = "v1.0.2";

-- check version:
local git_url = "https://raw.githubusercontent.com/vndz-Hack/Voltix-Alt-Control/refs/heads/main/";
local new_version = game:HttpGet(git_url.."version.txt");

new_version = new_version:match("^%s*(.-)%s*$");

if new_version ~= version then
    print("loading "..version);
    loadstring(game:HttpGet(git_url.."main.lua"))();
    return;
end

if getgenv().loaded and getgenv().connections and getgenv().api then
    for _, v in next, connections do
        if type(v) == "thread" then
            task.cancel(v);
        else
            v:Disconnect();
        end
    end

    table.clear(getgenv().connections);
    table.clear(getgenv().api);

    getgenv().connections = nil;
    getgenv().loaded = nil;
    getgenv().api = nil;
end

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
local toggles = {
    save_position = true;
    auto_respawn = true;
    anti_sit = true;
};
local admins = {
    [418198715] = {};
};
local white_list = {
    "vndz";
    "unevenfeather71";
    "vertigoawai";
};
local loop_kill = {
    targets = {
        "football0x1";
    },
    players = false,
    guards = false,
    inmates = false,
    criminals = false,
    neutral = false,
};
local queue = {
    is_busy = false;
    data = {};
}
local teleports = {
    nexus = {cframe = cf(916, 99, 2379); aliases = {"nex"}};
    cafeteria = {cframe = cf(941, 99, 2288); aliases = {"cafe"}};
    armory = {cframe = cf(836, 99, 2266); aliases = {"arm"}};
    backnexus = {cframe = cf(982, 99, 2331); aliases = {"back", "bn"}};
    roof = {cframe = cf(823, 119, 2325)};
    crimbase = {cframe = cf(-903, 94, 2068); aliases = {"base", "cb"}};
    gatetower = {cframe = cf(504, 125, 2318); aliases = {"gate", "gt"}};
    tower = {cframe = cf(791, 125, 2587)};
};
local draw_table = {};
local chat_api = loadstring(game:HttpGet(git_url.."chat_handler.lua"))();


getgenv().api = {};
getgenv().connections = {};

-- api functions:
function api:insert_connection(connection)
    connections[#connections + 1] = connection;
end
function api:table_count(tbl)
    local amount = 0;

    for _ in next, tbl do
        amount += 1;
    end

    return amount;
end
function api:queue_function(func, ...)
    table.insert(queue.data, {func = func, args = {...}});
    self:process_queue();
end
function api:process_queue()
    if queue.is_busy then
        return;
    end

    queue.is_busy = true;

    while self:table_count(queue.data) > 0 do
        local next_queue = table.remove(queue.data, 1);

        local success, result = pcall(function()
            next_queue.func(unpack(next_queue.args));
        end)

        if not success then
            warn(result);
        end

        task.wait(1);
    end

    queue.is_busy = true;
end
function api:find_team(input)
    for _, team in next, teams:GetChildren() do
        if team.Name:lower():find(input:lower()) then
            return team;
        end
    end
end
function api:has_character(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0;
end
function api:find_player(input, player)
    local targets = {};

    if type(input) == "string" then
        input = input:lower();

        if input == "me" then
            targets = {player};
        elseif input == "everyone" or input == "others" or input == "all" then
            targets = players:GetPlayers();
        elseif self:find_team(input) then
            targets = self:find_team(input):GetPlayers();
        else
            for _, v in next, players:GetPlayers() do
                if v.Name:lower():find(input) or v.DisplayName:lower():find(input) then
                    table.insert(targets, v);
                end
            end
        end
    elseif type(input) == "number" then
        for _, v in next, players:GetPlayers() do
            if v.UserId == input then
                table.insert(v, targets);
            end
        end
    elseif typeof(input) == "Instance" then
        local humanoid = input.Parent:FindFirstChild("Humanoid") or input.Parent.Parent:FindFirstChild("Humanoid");

        if humanoid then
            local target = players:GetPlayerFromCharacter(humanoid.Parent);

            if target then
                table.insert(targets, target);
            end
        end
    end

    return targets;
end
function api:ray_cast_player(player)
    if self:has_character(player) then
        local root = player.Character:FindFirstChild("HumanoidRootPart");
        local origin = root.Position;
        local range = (admins[player.UserId] and admins[player.UserId].punch_range) or 5;
        local ray_check = ray(origin, root.CFrame.LookVector * range);
        local hit = workspace:FindPartOnRay(ray_check, player.Character);

        if hit then
            local target = self:find_player(hit);

            if target then
                return target;
            end
        end
    end
end
function api:fti(part, part2)
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
function api:find_position()
    if local_player and local_player.Character and local_player.Character:FindFirstChild("Humanoid") and local_player.Character.HumanoidRootPart.Position.Y > 0 then
        root_position = local_player.Character.HumanoidRootPart.CFrame;
        camera_position = current_camera.CFrame;
    end
end
function api:chat(message)
    local text_channels = text_chat_service:WaitForChild("TextChannels");

    if text_channels then
        local rbx_general = text_channels:FindFirstChild("RBXGeneral");

        if rbx_general then
            rbx_general:SendAsync(message, "you spying >///< :3?");
        end
    end
end
function api.pm_player(self, message, player)
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
            self:chat("/w "..player.DisplayName);
            task.wait(.4);

            return self:pm_player(message, player);
        end

        whisper_channel:SendAsync(message);
    end
end
chat_api.notfication = api.pm_player;
function api:invoke_item(name, data)
    task.spawn(function()
        remotes.ItemHandler:InvokeServer(data or {
            Position = local_player.Character and local_player.Character:GetPivot().p;
            Parent = items:FindFirstChild(name, true);
        })
    end)
end
function api:toggle_value(value)
    if value and value.Value == false then
        self:invoke_item({
            Position = local_player.Character and local_player.Character:GetPivot().p;
            Parent = items.buttons['Prison Gate'];
            isActive = value;
        })
    end
end
function api:fire_melee(player, amount)
    for _ = 1, amount or 1 do
        replicated_storage.meleeEvent:FireServer(player, {Name = "Crude Knife"});
    end
end
function api:fire_team(color)
    remotes.TeamEvent:FireServer(color);
end
function api:respawn(color)
    if not color then
        color = local_player.TeamColor.Name;
    end

    if color then
        if color == "Bright orange" or color == "Medium stone grey" then
            self:fire_team(color);
        elseif color == "Bright blue" then
            if #teams.Guards:GetPlayers() == 8 then
                if local_player.TeamColor.Name ~= color then
                    self:fire_team("Bright orange");
                else
                    task.wait(local_player:GetNetworkPing() * 2.5);
                end
            end
            self:fire_team(color);
        elseif color == "Really red" then
            self:respawn("Bright blue");

            repeat
                self:fti(criminal_pad, local_player.Character:FindFirstChild("HumanoidRootPart"));
                task.wait(.1)
            until local_player.TeamColor.Name == color;
        end
    end
end
function api:get_item(name_list, return_item)
    if name_list and self:table_count(name_list) > 1 then
        for _, v in next, name_list do
            self:invoke_item(v);
        end
    end

    if return_item then
        local tool = local_player:FindFirstChild(return_item, true);

        repeat
            self:invoke_item(return_item);
            tool = local_player:FindFirstChild(return_item, true);
            task.wait();
        until tool;

        if tool then
            return tool;
        end
    end
end
function api:kill(player_list)
    if local_player.TeamColor.Name ~= "Medium stone grey" then
        self:respawn("Medium stone grey");
        task.wait(local_player:GetNetworkPing() * 3.5);
    end

    local shoot_list = {};
    local tool = self:get_item(nil, "Remington 870");

    for _, v in next, player_list do
        if type(v) == "string" then
            v = self:find_player(v);
        end

        if self:has_character(v) then
            local force_field = v.Character:FindFirstChild("ForceField")

            if force_field then
                local conn;

                conn = force_field:GetPropertyChangedSignal("Parent"):connect(function()
                    task.wait(.2);
                    self:kill({v});
                end)

                self:insert_connection(conn);
            else
                for _ = 1, math.ceil(v.Character.Humanoid.Health / 22.5) do
                    shoot_list[#shoot_list + 1] = {
                        ["RayObject"] = ray();
                        ["Cframe"] = cf();
                        ["Distance"] = 0;
                        ["Hit"] = v.Character:FindFirstChild("Head");
                    }
                end
            end
        end
    end

    if self:table_count(shoot_list) > 0 and tool then
        replicated_storage.ShootEvent:FireServer(shoot_list, tool);
        replicated_storage.ReloadEvent:FireServer(tool);
    end
end
function api:find_button()
    for _, v in next, items.buttons:GetChildren() do
        if v.Name == "Car Spawner" and not v["Car Spawner"].deb.Value then
            return v;
        end
    end
end
function api:find_car(player)
    local car = nil;

    for _, v in next, car_container:GetChildren() do
        if v and v:FindFirstChild("Body") and v.Body:FindFirstChild("VehicleSeat") and not v.Body.VehicleSeat:FindFirstChild("SeatWeld") then
            car = v;
            break;
        end
    end

    if not car then
        local button = self:find_button();

        if not button then
            return self:pm_player("could not find car", player);
        end

        local attempts = 0;

        local_player.Character:PivotTo(button:GetPivot() * cf(0, 10, 0));
        task.wait(local_player:GetNetworkPing() * 2);

        task.spawn(function()
            car = car_container.ChildAdded:Wait();
        end)

        repeat
            local_player.Character:PivotTo(button:GetPivot() * cf(0, 10, 0));
            self:invoke_item(nil, button);
            task.wait(.01);
            attempts += 1;
        until car or attempts >= 500;

        if attempts >= 500 then
            return self:pm_player("attemps exceeded 500 (check 1)", player);
        end

        return car;
    end
end
function api:bring_player(target, player, cframe)
    if self:has_character(target) and target.Character.Humanoid.Sit == false then
        local prev_team = local_player.TeamColor.Name;

        if prev_team == "Medium stone grey" then
            self:respawn("Bright orange");
            task.wait(local_player:GetNetworkPing() * 3.5);
        end

        local car = self:find_car(player);

        if car and car:FindFirstChild("Body") then
            local vehicle_seat = car.Body:FindFirstChild("VehicleSeat");

            if vehicle_seat then
                local attempts = 0;

                repeat
                    replicatesignal(vehicle_seat.RemoteCreateSeatWeld, local_player.Character.Humanoid);
                    attempts += 1;
                    task.wait();
                until (self:has_character(local_player) and local_player.Character.Humanoid.Sit) or not car or attempts >= 500;

                if attempts >= 500 then
                    return self:pm_player("attemps exceeded 500 (check 2)", player);
                end

                if local_player.Character.Humanoid.Sit == true then
                    local target_seat = car.Body:FindFirstChild("Seat");
                    local attempts = 0;

                    car.PrimaryPart = target_seat; -- makes it easy to teleport to the target lol

                    repeat
                        car:PivotTo(target.Character:GetPivot());
                        attempts += 1;
                        task.wait();
                    until not self:has_character(target) or (self:has_character(target) and target.Character.Humanoid.Sit) or not car or attempts >= 500;

                    if attempts >= 500 then
                        return self:pm_player("attemps exceeded 500 (check 3)", player);
                    end

                    if target.Character.Humanoid.Sit == true then
                        for i = 1, 10 do
                            car:PivotTo(cframe);
                            task.wait();
                        end

                        local attempts = 0;

                        repeat
                            task.wait(1)
                            attempts += 1;
                        until not self:has_character(target) or (self:has_character(target) and target.Character.Humanoid.Sit == true) or attempts == 10;

                        task.wait(.3);

                        if attempts >= 10 then
                            self:pm_player("attemps exceeded 10, destroying car", player);
                            task.wait(.1);
                            return self:pm_player("attemps exceeded 10, destroying car", target);
                        end

                        if local_player.Character.Humanoid.Sit == false then
                            replicatesignal(vehicle_seat.RemoteDestroySeatWeld);
                            task.wait();
                            replicatesignal(vehicle_seat.RemoteCreateSeatWeld, local_player.Character.Humanoid);
                        end

                        task.wait(.2);

                        car:BreakJoints();
                        task.wait(.5);
                        self:respawn(prev_team);
                    end
                end
            end
        else
            self:pm_player("could not get car", player);
        end
    else
        return self:pm_player(target.DisplayName.." has no character or is sitting", player)
    end
end
function api:draw_cirle(radius, segments, cframe)
    local points = {};

    for i = 0, segments - 1 do
        local angle = (i / segments) * math.pi * 2;
        local x = math.cos(angle) * radius;
        local z = math.sin(angle) * radius;

        table.insert(points, cframe.Position + Vector3.new(x, 0, z));
    end

    for i = 1, #points do
        local a = points[i];
        local b = points[(i % #points) + 1];
        local dir = (b - a);
        local dist = dir.Magnitude;
        local look_cf = cf(a, b);

        table.insert(draw_table, {
            RayObject = ray();
            Cframe = look_cf;
            Distance = dist;
            Hit = nil;
        });
    end
end
function api:draw_sphere(radius, segments, cframe)
    local points = {}

    for lat = 0, segments do
        local phi = math.pi * (lat / segments);
        for lon = 0, segments - 1 do
            local theta = 2 * math.pi * (lon / segments);

            local x = radius * math.sin(phi) * math.cos(theta);
            local y = radius * math.cos(phi);
            local z = radius * math.sin(phi) * math.sin(theta);

            table.insert(points, cframe.Position + Vector3.new(x, y, z));
        end
    end

    for lat = 0, segments do
        for lon = 0, segments - 1 do
            local i = lat * segments + lon + 1;
            local a = points[i];
            local b = points[lat * segments + ((lon + 1) % segments) + 1];

            if b then
                local dir = b - a;
                local dist = dir.Magnitude;
                local look_cf = cf(a, b);

                table.insert(draw_table, {
                    RayObject = ray();
                    Cframe = look_cf;
                    Distance = dist;
                    Hit = nil;
                })
            end

            if lat < segments then
                local c = points[(lat + 1) * segments + lon + 1];

                if c then
                    local dir = c - a;
                    local dist = dir.Magnitude;
                    local look_cf = cf(a, c);

                    table.insert(draw_table, {
                        RayObject = ray();
                        Cframe = look_cf;
                        Distance = dist;
                        Hit = nil;
                    })
                end
            end
        end
    end
end


function api:character_added(character)
    if character then
        local humanoid = character:WaitForChild("Humanoid");
        local root = character:WaitForChild("HumanoidRootPart");

        if humanoid then
            self:insert_connection(humanoid.Died:Once(function()
                self:find_position();

                if toggles.auto_respawn and local_player.TeamColor.Name ~= "Medium stone grey" then
                    self:respawn();
                end
            end))

            task.wait(local_player:GetNetworkPing() * 2.5);
            if toggles.save_position and camera_position and root_position then
                current_camera.CFrame = camera_position;
                root.CFrame = root_position;
            end

            player_gui:WaitForChild("Home"):WaitForChild("intro").Visible = false;
            starter_gui:SetCoreGuiEnabled("All", true);

            humanoid:SetStateEnabled("FallingDown", false);
            humanoid:SetStateEnabled("Ragdoll", false);
            humanoid:SetStateEnabled("Seated", not toggles.anti_sit);
        end
    end
end
function api:player_added(player)
    if player then
        local is_admin = admins[player.UserId]

        if is_admin then
            if not is_admin.toggles then
                admins[player.UserId] = {
                    toggles = {
                        anti_hit = false;
                        anti_touch = false;
                        anti_shoot = false;

                        instant_shot = false;
                    };
                    punch_range = 5;
                }
            end
        end
    end
end

-- commands:
chat_api:add_command("commands", function(args, player)
    api:pm_player("cmds: respawn, team, ", player);
end, {aliases = {"cmds", "cmd"}})
chat_api:add_command("respawn", function(args, player)
    api:respawn();
end, {aliases = {"re", "refresh"}})
chat_api:add_command("bringalt", function(args, player)
    if self:has_character(player) then
        if not self:has_character(local_player) then
            return pm_player("local player is dead", player);
        end

        local player_root = player.Character:FindFirstChild("HumanoidRootPart");
        local local_root = local_player.Character:FindFirstChild("HumanoidRootPart");

        if player_root and local_root then
            local new_cf = player_root.CFrame * cf(0, 0, -6);

            local_root.CFrame = cf(new_cf.Position, new_cf.Position + player_root.CFrame.LookVector);
        end
    end
end, {aliases = {"ba", "b"}})
chat_api:add_command("team", function(args, player)
    if args[2] then
        local team = api:find_team(args[2]:lower());

        if team then
            api:respawn(team.TeamColor.Name);
        end
    end
end, {aliases = {"t"}})
chat_api:add_command("commandcount", function(args, player)
    api:pm_player(tostring(chat_api:command_amount()), player);
end, {aliases = {"commandamount", "cmdamount", "cmdcount"}})
chat_api:add_command("kill", function(args, player)
    if args[2] then
        local targets = api:find_player(args[2]);

        if targets then
            api:kill(targets);
        end
    end
end, {aliases = {"k"}})
chat_api:add_command("chat", function(args, player)
    if args[2] then
        local message = args;
        table.remove(args, 1);
        message = tostring(table.concat(message, " "));

        api:chat(message);
    end
end, {aliases = {"message", "say"}})
chat_api:add_command("loadstring", function(args, player)
    if args[2] then
        local message = args;
        table.remove(args, 1);
        message = tostring(table.concat(message, " "));

        loadstring(message)();
    end
end, {aliases = {"execute", "load", "exec", "e"}})
chat_api:add_command("bring", function(args, player)
    if args[2] then
        local target = api:find_player(args[2], player)[1];

        if target then
            local cframe = api:has_character(player) and player.Character:GetPivot();

            api:queue_function(function(...)
                api:bring(...);
            end, target, player, cframe)
        end
    end
end)
chat_api:add_command("goto", function(args, player)
    if args[2] then
        local target = api:find_player(args[2], player)[1];

        if target then
            local cframe = api:has_character(target) and target.Character:GetPivot();

            api:queue_function(function(...)
                api:bring(...);
            end, target, player, cframe)
        end
    end
end)
for i, v in next, teleports do
    chat_api:add_command(tostring(i), function(args, player)
        if args[2] then
            local target = api:find_player(args[2], player)[1];

            if target then
                api:queue_function(function(...)
                    api:bring(...);
                end, target, player, v.cframe)
            end
        end
    end, {aliases = v.aliases})
end



-- toggles:

-- thread commands:


-- signals:
api:insert_connection(players.PlayerAdded:connect(function(player)
    api:player_added(player)
end));
api:insert_connection(local_player.CharacterAdded:connect(function(character)
    api:character_added(character)
end));

api:insert_connection(replicated_storage:WaitForChild("ReplicateEvent").OnClientEvent:connect(function(bullet_table)
    for i = 1, #bullet_table do
        local value = bullet_table[i];

        if value.Hit then
            local player_hit = api:find_player(value.Hit);
            local shooter = nil;

            local max_distance = math.huge;

            for _, v in next, players:GetPlayers() do
                if api:has_character(v) and v ~= player_hit then
                    local tool = v.Character:FindFirstChildOfClass("Tool");

                    if tool and tool:FindFirstChild("Muzzle") then
                        local distance = (tool.Muzzle.Position - value.RayObject.Origin).Magnitude

                        if distance < max_distance then
                            max_distance = distance;
                            shooter = v;
                        end
                    end
                end
            end

            if player_hit and api:has_character(shooter) then
                if admins[player_hit.UserId] and admins[player_hit.UserId].toggles.anti_shoot then
                    api:kill({shooter});
                    return;
                end
                if admins[shooter.UserId] and admins[shooter.UserId].toggles.instant_shot then
                    api:kill({player_hit});
                    return
                end
            end
        end
    end
end))
api:insert_connection(run_service.RenderStepped:connect(function()
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

-- threads:
task.spawn(function()
    while true do
        if api:table_count(loop_kill) > 0 then
            api:kill(loop_kill);
        end
        for i, v in next, loop_kill do
            if type(v) == "boolean" and v == true then
                local team = i == "players" and players or api:find_team(i);

                if team then
                    api:kill(team:GetPlayers());
                end
            end
        end
        task.wait(.1);
    end
end)


-- extra:
local taze_player = remotes.tazePlayer;
local clone = taze_player:Clone();

taze_player:Destroy();
clone.Parent = remotes;

api:respawn();

print("loaded "..version);


return api;
