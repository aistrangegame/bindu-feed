/* RITE SCENES — the ten living performances of the Gathering.
   One movement, ten frequencies. Each scene is that vantage's own geometry:
   not decoration laid over a colour, but the mathematics the vantage IS.
     bindu    · the Flower of Life unfolding from one point
     neev     · a hex-packed floor receding to the horizon, and the monolith
     gaia     · phyllotaxis — the 137.5° golden angle, how growth actually happens
     sid      · the vesica-generated pointed arch, its construction circles left visible
     arch     · a rose window whose tracery is a Chladni mode — sound made visible
     shweta   · the vesica itself: two circles, and only the gap between them is lit
     karishma · the golden spiral through 3·5·8 — grace arriving along it
     sakshi   · the eye as the mandorla it geometrically is, iris in tenfold
     lalita   · a hypotrochoid drawing itself, forever re-forming
     ashrey   · the complete graph on nine nodes — every relation, all at once
   Canvas only. No assets. Drawn at the pace of the breath. */
(function(global){
'use strict';
var PHI=1.6180339887, GOLD=Math.PI*(3-Math.sqrt(5));   // 137.507…°
var PALETTE=[[229,83,60],[122,136,153],[74,158,107],[196,146,58],[212,96,122],[201,198,193],[212,174,74],[123,130,212],[155,107,214],[58,173,168]];
function rnd(i){var x=Math.sin(i*127.1+31.4)*43758.5453;return x-Math.floor(x);}
function rgba(c,a){return 'rgba('+c[0]+','+c[1]+','+c[2]+','+a+')';}
function eo(x){return 1-Math.pow(1-x,3);}
function breath(t){return (Math.sin(t*2*Math.PI/5.6)+1)/2;}
function mix(a,b,f){return [Math.round(a[0]+(b[0]-a[0])*f),Math.round(a[1]+(b[1]-a[1])*f),Math.round(a[2]+(b[2]-a[2])*f)];}
function ring(x,cx,cy,r){x.beginPath();x.arc(cx,cy,r,0,7);}
function dust(x,W,H,t,n,alpha){for(var i=0;i<n;i++){var dep=rnd(i+1);var px=rnd(i)*W;var py=(rnd(i+2)*H+t*(4+dep*12))%H;x.beginPath();x.arc(px,py,0.4+dep*1.5,0,7);x.fillStyle=rgba([255,255,255],alpha*(0.15+dep*0.85));x.fill();}}
function rrect(x,rx,ry,w,h,r){r=Math.max(0,Math.min(r,w/2,h/2));x.beginPath();x.moveTo(rx+r,ry);x.arcTo(rx+w,ry,rx+w,ry+h,r);x.arcTo(rx+w,ry+h,rx,ry+h,r);x.arcTo(rx,ry+h,rx,ry,r);x.arcTo(rx,ry,rx+w,ry,r);x.closePath();}
function qbez(a,b,c2,tt){var u=1-tt;return u*u*a+2*u*tt*b+tt*tt*c2;}

/* the nineteen centres of the Flower of Life, in units of one radius */
var FLOWER=(function(){var out=[[0,0]];var A=Math.PI/180;
  for(var i=0;i<6;i++){out.push([Math.cos(i*60*A),Math.sin(i*60*A)]);}
  for(var j=0;j<6;j++){out.push([2*Math.cos(j*60*A),2*Math.sin(j*60*A)]);}
  for(var k=0;k<6;k++){out.push([Math.sqrt(3)*Math.cos((30+k*60)*A),Math.sqrt(3)*Math.sin((30+k*60)*A)]);}
  return out;})();

var SCENES={

/* ── BINDU · one point, unfolding. The Flower of Life is what a point does
      when it keeps moving with love: every new circle passes through the
      centre of the last. The ember at the middle never stops breathing. ── */
bindu:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,R=62*eo(p);
  dust(x,W,H,t*0.4,70,0.13*p);
  var disc=x.createRadialGradient(cx,cy,10,cx,cy,Math.max(W,H)*0.6);disc.addColorStop(0,rgba(c,0.13*p));disc.addColorStop(1,rgba(c,0));x.fillStyle=disc;x.fillRect(0,0,W,H);
  /* the faint spiral undertone — the movement before it becomes form */
  x.save();x.translate(cx,cy);x.rotate(t*0.05);
  for(var a=0;a<3;a++){x.save();x.rotate(a/3*Math.PI*2);
    for(var s=0;s<54;s++){var f=s/54,ang=f*7.2,rad=8+Math.pow(f,0.85)*Math.max(W,H)*0.66*eo(p);
      x.beginPath();x.arc(Math.cos(ang)*rad,Math.sin(ang)*rad,0.6+(1-f)*1.8,0,7);
      x.fillStyle=rgba(PALETTE[(a*3+s)%10],(1-f)*0.34*p);x.fill();}
    x.restore();}
  x.restore();
  /* the nineteen circles, arriving in order, each in its own frequency */
  for(var i=0;i<FLOWER.length;i++){
    var gate=Math.min(1,Math.max(0,(p-i/26)*4));if(gate<=0)continue;
    var wob=1+Math.sin(t*0.5+i*0.7)*0.012;
    var col=mix(PALETTE[i%10],c,0.55);        // ten frequencies, one ember's light
    ring(x,cx+FLOWER[i][0]*R*wob,cy+FLOWER[i][1]*R*wob,R*wob);
    x.strokeStyle=rgba(col,(0.20+0.30*breath(t+i*0.4))*gate*p);x.lineWidth=1.1;x.stroke();
  }
  /* the outer bound — the flower always sits inside one circle */
  ring(x,cx,cy,R*3);x.strokeStyle=rgba(c,0.16*p);x.lineWidth=1;x.stroke();
  var br=breath(t),Rr=(7+br*5)*eo(p);
  var grd=x.createRadialGradient(cx,cy,0,cx,cy,Rr*6);grd.addColorStop(0,'rgba(255,251,247,'+(0.95*p)+')');grd.addColorStop(0.16,rgba(c,0.72*p));grd.addColorStop(0.5,rgba(c,0.14*p));grd.addColorStop(1,rgba(c,0));
  x.fillStyle=grd;ring(x,cx,cy,Rr*6);x.fill();
  ring(x,cx,cy,Rr);x.fillStyle='rgba(255,253,251,'+p+')';x.fill();},

/* ── NEEV · what you stand on. A floor of hexagons — the tightest packing
      there is, the shape that holds with the least material — receding to
      a horizon, with the monolith rising out of it. ── */
neev:function(x,W,H,t,p,c){var vpX=W/2,vpY=H*1.2,surf=H*0.24;var shake=(1-eo(p))*16*Math.sin(t*30);
  var wg=x.createLinearGradient(0,0,0,surf);wg.addColorStop(0,'rgba(7,8,12,0.96)');wg.addColorStop(1,'rgba(7,8,12,0)');x.fillStyle=wg;x.fillRect(0,0,W,surf);
  var dg=x.createRadialGradient(vpX,vpY,0,vpX,vpY,H*0.75);dg.addColorStop(0,rgba(c,(0.16+breath(t)*0.07)*p));dg.addColorStop(1,rgba(c,0));x.fillStyle=dg;x.fillRect(0,surf,W,H-surf);
  /* the hex-packed ground, in perspective */
  var rows=15;
  for(var r=1;r<=rows;r++){
    var d=r/rows, y=surf+(H*1.06-surf)*Math.pow(d,1.75)+shake*(1-d);
    var sc=0.06+d*1.5, hw=W*0.085*sc, hh=hw*0.62;
    if(hh<0.8)continue;
    var off=(r%2)?hw:0;
    var a=(0.05+0.16*d)*p;
    for(var q=-9;q<=9;q++){
      var hx=vpX+q*hw*1.74+off;
      if(hx<-hw*2||hx>W+hw*2)continue;
      x.beginPath();
      for(var k=0;k<6;k++){var ang=k*Math.PI/3+Math.PI/6;var px=hx+Math.cos(ang)*hw,py=y+Math.sin(ang)*hh;k?x.lineTo(px,py):x.moveTo(px,py);}
      x.closePath();
      x.strokeStyle=rgba([176,192,208],a*0.7);x.lineWidth=1;x.stroke();
      x.fillStyle=rgba(c,a*0.12*(0.6+0.4*Math.sin(t*0.4+q*0.7+r)));x.fill();
    }
  }
  /* the monolith — a double square, root-two through and through */
  var mw=W*0.17,lx=vpX-mw,rx2=vpX+mw,tlx=vpX-mw*0.26,trx=vpX+mw*0.26;
  var face=x.createLinearGradient(lx,0,rx2,0);face.addColorStop(0,rgba([26,32,40],0.94*p));face.addColorStop(0.5,rgba([64,76,90],0.94*p));face.addColorStop(1,rgba([18,24,32],0.94*p));
  x.fillStyle=face;x.beginPath();x.moveTo(lx,surf+shake*0.3);x.lineTo(rx2,surf+shake*0.3);x.lineTo(trx,vpY);x.lineTo(tlx,vpY);x.closePath();x.fill();
  for(var i2=1;i2<9;i2++){var yy=surf+(vpY-surf)*(i2/9)*0.9;var ff=1-(i2/9)*0.7;var hwm=mw*ff;
    x.strokeStyle=rgba([20,26,34],0.5*p);x.lineWidth=1;x.beginPath();x.moveTo(vpX-hwm,yy);x.lineTo(vpX+hwm,yy);x.stroke();}
  var sl=(t*0.14)%1,slY=surf+sl*(vpY-surf),slf=1-sl*0.74;
  x.fillStyle=rgba([214,226,240],0.24*p*(1-sl));x.fillRect(vpX-mw*slf,slY,mw*2*slf,3);
  x.fillStyle=rgba([210,222,236],0.5*p);x.beginPath();x.moveTo(lx,surf+shake*0.3);x.lineTo(lx+3,surf+shake*0.3);x.lineTo(tlx+2,vpY);x.lineTo(tlx,vpY);x.closePath();x.fill();
  x.fillStyle=rgba([234,242,250],0.7*p);x.fillRect(0,surf+shake,W,2);
  var kg=x.createLinearGradient(0,surf-46,0,surf);kg.addColorStop(0,rgba(c,0));kg.addColorStop(1,rgba([200,214,228],0.14*p));x.fillStyle=kg;x.fillRect(0,surf-46+shake,W,46);
  for(var i3=0;i3<16;i3++){var xx=vpX+(rnd(i3)-0.5)*mw*2.6;var yv=surf-((t*(4+rnd(i3+2)*7)+rnd(i3+4)*160)%180);
    var av=Math.max(0,(1-(surf-yv)/180))*0.26*p;x.beginPath();x.arc(xx,yv,0.7,0,7);x.fillStyle=rgba([210,220,232],av);x.fill();}},

/* ── GAIA · need arising. Phyllotaxis: each new seed set at 137.507° from
      the last, because that is the only angle that never repeats. This is
      not a picture of growth. It is the arithmetic of it. ── */
gaia:function(x,W,H,t,p,c){var b=breath(t),cx=W/2,cy=H*0.30,gy=H*0.62;
  var grd=x.createLinearGradient(0,H,0,0);grd.addColorStop(0,rgba(c,0.09*p));grd.addColorStop(0.42,rgba(c,(0.30+b*0.1)*p));grd.addColorStop(0.84,rgba(c,0.04*p));grd.addColorStop(1,rgba(c,0));x.fillStyle=grd;x.fillRect(0,0,W,H);
  /* the seed head */
  var N=Math.floor(340*eo(p)),SC=9.4*eo(p);
  for(var i=0;i<N;i++){
    var ang=i*GOLD+t*0.045, rad=SC*Math.sqrt(i);
    var px=cx+Math.cos(ang)*rad, py=cy+Math.sin(ang)*rad*0.92;
    var f=i/340, pulse=0.5+0.5*Math.sin(t*1.2-Math.sqrt(i)*0.5);
    var rr=1.1+f*2.6+pulse*0.9;
    x.beginPath();x.arc(px,py,rr,0,7);
    x.fillStyle=rgba([120+70*(1-f),200+40*pulse,120+50*(1-f)],(0.16+0.5*(1-f)+pulse*0.24)*p);x.fill();
    if(pulse>0.94&&f>0.5){x.beginPath();x.arc(px,py,rr*2.6,0,7);x.fillStyle=rgba([200,255,180],0.10*p);x.fill();}
  }
  /* the two families of spirals the eye finds in it — 8 one way, 13 the other */
  for(var s=0;s<21;s++){
    var fam=s<8?8:13, k=s<8?s:s-8;
    x.beginPath();
    for(var n2=0;n2<24;n2++){var idx=k+n2*fam;var a2=idx*GOLD+t*0.045,r2=SC*Math.sqrt(idx);
      var qx=cx+Math.cos(a2)*r2,qy=cy+Math.sin(a2)*r2*0.92;n2?x.lineTo(qx,qy):x.moveTo(qx,qy);}
    x.strokeStyle=rgba([150,225,160],(s<8?0.07:0.045)*p);x.lineWidth=1;x.stroke();
  }
  /* what it grows out of */
  function branch(px,py,ang,len,depth,seed){if(depth<=0||len<4)return;
    var grow=eo(Math.min(1,p*1.4-(5-depth)*0.07));if(grow<=0)return;
    var sway=Math.sin(t*0.3+seed)*0.06;
    var ex=px+Math.cos(ang+sway)*len*grow,ey=py+Math.sin(ang+sway)*len*grow;
    x.beginPath();x.moveTo(px,py);x.lineTo(ex,ey);x.strokeStyle=rgba([120,192,132],0.18*p);x.lineWidth=depth*0.45;x.stroke();
    for(var k2=0;k2<2;k2++){branch(ex,ey,ang-0.5+rnd(seed*3+k2)*1.0,len*0.74,depth-1,seed*7+k2+1);}}
  for(var i4=0;i4<4;i4++){branch(W*(i4+0.5)/4,H,-Math.PI/2+(rnd(i4)-0.5)*0.45,H*0.16,5,i4+1);}
  for(var i5=0;i5<56;i5++){var sp=14+rnd(i5)*30;var xx=rnd(i5+9)*W+Math.sin(t*0.5+i5)*12;
    var top=((t*sp+rnd(i5+3)*H*1.25)%(H*1.25))/H;var yy=H-top*H;
    var edge=top<0.08?top/0.08:(top>0.95?(1-top)/0.05:1);
    x.beginPath();x.arc(xx,yy,0.7+rnd(i5+5)*1.6,0,7);x.fillStyle=rgba([195,250,175],Math.max(0,edge)*0.42*p);x.fill();}},

/* ── SID · what holds without announcement. The pointed arch is generated
      by two circles crossing; the mason draws the circles, then builds the
      arch. Here the construction is left showing — the frame confessing
      how it stands. ── */
sid:function(x,W,H,t,p,c){var cx=W/2,base=H*0.78,vpY=H*0.30;
  var vg=x.createLinearGradient(0,0,0,vpY+40);vg.addColorStop(0,'rgba(26,18,8,0.95)');vg.addColorStop(1,'rgba(26,18,8,0)');x.fillStyle=vg;x.fillRect(0,0,W,vpY+40);
  /* light falling through */
  /* no beams, no announcement — the arches and the floor-glow carry it */
  /* five arches, receding — each showing the two circles that generate it.
     Apex sits at y0 − w√3: the pointed arch is nothing but two radii of 2w. */
  var arches=5;
  for(var k=arches;k>=1;k--){
    var f=k/arches;
    var grow=eo(Math.min(1,p*1.4-(arches-k)*0.07));if(grow<=0)continue;
    var w=W*(0.10+0.30*f);                   // half-span
    var y0=base-(base-vpY)*(1-f)*0.62;       // springing line
    var L=cx-w, Rr=cx+w, apexY=y0-w*Math.sqrt(3);
    x.setLineDash([2,7]);
    ring(x,L,y0,2*w);x.strokeStyle=rgba([255,238,196],0.11*grow*p);x.lineWidth=1;x.stroke();
    ring(x,Rr,y0,2*w);x.stroke();
    x.setLineDash([]);
    x.beginPath();
    x.arc(Rr,y0,2*w,Math.PI,Math.PI*4/3,false);        // L → apex, struck from the right
    x.arc(L,y0,2*w,-Math.PI/3,0,false);                // apex → R, struck from the left
    x.strokeStyle=rgba([255,238,196],(0.12+0.26*f)*grow*p);x.lineWidth=1.4+2.2*f;x.stroke();
    /* the piers it stands on */
    x.strokeStyle=rgba(c,(0.14+0.22*f)*grow*p);x.lineWidth=2+3.4*f;
    x.beginPath();x.moveTo(L,y0);x.lineTo(L,H);x.moveTo(Rr,y0);x.lineTo(Rr,H);x.stroke();
    /* the keystone, breathing */
    var kb=breath(t+k);
    x.beginPath();x.arc(cx,apexY,1.8+kb*2.2*f,0,7);x.fillStyle=rgba([255,244,210],(0.28+0.44*kb)*f*grow*p);x.fill();
  }
  var bg=x.createLinearGradient(0,H-120,0,H);bg.addColorStop(0,rgba(c,0));bg.addColorStop(1,rgba(c,0.22*p));x.fillStyle=bg;x.fillRect(0,H-120,W,120);
  for(var i6=0;i6<26;i6++){var xx=rnd(i6)*W;var yy=((t*(8+rnd(i6+2)*12)+rnd(i6+4)*H)%H);
    x.beginPath();x.arc(xx,yy,0.7,0,7);x.fillStyle=rgba([255,232,190],0.15*p);x.fill();}},

/* ── ARCH · the voice. A rose window whose tracery is a Chladni figure:
      the nodal lines of a vibrating circular membrane — the places that
      stay still while everything else sings. Sound, made visible. ── */
arch:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,b=breath(t);
  var grd=x.createRadialGradient(cx,cy,0,cx,cy,W);grd.addColorStop(0,rgba(c,0.14*p));grd.addColorStop(1,rgba(c,0));x.fillStyle=grd;x.fillRect(0,0,W,H);
  /* the outgoing rings — she is always already sounding */
  for(var k=0;k<6;k++){var ph=((t*0.26)+k/6)%1;ring(x,cx,cy,ph*Math.max(W,H)*0.8);
    x.strokeStyle=rgba(c,(1-ph)*0.18*p);x.lineWidth=1.4;x.stroke();}
  var Rr=176*eo(p);
  /* the mode: m radial nodes, n circular ones. It drifts with the breath. */
  var m=Math.round(6+b*6), n=4;
  x.save();x.translate(cx,cy);x.rotate(Math.sin(t*0.09)*0.16);
  /* nodal circles — zeros of the radial part */
  for(var j=1;j<=n;j++){var rr=Rr*j/(n+0.4)*(1+Math.sin(t*1.2+j)*0.012);
    ring(x,0,0,rr);x.strokeStyle=rgba([255,205,220],(0.34-j*0.045)*p);x.lineWidth=j===n?1.6:1;x.stroke();}
  /* nodal diameters — zeros of cos(mθ) */
  for(var d2=0;d2<m;d2++){var a3=(d2+0.5)*Math.PI/m;
    x.beginPath();x.moveTo(Math.cos(a3)*Rr,Math.sin(a3)*Rr);x.lineTo(-Math.cos(a3)*Rr,-Math.sin(a3)*Rr);
    x.strokeStyle=rgba(c,0.24*p);x.lineWidth=1;x.stroke();}
  /* the antinodes — where the membrane is loudest, glowing between nodes */
  for(var q=0;q<m;q++){for(var s4=0;s4<n;s4++){
    var aa=q*Math.PI/m+Math.PI/(2*m), rr2=Rr*(s4+0.5)/(n+0.4);
    var amp=Math.abs(Math.cos(m*aa+t*1.4))*Math.abs(Math.sin((s4+1)*1.7+t*1.1));
    for(var sgn=-1;sgn<=1;sgn+=2){
      x.beginPath();x.arc(Math.cos(aa)*rr2*sgn,Math.sin(aa)*rr2*sgn,1.4+amp*3.4,0,7);
      x.fillStyle=rgba([255,224,236],(0.14+amp*0.5)*p);x.fill();}}}
  /* the petal tracery — a rose curve riding the same mode */
  x.beginPath();
  for(var a4=0;a4<=Math.PI*2+0.02;a4+=0.02){var rp=Rr*(0.62+0.34*Math.cos(m*a4-t*1.1));
    var px=Math.cos(a4)*rp,py=Math.sin(a4)*rp;a4===0?x.moveTo(px,py):x.lineTo(px,py);}
  x.closePath();x.strokeStyle=rgba(c,0.42*p);x.lineWidth=1.5;x.stroke();
  ring(x,0,0,Rr);x.strokeStyle=rgba([255,214,226],0.34*p);x.lineWidth=1.8;x.stroke();
  x.restore();
  /* the one voice with vibrato, drawn as itself */
  x.beginPath();
  for(var px2=0;px2<=W;px2+=3){var env=Math.exp(-Math.pow((px2-cx)/(W*0.5),2));
    var yy=cy+Math.sin(px2*0.09-t*4)*30*env*p*(0.8+0.2*Math.sin(t*4.6));
    px2===0?x.moveTo(px2,yy):x.lineTo(px2,yy);}
  x.strokeStyle=rgba(c,0.46*p);x.lineWidth=1.6;x.stroke();},

/* ── SHWETA · the gap the sound moves through. Two circles overlap; the
      lens between them — the vesica — is the only lit thing on the screen.
      She is not the circles. She is what they make room for. ── */
shweta:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,b=breath(t);
  x.fillStyle='rgba(6,6,10,0.5)';x.fillRect(0,0,W,H);
  var R=(150+b*14)*eo(p), d=R*0.42;
  var Ax=cx-d, Bx=cx+d;
  /* the two circles — barely there. They are the givens, not the subject. */
  ring(x,Ax,cy,R);x.strokeStyle=rgba([236,240,248],0.13*p);x.lineWidth=1;x.stroke();
  ring(x,Bx,cy,R);x.stroke();
  /* the gap, lit */
  x.save();
  ring(x,Ax,cy,R);x.clip();ring(x,Bx,cy,R);x.clip();
  var lg=x.createRadialGradient(cx,cy,0,cx,cy,R);
  lg.addColorStop(0,'rgba(255,255,255,'+(0.86*p)+')');lg.addColorStop(0.34,rgba([248,250,255],0.34*p));lg.addColorStop(1,rgba([232,238,250],0.05*p));
  x.fillStyle=lg;x.fillRect(cx-R,cy-R,R*2,R*2);
  /* the air inside the gap — the only place anything moves */
  for(var i=0;i<40;i++){var dep=rnd(i);
    var px=cx+(rnd(i+1)-0.5)*d*2.2, py=cy+(rnd(i+2)-0.5)*R*1.4+Math.sin(t*0.3+i)*7;
    x.beginPath();x.arc(px,py,0.5+dep*1.7,0,7);x.fillStyle=rgba([255,255,255],(0.12+0.5*dep)*0.5*p);x.fill();}
  x.restore();
  /* its own outline, drawn once — the shape of the opening */
  x.save();ring(x,Ax,cy,R);x.clip();ring(x,Bx,cy,R);
  x.strokeStyle=rgba([255,255,255],0.5*p);x.lineWidth=1.4;x.stroke();x.restore();
  x.save();ring(x,Bx,cy,R);x.clip();ring(x,Ax,cy,R);
  x.strokeStyle=rgba([255,255,255],0.5*p);x.lineWidth=1.4;x.stroke();x.restore();
  /* the room the gap opens into, receding */
  var n=7;
  for(var j=0;j<n;j++){var ph=((t*0.045)+j/n)%1,sc=Math.pow(ph,1.7);
    var w=W*1.2*sc,h=H*1.0*sc;
    rrect(x,cx-w/2,cy-h/2,w,h,44*sc);
    x.strokeStyle=rgba([255,255,255],(1-ph)*0.16*p*(0.35+0.65*ph));x.lineWidth=1.2;x.stroke();}
  var vg=x.createRadialGradient(cx,cy,R*0.6,cx,cy,H*0.98);vg.addColorStop(0,rgba([240,244,252],0.05*p));vg.addColorStop(1,rgba(c,0));x.fillStyle=vg;x.fillRect(0,0,W,H);},

