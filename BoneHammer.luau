--Connected Discord-GitHub
--flowersareabove (discord) & NatFlowers17 (roblox)

local BoneHammer = {}
BoneHammer.__index = BoneHammer

--serviços
local tween = game:GetService("TweenService")

--Modulo de dano
local ReceiveDamage = require(game:GetService("ServerStorage").Modules.ReceiveDamage)

--Variaveis
local Damage = 50
local DecalArea = .4
local kb = true
local kb_strenght = -200 --negativo = joga longe, positivo joga perto

function BoneHammer:Create(character : CharacterAppearance, add)
	local NewHammer = setmetatable({}, BoneHammer)
	
	--poo variaveis
	NewHammer.Model = script.BoneHammer:Clone()
	
	--variaveis
	local tweening = false
	local sounds = script.Parent.Sounds
	local attacking = false
	local humanoid : Humanoid = character:FindFirstChild("Humanoid")
	local Torso : Part = character:FindFirstChild("Torso")
	local hrp : Part = character:FindFirstChild("HumanoidRootPart")
	
	--hammerpos
	local hammerpos = hrp.CFrame * CFrame.new(0, 0, -30)
	local part = Instance.new("Part", workspace)
	part.CanCollide = false
	part.Transparency = 1
	part.Anchored = true
	part.CFrame = hammerpos
	
	local sound_jump = sounds.BoneHammerJump:Clone()
	sound_jump.Parent = character
	sound_jump.Volume = 1
	sound_jump:Play()
	
	--Colocando o player no alto
	local tweenfly = tween:Create(hrp, TweenInfo.new(.5, Enum.EasingStyle.Bounce), {CFrame = hrp.CFrame * CFrame.new(0, 30, 0)})
	tweenfly:Play()
	attacking = true
	
	--task.spawn do hrp anchored e platform
	task.spawn(function()
		hrp.Anchored = true
		humanoid.PlatformStand = true
		repeat
			wait()
		until not attacking
		hrp.Anchored = false
		humanoid.PlatformStand = false
	end)
	
	tweenfly.Completed:Wait()
	--martelo
	--som
	task.wait(.4)
	local sound_spawn = sounds.BoneHammer:Clone()
	sound_spawn.Parent = character
	sound_spawn.Volume = 2
	sound_spawn:Play()
	
	--modelo
	NewHammer.Model.Parent = workspace
	NewHammer.Model:PivotTo(hrp.CFrame * CFrame.new(0, 20, 0))
	NewHammer.Model.PrimaryPart.CFrame = CFrame.lookAt(NewHammer.Model.PrimaryPart.Position, part.Position)
	
	task.spawn(function()
		task.wait(.7)
		local rotate = script.Parent.Sounds.BoneHammerRotateSound:Clone()
		rotate.Parent = NewHammer.Model
		rotate:Play()
	end)
	task.wait(1)
	
	local rotationTween = tween:Create(NewHammer.Model.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Circular), {Orientation = NewHammer.Model.PrimaryPart.Orientation + Vector3.new(math.rad(-26000), 0, 0)})
	rotationTween:Play()

	task.spawn(function()
		task.wait(1.9)
		local somdelazer = script.Parent.Sounds.BoneHammerOnGoing:Clone()
		somdelazer.Parent = NewHammer.Model
		somdelazer:Play()
	end)
	
	rotationTween.Completed:Wait()

	--Tween
	local defaultpos = NewHammer.Model.PrimaryPart.Position
	local tween2 = tween:Create(NewHammer.Model.PrimaryPart, TweenInfo.new(.3, Enum.EasingStyle.Exponential), {Position = part.Position - Vector3.new(0, 2, 0)})
	tween2:Play()
	
	--esperando
	task.wait(.2)
	
	--Decal function
	local function CreateDecal(Brickcolor)
		--Som de impacto
		local sound = script.Parent.Sounds.BoneHammerImpact:Clone()
		sound.Parent = workspace
		sound:Play()
		task.spawn(function()
			sound.Ended:Wait()
			sound:Destroy()
		end)
		-----------------------------------CAMERA SHAKE
		--Spawnando as decal
		tweening = true
		local decal : Model = script.Decal:Clone()
		local decal_explosion : Model = script.Decal_Explosion:Clone()
		
		decal.Parent = workspace.VFX
		decal_explosion.Parent = workspace.VFX
		--local pos = NewHammer.Model.PrimaryPart.Position - Vector3.new(1, 10, 4)
		local pos = part.Position - Vector3.new(0, 4, 0)
		decal:PivotTo(CFrame.new(pos))
		
		task.spawn(function()
			decal_explosion:ScaleTo(5)
			decal:ScaleTo(5)
			decal_explosion:PivotTo(CFrame.new(pos))
			
			for i, v in pairs(decal_explosion:GetDescendants()) do
				if v:IsA("Part") then
					local part : Part = v
					part.BrickColor = Brickcolor

					part:SetNetworkOwner(character.Parent)

					local att = Instance.new("Attachment", part)
					local lv = Instance.new("LinearVelocity", att)
					lv.MaxForce = math.huge
					lv.Attachment0 = att
					lv.VectorVelocity = (decal.PrimaryPart.Position - part.Position).Unit * -100
					game.Debris:AddItem(att, .2)
				end
			end
			for i, v in pairs(decal:GetDescendants()) do
				if v:IsA("Part") then
					local part : Part = v
					part.BrickColor = Brickcolor
				end
			end
			
			task.wait(10)
			
			for i, v in pairs(NewHammer.Model:GetChildren()) do
				if not v:IsA("MeshPart") then continue end
				
				local part : Part = v
				local tweena = tween:Create(part, TweenInfo.new(10), {Transparency = 1})
				tweena:Play()
				
				local pos = part.Position
				local goal = Vector3.new(pos.X, pos.Y - 20, pos.Z)
				local tween2 = tween:Create(part, TweenInfo.new(10), {Position = goal})
				tween2:Play()
			end
			
			for i, v in pairs(decal:GetDescendants()) do
				if v:IsA("Part") then
					local part : Part = v
					local tweena = tween:Create(part, TweenInfo.new(10), {Transparency = 1})
					tweena:Play()

					local pos = part.Position
					local goal = Vector3.new(pos.X, pos.Y - 20, pos.Z)
					local tween2 = tween:Create(part, TweenInfo.new(10), {Position = goal})
					tween2:Play()
				end
			end
			for i, v in pairs(decal_explosion:GetDescendants()) do
				if v:IsA("Part") then
					local part : Part = v
					local tweena = tween:Create(part, TweenInfo.new(10), {Transparency = 1})
					tweena:Play()
					part.CanCollide = false
					part.Anchored = true
					local pos = part.Position
					local goal = Vector3.new(pos.X, pos.Y - 20, pos.Z)
					local tween2 = tween:Create(part, TweenInfo.new(10), {Position = goal})
					tween2:Play()
				end
			end
			
			task.wait(5)
			decal:Destroy()
			decal_explosion:Destroy()
			NewHammer.Model:Destroy()
		end)
	end
	
	--hitbox
	local hitbox = script.Hitbox:Clone()
	hitbox.Parent = workspace
	hitbox.Position = part.Position
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, NewHammer.Model}
	
	local parts = workspace:GetPartsInPart(hitbox, params)
	local hits = {}
	for i, plr in pairs(parts) do
		--verificação
		if plr.Parent:FindFirstChild("Humanoid") and not table.find(hits, plr.Parent) then
			table.insert(hits, plr.Parent)
			
			--Dano
			local humanoid = plr.Parent:FindFirstChild("Humanoid")
			local kbpos = (NewHammer.Model.PrimaryPart.Position - humanoid.Parent:FindFirstChild("HumanoidRootPart").Position).Unit * kb_strenght
			ReceiveDamage:TakeDamage(character, humanoid, Damage, kb, kbpos)
		end
	end
	
	--Creating decal
	local DecalPositionFinder = Instance.new("Part", workspace)
	DecalPositionFinder.Position = Vector3.new(hammerpos.X, hammerpos.Y - 2, hammerpos.Z)
	DecalPositionFinder.Anchored = true
	DecalPositionFinder.CanCollide = false
	DecalPositionFinder.Size = Vector3.new(1, 1, 1) * 4
	DecalPositionFinder.Transparency = 1
	local MapFinder = workspace:GetPartsInPart(DecalPositionFinder, params)
	for i, map_part in pairs(MapFinder) do
		if map_part:GetAttribute("Map") then
			CreateDecal(map_part.BrickColor)
		end
	end
	
	--end
	attacking = false
	hitbox:Destroy()
	
	if NewHammer.Model and not tweening then
		for i, v in pairs(NewHammer.Model:GetChildren()) do
			if not v:IsA("MeshPart") then continue end

			local part : Part = v
			local tweena = tween:Create(part, TweenInfo.new(8), {Transparency = 1})
			tweena:Play()
		end
		
		task.wait(10)
		
		NewHammer.Model:Destroy()
	end
end

return BoneHammer