local Layout={}
function Layout.compute(viewWidth,viewHeight,desiredWidth,desiredHeight,compact)
 local width=math.min(math.max(300,desiredWidth),math.max(260,viewWidth-16));local height=math.min(math.max(360,desiredHeight),math.max(260,viewHeight-16))
 local narrow=width<700 or compact==true;local columns=narrow and (width<420 and 2 or 3) or 1
 local rows=math.ceil(6/columns);local cellHeight=narrow and 32 or 35;local navWidth=narrow and width-24 or 155
 local navHeight=narrow and rows*(cellHeight+6)-6 or height-125
 local top=narrow and 76+navHeight+10 or 80;local left=narrow and 12 or 182
 return {width=width,height=height,narrow=narrow,contentX=left,contentY=top,contentWidth=width-left-12,contentHeight=height-top-40,
  navColumns=columns,navRows=rows,navWidth=navWidth,navHeight=navHeight,navCellWidth=math.floor((navWidth-(columns-1)*6-(narrow and 0 or 5))/columns),navCellHeight=cellHeight}
end
return Layout
