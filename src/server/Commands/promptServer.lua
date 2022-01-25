local Market = game:GetService("MarketplaceService")

return function(_, Player, AssetNumber)
	local Success, Error = pcall(Market.PromptPurchase, Market, Player, AssetNumber)

	return if Success then "Prompted " .. Player.Name .. " with asset." else "Error: " .. Error
end
