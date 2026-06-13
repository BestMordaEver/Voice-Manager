-- clock-driven telemetry flush; pushes collected metrics to vmagent every tick

local telemetry = require "telemetry/init"

return function ()
	telemetry.flush()
end
