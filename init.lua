require('_init.utility')
require('_init.enum.RF_Globals')
SRP = require('_init.serpent')

-- daylight saving time used
USE_DST = false

local ver = Sirin.getZoneVersion()

if ver == 3 then
	SERVER_AOP = true
elseif ver == 2 then
	SERVER_2232 = true
end
