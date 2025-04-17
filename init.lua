require('_system.utility.utility')
SRP = require('_system.utility.serpent')

-- daylight saving time used
USE_DST = false

local ver = Sirin.getZoneVersion()

if ver == 3 then
	SERVER_AOP = true
elseif ver == 2 then
	SERVER_2232 = true
end