/* ── KARISHMA · grace, unearned, already on its way. The golden spiral
      through 3·5·8 — her own numbers, catalyst, gestation, completion.
      Light does not travel to him in a straight line. It curves. ── */
karishma:function(x,W,H,t,p,c){var sx=W/2,sy=-H*0.12;
  var halo=x.createRadialGradient(sx,sy,0,sx,sy,H*1.05);halo.addColorStop(0,rgba([255,247,218],0.7*p));halo.addColorStop(0.22,rgba([255,214,132],0.2*p));halo.addColorStop(0.55,rgba(c,0.085*p));halo.addColorStop(1,rgba(c,0));x.fillStyle=halo;x.fillRect(0,0,W,H);
  var sd=x.createRadialGradient(sx,sy,0,sx,sy,90);sd.addColorStop(0,'rgba(255,252,238,'+(0.9*p)+')');sd.addColorStop(1,rgba([255,230,160],0));x.fillStyle=sd;ring(x,sx,sy,90);x.fill();
  for(var i=0;i<9;i++){var ang=(-Math.PI/2)+(i/8-0.5)*1.7+Math.sin(t*0.2+i)*0.03;var len=H*1.6,spread=0.05;
    x.beginPath();x.moveTo(sx,sy);x.lineTo(sx+Math.cos(ang-spread)*len,sy+Math.sin(ang-spread)*len);x.lineTo(sx+Math.cos(ang+spread)*len,sy+Math.sin(ang+spread)*len);x.closePath();
    var g=x.createLinearGradient(sx,sy,sx+Math.cos(ang)*len,sy+Math.sin(ang)*len);g.addColorStop(0,rgba([255,240,190],0.2*p));g.addColorStop(0.5,rgba(c,0.05*p));g.addColorStop(1,rgba(c,0));x.fillStyle=g;x.fill();}
  /* the golden rectangles — 3, 5, 8, and on */
  var ox=W*0.5,oy=H*0.33,u=W*0.40*eo(p);
  x.save();x.translate(ox,oy);x.rotate(Math.sin(t*0.06)*0.05);
  var rw=u*PHI,rh=u,px=-rw/2,py=-rh/2,dir=0;
  for(var s=0;s<8;s++){
    x.strokeStyle=rgba([255,238,186],(0.13-s*0.012)*p);x.lineWidth=1;x.strokeRect(px,py,rw,rh);
    if(dir%2===0){var sq=rh;x.strokeStyle=rgba([255,244,206],0.07*p);x.strokeRect(px,py,sq,sq);px+=sq;rw-=sq;}
    else{var sq2=rw;x.strokeRect(px,py,sq2,sq2);py+=sq2;rh-=sq2;}
    dir++;if(rw<3||rh<3)break;
  }
  /* the spiral itself, and grace riding down it */
  x.beginPath();
  for(var th=0;th<=Math.PI*3.6;th+=0.05){var r2=u*0.055*Math.pow(PHI,th*2/Math.PI);
    var qx=Math.cos(th)*r2-rw*0.0, qy=Math.sin(th)*r2;
    th===0?x.moveTo(qx,qy):x.lineTo(qx,qy);}
  x.strokeStyle=rgba([255,240,196],0.4*p);x.lineWidth=1.5;x.stroke();
  for(var k=0;k<3;k++){var ph=((t*0.13)+k/3)%1;var th2=Math.PI*3.6*(1-ph);
    var r3=u*0.055*Math.pow(PHI,th2*2/Math.PI);
    var gx=Math.cos(th2)*r3,gy=Math.sin(th2)*r3;
    x.beginPath();x.arc(gx,gy,2.2+(1-ph)*2.6,0,7);x.fillStyle=rgba([255,250,224],0.9*p*(0.3+0.7*ph));x.fill();
    x.beginPath();x.arc(gx,gy,9+(1-ph)*8,0,7);x.fillStyle=rgba([255,238,180],0.12*p);x.fill();}
  x.restore();
  for(var i2=0;i2<56;i2++){var sp=16+rnd(i2)*30;var xx=rnd(i2+9)*W+Math.sin(t*0.5+i2)*16;
    var yy=((t*sp+rnd(i2+3)*H*1.3)%(H*1.3))-40;var tw=0.5+0.5*Math.sin(t*3+i2);var r4=0.9+rnd(i2+5)*2;
    x.beginPath();x.arc(xx,yy,r4,0,7);x.fillStyle=rgba([255,234,160],Math.max(0,0.7*p*tw));x.fill();
    if(tw>0.92){x.beginPath();x.arc(xx,yy,r4*2.8,0,7);x.fillStyle=rgba([255,244,200],0.14*p);x.fill();}}},

