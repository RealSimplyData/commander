local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local assets = script.Assets
local core = script.Core
local packages
local preloaded = core.Preloaded
local dLog = require(core.dLog)

local utilities = {}
local loadedPackages = {
    ["Command"] = {
        ["Server"] = {},
        ["Player"] = {}
    },
    ["Stylesheet"] = {},
    ["Plugin"] = {}
}

local function assert(condition, ...)
    if not condition then
        error(string.format("Commander; 🚫 %s", ...))
    end
end

function copyTable(table)
    if typeof(table) ~= "table" then return table end
    local result = setmetatable({}, getmetatable(table))
    for index, value in ipairs(table) do
        result[copyTable(index)] = copyTable(value)
    end

    return result
end

dLog("Info", "Welcome to V2")

return function(settings, userPackages)
    assert(settings, "User configuration found missing, aborted!")
    assert(settings, "User packages found missing, aborted!")
    dLog("Wait", "Starting system...")

    Instance.new("Folder", ReplicatedStorage).Name = "Commander"
    Instance.new("RemoteEvent", ReplicatedStorage.Commander)
    Instance.new("RemoteFunction", ReplicatedStorage.Commander)
    dLog("Success", "Initialized remotes...")

    packages = Instance.new("Folder", script)
    packages.Name = "Packages"
    Instance.new("Folder", packages).Name = "Command"
    Instance.new("Folder", packages.Command).Name = "Server"
    Instance.new("Folder", packages.Command).Name = "Player"
    Instance.new("Folder", packages).Name = "Stylesheet"
    Instance.new("Folder", packages).Name = "Plugin"
    dLog("Success", "Initialized package system...")

    settings.Name = "Settings"
    settings.Parent = core
    dLog("Success", "Loaded user configuration...")
    dLog("Wait", "Loading all preloaded components...")
    for _, component in ipairs(preloaded:GetChildren()) do
        if component:IsA("ModuleScript") then
            utilities[component.Name] = require(component)
            dLog("Success", "Loaded component " .. component.Name)
        end
    end
    dLog("Success", "Complete loading all preloaded components, moving on...")

    if #userPackages:GetDescendants() == 0 then
        dLog("Warn", "There was no package to load with...")
    end

    for _, package in ipairs(userPackages:GetDescendants()) do
        if package:IsA("ModuleScript") then
            dLog("Wait", "Initializing package " .. package.Name)
            local requiredPackage = require(package)

            if utilities.Validify.validatePkg(requiredPackage) then
                dLog("Success", package.Name .. " is a valid package...")
                if requiredPackage.Class ~= "Command" then
                    package.Parent = packages[requiredPackage.Class]
                else
                    package.Parent = packages.Command[requiredPackage.Category]
                end
                dLog("Success", "Complete initializing package " .. package.Name ..", moving on...")
            else
                dLog("Warn", "Package " .. package.Name .. " is not a valid package and has been ignored")
            end
        end
    end

    dLog("Wait", "Setting up packages...")
    for _, package in ipairs(packages:GetDescendants()) do
        if package:IsA("ModuleScript") then
            package = require(package)
            local packageInfo = {
                ["Name"] = package.Name,
                ["Description"] = package.Description,
                ["Class"] = package.Class,
                ["Category"] = package.Category or "N/A",
                ["Author"] = package.Author,
                ["Target"] = package.Target
            }

            package.Settings = copyTable(settings)
            package.API = utilities.API
            package.Core = core
            package.Util = utilities

            if package.Class == "Command" then
                loadedPackages.Command[package.Category][package.Name] = packageInfo
            else
                loadedPackages[package.Class][package.Name] = packageInfo
            end
        end
    end

    for _, package in pairs(loadedPackages.Plugin) do
        if typeof(package.Target) == "table" and package.Target.Init then
            dLog("Wait", "Initializing plugin " .. package.Name .. "...")
            package.Target:Init()
            dLog("Success", "Initialized plugin " .. package.Name)
        end
    end

    dLog("Success", "Finished initializing all packages...")
    dLog("Wait", "Connecting to remotes...")
    dLog("Success", "Connected")
    dLog("Wait", "Connecting player events and initializing for players...")
    Players.PlayerAdded:Connect(function(player)
        utilities.API.initializePlayer(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        utilities.API.initializePlayer(player)
    end
    dLog("Success", "Done")
end