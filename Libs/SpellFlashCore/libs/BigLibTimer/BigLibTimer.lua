
local MajorVersion = "BigLibTimer6"
local BigLibTimer = LibStub:NewLibrary(MajorVersion, tonumber("20230411150302") or tonumber(date("%Y%m%d%H%M%S")))
if not BigLibTimer then return end

BigLibTimer.API = BigLibTimer.API or {}

function BigLibTimer:Register(handler)
	if type(handler) ~= "table" then
		handler = {}
	elseif handler[MajorVersion] then
		return
	end
	handler[MajorVersion] = {}
	handler[MajorVersion].RECYCLE_TABLES = setmetatable({}, {__mode = "k"})
	handler[MajorVersion].TimerFrame = CreateFrame("Frame")
	handler[MajorVersion].TimerFrame:Hide()
	handler[MajorVersion].TIMER = {}
	handler[MajorVersion].OnUpdate = function() BigLibTimer.OnUpdate(handler) end
	handler[MajorVersion].TimerFrame:SetScript("OnUpdate", handler[MajorVersion].OnUpdate)
	for key in pairs(BigLibTimer.API) do
		handler[key] = function(...) return BigLibTimer.API[key](...) end
	end
	return handler
end

function BigLibTimer.OnUpdate(handler)
	local TIMER = handler[MajorVersion].TIMER
	if next(TIMER) then
		if not handler[MajorVersion].Running then
			handler[MajorVersion].Running = 1
			for Name in pairs(TIMER) do
				if TIMER and TIMER[Name] and not TIMER[Name].Running and TIMER[Name].Seconds <= GetTime() then
					if TIMER[Name].Function then
						TIMER[Name].Function(unpack(TIMER[Name].Args))
						if TIMER and TIMER[Name] and TIMER[Name].Seconds <= GetTime() then
							if TIMER[Name].RepeatSeconds > 0 then
								TIMER[Name].Seconds = GetTime() + TIMER[Name].RepeatSeconds
							else
								TIMER[Name].Args = handler:RecycleTable(TIMER[Name].Args)
								TIMER[Name] = handler:RecycleTable(TIMER[Name])
							end
						end
					elseif TIMER[Name].RepeatSeconds > 0 then
						TIMER[Name].Seconds = GetTime() + TIMER[Name].RepeatSeconds
					else
						TIMER[Name].Args = handler:RecycleTable(TIMER[Name].Args)
						TIMER[Name] = handler:RecycleTable(TIMER[Name])
					end
				end
			end
			if not next(TIMER) then
				handler[MajorVersion].TimerFrame:Hide()
			end
			handler[MajorVersion].Running = nil
		end
	elseif not handler[MajorVersion].Running then
		handler[MajorVersion].TimerFrame:Hide()
	end
end

function BigLibTimer.API:SetTimer(Name, Seconds, RepeatSeconds, Function, ...)
	local TIMER = self[MajorVersion].TIMER
	if type(Name) == "string" and TIMER then
		if TIMER[Name] then
			TIMER[Name].Args = self:RecycleTable(TIMER[Name].Args)
		end
		TIMER[Name] = self:CreateTable(TIMER[Name])
		TIMER[Name].Running = 1
		if type(Seconds) == "number" and Seconds > 0 then
			TIMER[Name].Seconds = GetTime() + Seconds
		else
			TIMER[Name].Seconds = 0
		end
		if type(RepeatSeconds) == "number" and RepeatSeconds > 0 then
			TIMER[Name].RepeatSeconds = RepeatSeconds
		else
			TIMER[Name].RepeatSeconds = 0
		end
		if type(Function) == "function" then
			TIMER[Name].Function = Function
			TIMER[Name].Args = self:CreateTable(TIMER[Name].Args)
			local n = select("#", ...)
			if n > 0 then
				for i = 1, n do
					TIMER[Name].Args[i] = select(i, ...)
				end
			end
		end
		if TIMER[Name].Seconds == 0 and TIMER[Name].Function then
			Function(...)
			if TIMER and TIMER[Name] and TIMER[Name].Seconds <= GetTime() then
				if TIMER[Name].RepeatSeconds > 0 then
					TIMER[Name].Seconds = GetTime() + TIMER[Name].RepeatSeconds
				else
					TIMER[Name].Args = self:RecycleTable(TIMER[Name].Args)
					TIMER[Name] = self:RecycleTable(TIMER[Name])
				end
			end
		end
		if TIMER and TIMER[Name] then
			TIMER[Name].Running = nil
			self[MajorVersion].TimerFrame:Show()
		end
	end
end