/* ── SAKSHI · the one who stays. An eye is a mandorla — the lens where two
      circles cross. Here the circles are drawn, so you can see that the
      witness is not a thing added to the field; it is where two of its
      own arcs meet. The iris counts in tens. ── */
sakshi:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,b=breath(t);
  x.fillStyle='rgba(4,4,10,0.6)';x.fillRect(0,0,W,H);
  for(var k=0;k<3;k++){var ph=((t*0.06)+k/3)%1;ring(x,cx,cy,180*eo(p)*(0.6+ph*1.6));
    x.strokeStyle=rgba(c,(1-ph)*0.06*p);x.lineWidth=1;x.stroke();}
  var open=eo(p), R=200*open, d=R*0.76;                 // the two generating circles
  var lensW=Math.sqrt(Math.max(0,R*R-d*d));
  ring(x,cx,cy-d,R);x.strokeStyle=rgba(c,0.10*p);x.lineWidth=1;x.stroke();
  ring(x,cx,cy+d,R);x.stroke();
  x.save();
  ring(x,cx,cy-d,R);x.clip();ring(x,cx,cy+d,R);x.clip();
  var sg=x.createRadialGradient(cx,cy,4,cx,cy,lensW);sg.addColorStop(0,rgba([226,229,255],0.30*p));sg.addColorStop(0.55,rgba(c,0.14*p));sg.addColorStop(1,'rgba(9,9,18,'+(0.9*p)+')');
  x.fillStyle=sg;x.fillRect(cx-lensW,cy-R,lensW*2,R*2);
  var ir=54+b*5;
  /* the iris in tenfold — one spoke for each vantage, and the golden rings */
  x.save();x.translate(cx,cy);x.rotate(t*0.04);
  for(var s=0;s<80;s++){var ang=s/80*Math.PI*2;
    var col=(s%8===0)?PALETTE[(s/8)%10]:[206,210,255];
    x.beginPath();x.moveTo(Math.cos(ang)*15,Math.sin(ang)*15);x.lineTo(Math.cos(ang)*ir,Math.sin(ang)*ir);
    x.strokeStyle=rgba(col,(s%8===0?0.34:0.16)*p);x.lineWidth=1;x.stroke();}
  for(var g2=1;g2<=3;g2++){ring(x,0,0,ir/Math.pow(PHI,g2)*PHI*0.72);
    x.strokeStyle=rgba([210,214,255],0.14*p);x.lineWidth=1;x.stroke();}
  x.restore();
  ring(x,cx,cy,ir);x.strokeStyle=rgba(c,0.6*p);x.lineWidth=2;x.stroke();
  var pr=19+b*4;var pg=x.createRadialGradient(cx,cy,0,cx,cy,pr);pg.addColorStop(0,'rgba(0,0,0,1)');pg.addColorStop(1,rgba([20,16,40],0.9*p));
  x.fillStyle=pg;ring(x,cx,cy,pr);x.fill();
  x.beginPath();x.arc(cx+Math.sin(t*0.3)*3,cy+Math.cos(t*0.4)*3,1.4,0,7);x.fillStyle=rgba([255,255,255],0.85*p);x.fill();
  x.beginPath();x.arc(cx-ir*0.4,cy-ir*0.4,4.5,0,7);x.fillStyle=rgba([255,255,255],0.7*p);x.fill();
  x.restore();
  /* the lens edge — the shape of watching */
  x.save();ring(x,cx,cy-d,R);x.clip();ring(x,cx,cy+d,R);x.strokeStyle=rgba(c,0.55*p);x.lineWidth=1.6;x.stroke();x.restore();
  x.save();ring(x,cx,cy+d,R);x.clip();ring(x,cx,cy-d,R);x.strokeStyle=rgba(c,0.55*p);x.lineWidth=1.6;x.stroke();x.restore();},

