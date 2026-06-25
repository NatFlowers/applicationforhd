--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local physics = game:GetService("PhysicsService")
--modules
local PlayerStats_Module = require(ServerStorage.Modules.PlayerStats)
local InfoModule = require(ReplicatedStorage.Info.InfoModule)
--vars
local licenses = {}
for license in InfoModule.LicensesProducts do
	table.insert(licenses, license)
end
local FrameTable = {}
local FullPrice = 0
local Connections = {}
local Change = 0


--module
local PaymentModule = {}
PaymentModule.__index = PaymentModule
PaymentModule._AllCashRegisters = {}
Players.PlayerRemoving:Connect(function(plr_leaving)
	local data = PaymentModule._AllCashRegisters[plr_leaving.Name]
	if data then
		data:Clean()
	end
end)


--functions
function PaymentModule.new(owner : Player, model)
	--oop
	local self = setmetatable({}, PaymentModule)
	
	--adding it to the table
	PaymentModule._AllCashRegisters[owner.Name] = self
	
	--physics
	local PaymentGroup = "_PaymentCollisionGroup"
	pcall(function()
		physics:RegisterCollisionGroup(PaymentGroup)
	end)
	--physics:CollisionGroupSetCollidable(PaymentGroup, "Default", false)
	--setting collision group
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("MeshPart") or part:IsA("BasePart") then
			part.CollisionGroup = PaymentGroup
		end
	end
	
	--vars
	self.Player = owner
	self.Char = self.Player.Character
	self.CashRegister = model
	--monitor
	self.GUI = self.CashRegister.POSModel.POS.CashRegisterUI.SurfaceGui
	self.Items_Frame = self.GUI.NormalCheckoutFrame
	self.Cash_Frame = self.GUI.CashFrame
	self.Card_Frame = self.GUI.CardFrame
	--
	local hum : Humanoid = self.Char:FindFirstChild("Humanoid")
	local hrp : Part = self.Char:FindFirstChild("HumanoidRootPart")
	local _POSITION : Part = model:FindFirstChild("_POSITION")
	local _CAMERA : Part = model:FindFirstChild("_CAMERA")
	
	--player interacted with cashregister
	local clickint = Instance.new("ClickDetector", _POSITION)
	local debounce = false
	clickint.MouseClick:Connect(function(plr)
		--verifying
		if plr ~= owner or not hum or hum.Health <= 0 or debounce then return end
		debounce = true
		task.delay(1, function()
			debounce = false
		end)
		
		--locking plr
		self:LockPlayer(_POSITION.Position, _CAMERA.Position)
	end)
	
	--setting info
	self:Reset()
	
	--return
	return self
end

--value
ReplicatedStorage.Remotes.Functions.CheckPaymentValue.OnServerInvoke = function(plr, value, _type)
	--var
	local Success = false
	
	--types
	if _type == "card" then
		--giving money
		if value == FullPrice then
			PaymentModule._AllCashRegisters[plr.Name]:CheckMoney(FullPrice)
		end

		--returning
		Success = value == FullPrice
	elseif _type == "cash" then
		--giving money
		if value == Change then
			PaymentModule._AllCashRegisters[plr.Name]:CheckMoney(FullPrice)
		end

		--returning
		Success = value == Change
	end
	
	--resetting
	if Success then
		task.delay(1, function()
			PaymentModule._AllCashRegisters[plr.Name]:Reset()
		end)
		
		--=======================================================TESTING PURPOSES
		task.delay(5, function()
			if plr.Character:HasTag("RegisterOperation") then
				PaymentModule._AllCashRegisters[plr.Name]:LockPlayer()
			end
		end)
	end
	
	--returning
	return Success
end

--================================================================
--change gui
function PaymentModule:ChangeGUI(guiname)
	if guiname == "checkout" then
		self.GUI.CardFrame.Visible = false
		self.GUI.CashFrame.Visible = false
		self.GUI.NormalCheckoutFrame.Visible = true
		
	elseif guiname == "cash" then
		self.GUI.CardFrame.Visible = false
		self.GUI.CashFrame.Visible = true
		self.GUI.NormalCheckoutFrame.Visible = false
		
		--cleaning
		self:ClearItemScreen()
		
	elseif guiname == "card" then
		self.GUI.CardFrame.Visible = true
		self.GUI.CashFrame.Visible = false
		self.GUI.NormalCheckoutFrame.Visible = false
		
		--cleaning
		self:ClearItemScreen()
		
	end
end

