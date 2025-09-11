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

-- unload:
if getgenv().loaded and getgenv().data then
    for _, v in next, getgenv().data.connections do
        if type(v) == "thread" then
            task.cancel(v);
        else
            v:Disconnect();
        end
    end

    getgenv().data = getgenv().data;
end

-- load:
getgenv().loaded = true;
print("now loading "..version);

-- services:
local replicate_storage = game:service"ReplicatedStorage";
local text_chat_service = game:service"TextChatService";
local starter_gui = game:service"StarterGui";
local run_service = game:service"RunService";
local players = game:service"Players";
local teams = game:service"Teams";

-- variables:
local local_player = players.LocalPlayer;
local current_camera = workspace.CurrentCamera;
local terrain = workspace.Terrain;
local car_container = workspace.CarContainer;
local criminals_pad = workspace"Criminals Spawn".SpawnLocation;
local items = workspace.Prison_ITEMS
local player_gui = local_player:WaitForChild"PlayerGui";
local remotes = workspace.Remote;

local prefix = "-";
local root_cf = nil;
local camera_cf = nil;

local cf = CFrame.new;
local v3 = Vector3.new;
local v2 = Vector2.new;
local ray = Ray.new;



-- tables:
getgenv().data = getgenv().data or {
    api = {};
    connections = {};
    draw_table = {};
    toggles = {
        anti_sit = false;
        respawn = true;
        save_position = true;

        bypass_wl = false;
    };
    loop_kill = {
        targets = {
            "football0x1";
        };
        players = false;
        guards = false;
        inmates = false;
        criminals = false;
        neutral = false;
    };
    admins = {
        [418198715] = {};
    };
    white_list = {
        -- "vndz";
        "vertigoawai";
        "bye2enjoyer";
        "unevenfeather71";
        "LegacyMoveTorso";
    };
};

local chat_api = loadstring(game:HttpGet(git_url.."chat_handler.lua"))();