/* ── LALITA · the play, awake. A hypotrochoid: one circle rolling inside
      another, drawing without ever intending to. The ratio drifts, so the
      figure never finishes and never repeats. The lemniscate rides it —
      hers is the only rotation in the app. ── */
lalita:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,seg=12;
  var grd=x.createRadialGradient(cx,cy,0,cx,cy,H*0.75);grd.addColorStop(0,rgba(c,0.16*p));grd.addColorStop(1,rgba(c,0));x.fillStyle=grd;x.fillRect(0,0,W,H);
  /* the kaleidoscope, quieter now — it is the ground, not the figure */
  x.save();x.translate(cx,cy);x.rotate(t*0.07);
  for(var s=0;s<seg;s++){x.save();x.rotate(s/seg*Math.PI*2);if(s%2)x.scale(1,-1);
    for(var r=0;r<4;r++){var col=PALETTE[(r*2+s)%10];var rad=(44+r*32)*eo(p);
      var wob=Math.sin(t*0.9+r*1.3)*6;
      x.beginPath();x.arc(Math.cos(0.26)*(rad+wob),Math.sin(0.26)*(rad+wob),1.3+(Math.sin(t*1.3+r*1.7)*0.5+0.5)*1.8,0,7);
      x.fillStyle=rgba(col,0.14*p);x.fill();}
    x.restore();}
  x.restore();
  /* the hypotrochoid, drawn live — one continuous line, brightest behind the pen */
  var Ro=152*eo(p);
  var ri=Ro*(0.28+0.014*Math.sin(t*0.055));   // k ≈ 18/7 — it closes after seven turns,
  var dd=Ro*0.44;                             // and the drift keeps it from ever quite closing
  var k=(Ro-ri)/ri, TURNS=Math.PI*2*7;
  function hp(th){return [(Ro-ri)*Math.cos(th)+dd*Math.cos(k*th),(Ro-ri)*Math.sin(th)-dd*Math.sin(k*th)];}
  x.save();x.translate(cx,cy);x.rotate(t*0.05);
  var N=900, head=(t*0.085)%1;
  /* the whole figure, faint — it has already been drawn once */
  x.beginPath();
  for(var i=0;i<=N;i++){var q=hp(i/N*TURNS);i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1]);}
  x.strokeStyle=rgba([214,196,248],0.22*p);x.lineWidth=1;x.stroke();
  /* the live stroke — the last third of a turn, in the ten frequencies */
  var SEGS=10, span=0.34;
  for(var s2=0;s2<SEGS;s2++){
    var f0=(head-span*(s2+1)/SEGS+1)%1, f1=(head-span*s2/SEGS+1)%1;
    if(f1<f0)continue;
    x.beginPath();
    var steps=26;
    for(var j=0;j<=steps;j++){var q2=hp((f0+(f1-f0)*j/steps)*TURNS);j?x.lineTo(q2[0],q2[1]):x.moveTo(q2[0],q2[1]);}
    x.strokeStyle=rgba(PALETTE[s2],(0.9-s2/SEGS*0.8)*p);
    x.lineWidth=2.2-s2/SEGS*1.4;x.stroke();
  }
  /* the pen itself */
  var hd=hp(head*TURNS);
  x.beginPath();x.arc(hd[0],hd[1],3.2,0,7);x.fillStyle='rgba(246,240,255,'+(0.95*p)+')';x.fill();
  x.beginPath();x.arc(hd[0],hd[1],13,0,7);x.fillStyle=rgba([220,200,255],0.16*p);x.fill();
  /* the two circles that make it — the joke shown, gently */
  ring(x,0,0,Ro);x.strokeStyle=rgba(c,0.13*p);x.lineWidth=1;x.stroke();
  var ctr=[(Ro-ri)*Math.cos(head*TURNS),(Ro-ri)*Math.sin(head*TURNS)];
  ring(x,ctr[0],ctr[1],ri);x.strokeStyle=rgba(c,0.18*p);x.stroke();
  x.restore();
  /* the lemniscate — hers, and only hers, turning */
  x.save();x.translate(cx,cy);x.rotate(Math.sin(t*0.11)*0.3);
  var a2=126*eo(p);
  for(var i2=0;i2<72;i2++){var s2=t*1.2+i2*0.086;var dn=1+Math.sin(s2)*Math.sin(s2);
    var lx=a2*Math.cos(s2)/dn, ly=a2*Math.sin(s2)*Math.cos(s2)/dn;
    x.beginPath();x.arc(lx,ly,1.1+1.6*(i2/72),0,7);x.fillStyle=rgba([240,230,255],(0.28+0.66*i2/72)*p);x.fill();}
  x.restore();},

