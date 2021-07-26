local Package
local PackageTarget = {}

local Players = game:GetService("Players")

local function safePcall(functionToCall, ...)
    local retries = 0
    local success, result = pcall(functionToCall, ...)
    
    while not success and retries < 3 do
        success, result = pcall(functionToCall, ...)
        retries += 1
        wait(5)
    end

    return success, result
end

function PackageTarget.OnInvoke(userId)
    local success, username = safePcall(Players.GetNameFromUserIdAsync, Players, userId)
    local currentIndex = 0

    for _, permission in ipairs(PackageTarget.Settings.Permissions) do
        local allowed
        if typeof(permission.Authorize) == "table" then
            if permission.Type == "UserId" then
                for _, authorize in ipairs(permission.Authorize) do
                    if authorize == tostring(userId) then
                        allowed = true
                    end
                end
            elseif success and permission.Type == "Username" then
                for _, authorize in ipairs(permission.Authorize) do
                    if authorize == username then
                        allowed = true
                    end
                end
            end
        else
            if permission.Type == "UserId" then
                allowed = permission.Authorize == tostring(userId)
            elseif success and permission.Type == "Username" then
                allowed = permission.Authorize == username
            end
        end

        if allowed then
            local groupIndex = PackageTarget.GroupsIndex[permission.Group]
            if currentIndex < groupIndex then
                currentIndex = groupIndex
            end

            if groupIndex == #PackageTarget.Settings.Groups then
                break
            end
        end
    end

    return currentIndex
end

function PackageTarget:Init()
    PackageTarget.Settings = require(Package.Core.Settings)
    PackageTarget.GroupsIndex = {}

    for index, group in ipairs(PackageTarget.Settings.Groups) do
        PackageTarget.GroupsIndex[group.Name] = index
    end

    Package.API.addChecker("User", PackageTarget.OnInvoke)
end

Package = {
    Name = "UserChecker",
    Description = "Adds Username/UserId support to the API's admin checking function",
    Author = "7kayoh",
    Class = "Plugin",
    Target = PackageTarget
}

return Package