local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId
local JobId = game.JobId

local function fetchServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    return success and result or nil
end

local function serverHop()
    print("Đang quét danh sách server...")
    local nextCursor = nil
    
    repeat
        local data = fetchServers(nextCursor)
        if data and data.data then
            for _, server in ipairs(data.data) do
                -- Kiểm tra: Còn chỗ trống + Không phải server hiện tại + ID hợp lệ
                if server.playing < server.maxPlayers and server.id ~= JobId then
                    print("Đã tìm thấy server! Đang kết nối: " .. server.id)
                    
                    local teleportSuccess, err = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                    end)
                    
                    if teleportSuccess then
                        return -- Thoát hàm nếu bắt đầu teleport thành công
                    else
                        warn("Teleport thất bại, đang thử server khác: " .. tostring(err))
                    end
                end
            end
            nextCursor = data.nextPageCursor
        end
        task.wait(1) -- Đợi một chút để tránh spam API quá nhanh
    until not nextCursor
    
    warn("Đã quét hết danh sách mà không có server trống. Đang thử lại từ đầu...")
end

-- Vòng lặp chạy mỗi 20 giây
while true do
    print("Chờ 20 giây để thực hiện hop tiếp theo...")
    task.wait(20)
    serverHop()
end