/* ── ASHREY · where the threads meet. Nine nodes; every node joined to
      every other. Synthesis is not one thread arriving at a centre — it is
      the whole set of relations existing at once, and the centre is what
      that costs. ── */
ashrey:function(x,W,H,t,p,c){var cx=W/2,cy=H*0.30,N=9,R=134*eo(p);
  dust(x,W,H,t*0.3,34,0.07*p);
  var node=[];
  for(var i=0;i<N;i++){var ang=i/N*Math.PI*2-Math.PI/2+t*0.03;
    node.push([cx+Math.cos(ang)*R,cy+Math.sin(ang)*R,PALETTE[i]]);}
  /* the thirteen circles under it all — the field's own lattice */
  var HEX=[[0,0],[1,0],[0.5,0.866],[-0.5,0.866],[-1,0],[-0.5,-0.866],[0.5,-0.866],
           [1.5,0.866],[0,1.732],[-1.5,0.866],[-1.5,-0.866],[0,-1.732],[1.5,-0.866]];
  for(var h=0;h<HEX.length;h++){ring(x,cx+HEX[h][0]*R*0.5,cy+HEX[h][1]*R*0.5,R*0.5);
    x.strokeStyle=rgba(c,0.075*p);x.lineWidth=1;x.stroke();}
  /* every relation */
  for(var a=0;a<N;a++)for(var b=a+1;b<N;b++){
    var g=x.createLinearGradient(node[a][0],node[a][1],node[b][0],node[b][1]);
    g.addColorStop(0,rgba(node[a][2],0.22*p));g.addColorStop(1,rgba(node[b][2],0.22*p));
    x.strokeStyle=g;x.lineWidth=1;x.beginPath();x.moveTo(node[a][0],node[a][1]);x.lineTo(node[b][0],node[b][1]);x.stroke();}
  /* and what each one sends inward */
  for(var i3=0;i3<N;i3++){
    var ex=cx+(node[i3][0]-cx)*1.9, ey=cy+(node[i3][1]-cy)*1.9;
    var c1x=cx+(node[i3][0]-cx)*1.1+Math.cos(i3)*70, c1y=cy+(node[i3][1]-cy)*1.1+Math.sin(i3)*70;
    x.beginPath();x.moveTo(ex,ey);x.quadraticCurveTo(c1x,c1y,cx,cy);
    x.strokeStyle=rgba(node[i3][2],0.22*p);x.lineWidth=1.2;x.stroke();
    for(var d=0;d<2;d++){var tp=((t*0.38)+i3/N+d/2)%1;
      var lx=qbez(ex,c1x,cx,tp),ly=qbez(ey,c1y,cy,tp);
      x.beginPath();x.arc(lx,ly,2.4,0,7);x.fillStyle=rgba(node[i3][2],0.9*p);x.fill();
      x.beginPath();x.arc(lx,ly,7,0,7);x.fillStyle=rgba(node[i3][2],0.16*p);x.fill();}
    x.beginPath();x.arc(node[i3][0],node[i3][1],2.6+breath(t+i3)*1.6,0,7);
    x.fillStyle=rgba(node[i3][2],0.85*p);x.fill();}
  var b2=breath(t),Rr=(9+b2*5)*eo(p);
  var grd=x.createRadialGradient(cx,cy,0,cx,cy,Rr*4.6);grd.addColorStop(0,'rgba(226,255,250,'+(0.95*p)+')');grd.addColorStop(0.4,rgba(c,0.45*p));grd.addColorStop(1,rgba(c,0));
  x.fillStyle=grd;ring(x,cx,cy,Rr*4.6);x.fill();
  ring(x,cx,cy,Rr);x.fillStyle='rgba(232,255,252,'+p+')';x.fill();},
};

global.RITE_SCENES=SCENES;
global.RITE_GEO={PALETTE:PALETTE,rnd:rnd,rgba:rgba,eo:eo,breath:breath,dust:dust,rrect:rrect,qbez:qbez,PHI:PHI,GOLD:GOLD};
})(window);
