local Pong = {}

local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

local secrets = require(ServerStorage.Storage.Modules.secrets)

local PROXY_URL = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/proxy/discord"

function Pong:__Push(Template)
	local RESPONSE_DATA = {
		["webhookURL"] = secrets["NS_DISCORD_PING_WEBHOOK"],
		["webhookPayload"] = Http:JSONEncode(Template),
	}

	local response = Http:PostAsync(
		PROXY_URL,
		Http:JSONEncode(RESPONSE_DATA),
		Enum.HttpContentType.ApplicationJson,
		false,
		{
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		}
	)
	response = Http:JSONDecode(response)

	if response and response.status ~= "ok" then
		return true, response
	end

	return false
end

-- Returns a tuple, first boolean representing the success of the operation and second the error response if there is any.
function Pong:Send(options: { [string]: any })
	local TEMPLATE = {
		["embeds"] = {
			{
				["title"] = "Pong!",
				["description"] = ("Pinged from CTXE **%s**!"):format(options.CTXE.Name),
				["footer"] = {
					["text"] = options.Job,
				},
			},
		},
	}

	return Pong:__Push(TEMPLATE)
end

return Pong
