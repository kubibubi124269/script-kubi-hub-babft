local T={}
T.order={'CALM','NORMAL','FAST','TURBO'}
T.mm2={
 CALM={flight=9,vertical=5,walk=.65,scan=1.1},
 NORMAL={flight=15,vertical=9,walk=1,scan=.75},
 FAST={flight=20,vertical=10,walk=1,scan=.55},
 TURBO={flight=24,vertical=12,walk=1,scan=.4},
}
T.steal={CALM=2,NORMAL=1.25,FAST=.8,TURBO=.5}
T.bike={
 CALM={gas=1.8,coast=.8,interval=7,wheelie=.45},
 NORMAL={gas=3,coast=.5,interval=5,wheelie=.7},
 FAST={gas=4,coast=.3,interval=4,wheelie=.9},
 TURBO={gas=5,coast=.2,interval=3.2,wheelie=1},
}
return T
