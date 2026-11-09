return function(M)
 local A={};A.__index=A;A.run=M.Application.run
 local N={order={'STEAL','QUICK','SETTINGS'},titles={STEAL='AutoSteal',QUICK='Narzędzia',SETTINGS='Ustawienia'},matches=M.Navigation.matches}
 function N.resolve(id)return id=='HOME' and 'STEAL' or id=='DEBUG' and 'SETTINGS' or id end
 function N.rank(id)return id=='STEAL' and 1 or id=='QUICK' and 2 or 3 end

 local function normalize(text)
  return (text:lower():gsub('%s+',' '):match('^%s*(.-)%s*$'))
 end
 local function isSteal(prompt)
  local action=normalize(prompt.ActionText)
  local object=normalize(prompt.ObjectText)
  return action=='steal' or action=='ukradnij' or action=='voler' or action=='roubar' or action=='robar'
   or (object~='' and action=='steal '..object)
 end
 local function promptPosition(prompt)
  local parent=prompt.Parent
  if not parent then return nil end
  if parent:IsA('Attachment') then return parent.WorldPosition end
  if parent:IsA('BasePart') then return parent.Position end
  if parent:IsA('Model') and parent.PrimaryPart then return parent.PrimaryPart.Position end
 end
 local function character(player)
  local model=player.Character
  local humanoid=model and model:FindFirstChildOfClass('Humanoid')
  local root=model and model:FindFirstChild('HumanoidRootPart')
  if humanoid and humanoid.Health>0 and root and root:IsA('BasePart') then return model,root end
 end

 function A.new(onCreating)
  local self=setmetatable({alive=true,mode='BRAINROT',navigation=N,clock=os.clock,shown={},enabled=false,nextAt=0,sequence=0},A)
  self.player=game:GetService('Players').LocalPlayer;assert(self.player,'Brak LocalPlayer.')
  assert(self.player:WaitForChild('PlayerGui',10),'Brak PlayerGui.')
  self.input=game:GetService('UserInputService')
  self.config={data=M.Util.copy(M.Config.defaults)}
  self.log=M.Log.new(function()return os.date('%H:%M:%S')end)
  self.runtime=M.Runtime.new(self.clock,function(module,err)self.log:error(module,err);if self.ui then self.ui:toast(module,err,true)end end)
  if onCreating then onCreating(self)end
  local prompts=game:GetService('ProximityPromptService')
  local ui=M.UI.new(self);self.ui=ui
  ui.title.Text='KUBI HUB  /  STEAL A BRAINROT'
  ui.subtitle.Text='V'..M.Version.current..'  •  AUTOSTEAL'
  local home=ui:card(ui:page('STEAL'),'AutoSteal w zasięgu')
  ui:label(home,'Włącz i podejdź do Brainrota, aż gra pokaże „Steal”. Hub przytrzyma przycisk przez czas wymagany przez grę. Zanieś Brainrota do bazy samodzielnie.')
  ui:feature(home,'AutoSteal',function()return self.enabled end,function()self:setEnabled(not self.enabled)end,function(panel)
   ui:label(panel,'Po otwarciu huba odejdź od celu i podejdź ponownie, jeśli napis był już widoczny. Hub podejmuje jedną próbę dla danego wyświetlenia przycisku. Po przerwie wybiera najbliższą dostępną akcję.')
  end)
  self.state=ui:label(home,'AutoSteal wyłączony.')
  self.last=ui:label(home,'Ostatnia próba: —')
  ui:button(home,'STOP / wyłącz AutoSteal',function()self:setEnabled(false)end)
  local settings=ui:card(ui:page('SETTINGS'),'Sesja')
  ui:button(settings,'Wróć do wyboru huba',function()self:unload();_G.KubiHubRuntime=M.Launcher.new()end)
  ui:button(settings,'Wyłącz hub',function()self:unload()end)
  ui.statusBody=ui:card(ui:page('SETTINGS'),'Ostatni komunikat')
  ui.statusInfo=ui:label(ui.statusBody,'Gotowy.')
  M.QuickTools(self);ui:show('STEAL')

  self.runtime:connect(prompts.PromptShown,function(prompt)
   if not self.shown[prompt] and isSteal(prompt) then
    self.sequence+=1
    self.shown[prompt]={order=self.sequence}
   end
  end,'AutoSteal')
  self.runtime:connect(prompts.PromptHidden,function(prompt)
   self.shown[prompt]=nil
   if self.active and self.active.prompt==prompt then self:finish(self.clock(),'Anulowano: akcja zniknęła.')end
  end,'AutoSteal')
  self.runtime:connect(prompts.PromptTriggered,function(prompt,player)
   local active=self.active
   if active and active.prompt==prompt and player==self.player then active.triggered=true end
  end,'AutoSteal')
  self.runtime:connect(self.player.CharacterAdded,function()self:setEnabled(false,'Odrodzenie. Włącz AutoSteal ponownie.')end,'AutoSteal')
  self.runtime:connect(game:GetService('RunService').Heartbeat,function(dt)self.runtime:tick(dt)end,'Brainrot')
  self.runtime:schedule('AutoSteal',.05,function(_,now)
   local ok,err=pcall(self.update,self,now)
   if not ok then self:setEnabled(false,'AutoSteal przerwany przez błąd.');self.runtime.errors('AutoSteal',err)end
  end)
  self.runtime:schedule('BrainrotUI',.1,function()ui:tick()end)
  return self
 end

 function A:distance(prompt,model,root)
  if not prompt.Enabled or not isSteal(prompt) or not prompt:IsDescendantOf(workspace) or prompt:IsDescendantOf(model) then return nil end
  local position=promptPosition(prompt)
  local distance=position and (position-root.Position).Magnitude
  if distance and distance<=prompt.MaxActivationDistance then return distance end
 end

 function A:finish(now,result)
  local active=self.active
  if not active then return end
  self.active=nil
  self.nextAt=now+1.25
  local ok,err=pcall(function()active.prompt:InputHoldEnd()end)
  if not ok then
   self.enabled=false
   self.state.Text='AutoSteal wyłączony po błędzie interakcji.'
   self.last.Text='Ostatnia próba: nie udało się zwolnić przycisku.'
   self.ui:refreshFeatures()
   self.runtime.errors('AutoSteal',err)
   return
  end
  if active.triggered then result='Zarejestrowano interakcję. Sprawdź, czy niesiesz Brainrota.' end
  self.last.Text='Ostatnia próba: '..result
  if self.enabled then self.state.Text='Krótka przerwa przed kolejną próbą.' end
 end

 function A:setEnabled(value,reason)
  self.enabled=value
  if value then
   self.state.Text='Czekam na „Steal” w zasięgu.'
  else
   self:finish(self.clock(),'Przerwano ręcznie.')
   self.state.Text=reason or 'AutoSteal wyłączony.'
  end
  self.ui:refreshFeatures()
 end

 function A:update(now)
  if not self.enabled then return end
  local model,root=character(self.player)
  if not root then
   self:setEnabled(false,'Brak aktywnej postaci. Włącz AutoSteal ponownie po odrodzeniu.')
   return
  end
  local active=self.active
  if active then
   if active.character~=model or not self.shown[active.prompt] or not self:distance(active.prompt,model,root) then
    self:finish(now,'Anulowano: akcja niedostępna lub poza zasięgiem.')
   elseif now>=active.untilAt then
    self:finish(now,'Zakończono przytrzymanie. Brak sygnału interakcji.')
   end
   return
  end
  if now<self.nextAt then return end
  local closest,record,best
  for prompt,row in pairs(self.shown) do
   if not prompt:IsDescendantOf(workspace) then
    self.shown[prompt]=nil
   elseif not row.attempted then
    local distance=self:distance(prompt,model,root)
    if distance and (not best or distance<best or distance==best and row.order<record.order) then closest,record,best=prompt,row,distance end
   end
  end
  if not closest then self.state.Text='Czekam na nowe „Steal” w zasięgu.';return end
  record.attempted=true
  local duration=closest.HoldDuration
  if duration<0 or duration>60 or duration~=duration then self.last.Text='Ostatnia próba: nieobsługiwany czas interakcji.';return end
  self.active={prompt=closest,character=model,untilAt=now+duration+.1}
  self.state.Text='Przytrzymuję „Steal”…'
  local ok,err=pcall(function()closest:InputHoldBegin()end)
  if not ok then self:setEnabled(false,'Gra nie przyjęła próby AutoSteal.');self.runtime.errors('AutoSteal',err)end
 end

 function A:stopAll()self:setEnabled(false);if self.quickTools then self.quickTools:reset()end end
 function A:unload()
  if not self.alive then return end
  self:stopAll();self.alive=false;self.runtime:close();table.clear(self.shown)
  if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end
 end
 return A
end
