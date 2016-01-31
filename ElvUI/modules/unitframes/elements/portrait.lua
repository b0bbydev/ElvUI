local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Portrait(frame, type)
	local portrait

	if type == 'texture' then
		local backdrop = CreateFrame('Frame',nil,frame)
		portrait = frame:CreateTexture(nil, 'OVERLAY')
		portrait:SetTexCoord(0.15,0.85,0.15,0.85)
		backdrop:SetOutside(portrait)
		backdrop:SetFrameLevel(frame:GetFrameLevel())
		backdrop:SetTemplate('Default')
		portrait.backdrop = backdrop
	else
		portrait = CreateFrame("PlayerModel", nil, frame)
		portrait:SetFrameStrata('LOW')
		portrait:CreateBackdrop('Default')
	end

	portrait.PostUpdate = self.PortraitUpdate

	portrait.overlay = CreateFrame("Frame", nil, frame)
	portrait.overlay:SetFrameLevel(frame:GetFrameLevel() - 5)

	return portrait
end

function UF:SizeAndPosition_Portrait(frame)
	local db = frame.db
	if frame.Portrait then
		frame.Portrait:Hide()
		frame.Portrait:ClearAllPoints()
		frame.Portrait.backdrop:Hide()
	end
	frame.Portrait = db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D
	
	local portrait = frame.Portrait
	if frame.USE_PORTRAIT then
		if not frame:IsElementEnabled('Portrait') then
			frame:EnableElement('Portrait')
		end

		portrait:ClearAllPoints()
		portrait.backdrop:ClearAllPoints()
		if frame.USE_PORTRAIT_OVERLAY then
			if db.portrait.style == '3D' then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
			end
			portrait:SetAllPoints(frame.Health)
			portrait:SetAlpha(0.3)
			portrait:Show()
			portrait.backdrop:Hide()
		else
			portrait:SetAlpha(1)
			portrait:Show()
			portrait.backdrop:Show()
			if db.portrait.style == '3D' then
				portrait:SetFrameLevel(frame:GetFrameLevel() + 5)
			end
			
			if frame.PORTRAIT_POSITION == "LEFT" then
				if frame.USE_MINI_CLASSBAR and frame.USE_CLASSBAR and not frame.CLASSBAR_DETACHED then
					portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 0, -((frame.CLASSBAR_HEIGHT/2)))
				else
					portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT")
				end

				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0)
				else
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0)
				end
			else
				if frame.USE_MINI_CLASSBAR and frame.USE_CLASSBAR and not frame.CLASSBAR_DETACHED then
					portrait.backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", 0, -((frame.CLASSBAR_HEIGHT/2)))
				else
					portrait.backdrop:Point("TOPRIGHT", frame, "TOPRIGHT")
				end
				
				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0)
				else
					portrait.backdrop:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0)
				end
			end
			
			
			portrait:SetInside(portrait.backdrop, frame.BORDER)	
		end
	else
		if frame:IsElementEnabled('Portrait') then
			frame:DisableElement('Portrait')
			portrait:Hide()
			portrait.backdrop:Hide()
		end
	end	
end

function UF:PortraitUpdate(unit)
	local db = self:GetParent().db
	if not db then return end

	local portrait = db.portrait
	if portrait.enable and portrait.overlay then
		self:SetAlpha(0);
		self:SetAlpha(0.35);
	else
		self:SetAlpha(1)
	end

	if self:GetObjectType() ~= 'Texture' then
		local model = self:GetModel()
		local rotation = portrait.rotation or 0
		local camDistanceScale = portrait.camDistanceScale or 1
		local xOffset, yOffset = (portrait.xOffset or 0), (portrait.yOffset or 0)

		if model and model.find and model:find("worgenmale") then
			self:SetCamera(1)
		end

		if self:GetFacing() ~= (rotation / 60) then
			self:SetFacing(rotation / 60)
		end

		self:SetCamDistanceScale(camDistanceScale)
		self:SetPosition(0, xOffset, yOffset)
	end
end

