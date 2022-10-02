Core = nil

-- GETTING FRAMEWORK OBJECT
CreateThread(function()
	if cfg.framework == 'esx' then
		TriggerEvent('esx:getSharedObject', function(obj)
            Core = obj
        end)
	end
	if cfg.framework == 'qbcore' then
		Core = exports['qb-core']:GetCoreObject()
	end
end)