-- functions:
function data.api:insert_connection(conn)
    data.connections[#data.connections + 1] = conn;
end
function data.api:table_count(tbl)
    local count = 0;

    for _ in next, tbl do
        count += 1;
    end

    return count;
end
function data.api:remove_data(tbl, predicate)
    for i = #tbl, 1, -1 do
        if predicate(tbl[i], i) then
            table.remove(tbl, i)
        end
    end
end
function data.api:fti(part, part2)
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
function data.api:save_position()
    if local_player and local_player.Character and local_player.Character:FindFirstChild"HumanoidRootPart" and local_player.Character.HumanoidRootPart.Position.Y > 0 then
        root_cf = local_player.Character.HumanoidRootPart.CFrame;
        camera_cf = current_camera.CFrame;
    end
end
function data.api:invoke_item(name, tbl)
    task.spawn(function()
        remotes.ItemHandler:InvokeServer(tbl or {
            Position = local_player.Character and local_player.Character:GetPivot().p;
            Parent = items:FindFirstChild(v, true);
        })
    end)
end
function data.api:fire_team(color, amount)
    for i = 1, amount or 1 do
        remotes.TeamEvent:FireServer(color);
    end
end
function data.api:get_item(item_list, return_item)
    if item_list and self:table_count(item_list) > 0 then
        for _, v in next, item_list do
            self:invoke_item(v);
        end
    end

    if return_item then
        local tool = local_player:FindFirstChild(return_item, true);

        if not tool then
            repeat
                self:invoke_item(return_item);
                tool = local_player:FindFirstChild(return_item, true);
                task.wait();
            until tool;
        end

        return tool;
    end
end
function data.api:respawn(color)
    if not color then
        color = local_player.TeamColor.Name;
    end

    if color then
        if color == "Bright orange" or color == "Medium stone grey" then
            self:fire_team(color);
        elseif color == "Bright blue" then
            if #teams.Guards:GetPlayers() >= 8 then
                self:respawn("Bright orange");
                task.wait(local_player:GetNetworkPing() * 3);
            end

            self:fire_team("Bright blue");
        elseif color == "Really red" then
            self:respawn("Bright blue");

            repeat
                self:fti(criminals_pad, local_player.Character:FindFirstChild"HumanoidRootPart");
                task.wait(.1);
            until local_player.TeamColor.Name == color;
        end
    end
end
function data.api:has_character(player)
    return player and player.Character and player.Character:FindFirstChild"Humanoid" and player.Character.Humanoid.Health > 0;
end
function data.api:find_team(input)
    for _, v in next, teams:GetChildren() do
        if v.Name:lower():find(input:lower()) then
            return v;
        end
    end
end
function data.api:find_player(input, player)
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
                table.insert(targets, v);
            end
        end
    elseif typeof(input) == "Instance" then
        local humanoid = input.Parent:FindFirstChild"Humanoid" or input.Parent.Parent:FindFirstChild"Humanoid";

        if humanoid then
            local target = players:GetPlayerFromCharacter(humanoid.Parent);

            if target then
                targets = {target};
            end
        end
    end

    if data.toggles.bypass_wl == false then
        self:remove_data(targets, function(target)
            return table.find(data.white_list, target.Name);
        end)
    end

    return targets;
end
function data.api:kill(player_list)
    if local_player.TeamColor.Name ~= "Medium stone grey" then
        respawn("Medium stone grey");
        task.wait(local_player:GetNetworkPing() * 3.5);
    end

    local shoot_table = {};
    local tool = self:get_item(nil, "Remington 870");

    for _, v in next, player_list do
        if type(v) == "string" then
            v = self:find_player(v);
        end

        if self:has_character(v) and not v.Character:FindFirstChild"ForceField" then
            for _ = 1, math.ceil(v.Character.Humanoid.Health / 22.5) do
                shoot_table[#shoot_table + 1] = {
                    RayObject = ray();
                    Cframe = cf();
                    Distance = 0;
                    Hit = v.Character:FindFirstChild"Head";
                };
            end
        end
    end

    if tool and self:table_count(shoot_table) > 0 then
        replicate_storage.ShootEvent:FireServer(shoot_table, tool);
        replicate_storage.ReloadEvent:FireServer(tool);
    end
end
function data.api:chat(message)
    local text_channels = text_chat_service:FindFirstChild"TextChannels";

    if text_channels then
        local rbx_general = text_channels:FindFirstChild"RBXGeneral";

        if rbx_general then
            rbx_general:SendAsync(message, "are u spying on me :3 >/////<");
        end
    end
end
function data.api:pm_player(message, player)
    local text_channels = text_chat_service:FindFirstChild"TextChannels";

    if text_channels then
        local pm_channel = nil;

        for _, v in next, text_channels:GetChildren() do
            if v.Name:find("RBXWhisper") and v.Name:find(tostring(local_player.UserId)) and v.Name:find(tostring(player.UserId)) then
                pm_channel = v;
                break;
            end
        end

        if not pm_channel then
            self:chat("/w "..player.Name);
            task.wait(.4);

            return self:pm_player(message, player);
        end

        pm_channel:SendAsync(message);
    end
end
chat_api.notification = data.api.pm_player;

function data.api:character_added(character)
    if character then
        local humanoid = character:WaitForChild"Humanoid";
        local root = character:WaitForChild"HumanoidRootPart";

        if humanoid then
            self:insert_connection(humanoid.Died:Once(function()
                if data.toggles.respawn then
                    self:respawn();
                end
            end))

            task.wait(local_player:GetNetworkPing() * 3);

            if data.toggles.save_position and root_cf and camera_cf then
                root.CFrame = root_cf;
                current_camera.CFrame = camera_cf;
            end

            player_gui:WaitForChild"Home":WaitForChild"intro".Visible = false;
            starter_gui:SetCoreGuiEnabled("All", true);

            humanoid:SetStateEnabled("FallingDown", false);
            humanoid:SetStateEnabled("Ragdoll", false);
            humanoid:SetStateEnabled("Seated", not data.toggles.anti_sit);
        end
    end
end
function data.api:player_added(player)
    if player then
        local is_admin = data.admins[player.UserId];

        if is_admin then
            if not is_admin.toggles then
                data.admins[player.UserId] = {
                    toggles = {};
                    threads = {};
                };
            end

            self:insert_connection(player.Chatted:connect(function(message)
                chat_api:on_chatted(message, player, prefix);
            end))
        end
    end
end

-- commands:
chat_api:add_command("commands", function(args, player)
    local cmds = chat_api:get_commands();

    for i, line in next, cmds do
        data.api:pm_player(string.format("Commands (%d): %s", i, line), player);
    end
end, {aliases = {"cmds"}})
chat_api:add_command("say", function(args, player)
    local message = args;
    table.remove(args, 1);
    message = table.concat(message, " ");

    data.api:chat(tostring(message));
end, {aliases = {"chat", "message"}});
chat_api:add_command("loadstring", function(args, player)
    local code = args;
    table.remove(args, 1);
    code = table.concat(code, " ");

    loadstring(tostring(code))();
end, {aliases = {"execute", "exec", "ls", "e"}});

chat_api:add_command("kill", function(args, player)
    if args[2] then
        local targets = data.api:find_player(args[2], player);

        if targets then
            kill(targets);
        end
    end
end, {aliases = {"k"}})

-- thread commands:

-- toggles:

-- connections:
data.api:insert_connection(local_player.CharacterAdded:connect(function(character)
    data.api:character_added(character);
end))
data.api:insert_connection(local_player.CharacterRemoving:connect(function()
    data.api:save_position();
end))
data.api:insert_connection(players.PlayerAdded:connect(function(player)
    data.api:player_added(player);
end))

data.api:insert_connection(run_service.RenderStepped:connect(function()
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
data.api:insert_connection(task.spawn(function()
    while true do
        if data.api:table_count(data.loop_kill.targets) > 0 then
            kill(data.loop_kill.targets)
        end

        for i, v in next, loopkill do
            if type(v) == "boolean" and v == true then
                local team = i == "players" and players or data.api:find_team(i);

                if team then
                    data.api:kill(team:GetPlayers());
                end
            end
        

        task.wait(.1);
    end
end))

-- extras:

for _, v in next, players:GetPlayers() do
    data.api:player_added(v);
end

data.api:respawn();

print("loaded "..version.." in "..(tick() - start).. "seconds");
