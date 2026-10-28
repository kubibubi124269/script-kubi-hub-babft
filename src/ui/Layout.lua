local Layout={}
function Layout.compute(viewWidth,viewHeight,desiredWidth,desiredHeight,compact)
 local width=math.min(math.max(300,desiredWidth),math.max(260,viewWidth-16));local height=math.min(math.max(360,desiredHeight),math.max(260,viewHeight-16))
 local narrow=width<700 or compact==true;local top=narrow and 120 or 80;local left=narrow and 12 or 182
 return {width=width,height=height,narrow=narrow,contentX=left,contentY=top,contentWidth=width-left-12,contentHeight=height-top-40}
end
return Layout
