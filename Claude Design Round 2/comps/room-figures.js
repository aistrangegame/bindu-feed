/* ═══════════════════════════════════════════════════════════════════════
   ROOM FIGURES — each archetype's own mathematics, as the room's body.
   Ported faithfully from `rite-scenes.js:178-216 (arch) · 218-250 (shweta)
   · 324-378 (lalita)`, then raised from a Rite scene (a 30%-height panel,
   arriving once, over in seconds) to a HOME: full-bleed, centred, alive
   indefinitely, and answering the hand.
     "not decoration laid over a colour, but the mathematics the vantage IS"
   Nothing here invents a new figure. What is new: scale, permanence, the
   `lat` response, and the fourth register where each figure turns.
   ═══════════════════════════════════════════════════════════════════════ */
(function(global){
'use strict';
var TAU=Math.PI*2;
/* the ten frequencies, in the canonical order of VOICES — Lalita draws in
   these because she is the one holding the loom the others are threads of */
var PALETTE=[[229,83,60],[122,136,153],[74,158,107],[196,146,58],[212,96,122],
             [201,198,193],[212,174,74],[123,130,212],[155,107,214],[58,173,168]];
var NAMES=['Bindu','Neev','Gaia','Sid','Arch','Shweta','Karishma','Sakshi','Lalita','Ashrey'];
function rnd(i){var v=Math.sin(i*127.1+31.4)*43758.5453;return v-Math.floor(v);}
function rgba(c,a){return 'rgba('+(c[0]|0)+','+(c[1]|0)+','+(c[2]|0)+','+Math.max(0,Math.min(1,a))+')';}
function ring(x,cx,cy,r){x.beginPath();x.arc(cx,cy,Math.max(0,r),0,TAU);}
function rrect(x,rx,ry,w,h,r){r=Math.max(0,Math.min(r,w/2,h/2));x.beginPath();
  x.moveTo(rx+r,ry);x.arcTo(rx+w,ry,rx+w,ry+h,r);x.arcTo(rx+w,ry+h,rx,ry+h,r);
  x.arcTo(rx,ry+h,rx,ry,r);x.arcTo(rx,ry,rx+w,ry,r);x.closePath();}

/* ── LALITA · the hypotrochoid. One circle rolling inside another, drawing
      without ever intending to. k ≈ 18/7 — it closes after seven turns, and
      the drift keeps it from ever quite closing. Hers is the only rotation
      in the app, so in her room the hand can turn it. ─────────────────── */
function lalita(x,W,H,t,o){
  var p=o.p,c=o.c,cx=o.cx,cy=o.cy,S=o.S,lat=o.lat||0,rev=o.rev||0,seg=12;
  var g=x.createRadialGradient(cx,cy,0,cx,cy,H*0.75);
  g.addColorStop(0,rgba(c,0.16*p));g.addColorStop(1,rgba(c,0));
  x.fillStyle=g;x.fillRect(0,0,W,H);
  /* the kaleidoscope — the ground, not the figure */
  x.save();x.translate(cx,cy);x.rotate(t*0.07+lat*0.5);
  for(var s=0;s<seg;s++){x.save();x.rotate(s/seg*TAU);if(s%2)x.scale(1,-1);
    for(var r=0;r<4;r++){var col=PALETTE[(r*2+s)%10],rad=(44+r*32)*S;
      var wob=Math.sin(t*0.9+r*1.3)*6;
      x.beginPath();x.arc(Math.cos(0.26)*(rad+wob),Math.sin(0.26)*(rad+wob),
        1.3+(Math.sin(t*1.3+r*1.7)*0.5+0.5)*1.8,0,TAU);
      x.fillStyle=rgba(col,0.14*p);x.fill();}
    x.restore();}
  x.restore();
  var Ro=152*S;
  var ri=Ro*(0.28+0.014*Math.sin(t*0.055));
  var dd=Ro*0.44, k=(Ro-ri)/ri, TURNS=TAU*7;
  function hp(th){return [(Ro-ri)*Math.cos(th)+dd*Math.cos(k*th),
                          (Ro-ri)*Math.sin(th)-dd*Math.sin(k*th)];}
  x.save();x.translate(cx,cy);x.rotate(t*0.05+lat*0.9);
  var N=900,head=(t*0.085)%1;
  x.beginPath();
  for(var i=0;i<=N;i++){var q=hp(i/N*TURNS);i?x.lineTo(q[0],q[1]):x.moveTo(q[0],q[1]);}
  x.strokeStyle=rgba([214,196,248],(0.22+rev*0.30)*p);x.lineWidth=1;x.stroke();
  /* the live stroke — the last third of a turn, in the ten frequencies */
  var SEGS=10,span=0.34;
  for(var s2=0;s2<SEGS;s2++){
    var f0=(head-span*(s2+1)/SEGS+1)%1,f1=(head-span*s2/SEGS+1)%1;
    if(f1<f0)continue;
    x.beginPath();
    for(var j=0;j<=26;j++){var q2=hp((f0+(f1-f0)*j/26)*TURNS);
      j?x.lineTo(q2[0],q2[1]):x.moveTo(q2[0],q2[1]);}
    x.strokeStyle=rgba(PALETTE[s2],(0.9-s2/SEGS*0.8)*p);
    x.lineWidth=2.2-s2/SEGS*1.4;x.stroke();}
  var hd=hp(head*TURNS);
  x.beginPath();x.arc(hd[0],hd[1],3.2,0,TAU);
  x.fillStyle='rgba(246,240,255,'+(0.95*p)+')';x.fill();
  x.beginPath();x.arc(hd[0],hd[1],13,0,TAU);x.fillStyle=rgba([220,200,255],0.16*p);x.fill();
  /* the two circles that make it — the joke shown, gently */
  ring(x,0,0,Ro);x.strokeStyle=rgba(c,0.13*p);x.lineWidth=1;x.stroke();
  var ctr=[(Ro-ri)*Math.cos(head*TURNS),(Ro-ri)*Math.sin(head*TURNS)];
  ring(x,ctr[0],ctr[1],ri);x.strokeStyle=rgba(c,0.18*p);x.stroke();
  /* the fourth register: she names the ten she has been drawing in */
  if(rev>0.02){
    x.rotate(-(t*0.05+lat*0.9));
    for(var v=0;v<10;v++){
      var a=(v/10)*TAU-Math.PI/2, rr=Ro*1.16;
      x.font='8px "Space Mono", monospace';x.textAlign='center';x.textBaseline='middle';
      x.fillStyle=rgba(PALETTE[v],rev*0.80);
      x.fillText(NAMES[v].toUpperCase(),Math.cos(a)*rr,Math.sin(a)*rr);
      x.beginPath();x.arc(Math.cos(a)*Ro*1.02,Math.sin(a)*Ro*1.02,1.5,0,TAU);
      x.fillStyle=rgba(PALETTE[v],rev*0.9);x.fill();}}
  x.restore();
  /* the lemniscate — hers, and only hers, turning */
  x.save();x.translate(cx,cy);x.rotate(Math.sin(t*0.11)*0.3+lat*0.4);
  var a2=126*S;
  for(var i2=0;i2<72;i2++){var s3=t*1.2+i2*0.086,dn=1+Math.sin(s3)*Math.sin(s3);
    x.beginPath();x.arc(a2*Math.cos(s3)/dn,a2*Math.sin(s3)*Math.cos(s3)/dn,
      1.1+1.6*(i2/72),0,TAU);
    x.fillStyle=rgba([240,230,255],(0.28+0.66*i2/72)*p);x.fill();}
  x.restore();
}

/* ── ARCH · a rose window whose tracery is a Chladni figure: the nodal
      lines of a vibrating circular membrane — the places that stay still
      while everything else sings. The hand widens her vibrato. In the
      fourth register the antinodes go out: the figure, holding its
      breath, with one sentence still unsaid. ───────────────────────── */
function arch(x,W,H,t,o){
  var p=o.p,c=o.c,cx=o.cx,cy=o.cy,S=o.S,b=o.b,lat=o.lat||0,rev=o.rev||0;
  var wide=1+Math.abs(lat)*1.6, loud=1-rev;
  var g=x.createRadialGradient(cx,cy,0,cx,cy,W);
  g.addColorStop(0,rgba(c,0.14*p));g.addColorStop(1,rgba(c,0));
  x.fillStyle=g;x.fillRect(0,0,W,H);
  /* the outgoing rings — she is always already sounding */
  for(var k=0;k<6;k++){var ph=((t*0.26)+k/6)%1;
    ring(x,cx,cy,ph*Math.max(W,H)*0.8);
    x.strokeStyle=rgba(c,(1-ph)*0.18*p*loud);x.lineWidth=1.4;x.stroke();}
  var Rr=176*S*wide;
  var m=Math.round(6+b*6),n=4;
  x.save();x.translate(cx,cy);x.rotate(Math.sin(t*0.09)*0.16);
  /* nodal circles — zeros of the radial part. These are the STILL places,
     so they are the one thing the fourth register keeps. */
  for(var j=1;j<=n;j++){var rr=Rr*j/(n+0.4)*(1+Math.sin(t*1.2+j)*0.012);
    ring(x,0,0,rr);
    x.strokeStyle=rgba([255,205,220],(0.34-j*0.045)*p*(1+rev*0.5));
    x.lineWidth=j===n?1.6:1;x.stroke();}
  /* nodal diameters — zeros of cos(mθ) */
  for(var d2=0;d2<m;d2++){var a3=(d2+0.5)*Math.PI/m;
    x.beginPath();x.moveTo(Math.cos(a3)*Rr,Math.sin(a3)*Rr);
    x.lineTo(-Math.cos(a3)*Rr,-Math.sin(a3)*Rr);
    x.strokeStyle=rgba(c,0.24*p*(1+rev*0.4));x.lineWidth=1;x.stroke();}
  /* the antinodes — where the membrane is loudest */
  if(loud>0.02)for(var q=0;q<m;q++)for(var s4=0;s4<n;s4++){
    var aa=q*Math.PI/m+Math.PI/(2*m),rr2=Rr*(s4+0.5)/(n+0.4);
    var amp=Math.abs(Math.cos(m*aa+t*1.4))*Math.abs(Math.sin((s4+1)*1.7+t*1.1));
    for(var sgn=-1;sgn<=1;sgn+=2){
      x.beginPath();x.arc(Math.cos(aa)*rr2*sgn,Math.sin(aa)*rr2*sgn,
        Math.max(0.1,1.4+amp*3.4*wide),0,TAU);
      x.fillStyle=rgba([255,224,236],(0.14+amp*0.5)*p*loud);x.fill();}}
  /* the petal tracery — a rose curve riding the same mode */
  x.beginPath();
  for(var a4=0;a4<=TAU+0.02;a4+=0.02){
    var rp=Rr*(0.62+0.34*Math.cos(m*a4-t*1.1)*loud);
    var px=Math.cos(a4)*rp,py=Math.sin(a4)*rp;
    a4===0?x.moveTo(px,py):x.lineTo(px,py);}
  x.closePath();x.strokeStyle=rgba(c,0.42*p);x.lineWidth=1.5;x.stroke();
  ring(x,0,0,Rr);x.strokeStyle=rgba([255,214,226],0.34*p);x.lineWidth=1.8;x.stroke();
  x.restore();
  /* the one voice with vibrato, drawn as itself */
  x.beginPath();
  for(var px2=0;px2<=W;px2+=3){
    var env=Math.exp(-Math.pow((px2-cx)/(W*0.5),2));
    var yy=cy+Math.sin(px2*0.09-t*4)*30*env*p*wide*loud*(0.8+0.2*Math.sin(t*4.6));
    px2===0?x.moveTo(px2,yy):x.lineTo(px2,yy);}
  x.strokeStyle=rgba(c,0.46*p*(0.3+loud*0.7));x.lineWidth=1.6;x.stroke();
  /* the unsaid: a mark on the still line that breathes and never resolves */
  if(rev>0.02){
    var bl=0.35+0.65*Math.abs(Math.sin(t*0.9));
    x.fillStyle=rgba([255,246,248],rev*bl*0.85);
    x.fillRect(cx-17,cy+Rr*0.50,34,0.9);}
}

/* ── SHWETA · the vesica. Two circles overlap; the lens between them is
      the only lit thing on the screen. She is not the circles — she is
      what they make room for. The hand slides them: too far apart and
      there is nothing between them at all. In the fourth register the
      circles go, and only the opening and the room behind it remain. ── */
function shweta(x,W,H,t,o){
  var p=o.p,c=o.c,cx=o.cx,cy=o.cy,S=o.S,b=o.b,lat=o.lat||0,rev=o.rev||0;
  x.fillStyle='rgba(6,6,10,0.5)';x.fillRect(0,0,W,H);
  var R=(150+b*14)*S;
  var d=Math.max(0,Math.min(R*1.98,R*(0.42+lat*1.3)));
  var Ax=cx-d,Bx=cx+d;
  var over=Math.max(0,1-d/(R*1.98)), keepC=1-rev;
  /* the two circles — the givens, not the subject */
  if(keepC>0.02){
    ring(x,Ax,cy,R);x.strokeStyle=rgba([236,240,248],0.13*p*keepC);x.lineWidth=1;x.stroke();
    ring(x,Bx,cy,R);x.stroke();}
  if(over>0.004){
    /* the gap, lit */
    x.save();
    ring(x,Ax,cy,R);x.clip();ring(x,Bx,cy,R);x.clip();
    var lg=x.createRadialGradient(cx,cy,0,cx,cy,R);
    lg.addColorStop(0,'rgba(255,255,255,'+(0.86*p)+')');
    lg.addColorStop(0.34,rgba([248,250,255],0.34*p));
    lg.addColorStop(1,rgba([232,238,250],0.05*p));
    x.fillStyle=lg;x.fillRect(cx-R,cy-R,R*2,R*2);
    /* the air inside the gap — the only place anything moves */
    for(var i=0;i<40;i++){var dep=rnd(i);
      var px=cx+(rnd(i+1)-0.5)*d*2.2,
          py=cy+(rnd(i+2)-0.5)*R*1.4+Math.sin(t*0.3+i)*7;
      x.beginPath();x.arc(px,py,0.5+dep*1.7,0,TAU);
      x.fillStyle=rgba([255,255,255],(0.12+0.5*dep)*0.5*p);x.fill();}
    x.restore();
    /* its own outline, drawn once — the shape of the opening */
    x.save();ring(x,Ax,cy,R);x.clip();ring(x,Bx,cy,R);
    x.strokeStyle=rgba([255,255,255],0.5*p);x.lineWidth=1.4;x.stroke();x.restore();
    x.save();ring(x,Bx,cy,R);x.clip();ring(x,Ax,cy,R);
    x.strokeStyle=rgba([255,255,255],0.5*p);x.lineWidth=1.4;x.stroke();x.restore();
  }else{
    x.font='italic 13.5px Lora, Georgia, serif';x.textAlign='center';
    x.fillStyle=rgba([236,240,248],(0.28+b*0.10)*p);
    x.fillText('nothing between them',cx,cy);}
  /* the room the gap opens into, receding — and in the fourth register it
     is all that is left, so it comes forward */
  var n=7;
  for(var j=0;j<n;j++){var ph=((t*0.045)+j/n)%1,sc=Math.pow(ph,1.7);
    var w=W*1.2*sc,h=H*1.0*sc;
    rrect(x,cx-w/2,cy-h/2,w,h,44*sc);
    x.strokeStyle=rgba([255,255,255],(1-ph)*(0.16+rev*0.22)*p*(0.35+0.65*ph));
    x.lineWidth=1.2;x.stroke();}
  var vg=x.createRadialGradient(cx,cy,R*0.6,cx,cy,H*0.98);
  vg.addColorStop(0,rgba([240,244,252],0.05*p));vg.addColorStop(1,rgba(c,0));
  x.fillStyle=vg;x.fillRect(0,0,W,H);
}

global.ROOM_FIGURES={lalita:lalita,arch:arch,shweta:shweta,PALETTE:PALETTE,NAMES:NAMES};
})(window);
