local TweenService = game:GetService("TweenService")

local random = Random.new(1234)

task.spawn(function() 
	while true do
		local tween1 = TweenService:Create(script.Parent, TweenInfo.new(random:NextNumber(60, 90), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), 
			{ Position = UDim2.fromScale(random:NextNumber(0.25, 0.75), random:NextNumber(0.25, 0.75)) })
		tween1:Play()
		tween1.Completed:Wait()
	end
end)

task.spawn(function() 
	while true do
		local tween1 = TweenService:Create(script.Parent, TweenInfo.new(random:NextNumber(60, 90), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
			{ ImageColor3 = Color3.fromHSV(random:NextNumber(0,1),1,1) })
		tween1:Play()
		tween1.Completed:Wait()
	end
end)
