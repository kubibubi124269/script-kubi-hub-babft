local Layout={}
function Layout.compute(viewWidth,viewHeight,desiredWidth,desiredHeight,compact,tabCount)
 local width=math.min(math.max(300,desiredWidth),math.max(260,viewWidth-16));local height=math.min(math.max(360,desiredHeight),math.max(260,viewHeight-16))
 local narrow=width<700 or compact==true;local navWidth=width<420 and 88 or compact and 116 or 140
 return {width=width,height=height,narrow=narrow,contentX=navWidth+26,contentY=80,contentWidth=width-navWidth-38,contentHeight=height-120,
 navColumns=1,navRows=tabCount or 6,navWidth=navWidth,navHeight=height-120,navCellWidth=navWidth-5,navCellHeight=width<420 and 36 or 40}
end
return Layout
