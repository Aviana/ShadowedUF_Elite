local ShadowUF = ShadowUF
local EliteIndicator = {}
local L = ShadowUF.L
local silverDragon = "Interface/AddOns/ShadowedUF_Elite/UI-DialogBox-Silver-Dragon"
local allowedUnits = {
	["player"] = true,
	["target"] = true,
	["targettarget"] = true,
	["targettargettarget"] = true,
	["pet"] = true,
	["pettarget"] = true,
	["focus"] = true,
	["focustarget"] = true,
}

ShadowUF:RegisterModule(EliteIndicator, "eliteIndicator", "Show the dragon graphic around the frame for elite and rare mobs.")

function EliteIndicator:OnInitialize()
	for unit, _ in pairs(allowedUnits) do
		ShadowUF.db.profile.units[unit].eliteIndicator = ShadowUF.db.profile.units[unit].eliteIndicator or {enabled = false, side = "left"}
	end
end
EliteIndicator.OnProfileChange = EliteIndicator.OnInitialize

function EliteIndicator:OnConfigurationLoad()
	ShadowUF.Config.unitTable.args.indicators.args.elite = {
		order = 0,
		type = "group",
		name = "Elite Indicator",
		desc = "Show the dragon graphic around the frame for elite and rare mobs.",
		disabled = function(info)
			local unit = info[#(info)-2]
			return not allowedUnits[unit]
		end,
		args = {
			enabled = {
				type = "toggle",
				order = 0,
				name = L["Enable indicator"],
				arg = "indicators.$parent.enabled",
				set = function(info, value)
					local unit = info[#(info)-3]
					ShadowUF.db.profile.units[unit].eliteIndicator.enabled = value
					ShadowUF.Config.queueLayoutReload(unit)
				end,
				get = function(info)
					local unit = info[#(info)-3]
					return ShadowUF.db.profile.units[unit].eliteIndicator.enabled
				end,
				disabled = function(info)
					local unit = info[#(info)-3]
					return not allowedUnits[unit]
				end,
			},
			side = {
				type = "select",
				order = 1,
				name = "Side",
				values = {["left"] = L["Left"], ["right"] = L["Right"]},
				arg = "indicators.$parent.side",
				set = function(info, value)
					local unit = info[#(info)-3]
					ShadowUF.db.profile.units[unit].eliteIndicator.side = value
					ShadowUF.Config.queueLayoutReload(unit)
				end,
				get = function(info)
					local unit = info[#(info)-3]
					return ShadowUF.db.profile.units[unit].eliteIndicator.side
				end,
				disabled = function(info)
					local unit = info[#(info)-3]
					return not allowedUnits[unit]
				end,
			}
		}
	}
end

function EliteIndicator:OnEnable(frame)
	if not frame.eliteIndicator then
		frame.eliteIndicator = CreateFrame("Frame", nil, frame)
		frame.eliteIndicator:SetAllPoints(frame)
		frame.eliteIndicator.texture = frame.eliteIndicator:CreateTexture(nil, "ARTWORK")
		frame.eliteIndicator:SetFrameLevel(frame.indicators:GetFrameLevel())
	end

	frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self, "UpdateStatus")
	frame:RegisterUpdateFunc(self, "Update")
end

function EliteIndicator:OnDisable(frame)
	frame:UnregisterAll(self)
	if frame.eliteIndicator then
		frame.eliteIndicator:Hide()
	end
end

function EliteIndicator:OnLayoutApplied(frame)
	if not frame.eliteIndicator then return end

	local mod
	local side = string.upper(ShadowUF.db.profile.units[frame.unitSUF].eliteIndicator.side)

	if side == "RIGHT" then
		frame.eliteIndicator.texture:SetTexCoord(1,0,0,1)
		mod = -1
	else
		frame.eliteIndicator.texture:SetTexCoord(0,1,0,1)
		mod = 1
	end

	local size = frame:GetHeight() * 1.6

	frame.eliteIndicator.texture:SetHeight(size)
	frame.eliteIndicator.texture:SetWidth(size)
	frame.eliteIndicator.texture:SetPoint("CENTER", frame, side, mod*(size*0.25), 0)
end

function EliteIndicator:UpdateStatus(frame, event, unit)
	-- Fired when Elite status changes
	if frame.unitSUF ~= unit then return end
	self:Update(frame)
end

function EliteIndicator:Update(frame)

	local classif = UnitClassification(frame.unitSUF)
	local enabled = ShadowUF.db.profile.units[frame.unitSUF].eliteIndicator.enabled

	if classif == "worldboss" or classif == "rareelite" or frame.unitSUF == "player" or frame.unitSUF == "pet" then
		classif = "elite"
	end

	if classif == "rare" and enabled then
		frame.eliteIndicator.texture:SetTexture(silverDragon)
		frame.eliteIndicator:Show()
	elseif classif == "elite" and enabled then
		frame.eliteIndicator.texture:SetTexture(131078)
		frame.eliteIndicator:Show()
	else
		frame.eliteIndicator:Hide()
	end
end
