return function(M)
 local UI={};UI.__index=UI
 function UI.new(app)
  local self=setmetatable({app=app,pages={},buttons={},order=0,listConnections={},accentItems={},cards={},cardBodies={},firstCard={},refreshers={}},UI)
  self.palette={bg=Color3.fromRGB(12,15,24),panel=Color3.fromRGB(20,25,38),card=Color3.fromRGB(27,33,49),text=Color3.fromRGB(235,239,250),muted=Color3.fromRGB(150,165,190),accent=Color3.fromRGB(83,133,247),red=Color3.fromRGB(244,95,120)}
  local old=app.player.PlayerGui:FindFirstChild('KubiHubUltimateV5');if old then old:Destroy() end
  self.gui=self:create('ScreenGui',{Name='KubiHubUltimateV5',ResetOnSpawn=false,DisplayOrder=95,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},app.player.PlayerGui);app.runtime:own(self.gui)
  self.frame=self:create('Frame',{Name='Window',BackgroundColor3=self.palette.bg,BorderSizePixel=0,Active=true},self.gui);self:corner(self.frame,14)
  self.header=self:create('Frame',{Size=UDim2.new(1,0,0,65),BackgroundColor3=self.palette.panel,BorderSizePixel=0,Active=true},self.frame);self:corner(self.header,14)
  self:create('TextLabel',{Position=UDim2.fromOffset(18,8),Size=UDim2.new(1,-120,0,25),BackgroundTransparency=1,Text='KUBI HUB  /  ULTIMATE',TextColor3=self.palette.text,TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},self.header)
  self.subtitle=self:create('TextLabel',{Position=UDim2.fromOffset(18,36),Size=UDim2.new(1,-120,0,18),BackgroundTransparency=1,Text='V'..M.Version.current..'  •  ASYSTENT BUDOWANIA',TextColor3=self.palette.muted,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},self.header)
  self.nav=self:create('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.XY},self.frame)
  self.navLayout=self:create('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},self.nav)
  self.content=self:create('Frame',{BackgroundTransparency=1},self.frame)
  self.search=self:create('TextBox',{PlaceholderText='Szukaj funkcji lub schematu…',Text='',ClearTextOnFocus=false,BackgroundColor3=self.palette.card,TextColor3=self.palette.text,PlaceholderColor3=self.palette.muted,TextSize=13,Font=Enum.Font.Gotham,BorderSizePixel=0},self.frame);self:corner(self.search,8)
  self.results=self:create('ScrollingFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},self.content)
  self:create('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},self.results)
  self:bind(self.search:GetPropertyChangedSignal('Text'),function()self:searchCards()end)
  self.footer=self:create('TextButton',{Position=UDim2.new(0,14,1,-32),Size=UDim2.new(1,-28,0,24),Text='Gotowy. Prawy Ctrl: pokaż / ukryj.',TextColor3=self.palette.muted,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Font=Enum.Font.Gotham},self.frame)
  self:bind(self.footer.Activated,function()self:show('DEBUG')end)
  local function headerButton(text,x,fn)local b=self:create('TextButton',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,x,0,17),BackgroundColor3=self.palette.card,Text=text,TextColor3=self.palette.text,TextSize=17,Font=Enum.Font.GothamBold,BorderSizePixel=0},self.header);self:corner(b,7);self:bind(b.Activated,fn)end
  headerButton('−',-76,function()self:hide()end);headerButton('×',-40,function()app:stopAll();self:hide()end)
  self.bubble=self:create('TextButton',{Name='Reopen',Position=UDim2.new(0,10,.5,-24),Size=UDim2.fromOffset(48,48),Text='K',BackgroundColor3=self.palette.accent,TextColor3=Color3.new(1,1,1),TextSize=23,Font=Enum.Font.GothamBold,Visible=false,BorderSizePixel=0},self.gui);self:corner(self.bubble,12);self:bind(self.bubble.Activated,function()self.frame.Visible=true;self.bubble.Visible=false end)
  self.tooltip=self:create('TextLabel',{Size=UDim2.fromOffset(285,72),BackgroundColor3=self.palette.panel,TextColor3=self.palette.text,TextWrapped=true,TextSize=12,Font=Enum.Font.Gotham,Visible=false,ZIndex=90},self.gui);self:corner(self.tooltip,9)
  self.resize=self:create('TextButton',{Position=UDim2.new(1,-23,1,-23),Size=UDim2.fromOffset(20,20),Text='◢',TextColor3=self.palette.muted,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=15},self.frame)
  self:bind(self.header.InputBegan,function(input)if self:isPress(input) then self.drag={input=input,start=input.Position,position=self.frame.Position} end end)
  self:bind(self.resize.InputBegan,function(input)if self:isPress(input) then self.dragSize={input=input,start=input.Position,w=self.frame.AbsoluteSize.X,h=self.frame.AbsoluteSize.Y} end end)
  self:bind(app.input.InputChanged,function(input)
   if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
   if self.drag then local d=input.Position-self.drag.start;self.frame.Position=UDim2.new(self.drag.position.X.Scale,self.drag.position.X.Offset+d.X,self.drag.position.Y.Scale,self.drag.position.Y.Offset+d.Y)
   elseif self.dragSize then local d=input.Position-self.dragSize.start;app.config.data.ui.width=self.dragSize.w+d.X;app.config.data.ui.height=self.dragSize.h+d.Y;self:fit()
   elseif self.sliderDrag then self:setSliderFromInput(input.Position.X)
   elseif self.previewDrag then local d=input.Position-self.previewDrag;self.previewDrag=input.Position;app.preview:orbit(d.X*.5,-d.Y*.5) end
  end)
  self:bind(app.input.InputEnded,function(input)if self.drag and input==self.drag.input or self.dragSize and input==self.dragSize.input then self.drag=nil;self.dragSize=nil;self:rememberPosition();self:fit() end;if self:isPress(input) then self.sliderDrag=nil;self.previewDrag=nil end end)
  self:bind(app.input.InputBegan,function(input,processed)if input.KeyCode==Enum.KeyCode.RightControl and not app.input:GetFocusedTextBox() then self.frame.Visible=not self.frame.Visible;self.bubble.Visible=not self.frame.Visible end;if not processed and input.KeyCode==Enum.KeyCode.E then app:run('WORM',function()return app.adapter:rig('mouth')end) end end)
  local camera=workspace.CurrentCamera;if camera then self:bind(camera:GetPropertyChangedSignal('ViewportSize'),function()self:fit()end) end
  self:fit();return self
 end
 function UI:create(class,props,parent)
  local o=Instance.new(class);for k,v in pairs(props) do o[k]=v end;self.order=self.order+1;if o:IsA('GuiObject') then o.LayoutOrder=self.order end;o.Parent=parent;return o
 end
 function UI:bind(signal,fn,list)
  local c=self.app.runtime:connect(signal,fn,'GUI');if list then self.listConnections[#self.listConnections+1]=c end;return c
 end
 function UI:corner(o,r)self:create('UICorner',{CornerRadius=UDim.new(0,r)},o)end
 function UI:isPress(i)return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 function UI:rememberPosition()
  local c=workspace.CurrentCamera;if c then self.app.config.data.ui.x=math.clamp(self.frame.AbsolutePosition.X/c.ViewportSize.X,0,.95);self.app.config.data.ui.y=math.clamp(self.frame.AbsolutePosition.Y/c.ViewportSize.Y,0,.95) end
 end
 function UI:fit()
  local c=workspace.CurrentCamera;if not c then return end;local v=c.ViewportSize;local s=self.app.config.data.ui;local b=M.Layout.compute(v.X,v.Y,s.width,s.height,s.compact);self.layout=b
  self.frame.Size=UDim2.fromOffset(b.width,b.height);self.frame.Position=UDim2.fromOffset(math.clamp(s.x*v.X,4,math.max(4,v.X-b.width-4)),math.clamp(s.y*v.Y,4,math.max(4,v.Y-b.height-4)))
  self.nav.Position=UDim2.fromOffset(12,b.narrow and 76 or 80);self.nav.Size=b.narrow and UDim2.new(1,-24,0,34) or UDim2.new(0,155,1,-125);self.navLayout.FillDirection=b.narrow and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  for _,button in pairs(self.buttons) do button.Size=b.narrow and UDim2.fromOffset(112,32) or UDim2.new(1,-5,0,35) end
  self.search.Position=UDim2.fromOffset(b.contentX,b.contentY);self.search.Size=UDim2.fromOffset(b.contentWidth,32)
  self.content.Position=UDim2.fromOffset(b.contentX,b.contentY+42);self.content.Size=UDim2.fromOffset(b.contentWidth,math.max(40,b.contentHeight-42))
 end
 function UI:page(id,title)
  id=M.Navigation.resolve(id);title=M.Navigation.titles[id] or title
  if self.pages[id] then return self.pages[id] end
  local page=self:create('ScrollingFrame',{Name=id,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},self.content)
  self:create('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},page)
  self.pages[id]=page;self.buttons[id]=self:button(self.nav,title,function()self:show(id)end,nil,false);self.buttons[id].LayoutOrder=M.Navigation.rank(id);self:fit();return page
 end
 function UI:show(id)
  id=M.Navigation.resolve(id)
  if not self.pages[id] then return end
  if self.search.Text~='' then self.search.Text='' end;self.results.Visible=false
  self.current=id;for name,page in pairs(self.pages) do page.Visible=name==id;self.buttons[name].BackgroundColor3=name==id and self.palette.accent or self.palette.panel end
 end
 function UI:hide()self.frame.Visible=false;self.bubble.Visible=true;self.tooltip.Visible=false end
 function UI:label(parent,text,height)
  return self:create('TextLabel',{Size=UDim2.new(1,0,0,height or 35),BackgroundTransparency=1,Text=text,TextColor3=self.palette.text,TextWrapped=true,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},parent)
 end
 function UI:card(page,title,description)
  local card=self:create('Frame',{Size=UDim2.new(1,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=self.palette.card,BorderSizePixel=0},page);self:corner(card,11)
  self:create('UIPadding',{PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13),PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,12)},card);self:create('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},card)
  local heading=self:button(card,title,function()end)
  local body=self:create('Frame',{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},card)
  self:create('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},body)
  local record={outer=card,body=body,title=title,page=page.Name,terms=title..' '..(description or '')};self.cards[#self.cards+1]=record;self.cardBodies[body]=record
  local function open(value)body.Visible=value;heading.Text=(value and '▾  ' or '▸  ')..title end;record.open=open
  self:bind(heading.Activated,function()open(not body.Visible)end)
  open(not self.firstCard[page.Name]);self.firstCard[page.Name]=true
  if description then self:label(body,description,72) end
  record.result=self:button(self.results,(M.Navigation.titles[page.Name] or page.Name)..'  /  '..title,function()self:show(page.Name);open(true);task.defer(function()if self.app.alive then page.CanvasPosition=Vector2.new(0,math.max(0,card.AbsolutePosition.Y-page.AbsolutePosition.Y+page.CanvasPosition.Y)) end end)end)
  return body
 end
 function UI:searchCards()
  if not self.search then return end;local query=self.search.Text
  if query:match('^%s*$') then self.results.Visible=false;for id,page in pairs(self.pages) do page.Visible=id==self.current end;return end
  for _,page in pairs(self.pages) do page.Visible=false end;self.results.Visible=true
  for _,record in ipairs(self.cards) do record.result.Visible=M.Navigation.matches(query,record.terms) end
 end
 function UI:rememberTerm(parent,text)
  local at=parent;while at and at~=self.content do local r=self.cardBodies[at];if r then r.terms=r.terms..' '..tostring(text);return end;at=at.Parent end
 end
 function UI:button(parent,text,fn,tip,list)
  if not list then self:rememberTerm(parent,text) end
  local b=self:create('TextButton',{Size=UDim2.new(1,0,0,38),BackgroundColor3=self.palette.panel,Text=text,TextColor3=self.palette.text,TextSize=12,TextWrapped=true,Font=Enum.Font.GothamBold,BorderSizePixel=0},parent);self:corner(b,8)
  self:bind(b.Activated,function()self.app:run(self.current or 'GUI',fn)end,list)
  if tip then self:bind(b.MouseEnter,function()if self.app.config.data.ui.tooltips then self.tooltip.Text=tip;local p=self.app.input:GetMouseLocation();local v=workspace.CurrentCamera.ViewportSize;self.tooltip.Position=UDim2.fromOffset(math.clamp(p.X,0,math.max(0,v.X-290)),math.clamp(p.Y-82,0,math.max(0,v.Y-80)));self.tooltip.Visible=true end end,list);self:bind(b.MouseLeave,function()self.tooltip.Visible=false end,list) end
  return b
 end
 function UI:field(parent,title,initial,fn,multiline,get)
  self:rememberTerm(parent,title)
  self:label(parent,title,26)
  local box=self:create('TextBox',{Size=UDim2.new(1,0,0,multiline and 140 or 35),BackgroundColor3=self.palette.bg,BorderSizePixel=0,Text=tostring(initial or ''),PlaceholderText=title,TextColor3=self.palette.text,PlaceholderColor3=self.palette.muted,TextSize=12,Font=multiline and Enum.Font.Code or Enum.Font.Gotham,TextWrapped=true,ClearTextOnFocus=false,MultiLine=multiline==true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center},parent);self:corner(box,7)
  if fn then self:bind(box.FocusLost,function()self.app:run('GUI',function()local value,err=fn(box.Text);if value==false then if get then box.Text=tostring(get()) end;return false,err end;if value~=nil then box.Text=tostring(value) end end)end) end
  if get then local function refresh()box.Text=tostring(get())end;refresh();self.refreshers[#self.refreshers+1]=refresh end;return box
 end
 function UI:cycle(parent,title,values,get,set)
  local button
  button=self:button(parent,title..': '..tostring(get()),function()local at=1;for i,v in ipairs(values) do if v==get() then at=i%#values+1;break end end;local ok,err=set(values[at]);button.Text=title..': '..tostring(get());return ok,err end)
  self.refreshers[#self.refreshers+1]=function()button.Text=title..': '..tostring(get())end
  return button
 end
 function UI:toggle(parent,title,get,set)
  local b
  b=self:button(parent,'',function()local ok,err=set(not get());b.Text=title..': '..(get() and 'ON' or 'OFF');return ok,err end);b.Text=title..': '..(get() and 'ON' or 'OFF')
  self.refreshers[#self.refreshers+1]=function()b.Text=title..': '..(get() and 'ON' or 'OFF')end;return b
 end
 function UI:slider(parent,title,get,set,lo,hi,step)
  local label=self:label(parent,title..': '..tostring(get()),30)
  local track=self:create('Frame',{Size=UDim2.new(1,0,0,22),BackgroundColor3=self.palette.bg,BorderSizePixel=0,Active=true},parent);self:corner(track,7)
  local fill=self:create('Frame',{Size=UDim2.new((get()-lo)/(hi-lo),0,1,0),BackgroundColor3=self.palette.accent,BorderSizePixel=0},track);self:corner(fill,7)
  local d={track=track,fill=fill,label=label,title=title,set=set,lo=lo,hi=hi,step=step or 1}
  self:bind(track.InputBegan,function(input)if self:isPress(input) then self.sliderDrag=d;self:setSliderFromInput(input.Position.X) end end)
  local box=self:field(parent,'Wartość liczbowa',get(),function(value)local v=M.Util.number(tonumber(value),get(),lo,hi);set(v);fill.Size=UDim2.new((v-lo)/(hi-lo),0,1,0);label.Text=title..': '..string.format('%.1f',v);return v end)
  self.refreshers[#self.refreshers+1]=function()local v=get();box.Text=tostring(v);fill.Size=UDim2.new((v-lo)/(hi-lo),0,1,0);label.Text=title..': '..string.format('%.1f',v)end
 end
 function UI:setSliderFromInput(x)
  local d=self.sliderDrag;if not d then return end;local f=math.clamp((x-d.track.AbsolutePosition.X)/math.max(1,d.track.AbsoluteSize.X),0,1);local value=math.clamp(math.floor((d.lo+f*(d.hi-d.lo))/d.step+.5)*d.step,d.lo,d.hi);d.set(value);d.fill.Size=UDim2.new((value-d.lo)/(d.hi-d.lo),0,1,0);d.label.Text=d.title..': '..string.format('%.1f',value)
 end
 function UI:clearList(parent)
  for _,c in ipairs(self.listConnections) do self.app.runtime:disconnect(c) end;self.listConnections={}
  for _,o in ipairs(parent:GetChildren()) do if o:IsA('GuiObject') then o:Destroy() end end
 end
 function UI:theme()
  self.palette.accent=self.app.config.data.ui.theme=='PURPLE' and Color3.fromRGB(156,103,247) or Color3.fromRGB(83,133,247);self.bubble.BackgroundColor3=self.palette.accent;self:show(self.current or 'HOME')
 end
 function UI:refreshControls()for _,fn in ipairs(self.refreshers) do fn()end end
 function UI:toast(module,message,bad)
  self.footer.Text='['..module..'] '..tostring(message);self.footer.TextColor3=bad and self.palette.red or self.palette.muted
  if self.notification then self.notification:Destroy() end
  self.notification=self:create('TextLabel',{Size=UDim2.fromOffset(310,80),Position=UDim2.new(1,-326,1,-98),BackgroundColor3=self.palette.panel,Text='['..module..'] '..tostring(message):sub(1,220),TextColor3=bad and self.palette.red or self.palette.text,TextWrapped=true,TextSize=12,Font=Enum.Font.Gotham,ZIndex=80},self.gui);self:corner(self.notification,10);self.notifyUntil=self.app.clock()+5
 end
 function UI:tick()if self.notification and self.app.clock()>=self.notifyUntil then self.notification:Destroy();self.notification=nil end end
 return UI
end
