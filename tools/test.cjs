const fs=require('node:fs');const path=require('node:path');const cp=require('node:child_process');
const root=path.resolve(__dirname,'..');const {definitions,bundle}=require('./build.cjs');
const luau=process.env.LUAU_BIN||'luau';const compile=process.env.LUAU_COMPILE||'luau-compile';
const out=path.join(root,'.test-output');fs.mkdirSync(out,{recursive:true});
function run(bin,args){const r=cp.spawnSync(bin,args,{cwd:root,encoding:'utf8'});process.stdout.write(r.stdout||'');process.stderr.write(r.stderr||'');if(r.error)throw r.error;if(r.status!==0)process.exit(r.status||1);return r.stdout;}
const files=definitions.map(d=>d[1]).concat(['studio/Server.lua','main.lua','studio/Server.bundle.lua','tests/core.luau']);
const syntax=run(compile,['--null',...files]);const core=run(luau,['tests/core.luau']);
function lua(v){if(v===null)return 'nil';if(Array.isArray(v))return '{'+v.map(lua).join(',')+'}';if(typeof v==='object')return '{'+Object.entries(v).map(([k,x])=>'['+JSON.stringify(k)+']='+lua(x)).join(',')+'}';return JSON.stringify(v);}
let assetTest="local U=require('../src/core/Util');local I=require('../src/modules/inventory/Inventory')(U);local S=require('../src/schematics/Schema')(U,I)\n";
for(const [file,n] of [['worm-red.json',2830],['shredder.json',960]])assetTest+=`do local s,e=S.import(${lua(JSON.parse(fs.readFileSync(path.join(root,file),'utf8')))});assert(s,table.concat(e,'; '));assert(#s.elements==${n} and s.importedMechanics==true);print('PASS asset ${file} ${n} preview elements') end\n`;
fs.writeFileSync(path.join(out,'assets.luau'),assetTest);const assets=run(luau,['.test-output/assets.luau']);
const smoke=fs.readFileSync(path.join(root,'tests/RobloxMock.lua'),'utf8')+'\nlocal function startHub()\n'+fs.readFileSync(path.join(root,'main.lua'),'utf8')+'\nend\n'+fs.readFileSync(path.join(root,'tests/uiSmoke.lua'),'utf8');
fs.writeFileSync(path.join(out,'ui-smoke.luau'),smoke);run(compile,['--null','.test-output/ui-smoke.luau']);const ui=run(luau,['.test-output/ui-smoke.luau']);
fs.writeFileSync(path.join(out,'results.txt'),syntax+core+assets+ui);console.log('All offline checks passed. Native Roblox rendering and physics require Studio.');
