local function check(condition,message)assert(condition,message);print('PASS UI '..message)end
local first=startHub();check(first and first.alive,'full client starts in assistant mode')
check(first.adapter.capabilities.build~=true,'absent adapter cannot report build authorization')
local n=0;for _ in pairs(first.ui.pages)do n+=1 end;check(n==6,'exactly six navigation pages')
first.ui:show('CIRCLE');check(first.ui.current=='CIRCLE','dedicated Circle Maker page is reachable')
first.ui.search.Text='promień';check(first.ui.results.Visible,'global search shows results')
local found=false;for _,r in ipairs(first.ui.cards)do if r.result.Visible and r.title:find('Circle Maker',1,true)then found=true end end;check(found,'search indexes function settings')
for _,r in ipairs(first.ui.cards)do if r.title:find('Circle Maker',1,true)then r.result.Activated:Fire();check(r.body.Visible,'search expands matching section');check(first.ui.current=='CIRCLE','search opens matching tab')end end
first.ui:show('BUILDER');check(first.preview.shown>0 and first.preview.shown<=350,'viewport has bounded sampled geometry')
local oldSpeed=hum.WalkSpeed;local second=startHub();check(not first.alive,'second execution unloads first runtime');check(first.runtime:counts().connections==0,'old event connections are disconnected')
n=0;for _,o in ipairs(player.PlayerGui:GetChildren())do if o.Name=='KubiHubUltimateV5'then n+=1 end end;check(n==1,'second execution leaves one GUI')
check(hum.WalkSpeed==oldSpeed,'startup preserves original character movement')
for _,size in ipairs({Vector2.new(320,600),Vector2.new(760,600),Vector2.new(1280,720)})do workspace.CurrentCamera.ViewportSize=size;second.ui:fit();check(second.ui.layout.width<=size.X-8,'responsive window fits '..size.X)end
second:unload();check(second.runtime:counts().connections==0,'unload removes current connections');check(second.ui.gui.Parent==nil,'unload destroys owned GUI')
print('UI SMOKE COMPLETE: mock contract only; no native visual or physics claim')
