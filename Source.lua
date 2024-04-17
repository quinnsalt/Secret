
local Prey = nil
local Plr  = nil

local Players, Client, Mouse, RS, Camera =
    game:GetService("Players"),
    game:GetService("Players").LocalPlayer,
    game:GetService("Players").LocalPlayer:GetMouse(),
    game:GetService("RunService"),
    game:GetService("Workspace").CurrentCamera

local Circle       = Drawing.new("Circle")
local AimlockCircle = Drawing.new("Circle")

Circle.Color           = Color3.new(1,1,1)
Circle.Thickness       = 1
AimlockCircle.Color     = Color3.new(1,1,1)
AimlockCircle.Thickness = 1

local UpdateFOV = function ()
    if (not Circle and not AimlockCircle) then
        return Circle and AimlockCircle
    end
    AimlockCircle.Visible  = getgenv().Cult.AimlockFOV.Visible
    AimlockCircle.Radius   = getgenv().Cult.AimlockFOV.Radius * 3
    AimlockCircle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
    
    Circle.Visible  = getgenv().Cult.SilentFOV.Visible
    Circle.Radius   = getgenv().Cult.SilentFOV.Radius * 3
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
    return Circle and AimlockCircle
end

RS.Heartbeat:Connect(UpdateFOV)

local WallCheck = function(destination, ignore)
    local Origin    = Camera.CFrame.p
    local CheckRay  = Ray.new(Origin, destination - Origin)
    local Hit       = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
    return Hit      == nil
end

local WTS = function (Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local IsOnScreen = function (Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end

local FilterObjs = function (Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
        return true
    end
end

local ClosestPlrFromMouse = function()
    local Target, Closest = nil, 1/0
    
    for _ ,v in pairs(Players:GetPlayers()) do
    	if getgenv().Cult.Silent.WallCheck then
    		if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
    			local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
    			local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    
    			if (Circle.Radius > Distance and Distance < Closest and OnScreen) and WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}) then
    				Closest = Distance
    				Target = v
    			end
    		end
    	else
    		if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
    			local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
    			local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    
    			if (Circle.Radius > Distance and Distance < Closest and OnScreen) then
    				Closest = Distance
    				Target = v
    			end
    		end
    	end
    end
    return Target
end

local ClosestPlrFromMouse2 = function()
    local Target, Closest = nil, 1/0
    
    for _ ,v in pairs(Players:GetPlayers()) do
    	if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
        	if getgenv().Cult.Aimlock.WallCheck then
        		local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
        		local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        
        		if (Distance < Closest and OnScreen) and WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}) then
        			Closest = Distance
        			Target = v
        		end
                elseif getgenv().Cult.Aimlock.UseCircleRadius then
            		local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            		local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if (AimlockCircle.Radius > Distance and Distance < Closest and OnScreen) and WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}) then
            			Closest = Distance
            			Target = v
                    end
        	    else
        			local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
        			local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        
        			if (Distance < Closest and OnScreen) then
        				Closest = Distance
        				Target = v
        			end
        		end
            end
        end
    return Target
end

