local Debug = {}
local aux_util = require("openmw_aux.util")

local debugStart = "[CurableCritters] | "

Debug.log = function (data)
    -- make this a proper function at some point
    print(debugStart .. aux_util.deepToString(data))
end

return Debug