/* THE UNIVERSE · THE SKY ──────────────────────────────────────────
   One continuous descent, four scales, no screens between them:
     the sky      thirteen figures, and life crossing between them
     the region   inside one figure, in its own weather
     the world    a met story is an inhabited planet; depth is how long
                  life has been living there
     the well     down through his own past recognitions, to the Return
   You keep drawing in and you keep arriving somewhere. Nothing snaps,
   nothing zooms to fit, nothing anywhere is counted. ──────────────── */
(function(global){
'use strict';
var U=global.UNI, TAU=U.TAU, BONE=U.BONE;
var hash=U.hash, mix=U.mix, rgba=U.rgba, ring=U.ring, breath=U.breath;
var FLD=global.UNIFIELD;   /* the company. Absent on pages that predate it. */
var SUN=[-0.58,-0.34,0.74];

/* how much of each scale is showing, at this zoom */
function bands(z){
  var sky=1-Math.max(0,Math.min(1,(z-0.55)/0.5));
  var reg=Math.max(0,Math.min(1,(z-0.45)/0.5))*(1-Math.max(0,Math.min(1,(z-3.2)/2.2)));
  var wld=Math.max(0,Math.min(1,(z-2.6)/2.0));
  return {sky:sky,reg:reg,wld:wld};
}

/* ─── an inhabited world ───────────────────────────────────────── */
function planet(x,s,px,py,R,t,lens,detail){
  var room=U.ROOMS[s.room], col=mix(room.rgb,BONE,lens*0.35);
  var spin=t*s.spin, tilt=s.tilt;
  function proj(lat,lon){
    var a=lon+spin;
    var ux=Math.cos(lat)*Math.sin(a), uy=Math.sin(lat), uz=Math.cos(lat)*Math.cos(a);
    var cx2=Math.cos(tilt), sn=Math.sin(tilt);
    return [ux*cx2-uy*sn, ux*sn+uy*cx2, uz, ux,uy,uz];
  }
  /* the body */
  var g=x.createRadialGradient(px-R*0.36,py-R*0.34,R*0.05,px,py,R*1.05);
  if(s.met){
    g.addColorStop(0,rgba(mix(col,[255,250,242],0.34),0.72));
    g.addColorStop(0.45,rgba(mix(col,[20,18,26],0.30),0.62));
    g.addColorStop(1,rgba(mix(col,[6,5,10],0.82),0.96));
  }else{
    g.addColorStop(0,rgba(mix(col,[168,168,178],0.55),0.34));
    g.addColorStop(0.5,rgba(mix(col,[80,80,92],0.6),0.24));
    g.addColorStop(1,'rgba(8,8,12,0.9)');
  }
  x.fillStyle=g;ring(x,px,py,R);x.fill();
  /* land — the same continents every time he comes back */
  if(detail>0.2){
    for(var i=0;i<7;i++){
      var lat=(hash(s.seed*3.1+i)-0.5)*2.2, lon=hash(s.seed*5.7+i)*TAU;
      var p=proj(lat,lon); if(p[2]<=0.06)continue;
      var rr=R*(0.10+hash(s.seed*7.3+i)*0.22)*p[2];
      x.beginPath();x.ellipse(px+p[0]*R,py+p[1]*R,rr,rr*0.72,hash(i)*3,0,TAU);
      x.fillStyle=rgba(mix(col,[16,14,20],0.55),0.30*detail*p[2]);x.fill();
    }
  }
  /* night, and the sky's edge */
  x.save();ring(x,px,py,R);x.clip();
  var ng=x.createRadialGradient(px+R*0.55,py+R*0.5,R*0.1,px+R*0.4,py+R*0.4,R*1.7);
  ng.addColorStop(0,'rgba(2,2,5,0.94)');ng.addColorStop(0.5,'rgba(2,2,5,0.58)');ng.addColorStop(1,'rgba(2,2,5,0)');
  x.fillStyle=ng;x.fillRect(px-R,py-R,R*2,R*2);
  x.restore();
  ring(x,px,py,R*1.02);x.strokeStyle=rgba(mix(col,[255,252,246],0.5),s.met?0.30:0.12);x.lineWidth=1;x.stroke();
  var ag=x.createRadialGradient(px,py,R*0.96,px,py,R*1.5);
  ag.addColorStop(0,rgba(col,s.met?0.16:0.05));ag.addColorStop(1,rgba(col,0));
  x.fillStyle=ag;ring(x,px,py,R*1.5);x.fill();

  if(!s.met||detail<0.25)return;

  /* ─ the civilization. It only exists where he has been. ─ */
  var n=3+s.depth*4, lit=[];
  for(var j=0;j<n;j++){
    var lat0=(hash(s.seed*11.3+j*1.7)-0.5)*2.3, lon0=hash(s.seed*13.1+j*2.3)*TAU;
    if(room.civ==='towers'){lat0*=0.35;}
    if(room.civ==='lines'){lat0=Math.sin(j*0.9)*0.5;lon0=j/n*TAU;}
    if(room.civ==='rings'){var rr2=0.4+(j%3)*0.28;lat0=Math.sin(j*2.1)*rr2;lon0=(j*GOLDLESS(j))%TAU;}
    var p2=proj(lat0,lon0); if(p2[2]<=0.04)continue;
    var illum=p2[3]*SUN[0]+p2[4]*SUN[1]+p2[5]*SUN[2];
    var night=Math.max(0,Math.min(1,(0.18-illum)/0.5));
    var flick=1;
    if(room.civ==='ruins')  flick=hash(s.seed+j+Math.floor(t*0.4))>0.35?1:0.12;
    if(room.civ==='relight')flick=0.25+0.75*Math.max(0,Math.sin(t*0.5-j*0.4));
    if(room.civ==='districts')flick=0.4+0.6*(0.5+0.5*Math.sin(t*1.05-lat0*2.4));
    var sz=(1.1+hash(s.seed*17.7+j)*1.7)*Math.max(0.6,Math.min(2.6,R/38))*(0.5+p2[2]*0.5);
    var a=(0.34+night*0.66)*flick*detail;
    var wx=px+p2[0]*R, wy=py+p2[1]*R;
    lit.push([wx,wy,a,sz]);
    x.beginPath();x.arc(wx,wy,sz,0,TAU);
    x.fillStyle=rgba(mix(col,[255,242,214],night>0.4?0.84:0.35),a);x.fill();
    if(night>0.35&&R>28){x.beginPath();x.arc(wx,wy,sz*4.6,0,TAU);
      x.fillStyle=rgba(mix(col,[255,230,176],0.7),a*0.16);x.fill();}
    /* the towers all face outward; the arrays all speak upward */
    if(room.civ==='towers'&&R>46){x.beginPath();x.moveTo(wx,wy);
      x.lineTo(px+p2[0]*R*1.22,py+p2[1]*R*1.22);
      x.strokeStyle=rgba(col,a*0.4);x.lineWidth=0.8;x.stroke();}
    if(room.civ==='arrays'&&R>46&&j%3===0){x.beginPath();x.moveTo(wx,wy);
      x.lineTo(px+p2[0]*R*1.55,py+p2[1]*R*1.55-R*0.2);
      x.strokeStyle=rgba(mix(col,[220,255,252],0.5),a*0.30);x.lineWidth=0.8;x.stroke();}
    if(room.civ==='shafts'&&R>50){ring(x,wx,wy,sz*3.4);
      x.strokeStyle=rgba(mix(col,[255,190,160],0.4),a*0.28);x.lineWidth=0.7;x.stroke();}
    if(room.civ==='terraces'&&R>50){for(var q=1;q<=2;q++){ring(x,wx,wy,sz*(2.4+q*2.2));
      x.strokeStyle=rgba(mix(col,[210,255,200],0.4),a*0.16);x.lineWidth=0.6;x.stroke();}}
    if(room.civ==='mirrorcities'&&R>44){var pm=proj(-lat0,lon0);
      if(pm[2]>0.04){x.beginPath();x.arc(px+pm[0]*R,py+pm[1]*R,sz*0.8,0,TAU);
        x.fillStyle=rgba(mix(col,[255,244,220],0.6),a*0.45);x.fill();}}
  }
  /* the roads between them, and what moves along the roads */
  if(R>22&&lit.length>1){
    for(var m=0;m<lit.length-1;m++){
      var A=lit[m],B=lit[m+1];
      if(Math.hypot(A[0]-B[0],A[1]-B[1])>R*1.1)continue;
      x.beginPath();x.moveTo(A[0],A[1]);x.lineTo(B[0],B[1]);
      x.strokeStyle=rgba(mix(col,[255,238,206],0.6),Math.min(A[2],B[2])*0.30);x.lineWidth=0.6;x.stroke();
      var ph=((t*0.22+m*0.31)%1);
      x.beginPath();x.arc(A[0]+(B[0]-A[0])*ph,A[1]+(B[1]-A[1])*ph,1.1,0,TAU);
      x.fillStyle=rgba([255,246,226],Math.min(A[2],B[2])*0.85);x.fill();
    }
  }
  /* the rift, the net, the great road — one signature per kind of world */
  if(R>26){
    var sig=room.civ;
    if(sig==='furnaces'){
      x.beginPath();
      for(var f=0;f<=40;f++){var p3=proj(Math.sin(f/40*3.1)*0.7-0.1,f/40*TAU*0.8-0.7);
        if(p3[2]<=0)continue;x.lineTo(px+p3[0]*R,py+p3[1]*R);}
      x.strokeStyle=rgba([255,196,120],0.34*detail);x.lineWidth=1.4;x.stroke();
    }
    if(sig==='weave'){
      for(var la=-2;la<=2;la++){x.beginPath();
        for(var lo=0;lo<=44;lo++){var p4=proj(la*0.45,lo/44*TAU);
          if(p4[2]<=0.02)continue;x.lineTo(px+p4[0]*R,py+p4[1]*R);}
        x.strokeStyle=rgba(col,0.14*detail);x.lineWidth=0.6;x.stroke();}
      for(var lo2=0;lo2<8;lo2++){x.beginPath();
        for(var la2=-20;la2<=20;la2++){var p5=proj(la2/20*1.4,lo2/8*TAU);
          if(p5[2]<=0.02)continue;x.lineTo(px+p5[0]*R,py+p5[1]*R);}
        x.strokeStyle=rgba(col,0.10*detail);x.lineWidth=0.6;x.stroke();}
    }
    if(sig==='rings'){for(var rr3=1;rr3<=3;rr3++){ring(x,px,py,R*(0.28+rr3*0.20));
      x.strokeStyle=rgba(mix(col,[255,230,236],0.4),0.10*detail);x.lineWidth=0.7;x.stroke();}}
  }
  /* what orbits it — only worlds long lived-on have traffic above them */
  if(s.depth>=3&&R>24){
    for(var o=0;o<2;o++){
      var orr=R*(1.34+o*0.30), oe=0.30+o*0.10;
      x.beginPath();x.ellipse(px,py,orr,orr*oe,tilt*0.8,0,TAU);
      x.strokeStyle=rgba(col,0.13*detail);x.lineWidth=0.7;x.stroke();
      var ships=1+o;
      for(var sh=0;sh<ships;sh++){
        var ang=(t*(0.16+o*0.07)+sh/ships+o*0.3)%1*TAU;
        var ox=Math.cos(ang)*orr, oy=Math.sin(ang)*orr*oe;
        var cxr=Math.cos(tilt*0.8), sxr=Math.sin(tilt*0.8);
        x.beginPath();x.arc(px+ox*cxr-oy*sxr,py+ox*sxr+oy*cxr,1.5,0,TAU);
        x.fillStyle=rgba([255,250,238],0.8*detail);x.fill();
      }
    }
    if(room.civ==='ports'&&R>60){
      var pang=(t*0.10)%1*TAU;
      x.beginPath();x.arc(px+Math.cos(pang)*R*1.7,py+Math.sin(pang)*R*0.6,2.4,0,TAU);
      x.fillStyle=rgba([246,240,255],0.9*detail);x.fill();
    }
  }
}
function GOLDLESS(j){return 2.399963;}

/* ─── the whole thing ──────────────────────────────────────────── */
function render(x,W,H,t,v){
  var cam=v.cam, z=cam.z, lens=v.lens||0, B=bands(z), br=breath(t);
  var SX=function(wx){return (wx-cam.x)*z+W/2;}, SY=function(wy){return (wy-cam.y)*z+H/2;};

  var bg=x.createRadialGradient(W/2,H*0.44,0,W/2,H*0.44,H);
  bg.addColorStop(0,'#080711');bg.addColorStop(1,'#040307');
  x.fillStyle=bg;x.fillRect(0,0,W,H);

  /* deep dust, in three depths, so the sky has thickness */
  for(var L=0;L<3;L++){
    var par=0.30+L*0.40, n=L===0?58:38, a=(0.10+L*0.05)*(1-lens*0.4);
    for(var i=0;i<n;i++){
      var kk=i+L*97, wx=(hash(kk)*2-1)*1500, wy=(hash(kk+0.5)*2-1)*1700;
      var px=(wx-cam.x*par)*z+W/2, py=(wy-cam.y*par)*z+H/2+Math.sin(t*0.08+kk)*3;
      if(px<-20||px>W+20||py<-20||py>H+20)continue;
      x.beginPath();x.arc(px,py,(0.4+L*0.35)*Math.max(0.7,Math.min(2.4,z)),0,TAU);
      x.fillStyle=rgba([236,232,240],a*(0.5+0.5*Math.sin(t*0.4+kk)));x.fill();
    }
  }

  /* the region weather — once he is inside one, the place has its own air */
  if(B.reg>0.02){
    U.ROOMS.forEach(function(room){
      var d=Math.hypot(room.x-cam.x,room.y-cam.y);
      var inside=Math.max(0,Math.min(1,(room.r*1.6-d)/(room.r*0.9)));
      if(inside<=0.02)return;
      var amt=inside*B.reg;
      var tint=mix(room.rgb,BONE,lens*0.5);
      /* the air of the place, before anything in it */
      var tg=x.createRadialGradient(W/2,H*0.44,0,W/2,H*0.44,H*0.95);
      tg.addColorStop(0,rgba(tint,0.055*amt*(1-lens*0.5)));
      tg.addColorStop(1,rgba(tint,0.014*amt*(1-lens*0.5)));
      x.fillStyle=tg;x.fillRect(0,0,W,H);
      x.save();x.beginPath();x.rect(0,0,W,H);x.clip();
      room.field(x,W,H,t,amt*1.7*(1-lens*0.5),tint);
      x.restore();
    });
  }

  /* the thirteen nebulae */
  U.ROOMS.forEach(function(room,ri){
    var px=SX(room.x), py=SY(room.y), pr=room.r*z*(1.5+br*0.10);
    if(px+pr<-80||px-pr>W+80||py+pr<-80||py-pr>H+80)return;
    var col=mix(room.rgb,BONE,lens*0.55);
    var litN=0;for(var i=0;i<U.STARS.length;i++)if(U.STARS[i].room===ri&&U.STARS[i].met)litN++;
    var base=(0.050+Math.min(0.046,litN*0.009))/(1+Math.max(0,z-0.8)*1.2);
    var g=x.createRadialGradient(px,py,0,px,py,pr);
    g.addColorStop(0,rgba(col,(base+br*0.013)*(1-lens*0.42)));
    g.addColorStop(0.42,rgba(col,base*0.42*(1-lens*0.42)));
    g.addColorStop(1,rgba(col,0));
    x.fillStyle=g;ring(x,px,py,pr);x.fill();
  });

  /* the thirteen forms — the figure each room makes in the sky */
  var armA=Math.max(0,Math.min(1,(2.6-z)/1.6));
  if(armA>0.02){
    U.ROOMS.forEach(function(room){
      var px=SX(room.x), py=SY(room.y), R=room.r*z;
      if(px+R*1.6<-40||px-R*1.6>W+40||py+R*1.6<-40||py-R*1.6>H+40)return;
      if(R<12)return;
      room.arm(x,px,py,R,t,armA*0.72*(1-lens*0.55),mix(room.rgb,BONE,lens*0.5));
    });
  }

  /* the structures, beneath the light */
  if(lens>0.02){
    x.lineCap='round';
    U.STRUCTURES.forEach(function(st){
      var soft=st.loose, a=lens*(0.46-soft*0.24);
      var col=mix(BONE,[168,178,188],soft*0.5), wob=(1+soft*2.6);
      var pts=st.nodes.map(function(nd){
        return [SX(nd.x+Math.sin(t*0.16+nd.ph)*wob*5),SY(nd.y+Math.cos(t*0.13+nd.ph*1.3)*wob*5)];});
      if(pts.every(function(p){return p[0]<-60||p[0]>W+60||p[1]<-60||p[1]>H+60;}))return;
      x.beginPath();x.moveTo(pts[0][0],pts[0][1]);
      for(var j=1;j<pts.length;j++){
        x.quadraticCurveTo(pts[j-1][0],pts[j-1][1],(pts[j-1][0]+pts[j][0])/2,(pts[j-1][1]+pts[j][1])/2);}
      x.lineTo(pts[pts.length-1][0],pts[pts.length-1][1]);
      x.strokeStyle=rgba(col,a);x.lineWidth=Math.max(0.8,1.4*Math.min(1.6,z));x.stroke();
      st.nodes.forEach(function(nd,j){
        var p=pts[j], gl=nd.proof?(0.5+0.5*Math.sin(t*0.7+nd.ph)):0.25;
        x.beginPath();x.arc(p[0],p[1],(1.6+(nd.proof?1.6:0))*Math.min(2,Math.max(0.8,z)),0,TAU);
        x.fillStyle=rgba(col,lens*(0.20+gl*0.44-soft*0.12));x.fill();});
      if(z>0.85&&z<6){var p0=pts[0];
        x.font='9px "Space Mono", monospace';x.textAlign='left';
        x.fillStyle=rgba(col,lens*Math.min(0.42,(z-0.85)*0.7));
        x.fillText(st.name,p0[0]+11,p0[1]+3);}
    });
  }

  /* life on the move — between worlds, and between regions */
  U.LANES.forEach(function(ln,li){
    var ax=SX(ln.a.x), ay=SY(ln.a.y), bx=SX(ln.b.x), by=SY(ln.b.y);
    var far=ln.local?0:1;
    var vis=ln.local?B.reg*0.9+B.wld*0.4:Math.max(B.sky*0.9,0.22);
    if(vis<0.03)return;
    if(Math.max(ax,bx)<-60||Math.min(ax,bx)>W+60||Math.max(ay,by)<-60||Math.min(ay,by)>H+60)return;
    var mx=(ax+bx)/2, my=(ay+by)/2, nx=-(by-ay), ny=(bx-ax), nl=Math.hypot(nx,ny)||1;
    var bow=(far?0.16:0.10)*Math.hypot(bx-ax,by-ay);
    var qx=mx+nx/nl*bow, qy=my+ny/nl*bow;
    var col=mix(mix(U.ROOMS[ln.a.room].rgb,U.ROOMS[ln.b.room].rgb,0.5),BONE,0.35+lens*0.3);
    x.beginPath();x.moveTo(ax,ay);x.quadraticCurveTo(qx,qy,bx,by);
    x.strokeStyle=rgba(col,vis*(far?0.10:0.14));x.lineWidth=0.7;x.stroke();
    var count=far?2:1;
    for(var c=0;c<count;c++){
      var ph=((t*ln.spd+ln.ph+c/count)%1), iv=1-ph;
      var tx=iv*iv*ax+2*iv*ph*qx+ph*ph*bx, ty=iv*iv*ay+2*iv*ph*qy+ph*ph*by;
      for(var tr=0;tr<5;tr++){
        var p2=Math.max(0,ph-tr*0.012), i2=1-p2;
        var sx2=i2*i2*ax+2*i2*p2*qx+p2*p2*bx, sy2=i2*i2*ay+2*i2*p2*qy+p2*p2*by;
        x.beginPath();x.arc(sx2,sy2,(far?1.5:1.1)*(1-tr/5),0,TAU);
        x.fillStyle=rgba(mix(col,[255,250,240],0.6),vis*0.75*(1-tr/5));x.fill();
      }
    }
  });

  /* the worlds */
  var focus=null, fbest=1e9;
  for(var si=0;si<U.STARS.length;si++){
    var s=U.STARS[si];
    var px2=SX(s.x), py2=SY(s.y);
    var R=s.pr*z;
    if(px2+R*1.6<-30||px2-R*1.6>W+30||py2+R*1.6<-30||py2-R*1.6>H+30)continue;
    var dc=Math.hypot(px2-W/2,py2-H*0.44);
    if(s.met&&dc<fbest){fbest=dc;focus=s;}
    var col2=mix(U.ROOMS[s.room].rgb,BONE,lens*0.4), dim=1-lens*0.58;
    if(R<6){
      /* far off: a point of light, or a place where none has come on yet */
      if(!s.met){
        x.beginPath();x.arc(px2,py2,Math.max(0.6,0.9+z*0.5),0,TAU);
        x.fillStyle=rgba(mix(col2,[196,202,212],0.6),(0.15+0.22*Math.min(1,z))*dim);x.fill();
      }else{
        /* at the far zoom, company is only a shimmer — and colourless (§8.7) */
        var glow=(0.7+br*0.3)*(s.tw+(FLD?FLD.shimmer(s,t):0)), Rp=(1.6+s.depth*0.15)*Math.max(0.9,z*1.2)+0.8;
        if(s.depth>0&&z>0.5){
          for(var kk=1;kk<=Math.min(s.depth,8);kk++){
            ring(x,px2,py2,Rp+kk*(4.6*Math.min(2.2,z)));
            x.strokeStyle=rgba(col2,0.28*dim*(1-kk/12)*(0.62+br*0.38));x.lineWidth=0.9;x.stroke();}
        }
        var gr=Rp*4.2, gg=x.createRadialGradient(px2,py2,0,px2,py2,gr);
        gg.addColorStop(0,rgba(mix(col2,[255,252,246],0.55),0.72*glow*dim));
        gg.addColorStop(0.22,rgba(col2,0.30*glow*dim));gg.addColorStop(1,rgba(col2,0));
        x.fillStyle=gg;ring(x,px2,py2,gr);x.fill();
        ring(x,px2,py2,Rp);x.fillStyle=rgba(mix(col2,[255,253,250],0.7),0.92*dim);x.fill();
      }
    }else{
      planet(x,s,px2,py2,R,t,lens,Math.max(0,Math.min(1,(R-4)/26)));
    }
    /* mid distance: the company separates out of the shimmer and holds orbit.
       In the structure lens it fades to near-nothing — two ways of standing,
       not two overlays fighting. */
    if(FLD&&s.met&&v.mode==='sky')FLD.motes(x,s,px2,py2,Math.max(R,3.2+z*1.1),t,z,lens,dim);
  }

  /* the names — only at the far zoom, dim, lettered by hand */
  var show=Math.max(0,Math.min(1,(0.60-z)/0.24));
  if(show>0.01){
    x.textAlign='center';
    U.ROOMS.forEach(function(room){
      var px=SX(room.x), py=SY(room.y);
      if(px<-60||px>W+60||py<-40||py>H+40)return;
      x.font='9px "Space Mono", monospace';
      x.fillStyle=rgba(mix(room.rgb,BONE,0.42+lens*0.4),0.44*show);
      x.fillText(room.name.toUpperCase(),px,py+room.r*z*0.10+4);
    });
  }

  if(v.mode!=='sky'&&v.fallStar&&global.UNIFALL)global.UNIFALL.render(x,W,H,t,v,lens);
  return focus;
}

global.SKY={render:render,bands:bands};
})(window);
