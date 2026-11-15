local self = require('openmw.self')
local core = require('openmw.core')
local Item = require("openmw.types").Item

local lastOnActiveTimestamp = 0

local function onInit(dt)
    lastOnActiveTimestamp = dt.tm or 0
end

local function onInactive()
    if not self.cell then return end
    core.sendGlobalEvent("advWMap_tracking:objectInactive", {self, self.id, self.recordId, not self.cell.isExterior and self.cell.id or nil})
    lastOnActiveTimestamp = 0
end

local function onActivated()
    local object = self.object
    if object:isValid() then
        if Item.objectIsInstance(self) then
            core.sendGlobalEvent("advWMap_tracking:objectInactive",
                {object, object.id, object.recordId, not object.cell.isExterior and object.cell.id or nil})
        else
            core.sendGlobalEvent("advWMap_tracking:checkObjectStatus",
                {object, object.id, object.recordId, not object.cell.isExterior and object.cell.id or nil})
        end
        lastOnActiveTimestamp = 0
    end
end

local function onActive()
    if core.getRealTime() - lastOnActiveTimestamp > 0.5 then
        core.sendGlobalEvent("advWMap_tracking:objectActive", self.object)
    end
end


return {
    engineHandlers = {
        onInit = onInit,
        onInactive = onInactive,
        onActivated = onActivated,
        onActive = onActive,
    },
}