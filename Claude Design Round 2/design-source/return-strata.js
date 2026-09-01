/* A STRANGE FEED — THE RETURN · the strata engine
   §11 the patina, made material · §17.6 faded lovelier than fresh · §17.7 the fall
   One Age value governs every material. Nothing here counts; everything deepens.
   Exposed as window.RETURN_ART so the Swift port maps 1:1 (StrataField / Patina / Fall). */
(function(g){
'use strict';
const rgba=(c,a)=>'rgba('+(c[0]|0)+','+(c[1]|0)+','+(c[2]|0)+','+a+')';
const mix=(a,b,t)=>a+(b-a)*t;
const mixc=(a,b,t)=>[mix(a[0],b[0],t),mix(a[1],b[1],t),mix(a[2],b[2],t)];
const eo=x=>1-Math.pow(1-x,3);
const clamp=(x,a,b)=>x<a?a:x>b?b:x;
const rnd=i=>{const x=Math.sin(i*127.1+31.4)*43758.5453;return x-Math.floor(x);};
/* one cheap band-limited wiggle — the hand, not the machine */
const nz=x=>Math.sin(x*1.7)*0.5+Math.sin(x*3.9+1.3)*0.31+Math.sin(x*7.3+2.7)*0.19;

/* the palette of time: bone (raw, new) → amber → deep gold (old, loveliest) */
const BONE=[228,220,205], AMBER=[208,158,72], DEEP=[164,112,38], CREAM=[255,248,232];

/* ─── the one Age value (§11) ─── */
function age(days){
  const a=clamp(Math.pow(days/1095,0.55),0,1);
  return {days,a,sat:1-0.30*a,breathMul:1+0.45*a,grain:0.05+0.14*a,warm:0.30+0.70*a};
}

/* paper grain, generated once — a material, not an opacity */
let _grain=null;
function grainURL(){
  if(_grain)return _grain;
  const c=document.createElement('canvas');c.width=c.height=170;const x=c.getContext('2d');
  const im=x.createImageData(c.width,c.height);const d=im.data;
  for(let i=0;i<d.length;i+=4){const v=190+Math.random()*65;d[i]=v;d[i+1]=v*0.93;d[i+2]=v*0.77;d[i+3]=Math.random()*52;}
  x.putImageData(im,0,0);_grain=c.toDataURL();return _grain;
}

/* ─── one ring, drawn by hand ───
   Rings are never true circles. A new ring is eccentric and settles into true over
   four seconds — the visual twin of the sound entering 1.5% flat and coming into tune. */
function ringPath(ctx,cx,cy,R,wob,seed,gapAt,gapLen,rot){
  const N=180;let open=false;ctx.beginPath();rot=rot||0;
  for(let k=0;k<=N;k++){
    const u=k/N,ang=u*Math.PI*2-Math.PI/2+rot;
    if(gapLen>0){const d=(u-gapAt+1)%1;if(d<gapLen){open=false;continue;}}
    const r=R*(1+wob*nz(u*6.283+seed)*0.055);
    const x=cx+Math.cos(ang)*r,y=cy+Math.sin(ang)*r;
    if(!open){ctx.moveTo(x,y);open=true;}else ctx.lineTo(x,y);
  }
  ctx.stroke();
}

/* craquelure — fine radial cracks earned by age, never drawn on the new ring */
function craquelure(ctx,cx,cy,R,col,alpha,seed){
  for(let k=0;k<7;k++){
    const u=rnd(seed*13+k*7.7),ang=u*Math.PI*2,len=2+rnd(seed*5+k)*5;
    const r0=R-len*0.5,r1=R+len*0.5;
    ctx.beginPath();
    ctx.moveTo(cx+Math.cos(ang)*r0,cy+Math.sin(ang)*r0);
    ctx.lineTo(cx+Math.cos(ang)*r1,cy+Math.sin(ang)*r1);
    ctx.strokeStyle=rgba(col,alpha);ctx.lineWidth=0.6;ctx.stroke();
  }
}

/* ─── THE FIELD ───
   S = { rings, active, z (0 far → 1 arrived), camY, age, breathSecs, whispers } */
function drawField(ctx,W,H,S,t){
  const A=S.age,n=S.rings.length;
  const z=clamp(S.z,0,1),s=0.013+(1-0.013)*z;
  if(S.camTarget!==undefined)S.camY+=(S.camTarget-S.camY)*0.018;  // the camera settles, never cuts
  const cx=W/2,cy=H*S.camY;
  const bs=(S.breathSecs||9)*A.breathMul;
  const b=(Math.sin(t*2*Math.PI/bs)+1)/2;
  ctx.clearRect(0,0,W,H);

  /* the memory wash — cool has mellowed to amber in proportion to age */
  const vg=ctx.createRadialGradient(cx,cy,0,cx,cy,H*0.95);
  vg.addColorStop(0,rgba(mixc([26,26,38],[52,40,20],A.warm),0.52+0.10*b));
  vg.addColorStop(0.52,rgba(mixc([14,13,20],[22,17,12],A.warm),0.50));
  vg.addColorStop(1,'rgba(7,6,9,0)');
  ctx.fillStyle=vg;ctx.fillRect(0,0,W,H);

  /* the fall — the archive's own sky, streaming past and gone */
  if(z<0.88){
    const fade=1-Math.pow(clamp(z/0.88,0,1),0.7);
    for(let i=0;i<70;i++){
      const ang=rnd(i)*Math.PI*2,d0=0.05+rnd(i+40)*1.05;
      const r=d0*Math.max(W,H)*(0.25+z*2.4);
      const x=cx+Math.cos(ang)*r,y=cy+Math.sin(ang)*r*0.92;
      if(x<-20||x>W+20||y<-20||y>H+20)continue;
      const tail=z*z*16*(0.4+rnd(i+9));
      ctx.beginPath();ctx.moveTo(x,y);
      ctx.lineTo(x-Math.cos(ang)*tail,y-Math.sin(ang)*tail*0.92);
      ctx.strokeStyle=rgba([226,214,190],(0.06+rnd(i+3)*0.30)*fade);ctx.lineWidth=0.8;ctx.stroke();
    }
  }

  /* the strata — outermost (newest) first, so the old sit on top of the new */
  const gap=Math.min(W,H)*0.088;
  for(let i=n-1;i>=1;i--){
    const R=(8+i*gap)*s;
    if(R<0.6)continue;
    const rel=n<=2?1:clamp((n-1-i)/(n-2),0,1);      // 0 = newest · 1 = oldest return
    const rg=S.rings[i];
    const grown=eo(rg._in===undefined?1:rg._in);
    const trueness=rg._true===undefined?1:rg._true;
    const active=i===S.active;
    /* rings pass the camera and sweep out of the frame during the fall */
    const pass=1-clamp((R-H*0.60)/(H*0.42),0,1);
    if(pass<=0.01)continue;
    const col=mixc(BONE,rel>0.62?DEEP:AMBER,Math.pow(rel,0.72));
    const ph=(Math.sin(t*2*Math.PI/(bs*(1+rel*0.5))+i*0.8)+1)/2;
    /* every self keeps turning at its own rate — the near ones restless, the old ones
       almost still. An orrery of selves, not a diagram. */
    const rot=t*(0.004+0.026*Math.pow(1-rel,1.6))*(active?1.6:1);
    const al=(0.13+rel*0.30+(active?0.26:0)+ph*0.06)*grown*pass;
    ctx.strokeStyle=rgba(col,al);
    ctx.lineWidth=(0.9+rel*1.5+(active?0.9:0))*Math.min(1,s*1.6+0.35);
    ringPath(ctx,cx,cy,R*grown,(1-trueness)*1.5+0.35+rel*0.5+0.18*Math.sin(t*0.21+i),i*3.7,rnd(i*31)*0.9,rel>0.35&&rnd(i*17)>0.62?0.035+rnd(i*7)*0.05:0,rot);
    /* bloom — only the aged glow. The new ring is the plainest thing on the screen. */
    if(rel>0.42&&R>6){
      const bl=ctx.createRadialGradient(cx,cy,R*0.93,cx,cy,R*1.09);
      bl.addColorStop(0,rgba(col,0));bl.addColorStop(0.5,rgba(col,0.055*rel*pass*grown));bl.addColorStop(1,rgba(col,0));
      ctx.fillStyle=bl;ctx.beginPath();ctx.arc(cx,cy,R*1.09,0,7);ctx.fill();
    }
    if(rel>0.5&&R>18)craquelure(ctx,cx,cy,R*grown,col,0.05+rel*0.06,i);
    /* the node — a self, standing at its own distance from the story */
    if(R>7){
      const ang=-Math.PI/2+i*0.9+rot,nx=cx+Math.cos(ang)*R*grown,ny=cy+Math.sin(ang)*R*grown;
      const nr=(active?4.6:2.8+rel*1.2)*Math.min(1,s*2+0.3);
      if(rel>0.3||active){
        const hg=ctx.createRadialGradient(nx,ny,0,nx,ny,nr*5);
        hg.addColorStop(0,rgba(col,(0.24+rel*0.26)*pass*grown));hg.addColorStop(1,rgba(col,0));
        ctx.fillStyle=hg;ctx.beginPath();ctx.arc(nx,ny,nr*5,0,7);ctx.fill();
      }
      ctx.beginPath();ctx.arc(nx,ny,nr,0,7);
      ctx.fillStyle=rgba(mixc(col,CREAM,0.25+rel*0.3),(0.5+rel*0.42+(active?0.3:0))*pass*grown);ctx.fill();
      /* falling inward through time: each ring names itself as it passes */
      if(S.whispers&&z>0.06&&z<0.92&&R>H*0.16&&pass>0.12){
        ctx.save();ctx.font="9px 'Space Mono', monospace";if('letterSpacing' in ctx)ctx.letterSpacing='1.6px';
        ctx.fillStyle=rgba(col,0.30*pass);ctx.textAlign='center';
        ctx.fillText((rg.when||'').toUpperCase(),clamp(nx,44,W-44),ny-nr-9);ctx.restore();
      }
    }
  }

  /* the seed — the story itself. It did not move. */
  const sr=(4.4+b*2.6)*Math.min(1,0.35+s*1.4);
  const gl=ctx.createRadialGradient(cx,cy,0,cx,cy,sr*11);
  gl.addColorStop(0,'rgba(255,246,222,0.95)');
  gl.addColorStop(0.26,rgba(mixc(AMBER,CREAM,0.35),0.42+0.10*b));
  gl.addColorStop(1,rgba(AMBER,0));
  ctx.fillStyle=gl;ctx.beginPath();ctx.arc(cx,cy,sr*11,0,7);ctx.fill();
  ctx.beginPath();ctx.arc(cx,cy,sr,0,7);ctx.fillStyle='rgba(255,250,238,0.96)';ctx.fill();
  /* its corona — three slow arcs, never closing. The seed is alive, not a dot. */
  if(s>0.25)for(let k=0;k<3;k++){
    const rr=sr*(2.6+k*1.5)+b*2.2,a0=t*(0.10+k*0.055)*(k%2?-1:1)+k*2.1;
    ctx.beginPath();ctx.arc(cx,cy,rr,a0,a0+1.5+0.5*Math.sin(t*0.3+k));
    ctx.strokeStyle=rgba(mixc(CREAM,AMBER,0.5),(0.16-k*0.035)*(0.6+0.4*b));ctx.lineWidth=0.8;ctx.stroke();
  }

  /* a crossing sends one wave out through the strata — sound made visible */
  if(S.pulses&&S.pulses.length){
    S.pulses=S.pulses.filter(p=>t-p<3.2);
    S.pulses.forEach(p=>{
      const q=(t-p)/3.2,R=eo(q)*Math.max(W,H)*0.62*s+6;
      ctx.beginPath();ctx.arc(cx,cy,R,0,7);
      ctx.strokeStyle=rgba(mixc(CREAM,AMBER,0.6),0.20*(1-q)*(1-q));ctx.lineWidth=1.1;ctx.stroke();
    });
  }

  /* motes — the field's slow dust. With age it settles as sediment along the floor. */
  const mn=z>0.5?44:16;
  for(let i=0;i<mn;i++){
    const dep=rnd(i),sp=(1.4+dep*4.6)/A.breathMul;
    const settle=A.a*0.55;
    const xx=(rnd(i+3)*W+Math.sin(t*0.17+i)*11+W)%W;
    let yy=(rnd(i+7)*H+t*sp)%H;
    yy=mix(yy,H-8-rnd(i+11)*26,settle*(rnd(i+19)>0.55?1:0));
    const al=(0.06+dep*0.34)*(0.55+0.45*Math.sin(t*0.42+i))*z;
    ctx.beginPath();ctx.arc(xx,yy,0.5+dep*1.5,0,7);
    ctx.fillStyle=rgba(mixc([222,206,176],AMBER,A.warm*0.7),al);ctx.fill();
  }
}

g.RETURN_ART={age,grainURL,drawField,rgba,mixc,eo,clamp,rnd,BONE,AMBER,DEEP,CREAM};
})(window);