local GetClosestBodyPart = function (character)
    local ClosestDistance = 1/0
    local BodyPart = nil
    
    if (character and character:GetChildren()) then
        for _,  x in next, character:GetChildren() do
            if FilterObjs(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (Circle.Radius > Distance and Distance < ClosestDistance) then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end
    return BodyPart
end

local GetClosestBodyPartV2 = function (character)
    local ClosestDistance = 1/0
    local BodyPart = nil
    
    if (character and character:GetChildren()) then
        for _,  x in next, character:GetChildren() do
            if FilterObjs(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (Distance < ClosestDistance) then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end
    return BodyPart
end

Mouse.KeyDown:Connect(function(Key)
    local Keybind = getgenv().Cult.Aimlock.Key:lower()
    if (Key == Keybind) then
        if getgenv().Cult.Aimlock.Enabled == true then
            IsTargetting = not IsTargetting
            if IsTargetting then
                Plr = ClosestPlrFromMouse2()
            else
                if Plr ~= nil then
                    Plr = nil
                    IsTargetting = false
                end
            end
        end
    end
end)

Mouse.KeyDown:Connect(function(Key)
    local Keybind = getgenv().Cult.Silent.Keybind:lower()
    if (Key == Keybind) and getgenv().Cult.Silent.UseKeybind == true then
            if getgenv().Cult.Silent.Enabled == true then
				getgenv().Cult.Silent.Enabled = false
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Disabled Silent Aim",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            else
				getgenv().Cult.Silent.Enabled = true
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Enabled Silent Aim",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            end
        end
    end
)


Mouse.KeyDown:Connect(function(Key)
    local Keybind = getgenv().Cult.Both.UnderGroundKey:lower()
    if (Key == Keybind) and getgenv().Cult.Both.UseUnderGroundKeybind == true then
            if getgenv().Cult.Both.UnderGroundReolver == true then
				getgenv().Cult.Both.UnderGroundReolver = false
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Disabled UnderGround Resolver",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            else
				getgenv().Cult.Both.UnderGroundReolver = true
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Enabled UnderGround Resolver",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            end
        end
    end
)

Mouse.KeyDown:Connect(function(Key)
    local Keybind = getgenv().Cult.Both.DetectDesyncKey:lower()
    if (Key == Keybind) and getgenv().Cult.Both.UsDetectDesyncKeybind == true then
            if getgenv().Cult.Both.DetectDesync == true then
				getgenv().Cult.Both.DetectDesync = false
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Disabled Desync Resolver",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            else
				getgenv().Cult.Both.DetectDesync = true
                if getgenv().Cult.Both.SendNotification then
                    game.StarterGui:SetCore(
                        "SendNotification",
                        {
                            Title = "Cult",
                            Text = "Enabled Desync Resolver",
                            Icon = "",
                            Duration = 1
                        }
                    )
                end
            end
        end
    end
)

local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index = newcclosure(function(self, v)
    if (getgenv().Cult.Silent.Enabled and Mouse and tostring(v) == "Hit") then
        if Prey and Prey.Character then
    		if getgenv().Cult.Silent.PredictMovement then
    			local endpoint = game.Players[tostring(Prey)].Character[getgenv().Cult.Silent.Part].CFrame + (
    				game.Players[tostring(Prey)].Character[getgenv().Cult.Silent.Part].Velocity * getgenv().Cult.Silent.PredictionVelocity
    			)
    			return (tostring(v) == "Hit" and endpoint)
    		else
    			local endpoint = game.Players[tostring(Prey)].Character[getgenv().Cult.Silent.Part].CFrame
    			return (tostring(v) == "Hit" and endpoint)
    		end
        end
    end
    return backupindex(self, v)
end)

RS.Heartbeat:Connect(function()
	if getgenv().Cult.Silent.Enabled then
	    if Prey and Prey.Character and Prey.Character:WaitForChild(getgenv().Cult.Silent.Part) then
            if getgenv().Cult.Both.DetectDesync == true and Prey.Character:WaitForChild("HumanoidRootPart").Velocity.magnitude > getgenv().Cult.Both.DesyncDetection then            
                pcall(function()
                    local TargetVel = Prey.Character[getgenv().Cult.Silent.Part]
                    TargetVel.Velocity = Vector3.new(0, 0, 0)
                    TargetVel.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end)
            end
            if getgenv().Cult.Silent.AntiGroundShots == true and Prey.Character:FindFirstChild("Humanoid") == Enum.HumanoidStateType.Freefall then
                pcall(function()
                    local TargetVelv5 = Prey.Character[getgenv().Cult.Silent.Part]
                    TargetVelv5.Velocity = Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 0.5), TargetVelv5.Velocity.Z)
                    TargetVelv5.AssemblyLinearVelocity = Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 0.5), TargetVelv5.Velocity.Z)
                end)
            end
            if getgenv().Cult.Both.UnderGroundReolver == true then            
                pcall(function()
                    local TargetVelv2 = Prey.Character[getgenv().Cult.Silent.Part]
                    TargetVelv2.Velocity = Vector3.new(TargetVelv2.Velocity.X, 0, TargetVelv2.Velocity.Z)
                    TargetVelv2.AssemblyLinearVelocity = Vector3.new(TargetVelv2.Velocity.X, 0, TargetVelv2.Velocity.Z)
                end)
            end
	    end
	end
    if getgenv().Cult.Aimlock.Enabled == true then
        if getgenv().Cult.Both.DetectDesync == true and Plr and Plr.Character and Plr.Character:WaitForChild(getgenv().Cult.Aimlock.Part) and Plr.Character:WaitForChild("HumanoidRootPart").Velocity.magnitude > getgenv().Cult.Both.DesyncDetection then
            pcall(function()
                local TargetVelv3 = Plr.Character[getgenv().Cult.Aimlock.Part]
                TargetVelv3.Velocity = Vector3.new(0, 0, 0)
                TargetVelv3.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end
        if getgenv().Cult.Both.UnderGroundReolver == true and Plr and Plr.Character and Plr.Character:WaitForChild(getgenv().Cult.Aimlock.Part)then
            pcall(function()
                local TargetVelv4 = Plr.Character[getgenv().Cult.Aimlock.Part]
                TargetVelv4.Velocity = Vector3.new(TargetVelv4.Velocity.X, 0, TargetVelv4.Velocity.Z)
                TargetVelv4.AssemblyLinearVelocity = Vector3.new(TargetVelv4.Velocity.X, 0, TargetVelv4.Velocity.Z)
            end)
        end
    end
end)

