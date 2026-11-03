return function(M)
 local L={};L.__index=L
 function L.new()
  local player=game:GetService('Players').LocalPlayer;assert(player,'KUBI HUB wymaga klienta Roblox.');local pg=player:WaitForChild('PlayerGui',10);assert(pg,'Brak PlayerGui.')
  local self=setmetatable({alive=true},L);self.runtime=M.Runtime.new(os.clock,function(_,e)warn(e)end)
  local old=pg:FindFirstChild('KubiHubGameChooser');if old then old:Destroy() end
  local function create(class,props,parent)local o=Instance.new(class);for k,v in pairs(props) do o[k]=v end;o.Parent=parent;return o end
  self.gui=create('ScreenGui',{Name='KubiHubGameChooser',ResetOnSpawn=false,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg);self.runtime:own(self.gui)
  self.frame=create('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.9,0,0,295),BackgroundColor3=Color3.fromRGB(15,19,30),BorderSizePixel=0},self.gui)
  local close=create('TextButton',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-36,0,5),Text='×',TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=3},self.frame);self.runtime:connect(close.Activated,function()self:unload()end,'Launcher')
  create('UISizeConstraint',{MaxSize=Vector2.new(440,295),MinSize=Vector2.new(260,295)},self.frame);create('UICorner',{CornerRadius=UDim.new(0,14)},self.frame)
  create('TextLabel',{Size=UDim2.new(1,-32,0,36),Position=UDim2.fromOffset(16,16),BackgroundTransparency=1,Text='KUBI HUB  /  V'..M.Version.current,TextColor3=Color3.fromRGB(235,240,255),TextSize=21,Font=Enum.Font.GothamBold},self.frame)
  local detected=M.Games.detect(game.PlaceId,game.GameId)
  self.status=create('TextLabel',{Size=UDim2.new(1,-32,0,55),Position=UDim2.fromOffset(16,57),BackgroundTransparency=1,Text=detected and ('Wykryto: '..M.Games.items[detected].name..'\nWybierz swój hub.') or 'Wybierz grę. Otwórz ją najpierw w Robloxie.',TextColor3=Color3.fromRGB(170,185,210),TextWrapped=true,TextSize=13,Font=Enum.Font.Gotham},self.frame)
  for index,id in ipairs({'BABFT','MM2'}) do
   local b=create('TextButton',{Name=id,Size=UDim2.new(1,-40,0,54),Position=UDim2.fromOffset(20,120+(index-1)*66),Text=id=='BABFT' and 'BABFT — Builder i autofarma' or 'MM2 — Farm, Combat i Player',BackgroundColor3=Color3.fromRGB(65,110,220),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=15,TextWrapped=true,BorderSizePixel=0},self.frame);create('UICorner',{CornerRadius=UDim.new(0,9)},b)
   self.runtime:connect(b.Activated,function()local ok,err=self:choose(id);if not ok then self.status.Text=err;self.status.TextColor3=Color3.fromRGB(255,125,145) end end,'Launcher')
  end
  return self
 end
 function L:choose(id)
  if not self.alive then return false,'Wybór został już zamknięty.' end
  if self.launching then return false,'Trwa otwieranie wybranego huba.' end
  local allowed,reason=M.Games.canLaunch(id,game.PlaceId,game.GameId,game:GetService('RunService'):IsStudio());if not allowed then return false,reason end
  self.launching=true;local partial
  local function creating(app)partial=app end
  local ok,app=xpcall(function()return id=='BABFT' and M.Application.new(creating) or M.MM2App.new(creating)end,function(e)return tostring(e)..'\n'..debug.traceback()end)
  self.launching=false
  if not ok then if partial then partial.alive=false;partial.runtime:close() end;return false,app end
  self:unload();_G.KubiHubRuntime=app;return true,app
 end
 function L:unload()if not self.alive then return end;self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end end
 return L
end
