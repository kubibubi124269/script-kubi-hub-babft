return function(M)
 local L={};L.__index=L
 local function create(class,props,parent)
  local o=Instance.new(class);for k,v in pairs(props)do o[k]=v end;o.Parent=parent;return o
 end
 local function corner(o,r)create('UICorner',{CornerRadius=UDim.new(0,r)},o)end
 function L.new(language)
  local player=game:GetService('Players').LocalPlayer;assert(player,'KUBI HUB requires a Roblox client.')
  local pg=player:WaitForChild('PlayerGui',10);assert(pg,'Missing PlayerGui.')
  local self=setmetatable({alive=true,connections={}},L);self.runtime=M.Runtime.new(os.clock,function(_,e)warn(e)end)
  local old=pg:FindFirstChild('KubiHubGameChooser');if old then old:Destroy()end
  self.gui=create('ScreenGui',{Name='KubiHubGameChooser',ResetOnSpawn=false,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg);self.runtime:own(self.gui)
  self.frame=create('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.9,.85),BackgroundColor3=Color3.fromRGB(15,19,30),BorderSizePixel=0},self.gui)
  create('UISizeConstraint',{MaxSize=Vector2.new(440,465)},self.frame);corner(self.frame,14)
  local close=create('TextButton',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-34,0,5),Text='×',TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=3},self.frame)
  self.runtime:connect(close.Activated,function()self:unload()end,'Launcher')
  create('TextLabel',{Size=UDim2.new(1,-60,0,36),Position=UDim2.fromOffset(16,10),BackgroundTransparency=1,TextWrapped=true,Text='KUBI HUB DELUXE 7.0',TextColor3=Color3.fromRGB(235,240,255),TextSize=17,Font=Enum.Font.GothamBold},self.frame)
  self:show(M.Locale.valid(language) and 'games' or 'languages',M.Locale.valid(language) and language or nil)
  return self
 end
 function L:button(id,text,fn)
  self.order+=1
  local b=create('TextButton',{Name=id,Size=UDim2.new(1,-4,0,39),LayoutOrder=self.order,Text=text,BackgroundColor3=Color3.fromRGB(65,110,220),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=14,TextWrapped=true,BorderSizePixel=0},self.body)
  corner(b,8);self.connections[#self.connections+1]=self.runtime:connect(b.Activated,fn,'Launcher')
 end
 function L:show(screen,language)
  for _,c in ipairs(self.connections)do self.runtime:disconnect(c)end;table.clear(self.connections)
  if self.body then self.body:Destroy()end
  self.screen=screen;self.language=language;self.order=0
  local function t(text)return M.Locale.text(language,text)end
  self.body=create('ScrollingFrame',{Position=UDim2.fromOffset(15,52),Size=UDim2.new(1,-30,1,-65),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3},self.frame)
  create('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},self.body)
  local function label(text,height)
   self.order+=1;return create('TextLabel',{Size=UDim2.new(1,-5,0,height),LayoutOrder=self.order,BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(180,195,220),TextWrapped=true,TextSize=14,Font=Enum.Font.Gotham},self.body)
  end
  if screen=='languages' then
   self.status=label('Wybierz język / Choose a language',30)
   for _,code in ipairs(M.Locale.codes)do self:button('Language_'..code,M.Locale.names[code],function()self:show('community',code)end)end
  elseif screen=='community' then
   self.status=label(t('Społeczność KUBI HUB'),30)
   label(t('Dołącz na Discordzie lub zasubskrybuj kanał na YouTube. Kod PRO znajdziesz u twórcy.'),60)
   for _,row in ipairs(M.CommunityLinks.links)do
    self:button(row[1],t(row[2]),function()
     local copied=M.CommunityLinks.copy(row[3])
     self.status.Text=copied and t('Skopiowano link.') or t('Społeczność KUBI HUB')
    end)
    self.order+=1
    create('TextBox',{Name=row[1]..'URL',Size=UDim2.new(1,-5,0,28),LayoutOrder=self.order,Text=row[3],TextEditable=false,ClearTextOnFocus=false,BackgroundTransparency=1,TextColor3=Color3.fromRGB(180,195,220),TextSize=11,TextScaled=true,Font=Enum.Font.Gotham},self.body)
   end
   self:button('Continue',t('Dalej do gier'),function()self:show('games',language)end)
  else
   local detected=M.Games.detect(game.PlaceId,game.GameId)
   self.status=label(detected and t('Wykryto')..': '..M.Games.items[detected].name or t('Wybierz grę'),35)
   for _,id in ipairs({'BABFT','MM2','BRAINROT','BIKE','UNIVERSAL'})do
    self:button(id,M.Games.items[id].name,function()
     local ok,err=self:choose(id);if not ok then self.status.Text=err;self.status.TextColor3=Color3.fromRGB(255,125,145)end
    end)
   end
   self:button('ChangeLanguage',t('Zmień język'),function()self:show('languages')end)
  end
 end
 function L.back(app)
  local language=app.language;app:unload();_G.KubiHubRuntime=L.new(language)
 end
 function L:choose(id)
  if not self.alive then return false,'Wybór został już zamknięty.' end
  if self.launching then return false,'Trwa otwieranie wybranego huba.' end
  local allowed,reason=M.Games.canLaunch(id,game.PlaceId,game.GameId,game:GetService('RunService'):IsStudio())
  if not allowed then return false,reason end
  if self.screen~='games' then return false,M.Locale.text(self.language,'Wybierz język')end
  self.launching=true;local partial
  local function creating(app)partial=app;app.language=self.language end
  local apps={BABFT=M.Application,MM2=M.MM2App,BRAINROT=M.BrainrotApp,BIKE=M.BikeApp,UNIVERSAL=M.UniversalApp}
  local ok,app=xpcall(function()return apps[id].new(creating)end,function(e)return tostring(e)..'\n'..debug.traceback()end)
  self.launching=false
  if not ok then if partial then partial.alive=false;partial.runtime:close()end;return false,app end
  self:unload();_G.KubiHubRuntime=app;return true,app
 end
 function L:unload()if not self.alive then return end;self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end end
 return L
end