--Lock player
function PaymentModule:LockPlayer(pos, campos)
	--cam event
	ReplicatedStorage.Remotes.SetCamera:FireClient(self.Player, "cashregister", true, pos, campos)

	--adding tag
	self.Player.Character:AddTag("RegisterOperation")

	--testing
	local _table = {}
	for i = 0, 5 do
		local key = licenses[math.random(1, #licenses)]
		local license = InfoModule.LicensesProducts[key]
		local album = {}
		
		--getting one
		for _, x in license.Albums do
			album = x
			break
		end
		
		_table[i] = {Item = album.Name, Quantity = math.random(1, 4), Price = (album.SellingPrice.Max + album.SellingPrice.Min)/2}
	end
	
	--=====================================================TESTING PURPOSES
	self:AddItemScreen(_table, "cash")
end

--Item on screen
local randomfactor = false
function PaymentModule:AddItemScreen(ItemsTable, paymenttype, onlyAdd)
	--vars
	local parent : ScrollingFrame = self.Items_Frame.ItemFrame.ScrollingFrame
	
	--checkout
	self:ChangeGUI("checkout")
	
	--reading table
	--itemstable = {PRODUCT_A = {Item = "", Quantity = 0, Price = 0}, PRODUCT_B = {Item = "", Quantity = 0, Price = 0}}
	for item, info in ItemsTable do
		--creating
		local checkoutFrame : Frame = self.Items_Frame.ItemFrame.ScrollingFrame.Frame:Clone()
		
		--config
		checkoutFrame.Parent = parent
		checkoutFrame.ProductAmount.Text = info.Quantity
		checkoutFrame.ProductName.Text = info.Item
		checkoutFrame.ProductPrice.Text = "$" .. string.format("%05.2f", (info.Price * info.Quantity))
		checkoutFrame.Visible = true
		
		--adding to table
		table.insert(FrameTable, checkoutFrame)
		
		--price
		FullPrice += tonumber(info.Price * info.Quantity)
		
		--wait
		wait(.5)
		
		--price
		self.GUI.NormalCheckoutFrame.PaymentFrame.TotalPriceValue.Text = "$" .. string.format("%05.2f", FullPrice)
	end
	
	--only add
	if onlyAdd then return end
	
	--==============================================================
	randomfactor = not randomfactor
	if randomfactor then
		paymenttype = "card"
	else
		paymenttype = "cash"
	end
	
	--changing gui
	if paymenttype == "card" then
		self.GUI.NormalCheckoutFrame.PaymentFrame.PaymentType.Text = "Card"
	else
		self.GUI.NormalCheckoutFrame.PaymentFrame.PaymentType.Text = "Cash"
	end
	
	--wait
	task.wait(2)
	
	--waiting cam lock
	repeat wait() until self.Player.Character:HasTag("RegisterOperation")
	
	--payment
	if paymenttype == "card" then
		self:PayCard(self.Player, FullPrice)
	else
		self:PayCash(self.Player, FullPrice)
	end
end
function PaymentModule:ClearItemScreen()
	--removing
	for _, frame in FrameTable do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

--Card payment
function PaymentModule:PayCard(player : Player, QuantityToEarn)
	--vars
	local PlayerData = PlayerStats_Module.Players[player.Name]
	
	--enable gui
	ReplicatedStorage.Remotes.SendTypeOfPayment:FireClient(player, "Card", QuantityToEarn, self.CashRegister)
	
	--cashregister gui
	self:ChangeGUI("card")
	self.GUI.CardFrame.ItemFrame.ScrollingFrame.ValuesFrame.RecievedValue.Text = "$" .. string.format("%05.2f", QuantityToEarn)
end
--Cash payment
function PaymentModule:PayCash(player : Player, QuantityToEarn)
	--vars
	local PlayerData = PlayerStats_Module.Players[player.Name]
	local valuegived = (math.floor(QuantityToEarn / 10) * 10 + 10)
	local changevalue = valuegived - QuantityToEarn
	Change = changevalue
	
	--cashregister gui
	self:ChangeGUI("cash")
	self.GUI.CashFrame.TotalFrame.TotalPriceValue.Text = "$" .. string.format("%05.2f", QuantityToEarn)
	self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.ChangeValue.Text = "$" .. string.format("%05.2f", changevalue) --troco
	self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.RecievedValue.Text = "$" .. string.format("%05.2f", valuegived)
	
	--enable gui
	ReplicatedStorage.Remotes.SendTypeOfPayment:FireClient(player, "Cash", changevalue, self.CashRegister)
	
	--conn
	local conn = {}
	conn = ReplicatedStorage.Remotes.SendChange.OnServerEvent:Connect(function(plr, value)
		--verifying
		if plr ~= self.Player then return end
		
		if value < 0 then
			value = 0
		end
		
		--adding value
		self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.GivingChangeValue.Text = "$" .. string.format("%05.2f", value) --dinheiro dado
	end)
end
--========================Reset
function PaymentModule:Reset()
	--vars
	FullPrice = 0
	Change = 0
	
	--gui
	self.GUI.CardFrame.Visible = false
	self.GUI.CashFrame.Visible = false
	self.GUI.NormalCheckoutFrame.Visible = true
	self.GUI.NormalCheckoutFrame.PaymentFrame.TotalPriceValue.Text = "$0.00"
	self.GUI.NormalCheckoutFrame.PaymentFrame.PaymentType.Text = "Waiting client!"
	self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.GivingChangeValue.Text = "$0.00"
	self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.ChangeValue.Text = "$0.00"
	self.GUI.CashFrame.ItemFrame.ScrollingFrame.ValuesFrame.RecievedValue.Text = "$0.00"
end
--========================Returning
function PaymentModule:CheckMoney(money)
	PlayerStats_Module.Players[self.Player.Name]:AddCurrency(money, true)
end
--========================Remove
function PaymentModule:Clean()
	--removing
	PaymentModule._AllCashRegisters[self.Player.Name] = nil
end

return PaymentModule