RS.RenderStepped:Connect(function()
	if getgenv().Cult.Silent.Enabled then
        if getgenv().Cult.Silent.CheckIf_KO == true and Prey and Prey.Character then 
            local KOd = Prey.Character:WaitForChild("BodyEffects")["K.O"].Value
            local Grabbed = Prey.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KOd or Grabbed then
                Prey = nil
            end
        end
	end
    if getgenv().Cult.Aimlock.Enabled == true then
        if getgenv().Cult.Aimlock.CheckIf_KO == true and Plr and Plr.Character then 
            local KOd = Plr.Character:WaitForChild("BodyEffects")["K.O"].Value
            local Grabbed = Plr.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KOd or Grabbed then
                Plr = nil
                IsTargetting = false
            end
        end
		if getgenv().Cult.Aimlock.DisableTargetDeath == true and Plr and Plr.Character:FindFirstChild("Humanoid") then
			if Plr.Character.Humanoid.health < 4 then
				Plr = nil
				IsTargetting = false
			end
		end
		if getgenv().Cult.Aimlock.DisableLocalDeath == true and Plr and Plr.Character:FindFirstChild("Humanoid") then
			if Client.Character.Humanoid.health < 4 then
				Plr = nil
				IsTargetting = false
			end
		end
        if getgenv().Cult.Aimlock.DisableOutSideCircle == true and Plr and Plr.Character and Plr.Character:WaitForChild("HumanoidRootPart") then
            if
            AimlockCircle.Radius <
                (Vector2.new(
                    Camera:WorldToScreenPoint(Plr.Character.HumanoidRootPart.Position).X,
                    Camera:WorldToScreenPoint(Plr.Character.HumanoidRootPart.Position).Y
                ) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
             then
                Plr = nil
                IsTargetting = false
            end
        end
		if getgenv().Cult.Aimlock.PredictMovement and Plr and Plr.Character and Plr.Character:FindFirstChild(getgenv().Cult.Aimlock.Part) then
			if getgenv().Cult.Aimlock.UseShake then
				local Main = CFrame.new(Camera.CFrame.p,Plr.Character[getgenv().Cult.Aimlock.Part].Position + Plr.Character[getgenv().Cult.Aimlock.Part].Velocity * getgenv().Cult.Aimlock.PredictionVelocity +
				Vector3.new(
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue),
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue),
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue)
				) * 0.1)
				Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().Cult.Aimlock.Smoothness, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			else
    			local Main = CFrame.new(Camera.CFrame.p,Plr.Character[getgenv().Cult.Aimlock.Part].Position + Plr.Character[getgenv().Cult.Aimlock.Part].Velocity * getgenv().Cult.Aimlock.PredictionVelocity)
    			Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().Cult.Aimlock.Smoothness, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		elseif getgenv().Cult.Aimlock.PredictMovement == false and Plr and Plr.Character and Plr.Character:FindFirstChild(getgenv().Cult.Aimlock.Part) then
			if getgenv().Cult.Aimlock.UseShake then
				local Main = CFrame.new(Camera.CFrame.p,Plr.Character[getgenv().Cult.Aimlock.Part].Position +
				Vector3.new(
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue),
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue),
					math.random(-getgenv().Cult.Aimlock.ShakeValue, getgenv().Cult.Aimlock.ShakeValue)
				) * 0.1)
				Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().Cult.Aimlock.Smoothness, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		    else
    			local Main = CFrame.new(Camera.CFrame.p,Plr.Character[getgenv().Cult.Aimlock.Part].Position)
    			Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().Cult.Aimlock.Smoothness, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		    end
		end
	end
end)

task.spawn(function ()
    while task.wait() do
    	if getgenv().Cult.Silent.Enabled then
            Prey = ClosestPlrFromMouse()
    	end
        if Plr then
            if getgenv().Cult.Aimlock.Enabled and (Plr.Character) and getgenv().Cult.Aimlock.ClosestPart then
                getgenv().Cult.Aimlock.Part = tostring(GetClosestBodyPartV2(Plr.Character))
            end
        end
        if Prey then
            if getgenv().Cult.Silent.Enabled and (Prey.Character) and getgenv().Cult.Silent.ClosestPart then
                getgenv().Cult.Silent.Part = tostring(GetClosestBodyPart(Prey.Character))
            end
        end
    end
end)

local Script = {Functions = {}}
    Script.Functions.getToolName = function(name)
        local split = string.split(string.split(name, "[")[2], "]")[1]
        return split
    end
    Script.Functions.getEquippedWeaponName = function()
        if (Client.Character) and Client.Character:FindFirstChildWhichIsA("Tool") then
           local Tool =  Client.Character:FindFirstChildWhichIsA("Tool")
           if string.find(Tool.Name, "%[") and string.find(Tool.Name, "%]") and not string.find(Tool.Name, "Wallet") and not string.find(Tool.Name, "Phone") then
              return Script.Functions.getToolName(Tool.Name)
           end
        end
        return nil
    end
    RS.RenderStepped:Connect(function()
    if Script.Functions.getEquippedWeaponName() ~= nil then
        local WeaponSettings = getgenv().Cult.GunFOV[Script.Functions.getEquippedWeaponName()]
        if WeaponSettings ~= nil and getgenv().Cult.GunFOV.Enabled == true then
            getgenv().Cult.SilentFOV.Radius = WeaponSettings.FOV
        else
            getgenv().Cult.SilentFOV.Radius = getgenv().Cult.SilentFOV.Radius
        end
    end
end)
