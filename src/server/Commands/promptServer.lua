local Market = game:GetService("MarketplaceService")

return function (Context, Player, AssetNum)
	
	local succ,errorMsg = pcall(Market.PromptPurchase, Market, Player, AssetNum)
	
	if succ then
		return "Prompted "..Player.Name.." with asset."
	else
		return "Error: "..errorMsg
	end
	
end