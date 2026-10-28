local Performance={}
Performance.profiles={QUALITY={previewLimit=700,previewHz=30,statsInterval=.5},BALANCED={previewLimit=350,previewHz=15,statsInterval=1},PERFORMANCE={previewLimit=120,previewHz=6,statsInterval=2}}
function Performance.get(name,fps)
 local source=Performance.profiles[name] or Performance.profiles.BALANCED
 return {previewLimit=source.previewLimit,previewHz=fps and fps<30 and math.min(6,source.previewHz) or source.previewHz,statsInterval=fps and fps<30 and math.max(2,source.statsInterval) or source.statsInterval}
end
return Performance