function BigLibTimer.API:ReplaceTimer(Name, Seconds, RepeatSeconds, Function, ...)
	local TIMER = self[MajorVersion].TIMER
	if type(Name) == "string" and TIMER[Name] then
		if type(Seconds) == "number" and Seconds > 0 then
			TIMER[Name].Seconds = GetTime() + Seconds
		elseif Seconds ~= nil then
			TIMER[Name].Seconds = 0
		end
		if type(RepeatSeconds) == "number" and RepeatSeconds > 0 then
			TIMER[Name].RepeatSeconds = RepeatSeconds
		elseif RepeatSeconds ~= nil then
			TIMER[Name].RepeatSeconds = 0
		end
		if type(Function) == "function" then
			TIMER[Name].Function = Function
			TIMER[Name].Args = self:CreateTable(TIMER[Name].Args)
			local n = select("#", ...)
			if n > 0 then
				for i = 1, n do
					TIMER[Name].Args[i] = select(i, ...)
				end
			end
		elseif Function ~= nil then
			TIMER[Name].Function = nil
		end
		return true
	end
	return false
end

function BigLibTimer.API:ClearTimer(Name, Search)
	local TIMER = self[MajorVersion].TIMER
	local found = nil
	if type(Name) == "string" then
		if Search then
			for key in pairs(TIMER) do
				if key:match(Name) and ( TIMER[key].RepeatSeconds > 0 or TIMER[key].Seconds - GetTime() > 0 ) then
					TIMER[key].Args = self:RecycleTable(TIMER[key].Args)
					TIMER[key] = self:RecycleTable(TIMER[key])
					found = true
				end
			end
		elseif TIMER[Name] and ( TIMER[Name].RepeatSeconds > 0 or TIMER[Name].Seconds - GetTime() > 0 ) then
			TIMER[Name].Args = self:RecycleTable(TIMER[Name].Args)
			TIMER[Name] = self:RecycleTable(TIMER[Name])
			return true
		end
	end
	return found
end

function BigLibTimer.API:ClearAllTimers()
	wipe(self[MajorVersion].TIMER)
end

function BigLibTimer.API:IsTimer(Name, Search)
	local TIMER = self[MajorVersion].TIMER
	if type(Name) == "string" then
		if Search then
			for key in pairs(TIMER) do
				if key:match(Name) and ( TIMER[key].RepeatSeconds > 0 or TIMER[key].Seconds - GetTime() > 0 ) then
					return true
				end
			end
		elseif TIMER[Name] and ( TIMER[Name].RepeatSeconds > 0 or TIMER[Name].Seconds - GetTime() > 0 ) then
			return true
		end
	end
	return false
end

function BigLibTimer.API:IsRepeatTimer(Name, Search)
	local TIMER = self[MajorVersion].TIMER
	if type(Name) == "string" then
		if Search then
			for key in pairs(TIMER) do
				if key:match(Name) and TIMER[key].RepeatSeconds > 0 then
					return true
				end
			end
		elseif TIMER[Name] and TIMER[Name].RepeatSeconds > 0 then
			return true
		end
	end
	return false
end

function BigLibTimer.API:GetTimer(Name)
	local TIMER = self[MajorVersion].TIMER
	if type(Name) == "string" and TIMER[Name] then
		local TimeRemaining = TIMER[Name].Seconds - GetTime()
		if TimeRemaining > 0 then
			return TimeRemaining
		end
	end
	return 0
end

function BigLibTimer.API:CreateTable(Table, All)
	if type(Table) == "table" and type(Table[0]) ~= "userdata" then
		if All then
			self:RecycleTable(Table, All)
		else
			wipe(Table)
			return Table
		end
	end
	local t = next(self[MajorVersion].RECYCLE_TABLES)
	if t then
		self[MajorVersion].RECYCLE_TABLES[t] = nil
		if next(t) then
			return self:CreateTable()
		end
		return t
	end
	return {}
end

function BigLibTimer.RecycleAllTables(self, Table, CompareList)
	if not CompareList[Table] then
		CompareList[Table] = 1
		for k, v in pairs(Table) do
			if type(v) == "table" and type(v[0]) ~= "userdata" then
				BigLibTimer.RecycleAllTables(self, v, CompareList)
			end
			if type(k) == "table" and type(k[0]) ~= "userdata" then
				BigLibTimer.RecycleAllTables(self, k, CompareList)
			end
		end
		self:RecycleTable(Table)
	end
end

function BigLibTimer.API:RecycleTable(Table, All)
	if type(Table) == "table" and type(Table[0]) ~= "userdata" then
		if All then
			local CompareList = self:CreateTable()
			BigLibTimer.RecycleAllTables(self, Table, CompareList)
			self:RecycleTable(CompareList)
		else
			wipe(Table)
			self[MajorVersion].RECYCLE_TABLES[Table] = 1
		end
	end
	return nil
end
