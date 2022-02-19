local TweenV2 = require(game.ReplicatedStorage.Shared.TweenV2)
local Camera = workspace.CurrentCamera
local Start, End = workspace:WaitForChild("CAMERA_START"), workspace:WaitForChild("CAMERA_END")

Camera.CameraType = Enum.CameraType.Scriptable

task.wait(1)

Camera.CFrame = Start.CFrame

task.delay(3, function()
	TweenV2
		:Now({
			Object = Camera,
			Info = TweenInfo.new(60, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, math.huge, true, 3),
			Properties = { CFrame = End.CFrame },
		})
		:catch(error)
		:andThenCall(print, "Ran")
end)
