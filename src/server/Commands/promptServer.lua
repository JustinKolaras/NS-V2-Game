local Market = game:GetService("MarketplaceService")

return function(_, Player, AssetNumber)
	local Success, Error = pcall(Market.PromptPurchase, Market, Player, AssetNumber)

	return Success and "Prompted " .. Player.Name .. " with asset." or "Error: " .. Error
end
