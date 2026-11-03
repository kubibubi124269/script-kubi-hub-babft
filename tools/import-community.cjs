const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),dir=path.join(root,'assets/community');
const sources=[
 {id:'classic_house',name:'Classic House — dom',original:'ClassicHouse.Build',file:'classic-house.json',url:'https://luau.pro/catalog/build/7ee4963f-44cd-43a7-b5f5-d0febfc0acb8'},
 {id:'castle',name:'Zamek — architektura statyczna',original:'Castle.Build',file:'castle-static.json',url:'https://luau.pro/catalog/build/a88a7dd1-c2cc-4a64-b6aa-3abe45ded27d'}
];
const materials=new Set(['WoodBlock','PlasticBlock','MetalBlock','TitaniumBlock','GlassBlock','ConcreteBlock','StoneBlock','MarbleBlock','GoldBlock','IceBlock','NeonBlock','GrassBlock','FabricBlock']);
const index=sources.map(source=>{
 const text=fs.readFileSync(path.join(dir,source.original),'utf8').replace(/\r\n/g,'\n');const marker=/^LP_BUILD\s*$/m.exec(text);if(!marker)throw Error('No LP_BUILD: '+source.original);
 const raw=JSON.parse(text.slice(marker.index+marker[0].length)),data={},omitted={};let parts=0,originalParts=0;
 for(const[id,rows]of Object.entries(raw)){
  if(!Array.isArray(rows))throw Error('Invalid material group');originalParts+=rows.length;
  if(!materials.has(id)){omitted[id]=rows.length;continue;}
  data[id]=rows.map(row=>{const out={};for(const key of ['Position','Rotation','Size','Color'])if(row[key]!==undefined){if(!Array.isArray(row[key])||row[key].length!==3||!row[key].every(Number.isFinite))throw Error('Invalid '+key);out[key]=row[key];}if(!out.Position)throw Error('Missing position');return out;});parts+=rows.length;
 }
 if(parts<1||parts>10000)throw Error('Community geometry outside supported part count');
 fs.writeFileSync(path.join(dir,source.file),JSON.stringify(data)+'\n');
 return {...source,parts,originalParts,omitted,sourceSha256LF:crypto.createHash('sha256').update(text).digest('hex'),adaptation:'Geometria statyczna: pozycje, obroty, rozmiary i kolory bloków. Bez elektroniki, połączeń, wyposażenia, przezroczystości i ustawień fizyki oryginału.',credit:'Plik społeczności udostępniony przez luau.pro; autor oryginału niezweryfikowany.'};
});
fs.writeFileSync(path.join(dir,'index.json'),JSON.stringify(index,null,2)+'\n');
function lua(v){if(v===null)return 'nil';if(Array.isArray(v))return '{'+v.map(lua).join(',')+'}';if(typeof v==='object')return '{'+Object.entries(v).map(([k,x])=>'['+JSON.stringify(k)+']='+lua(x)).join(',')+'}';return JSON.stringify(v);}
fs.writeFileSync(path.join(root,'src/schematics/Community.lua'),'-- Generated from preserved community source files by tools/import-community.cjs.\nreturn '+lua(index)+'\n');
module.exports=index;
