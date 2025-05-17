local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Debris = game:GetService("Debris")

local tool = Instance.new("Tool")
tool.Name = "FE Gun"
tool.RequiresHandle = true
tool.CanBeDropped = false

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 1, 3)
handle.Color = Color3.fromRGB(20, 20, 20)
handle.Material = Enum.Material.Metal
handle.Anchored = false
handle.CanCollide = false
handle.Parent = tool

local grip = Instance.new("Part")
grip.Name = "Grip"
grip.Size = Vector3.new(0.5, 1.2, 1.2)
grip.Color = Color3.fromRGB(30, 30, 30)
grip.Material = Enum.Material.Metal
grip.Anchored = false
grip.CanCollide = false
grip.Parent = tool

local barrel = Instance.new("Part")
barrel.Name = "Barrel"
barrel.Size = Vector3.new(0.3, 0.3, 2)
barrel.Color = Color3.fromRGB(10, 10, 10)
barrel.Material = Enum.Material.Metal
barrel.Anchored = false
barrel.CanCollide = false
barrel.Parent = tool

-- Позиционируем grip и barrel относительно Handle
grip.CFrame = handle.CFrame * CFrame.new(0, -0.6, -0.5)
barrel.CFrame = handle.CFrame * CFrame.new(0, 0.2, 2)

local weldGrip = Instance.new("WeldConstraint")
weldGrip.Part0 = handle
weldGrip.Part1 = grip
weldGrip.Parent = handle

local weldBarrel = Instance.new("WeldConstraint")
weldBarrel.Part0 = handle
weldBarrel.Part1 = barrel
weldBarrel.Parent = handle

tool.GripForward = Vector3.new(0, 0, -1)
tool.GripPos = Vector3.new(0, -0.5, 0)
tool.GripRight = Vector3.new(1, 0, 0)
tool.GripUp = Vector3.new(0, 1, 0)

tool.Parent = LocalPlayer.Backpack

local function burnParts(model)
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            -- Постепенно увеличиваем прозрачность, имитируя сгорание
            coroutine.wrap(function()
                for i = 0, 1, 0.05 do
                    part.Transparency = i
                    wait(0.05)
                end
                part:Destroy()
            end)()
        end
    end
end

tool.Activated:Connect(function()
    local mouse = LocalPlayer:GetMouse()
    if not mouse then return end

    local char = LocalPlayer.Character
    if not char then return end

    -- Берём позицию в конце ствола для луча
    local barrelCF = barrel.CFrame
    local origin = barrelCF.Position + barrelCF.LookVector * (barrel.Size.Z / 2)

    local targetPos = mouse.Hit.Position

    -- Создаём лазер (луч)
    local beam = Instance.new("Part")
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.BrickColor = BrickColor.new("Bright red")
    beam.Size = Vector3.new(0.15, 0.15, (targetPos - origin).Magnitude)
    beam.CFrame = CFrame.new(origin, targetPos) * CFrame.new(0, 0, -beam.Size.Z / 2)
    beam.Parent = workspace

    Debris:AddItem(beam, 0.2)

    local ray = Ray.new(origin, (targetPos - origin).Unit * 500)
    local hitPart, hitPos = workspace:FindPartOnRay(ray, char)

    if hitPart then
        local targetModel = hitPart:FindFirstAncestorOfClass("Model")
        if targetModel then
            local humanoid = targetModel:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 and targetModel ~= char then
                humanoid.Health = 0

                -- Запускаем эффект "сгорания" локально
                burnParts(targetModel)

                delay(1.5, function()
                    if targetModel.Parent then
                        targetModel.Parent = nil
                    end
                end)
            end
        end
    end
end)
