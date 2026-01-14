-- =========================
-- DAKAIT HUB | SECURE LOADER
-- =========================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local KEY_FILE = "dakaithub_key.json"

-- executor safety
if not (writefile and readfile and isfile and loadstring) then
    LocalPlayer:Kick("Unsupported executor")
    return
end

-- basic anti-dump
if not debug or not string.dump then
    LocalPlayer:Kick("Security violation")
    return
end

-- XOR decoder
local function dec(str, key)
    local out = {}
    for i = 1, #str do
        out[i] = string.char(bit32.bxor(str:byte(i), key))
    end
    return table.concat(out)
end

-- one‑time key check
if not isfile(KEY_FILE) then

    local OrionLib = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
    ))()

    local Window = OrionLib:MakeWindow({
        Name = "DakaitHub | Team Access",
        SaveConfig = false,
        IntroText = "Enter One-Time Key"
    })

    local Tab = Window:MakeTab({
        Name = "Key System",
        Icon = "rbxassetid://4483345998"
    })

    local inputKey = ""

    local VALID_KEYS = {
        ["DAKAIT-TEAM-001"] = true,
        ["DAKAIT-RANJHA-777"] = true,
        ["DAKAIT-DEV-999"] = true,
    }

    Tab:AddTextbox({
        Name = "Enter Key",
        Callback = function(v)
            inputKey = string.upper(v)
        end
    })

    Tab:AddButton({
        Name = "Verify",
        Callback = function()
            if VALID_KEYS[inputKey] then
                writefile(KEY_FILE, HttpService:JSONEncode({
                    verified = true,
                    time = os.time()
                }))

                OrionLib:MakeNotification({
                    Name = "Access Granted",
                    Content = "Welcome to DakaitHub",
                    Time = 3
                })
                task.wait(1)
                OrionLib:Destroy()
            else
                OrionLib:MakeNotification({
                    Name = "Invalid Key",
                    Content = "Not authorized",
                    Time = 3
                })
            end
        end
    })

    OrionLib:Init()
    repeat task.wait() until isfile(KEY_FILE)
end

-- =========================
-- LOAD ENCRYPTED MAIN
-- =========================

local encrypted = game:HttpGet(
    "https://raw.githubusercontent.com/Pannu2009/Dakait-scripts/main/main.enc.lua"
)

local decoded = dec(encrypted, 73)
loadstring(decoded)()
