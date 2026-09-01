/* THE UNIVERSE · THE THIRTEEN ─────────────────────────────────────
   Each room of the Feed is a region of sky with its OWN FORM. The form is
   not decoration behind the stars — the stars sit ON it, so the whole sky
   reads as thirteen distinct figures before anything is named.
   Each room carries four things:
     place()  the armature the stories are strung along
     arm()    that armature drawn at sky scale, alive
     field()  what it feels like INSIDE the region — its own weather
     civ      how life builds, once life has taken hold on its worlds
   Nothing here counts anything. ─────────────────────────────────── */
(function(global){
'use strict';
var TAU=Math.PI*2, BONE=[214,206,192], GOLD=Math.PI*(3-Math.sqrt(5));
function hash(n){var x=Math.sin(n*127.1+31.4)*43758.5453;return x-Math.floor(x);}
function mix(a,b,f){return [a[0]+(b[0]-a[0])*f,a[1]+(b[1]-a[1])*f,a[2]+(b[2]-a[2])*f];}
function rgba(c,a){return 'rgba('+(c[0]|0)+','+(c[1]|0)+','+(c[2]|0)+','+(a<0?0:a)+')';}
function hx(h){return [parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)];}
function ring(x,cx,cy,r){x.beginPath();x.arc(cx,cy,r,0,TAU);}
var breath=function(t){return (Math.sin(t*TAU/10)+1)/2;};

/* ─── the thirteen ─────────────────────────────────────────────── */
var ROOMS=[
{id:'forge',name:'The Forge',hex:'#D4AE4A',x:-470,y:-1010,r:150,n:7,hz:294,civ:'furnaces',
 /* the tetractys — a crucible builds upward in rows */
 place:function(i,n,R){var rows=[[0],[-1,1],[-2,0,2],[-3,-1,1,3]];var f=[];
   rows.forEach(function(row,ri){row.forEach(function(c){f.push([c*R*0.20,(ri-1.4)*R*0.34]);});});
   return f[i%f.length];},
 arm:function(x,cx,cy,R,t,a,c){
   for(var k=0;k<3;k++){var s=R*(0.42+k*0.28),yy=cy+R*0.30-k*R*0.06;
     x.beginPath();x.moveTo(cx,yy-s*0.9);x.lineTo(cx+s*0.86,yy+s*0.5);x.lineTo(cx-s*0.86,yy+s*0.5);x.closePath();
     x.strokeStyle=rgba(c,a*(0.30-k*0.07));x.lineWidth=1;x.stroke();}
   var g=x.createRadialGradient(cx,cy+R*0.5,0,cx,cy+R*0.5,R*0.7);
   g.addColorStop(0,rgba([255,214,140],a*0.32*(0.6+0.4*Math.sin(t*1.7))));g.addColorStop(1,rgba(c,0));
   x.fillStyle=g;x.fillRect(cx-R,cy-R*0.4,R*2,R*1.4);
   for(var i=0;i<14;i++){var ph=(t*0.4+hash(i))%1;
     x.beginPath();x.arc(cx+(hash(i+3)-0.5)*R*1.2,cy+R*0.5-ph*R*1.5,0.8+(1-ph),0,TAU);
     x.fillStyle=rgba([255,226,164],a*(1-ph)*0.7);x.fill();}},
 field:function(x,W,H,t,a,c){ /* sparks rise; the air above a forge shivers */
   for(var i=0;i<70;i++){var ph=((t*0.24+hash(i))%1);
     var px=W*hash(i*3.1)+Math.sin(t*0.7+i)*12, py=H*(1.05-ph*1.15);
     x.beginPath();x.arc(px,py,0.7+(1-ph)*2,0,TAU);
     x.fillStyle=rgba(mix([255,226,164],c,0.4),a*(1-ph)*0.55);x.fill();}}},

{id:'signal',name:'The Signal',hex:'#3AADA8',x:470,y:-980,r:160,n:5,hz:285,civ:'arrays',
 /* the beam — stations along one axis, spaced as a signal weakens */
 place:function(i,n,R){return [(-0.55+Math.pow(i/(n-1),0.8)*1.35)*R*0.9,(i%2?1:-1)*R*0.10];},
 arm:function(x,cx,cy,R,t,a,c){
   x.beginPath();x.moveTo(cx-R*0.62,cy);x.lineTo(cx+R*0.8,cy);
   x.strokeStyle=rgba(c,a*0.24);x.lineWidth=1;x.stroke();
   for(var k=0;k<5;k++){var ph=((t*0.16)+k/5)%1;
     x.beginPath();x.arc(cx-R*0.55,cy,ph*R*1.5,-1.05,1.05);
     x.strokeStyle=rgba(c,a*(1-ph)*0.42);x.lineWidth=1.2;x.stroke();}},
 field:function(x,W,H,t,a,c){ /* wavefronts crossing, one after another, forever arriving */
   for(var k=0;k<7;k++){var ph=((t*0.10)+k/7)%1;
     x.beginPath();x.arc(W*0.08,H*0.4,ph*H*1.4,-1.2,1.2);
     x.strokeStyle=rgba(c,a*(1-ph)*0.34);x.lineWidth=1.4;x.stroke();}}},

{id:'descent',name:'The Descent',hex:'#E5533C',x:-90,y:-880,r:250,n:11,hz:126,civ:'shafts',
 /* the funnel — a spiral going down, tighter as it goes */
 place:function(i,n,R){var f=i/(n-1),ang=f*5.6,rr=R*(0.92-f*0.78);
   return [Math.cos(ang)*rr,Math.sin(ang)*rr*0.5+(f-0.4)*R*0.9];},
 arm:function(x,cx,cy,R,t,a,c){
   x.beginPath();
   for(var s=0;s<=120;s++){var f=s/120,ang=f*5.6+t*0.03,rr=R*(0.92-f*0.78);
     var px=cx+Math.cos(ang)*rr,py=cy+Math.sin(ang)*rr*0.5+(f-0.4)*R*0.9;
     s?x.lineTo(px,py):x.moveTo(px,py);}
   x.strokeStyle=rgba(c,a*0.30);x.lineWidth=1.2;x.stroke();
   for(var i=0;i<10;i++){var ph=((t*0.13+hash(i))%1),ang2=ph*5.6+t*0.03,rr2=R*(0.92-ph*0.78);
     x.beginPath();x.arc(cx+Math.cos(ang2)*rr2,cy+Math.sin(ang2)*rr2*0.5+(ph-0.4)*R*0.9,1.4,0,TAU);
     x.fillStyle=rgba(mix(c,[255,220,200],0.5),a*0.7*(1-ph*0.6));x.fill();}},
 field:function(x,W,H,t,a,c){ /* everything falls, and the falling is warm */
   for(var i=0;i<80;i++){var ph=((t*0.30+hash(i*1.7))%1);
     x.beginPath();x.arc(W*hash(i*2.3)+Math.sin(t*0.5+i)*9,H*(ph*1.15-0.08),0.7+ph*1.6,0,TAU);
     x.fillStyle=rgba(mix(c,[255,190,160],0.35),a*0.5*Math.sin(ph*Math.PI));x.fill();}}},

{id:'garden',name:'The Garden',hex:'#4A9E6B',x:330,y:-620,r:230,n:10,hz:146,civ:'terraces',
 /* phyllotaxis — the only angle that never repeats */
 place:function(i,n,R){var ang=i*GOLD,rr=R*0.30*Math.sqrt(i+0.6);return [Math.cos(ang)*rr,Math.sin(ang)*rr*0.9];},
 arm:function(x,cx,cy,R,t,a,c){
   for(var fam=0;fam<2;fam++){var step=fam?13:8;
     for(var k=0;k<step;k++){x.beginPath();
       for(var j=0;j<9;j++){var idx=k+j*step,ang=idx*GOLD+t*0.02,rr=R*0.30*Math.sqrt(idx+0.6);
         var px=cx+Math.cos(ang)*rr,py=cy+Math.sin(ang)*rr*0.9;j?x.lineTo(px,py):x.moveTo(px,py);}
       x.strokeStyle=rgba(c,a*(fam?0.10:0.16));x.lineWidth=1;x.stroke();}}
   for(var i=0;i<26;i++){var ang3=i*GOLD+t*0.02,rr3=R*0.30*Math.sqrt(i+0.6);
     var pl=0.5+0.5*Math.sin(t*1.1-Math.sqrt(i)*0.6);
     x.beginPath();x.arc(cx+Math.cos(ang3)*rr3,cy+Math.sin(ang3)*rr3*0.9,0.9+pl*1.2,0,TAU);
     x.fillStyle=rgba(mix(c,[200,255,190],0.5),a*(0.2+pl*0.4));x.fill();}},
 field:function(x,W,H,t,a,c){ /* it grows upward while you stand in it */
   for(var i=0;i<70;i++){var ph=((t*0.16+hash(i*1.3))%1);
     x.beginPath();x.arc(W*hash(i*3.7)+Math.sin(t*0.4+i)*14,H*(1.05-ph*1.15),0.8+ph*1.4,0,TAU);
     x.fillStyle=rgba(mix(c,[210,255,190],0.55),a*0.5*Math.sin(ph*Math.PI));x.fill();}}},

{id:'maya',name:'A Maya Game',hex:'#D4AE4A',x:-420,y:-430,r:240,n:9,hz:168,civ:'mirrorcities',
 /* a tiling that never quite repeats — sheared rhombi */
 place:function(i,n,R){var col=i%3,row=(i/3)|0;
   return [(col-1)*R*0.52+(row-1)*R*0.20,(row-1)*R*0.50];},
 arm:function(x,cx,cy,R,t,a,c){
   for(var row=-1;row<=1;row++)for(var col=-1;col<=1;col++){
     var px=cx+col*R*0.52+row*R*0.20, py=cy+row*R*0.50;
     var sw=(0.5+0.5*Math.sin(t*0.5+row*2+col*3));
     var w=R*0.26*(0.8+sw*0.2), h=R*0.25;
     x.beginPath();x.moveTo(px,py-h);x.lineTo(px+w,py);x.lineTo(px,py+h);x.lineTo(px-w,py);x.closePath();
     x.strokeStyle=rgba(c,a*(0.14+sw*0.20));x.lineWidth=1;x.stroke();
     if(sw>0.93){x.fillStyle=rgba(c,a*0.06);x.fill();}}},
 field:function(x,W,H,t,a,c){ /* tiles swap places when you are not looking */
   for(var i=0;i<26;i++){var px=W*hash(i*2.1),py=H*hash(i*3.3);
     var sw=(0.5+0.5*Math.sin(t*0.7+i)),w=16+hash(i)*22;
     x.beginPath();x.moveTo(px,py-w*0.6);x.lineTo(px+w,py);x.lineTo(px,py+w*0.6);x.lineTo(px-w,py);x.closePath();
     x.strokeStyle=rgba(c,a*(0.08+sw*0.16));x.lineWidth=1;x.stroke();}}},

{id:'watcher',name:'The Watcher',hex:'#7B82D4',x:110,y:-230,r:190,n:7,hz:189,civ:'towers',
 /* the mandorla — stations around the lens where two circles cross */
 place:function(i,n,R){var f=i/(n-1),ang=-Math.PI/2+f*TAU;
   return [Math.cos(ang)*R*0.78,Math.sin(ang)*R*0.32];},
 arm:function(x,cx,cy,R,t,a,c){
   var Rr=R*0.95,d=Rr*0.76;
   ring(x,cx,cy-d,Rr);x.strokeStyle=rgba(c,a*0.10);x.lineWidth=1;x.stroke();
   ring(x,cx,cy+d,Rr);x.stroke();
   x.save();ring(x,cx,cy-d,Rr);x.clip();ring(x,cx,cy+d,Rr);
   x.strokeStyle=rgba(c,a*0.42);x.lineWidth=1.4;x.stroke();x.restore();
   x.save();ring(x,cx,cy+d,Rr);x.clip();ring(x,cx,cy-d,Rr);
   x.strokeStyle=rgba(c,a*0.42);x.lineWidth=1.4;x.stroke();x.restore();
   var blink=Math.max(0,Math.sin(t*0.13)*8-7);      /* it blinks, rarely */
   ring(x,cx,cy,R*0.16*(1-blink));x.fillStyle=rgba(mix(c,[240,242,255],0.5),a*0.5);x.fill();},
 field:function(x,W,H,t,a,c){ /* almost nothing moves. Being watched is quiet. */
   for(var i=0;i<22;i++){var px=W*hash(i*1.9),py=H*hash(i*2.7);
     x.beginPath();x.arc(px,py+Math.sin(t*0.09+i)*3,0.8,0,TAU);
     x.fillStyle=rgba(c,a*0.4*(0.4+0.6*Math.sin(t*0.2+i)));x.fill();}}},

{id:'field',name:'The Field',hex:'#9B6BD6',x:-200,y:60,r:280,n:12,hz:198,civ:'weave',
 /* the lemniscate — it comes back through itself */
 place:function(i,n,R){var s=i/n*TAU,dn=1+Math.sin(s)*Math.sin(s);
   return [R*0.82*Math.cos(s)/dn,R*0.82*Math.sin(s)*Math.cos(s)/dn];},
 arm:function(x,cx,cy,R,t,a,c){
   x.beginPath();
   for(var s=0;s<=200;s++){var th=s/200*TAU,dn=1+Math.sin(th)*Math.sin(th);
     var px=cx+R*0.82*Math.cos(th)/dn,py=cy+R*0.82*Math.sin(th)*Math.cos(th)/dn;
     s?x.lineTo(px,py):x.moveTo(px,py);}
   x.closePath();x.strokeStyle=rgba(c,a*0.34);x.lineWidth=1.3;x.stroke();
   for(var k=0;k<5;k++){var ph=(t*0.06+k/5)%1,th2=ph*TAU,dn2=1+Math.sin(th2)*Math.sin(th2);
     x.beginPath();x.arc(cx+R*0.82*Math.cos(th2)/dn2,cy+R*0.82*Math.sin(th2)*Math.cos(th2)/dn2,1.6,0,TAU);
     x.fillStyle=rgba(mix(c,[240,230,255],0.6),a*0.8);x.fill();}},
 field:function(x,W,H,t,a,c){ /* a weave, and you are inside the weave */
   for(var i=-2;i<14;i++){
     x.beginPath();
     for(var px=0;px<=W;px+=8){x.lineTo(px,i*H/12+Math.sin(px*0.02+t*0.3+i)*10);}
     x.strokeStyle=rgba(c,a*0.13);x.lineWidth=1;x.stroke();}
   for(var j=-2;j<9;j++){
     x.beginPath();
     for(var py=0;py<=H;py+=8){x.lineTo(j*W/7+Math.sin(py*0.02+t*0.24+j)*10,py);}
     x.strokeStyle=rgba(c,a*0.10);x.lineWidth=1;x.stroke();}}},

{id:'thread',name:'The Thread',hex:'#C4923A',x:430,y:150,r:180,n:6,hz:210,civ:'lines',
 /* the braid — three strands, and the settlements sit at the crossings */
 place:function(i,n,R){var f=(i+0.5)/n;
   return [(f-0.5)*R*1.7,Math.sin(f*TAU*1.5)*R*0.30];},
 arm:function(x,cx,cy,R,t,a,c){
   for(var s=0;s<3;s++){x.beginPath();
     for(var px=-R*0.95;px<=R*0.95;px+=6){
       var f=(px+R*0.95)/(R*1.9);
       x.lineTo(cx+px,cy+Math.sin(f*TAU*1.5+s*TAU/3+t*0.18)*R*0.30);}
     x.strokeStyle=rgba(c,a*(0.30-s*0.06));x.lineWidth=1.2;x.stroke();}},
 field:function(x,W,H,t,a,c){ /* strands passing, endlessly crossing */
   for(var s=0;s<7;s++){x.beginPath();
     for(var py=0;py<=H;py+=8){
       x.lineTo(W*0.5+Math.sin(py*0.008+s*0.9+t*0.22)*W*0.42,py);}
     x.strokeStyle=rgba(c,a*0.12);x.lineWidth=1.1;x.stroke();}}},

{id:'body',name:'The Body',hex:'#C45A50',x:-450,y:330,r:200,n:8,hz:220,civ:'districts',
 /* hex packing — tissue */
 place:function(i,n,R){var H6=[[0,0],[1,0],[0.5,0.87],[-0.5,0.87],[-1,0],[-0.5,-0.87],[0.5,-0.87],[1.5,0.87]];
   var p=H6[i%H6.length];return [p[0]*R*0.46,p[1]*R*0.46];},
 arm:function(x,cx,cy,R,t,a,c){
   var H6=[[0,0],[1,0],[0.5,0.87],[-0.5,0.87],[-1,0],[-0.5,-0.87],[0.5,-0.87],[1.5,0.87],[-1.5,-0.87]];
   H6.forEach(function(p,i){var px=cx+p[0]*R*0.46,py=cy+p[1]*R*0.46;
     var pl=0.5+0.5*Math.sin(t*1.05-i*0.5);       /* one rhythm, passing through */
     x.beginPath();
     for(var k=0;k<6;k++){var ang=k*Math.PI/3;
       var qx=px+Math.cos(ang)*R*0.26*(0.94+pl*0.06),qy=py+Math.sin(ang)*R*0.26*(0.94+pl*0.06);
       k?x.lineTo(qx,qy):x.moveTo(qx,qy);}
     x.closePath();x.strokeStyle=rgba(c,a*(0.14+pl*0.20));x.lineWidth=1;x.stroke();});},
 field:function(x,W,H,t,a,c){ /* a pulse crosses the tissue, again and again */
   for(var i=0;i<40;i++){var px=W*hash(i*2.9),py=H*hash(i*1.3);
     var pl=0.5+0.5*Math.sin(t*1.05-py/H*3);
     x.beginPath();x.arc(px,py,2+pl*3,0,TAU);
     x.fillStyle=rgba(c,a*(0.10+pl*0.26));x.fill();}}},

{id:'forgetting',name:'The Forgetting',hex:'#C4A882',x:70,y:470,r:215,n:8,hz:231,civ:'ruins',
 /* the broken ring — the arc is missing in places */
 place:function(i,n,R){var arcs=[0.05,0.18,0.30,0.55,0.66,0.78,0.90,0.42];
   var ang=arcs[i%arcs.length]*TAU;return [Math.cos(ang)*R*0.74,Math.sin(ang)*R*0.74*0.9];},
 arm:function(x,cx,cy,R,t,a,c){
   for(var k=0;k<26;k++){var a0=k/26*TAU;
     var gone=hash(k*3.3+Math.floor(t*0.06))>0.66;   /* what is missing keeps changing */
     if(gone)continue;
     x.beginPath();x.arc(cx,cy,R*0.74,a0,a0+TAU/34);
     x.strokeStyle=rgba(c,a*0.30);x.lineWidth=1.3;x.stroke();}},
 field:function(x,W,H,t,a,c){ /* motes dissolve mid-flight */
   for(var i=0;i<64;i++){var ph=((t*0.13+hash(i*1.9))%1);
     var fade=Math.sin(ph*Math.PI);
     x.beginPath();x.arc(W*hash(i*2.7)+Math.sin(t*0.2+i)*20,H*hash(i*3.1)-ph*40,1.1,0,TAU);
     x.fillStyle=rgba(c,a*0.5*fade*fade);x.fill();}}},

{id:'remembering',name:'The Remembering',hex:'#8AB5A0',x:350,y:700,r:200,n:7,hz:252,civ:'relight',
 /* the same ring, closing — a light travels it and leaves it whole */
 place:function(i,n,R){var ang=-Math.PI/2+i/n*TAU;return [Math.cos(ang)*R*0.72,Math.sin(ang)*R*0.72*0.9];},
 arm:function(x,cx,cy,R,t,a,c){
   var head=(t*0.055)%1;
   for(var k=0;k<40;k++){var f=k/40,a0=-Math.PI/2+f*TAU;
     var rel=(head-f+1)%1, lit=Math.pow(1-rel,1.6);
     x.beginPath();x.arc(cx,cy,R*0.72,a0,a0+TAU/48);
     x.strokeStyle=rgba(c,a*(0.10+lit*0.5));x.lineWidth=1+lit*1.4;x.stroke();}
   var ha=-Math.PI/2+head*TAU;
   x.beginPath();x.arc(cx+Math.cos(ha)*R*0.72,cy+Math.sin(ha)*R*0.72,2.4,0,TAU);
   x.fillStyle=rgba(mix(c,[240,255,246],0.6),a*0.9);x.fill();},
 field:function(x,W,H,t,a,c){ /* motes gather back into place */
   for(var i=0;i<58;i++){var ph=((t*0.14+hash(i*2.3))%1),con=1-ph;
     var tx=W*hash(i*1.7),ty=H*hash(i*3.9);
     x.beginPath();x.arc(tx+Math.cos(i)*con*70,ty+Math.sin(i)*con*70,0.9+ph*1.4,0,TAU);
     x.fillStyle=rgba(c,a*0.5*ph);x.fill();}}},

{id:'circle',name:'The Circle',hex:'#D4607A',x:-330,y:760,r:175,n:6,hz:264,civ:'rings',
 /* concentric — three in, three out */
 place:function(i,n,R){var inner=i<3,ang=(i%3)/3*TAU+(inner?0.5:0);
   return [Math.cos(ang)*R*(inner?0.34:0.78),Math.sin(ang)*R*(inner?0.34:0.78)*0.9];},
 arm:function(x,cx,cy,R,t,a,c){
   [0.34,0.56,0.78].forEach(function(f,i){ring(x,cx,cy,R*f);
     x.strokeStyle=rgba(c,a*(0.28-i*0.05));x.lineWidth=1.1;x.stroke();});
   for(var k=0;k<3;k++){var ph=((t*0.10)+k/3)%1;ring(x,cx,cy,R*(0.2+ph*0.9));
     x.strokeStyle=rgba(c,a*(1-ph)*0.28);x.lineWidth=1.2;x.stroke();}},
 field:function(x,W,H,t,a,c){ /* ripples, from the middle of everything */
   for(var k=0;k<8;k++){var ph=((t*0.075)+k/8)%1;
     ring(x,W/2,H*0.44,ph*H*0.95);
     x.strokeStyle=rgba(c,a*(1-ph)*0.26);x.lineWidth=1.3;x.stroke();}}},

{id:'return',name:'The Return',hex:'#9B6BD6',x:140,y:1020,r:165,n:6,hz:315,civ:'ports',
 /* the orbit — it always comes back, and perihelion is the bright one */
 place:function(i,n,R){var ang=i/n*TAU;return [Math.cos(ang)*R*0.86,Math.sin(ang)*R*0.44];},
 arm:function(x,cx,cy,R,t,a,c){
   x.beginPath();x.ellipse(cx,cy,R*0.86,R*0.44,0,0,TAU);
   x.strokeStyle=rgba(c,a*0.30);x.lineWidth=1.2;x.stroke();
   var ph=(t*0.045)%1,ang=ph*TAU;
   var px=cx+Math.cos(ang)*R*0.86,py=cy+Math.sin(ang)*R*0.44;
   for(var k=0;k<16;k++){var a2=ang-k*0.055;
     x.beginPath();x.arc(cx+Math.cos(a2)*R*0.86,cy+Math.sin(a2)*R*0.44,1.6*(1-k/16),0,TAU);
     x.fillStyle=rgba(mix(c,[240,232,255],0.5),a*0.5*(1-k/16));x.fill();}
   x.beginPath();x.arc(px,py,2.6,0,TAU);x.fillStyle=rgba([246,240,255],a*0.95);x.fill();},
 field:function(x,W,H,t,a,c){ /* things sweeping back through */
   for(var i=0;i<9;i++){var ph=((t*0.09+hash(i))%1);
     var px=-40+ph*(W+80),py=H*hash(i*2.1)+Math.sin(ph*Math.PI)*-60;
     for(var k=0;k<10;k++){x.beginPath();x.arc(px-k*7,py+k*2,1.4*(1-k/10),0,TAU);
       x.fillStyle=rgba(mix(c,[240,232,255],0.4),a*0.5*(1-k/10));x.fill();}}}}
];
ROOMS.forEach(function(r){r.rgb=hx(r.hex);});

/* ─── the stories that exist ────────────────────────────────────
   Two per room, verbatim from the Archive (Game View / Home Feed). A world
   is lit because a story lives there — met-ness is not decoration, it IS
   the archive. Depth comes from each story's own resonance: how many times
   he has come back. Nothing is invented here and nothing is counted. */
/* [codex, title, resonance, the field voices who actually spoke, comments]
   The voices are verbatim from the Archive rosters (Game View). Nothing is
   added: three voices spoke means three voices spoke. */
var STORIES={
  maya:       [['C-1052','The Two Who Were One',89,['sakshi','lalita','gaia'],14],['C-1061','Still Life with Cold Coffee',34,['sakshi','sid','lalita'],6]],
  garden:     [['C-1047','The Smile While Making Eggs',52,['gaia','karishma','bindu'],8],['C-1033','The Heart-Shaped Patch',71,['gaia','lalita'],11]],
  watcher:    [['C-1038','The One Who Sees',67,['sakshi','lalita','ashrey'],11],['C-1029','Turning Around to Look',28,['sakshi'],4]],
  descent:    [['C-1055','Further In Than Last Time',44,['bindu','gaia'],7],['C-1041','What\u2019s at the Bottom',19,['bindu','lalita'],3]],
  return:     [['C-1058','Everything Was Waiting',63,['lalita','gaia','sakshi'],9],['C-1044','The Lobby',38,['lalita','sid'],5]],
  forgetting: [['C-1064','The Recording That Loops',41,['sakshi','lalita'],7],['C-1066','The Tool That Became the Wall',22,['sakshi','sid'],4]],
  remembering:[['C-1068','The Pattern Simply Seen',37,['sakshi','gaia'],6],['C-1070','Before the Lightning',29,['gaia','lalita'],4]],
  body:       [['C-1072','Four Hours Unable to Sleep',58,['gaia','bindu'],9],['C-1074','What the Chest Knew First',34,['gaia','sakshi'],5]],
  thread:     [['C-1076','Three Generations',48,['gaia','sid'],7],['C-1078','The Sacred in the Invoice',31,['sid','lalita'],4]],
  circle:     [['C-1080','These Faces',62,['gaia','arch','karishma'],10],['C-1082','The Original School',44,['gaia','arch'],6]],
  signal:     [['C-1084','The Dallas Night',55,['lalita','ashrey'],8],['C-1086','The Akash-Gaia Downloads',38,['lalita','sakshi','ashrey'],6]],
  forge:      [['C-1088','The Strange Game',72,['lalita','sid','ashrey'],12],['C-1090','The Joy of Form',41,['lalita','sid'],6]],
  field:      [['C-1092','The Watcher Watching the Watcher',88,['sakshi','lalita','bindu'],14],['C-1094','The Game Built the Room',61,['lalita','sakshi'],9]]
};
/* how often he has come back, read off the story's own resonance */
function depthOf(res){return res>=85?8:res>=60?5:res>=44?3:res>=28?1:0;}

/* ─── the hundred and two ──────────────────────────────────────
   One slot per story the wheel can hold, strung on its region's form.
   A met story is a world where life took hold. Depth is how long life has
   been living there. Year one: mostly dark, a scattering of light. */
var STARS=[], k=0;
ROOMS.forEach(function(room,ri){
  /* which two slots in this region hold the stories that exist */
  var picks=[Math.floor(hash(ri*7.7)*room.n),0];
  picks[1]=(picks[0]+2+Math.floor(hash(ri*3.3)*(room.n-3)))%room.n;
  var mine=STORIES[room.id]||[];
  for(var i=0;i<room.n;i++,k++){
    var p=room.place(i,room.n,room.r);
    var jx=(hash(k*5.1)-0.5)*room.r*0.10, jy=(hash(k*6.3)-0.5)*room.r*0.10;
    var slot=picks.indexOf(i), story=slot>=0?mine[slot]:null;
    STARS.push({room:ri,idx:i,x:room.x+p[0]+jx,y:room.y+p[1]+jy,
      met:!!story, depth:story?depthOf(story[2]):0,
      codex:story?story[0]:null, title:story?story[1]:null,
      spoke:story?story[3]:null, cmts:story?story[4]:0,
      seed:k,tw:0.45+hash(k*17.3)*0.55,
      spin:0.02+hash(k*19.1)*0.05, tilt:(hash(k*23.3)-0.5)*0.7,
      pr:7+hash(k*29.7)*4});
  }
});
var DEEP=STARS.filter(function(s){return s.depth>=3;});
var MET=STARS.filter(function(s){return s.met;});

/* ─── the travellers ───────────────────────────────────────────
   Life moves. Between the worlds of one region, and — slower, rarer —
   between regions. It only ever travels where he has already been. */
var LANES=[];
(function(){
  ROOMS.forEach(function(room,ri){
    var here=MET.filter(function(s){return s.room===ri;});
    for(var i=0;i<here.length;i++)for(var j=i+1;j<here.length;j++){
      if(hash(i*7.1+j*3.3+ri)<0.45)
        LANES.push({a:here[i],b:here[j],local:true,ph:hash(i+j+ri),
          spd:0.010+hash(i*2.2+j)*0.010});
    }
  });
  for(var q=0;q<9;q++){                        /* the long hauls */
    var a=MET[Math.floor(hash(q*3.7)*MET.length)], b=MET[Math.floor(hash(q*8.1+1)*MET.length)];
    if(!a||!b||a===b||a.room===b.room)continue;
    LANES.push({a:a,b:b,local:false,ph:hash(q*1.9),spd:0.0022+hash(q)*0.0026});
  }
})();

/* ─── what is under the light ──────────────────────────────────
   The structure lens reads Identity: belief-structures as chains of line
   and node. Nothing is red; nothing is a diagnosis. A structure whose
   stories have been long met sits looser — seen once in the light, it
   loosens. At world scale it appears as a lattice thrown over the globe:
   what built this place. */
var STRUCTURES=[
  {room:2, name:'I was sentenced to this life',              loose:0.15},
  {room:2, name:'consciousness suffering leads to positivity',loose:0.05},
  {room:4, name:'I am individual',                           loose:0.62},
  {room:6, name:'I am alone in my consciousness',            loose:0.78},
  {room:6, name:'separation',                                loose:0.30},
  {room:8, name:'I was broken and needed repair',            loose:0.48},
  {room:9, name:'I lost what needed earning back',           loose:0.22},
  {room:10,name:'permanence',                                loose:0.36},
  {room:11,name:'love comes from elsewhere',                 loose:0.70},
  {room:3, name:'scarcity',                                  loose:0.12},
  {room:5, name:'control',                                   loose:0.26},
  {room:7, name:'transaction',                               loose:0.08},
  {room:0, name:'hierarchy',                                 loose:0.18}
];
STRUCTURES.forEach(function(st,i){
  var room=ROOMS[st.room], N=5+Math.floor(hash(i*5.5)*3);
  var a0=hash(i*2.2)*TAU, spread=room.r*0.62;
  st.nodes=[];
  for(var j=0;j<N;j++){
    var t=j/(N-1||1), a=a0+(t-0.5)*2.1+Math.sin(i*1.7+j*1.3)*0.34, rr=spread*(0.26+t*0.74);
    st.nodes.push({x:room.x+Math.cos(a)*rr,y:room.y+Math.sin(a)*rr*0.85,
      proof:hash(i*9.1+j)>0.58, ph:hash(i*3.7+j)*TAU});
  }
});

global.UNI={ROOMS:ROOMS,STARS:STARS,DEEP:DEEP,MET:MET,LANES:LANES,STRUCTURES:STRUCTURES,STORIES:STORIES,
  hash:hash,mix:mix,rgba:rgba,ring:ring,breath:breath,BONE:BONE,TAU:TAU,GOLD:GOLD};
})(window);
