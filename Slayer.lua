if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then return end

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

getgenv().Settings = {JoinTeam = true, Team = "Marine"}
getgenv().AutoStoreFruit = true
getgenv().Webhook = true
getgenv().WebhookURL = ""

loadstring(game:HttpGet("https://raw.githubusercontent.com/FJN19-dev/Slayer/refs/heads/main/FindFruits.lua"))()
