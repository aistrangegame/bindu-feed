/* THE POINT — the yantra engine.
   One figure, drawn once, walked through. The nine enclosures are not nine screens with
   nine pictures: they are one architecture, and the walk inward is a camera. Scrolling
   moves the camera; you always see where you are, what you came through, and what is
   still ahead as a faint promise at the centre.
   Everything breathes at 0.1 Hz, in phase with the drone (Snd.breath()).
   The centre point is red. It always was. */
(function(g){
'use strict';
const TAU=Math.PI*2;
const lerp=(a,b,t)=>a+(b-a)*t;
const clamp=(x,a,b)=>x<a?a:x>b?b:x;
const rnd=i=>{const x=Math.sin(i*127.1+31.4)*43758.5453;return x-Math.floor(x);};
const eoq=x=>1-Math.pow(1-x,3);
const hx=h=>[parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)];
const rgba=(c,a)=>'rgba('+(c[0]|0)+','+(c[1]|0)+','+(c[2]|0)+','+a+')';

/* the enclosures, outward to inward — the radius each one lives at, in unit space */
const BAND=[1.38,0.93,0.77,0.62,0.50,0.39,0.29,0.20,0.125,0.06];
const CREAM=hx('#EDE6D6'), RED=hx('#C0392B');

/* the nine primary triangles — five downward (Shakti), four upward (Shiva) */
const DOWN=[[0.86,-0.94,0.92],[0.70,-0.74,0.80],[0.52,-0.58,0.66],[0.34,-0.40,0.50],[0.16,-0.24,0.34]];
const UP=[[-0.86,0.94,0.90],[-0.66,0.72,0.74],[-0.46,0.54,0.58],[-0.26,0.34,0.42]];
const TRIKONA=[0.10,-0.17,0.20];

const Y={
  cvs:null,ctx:null,W:393,H:852,dpr:1,
  focus:0,hue:CREAM,mode:'walk',flares:[],shaft:0,raf:null,sky:[],camY:0.5,

  init(cvs){
    this.cvs=cvs;this.ctx=cvs.getContext('2d');
    this.dpr=Math.min(2,g.devicePixelRatio||1);
    this.sky=Array.from({length:150},(_,i)=>({a:rnd(i)*TAU,d:0.06+rnd(i+50)*1.5,r:0.3+rnd(i+90)*1.0,p:rnd(i+7)*TAU,s:0.4+rnd(i+3)*0.6}));
    const fit=()=>{this.W=cvs.clientWidth||393;this.H=cvs.clientHeight||852;
      cvs.width=this.W*this.dpr;cvs.height=this.H*this.dpr;this.ctx.setTransform(this.dpr,0,0,this.dpr,0,0);};
    fit();new ResizeObserver(fit).observe(cvs);
    const loop=()=>{this.draw(performance.now()/1000);this.raf=requestAnimationFrame(loop);};
    loop();
  },
  setHue(h){this.hue=typeof h==='string'?hx(h):h;},
  setFocus(f){this.focus=clamp(f,0,BAND.length-1);},
  flare(){this.flares.push(performance.now()/1000);},
  setMode(m){this.mode=m;},

  /* the camera: band[focus] always fills the same share of the frame, so every enclosure
     is met at the same size — the walk is a change of place, not of scale */
  scale(){
    const f=this.focus,i=Math.floor(f),j=Math.min(BAND.length-1,i+1),t=f-i;
    const R=Math.min(this.W,this.H)*0.335;
    const a=Math.log(R/BAND[i]),b=Math.log(R/BAND[j]);
    return Math.exp(lerp(a,b,t));
  },
  band(){const f=this.focus,i=Math.floor(f),j=Math.min(BAND.length-1,i+1);return lerp(BAND[i],BAND[j],f-i);},
  toScreen(x,y){const s=this.scale();return{x:this.W/2+x*s,y:this.H*this.camY+y*s};},
  /* where a star sits on the enclosure it belongs to */
  anchors(n,idx){
    const r=BAND[clamp(idx,0,BAND.length-1)]*0.72;
    return Array.from({length:n},(_,i)=>{
      const a=-Math.PI/2+(i+0.5)*(TAU/n)+(idx%2?0.16:0);
      return{x:Math.cos(a)*r,y:Math.sin(a)*r};});
  },

  /* ── the figure ───────────────────────────────────────── */
  _petals(ctx,count,ri,ro,rot,w){
    for(let i=0;i<count;i++){
      const a=rot+i*TAU/count;const hw=(w||TAU/count)*0.5;
      const P=(r,ang)=>[Math.cos(ang)*r,Math.sin(ang)*r];
      const p0=P(ri,a-hw),p1=P(ro,a),p2=P(ri,a+hw),m=(ri+ro)*0.53;
      const c0=P(m,a-hw*0.62),c1=P(m,a+hw*0.62);
      ctx.beginPath();ctx.moveTo(p0[0],p0[1]);
      ctx.quadraticCurveTo(c0[0],c0[1],p1[0],p1[1]);
      ctx.quadraticCurveTo(c1[0],c1[1],p2[0],p2[1]);
      ctx.stroke();
    }
  },
  _tri(ctx,base,apex,hw){
    ctx.beginPath();ctx.moveTo(-hw,base);ctx.lineTo(hw,base);ctx.lineTo(0,apex);ctx.closePath();ctx.stroke();
  },
  _square(ctx,e,gates){
    ctx.beginPath();ctx.rect(-e,-e,e*2,e*2);ctx.stroke();
    if(!gates)return;
    const w=e*0.16,d=e*0.10;
    [[0,-1],[0,1],[-1,0],[1,0]].forEach(([ux,uy])=>{
      ctx.beginPath();
      if(uy){ctx.rect(-w,uy>0?e:-e-d,w*2,d);}else{ctx.rect(ux>0?e:-e-d,-w,d,w*2);}
      ctx.stroke();
    });
  },
  /* the whole figure, at one line weight and alpha */
  _figure(ctx,col,a,lw,t){
    ctx.strokeStyle=rgba(col,a);ctx.lineWidth=lw;
    this._square(ctx,1.46,true);this._square(ctx,1.38,false);this._square(ctx,1.30,false);
    this._petals(ctx,16,0.88,1.00,t*0.008,TAU/16*0.78);
    this._petals(ctx,8,0.70,0.84,-t*0.011,TAU/8*0.70);
    ctx.beginPath();ctx.arc(0,0,0.66,0,TAU);ctx.stroke();
    DOWN.forEach(([b,ap,hw])=>this._tri(ctx,b,ap,hw));
    UP.forEach(([b,ap,hw])=>this._tri(ctx,b,ap,hw));
    this._tri(ctx,TRIKONA[0],TRIKONA[1],TRIKONA[2]);
  },

  draw(t){
    const ctx=this.ctx,W=this.W,H=this.H;
    const br=g.Snd&&g.Snd.breath?g.Snd.breath():(Math.sin(t*TAU/10)+1)/2;
    const s=this.scale()*(1+0.010*br);
    const cx=W/2,cy=H*this.camY;
    const bandR=this.band();
    const dim=this.mode==='descend'?0.22:1;
    ctx.clearRect(0,0,W,H);

    /* the sky, receding as you go inward — the only cue that you are travelling */
    const zoom=Math.log(s)*0.16;
    for(let i=0;i<this.sky.length;i++){
      const st=this.sky[i];const r=st.d*Math.max(W,H)*0.62*(1+zoom*0.6);
      const x=cx+Math.cos(st.a)*r,y=cy+Math.sin(st.a)*r*0.96;
      if(x<-8||x>W+8||y<-8||y>H+8)continue;
      const al=(0.10+0.26*Math.abs(Math.sin(t*0.28*st.s+st.p)))*dim;
      ctx.globalAlpha=al;ctx.fillStyle='#EDE6D6';
      ctx.beginPath();ctx.arc(x,y,st.r,0,TAU);ctx.fill();
    }
    ctx.globalAlpha=1;

    /* the hue of the enclosure, breathed into the air around it */
    const wash=ctx.createRadialGradient(cx,cy,0,cx,cy,Math.max(W,H)*0.72);
    wash.addColorStop(0,rgba(this.hue,(0.10+0.05*br)*dim));
    wash.addColorStop(0.42,rgba(this.hue,0.035*dim));
    wash.addColorStop(1,'rgba(7,8,13,0)');
    ctx.fillStyle=wash;ctx.fillRect(0,0,W,H);

    ctx.save();ctx.translate(cx,cy);ctx.scale(s,s);
    ctx.lineJoin='round';

    /* the figure entire — faint, always there, the architecture you are inside of */
    this._figure(ctx,CREAM,0.16*dim,1.05/s,t);

    /* the enclosure you are in: the same lines, lit, inside an annulus of attention */
    const inner=bandR*0.62,outer=bandR*1.34;
    ctx.save();
    ctx.beginPath();ctx.arc(0,0,outer,0,TAU);ctx.arc(0,0,inner,0,TAU,true);ctx.clip();
    this._figure(ctx,this.hue,(0.62+0.16*br)*dim,1.9/s,t);
    ctx.restore();
    /* and its bloom */
    const bl=ctx.createRadialGradient(0,0,inner,0,0,outer);
    bl.addColorStop(0,rgba(this.hue,0));
    bl.addColorStop(0.5,rgba(this.hue,(0.055+0.03*br)*dim));
    bl.addColorStop(1,rgba(this.hue,0));
    ctx.fillStyle=bl;ctx.beginPath();ctx.arc(0,0,outer,0,TAU);ctx.fill();

    /* a crossing sends one wave out through the whole figure (screen space — the wave
       is the same size at every depth, because it is the sound you are seeing) */
    this.flares=this.flares.filter(f=>t-f<3.4);
    ctx.restore();
    this.flares.forEach(f=>{
      const q=(t-f)/3.4,R=6+eoq(q)*Math.max(W,H)*0.62;
      ctx.beginPath();ctx.arc(cx,cy,R,0,TAU);
      ctx.strokeStyle=rgba(this.hue,0.30*(1-q)*(1-q));ctx.lineWidth=1.4;ctx.stroke();
    });

    /* the centre. Red, from the first screen, before anything is said about it.
       Screen space: one particle, one size, at every depth of the walk. */
    const pr=5.2+br*2.4;
    const gl=ctx.createRadialGradient(cx,cy,0,cx,cy,pr*7);
    gl.addColorStop(0,rgba(RED,0.8));gl.addColorStop(0.3,rgba(RED,0.30));gl.addColorStop(1,rgba(RED,0));
    ctx.fillStyle=gl;ctx.beginPath();ctx.arc(cx,cy,pr*7,0,TAU);ctx.fill();
    ctx.beginPath();ctx.arc(cx,cy,pr*0.5,0,TAU);ctx.fillStyle=rgba([234,126,106],0.95);ctx.fill();

    /* incense — motes in the lit air, rising slowly */
    for(let i=0;i<34;i++){
      const dp=rnd(i+11);
      const x=(rnd(i+5)*W+Math.sin(t*0.13+i)*14+W)%W;
      const y=(rnd(i+29)*H-t*(3+dp*9))%H;
      const al=(0.05+dp*0.26)*(0.5+0.5*Math.sin(t*0.4+i))*dim;
      ctx.beginPath();ctx.arc(x,(y+H)%H,0.5+dp*1.3,0,TAU);
      ctx.fillStyle=rgba(this.hue,al);ctx.fill();
    }

    /* the descent: the figure recedes and one shaft of the enclosure's light remains */
    if(this.shaft>0){
      const sg=ctx.createLinearGradient(0,0,0,H);
      sg.addColorStop(0,rgba(this.hue,0.22*this.shaft));
      sg.addColorStop(0.5,rgba(this.hue,0.07*this.shaft));
      sg.addColorStop(1,rgba(this.hue,0));
      ctx.fillStyle=sg;ctx.fillRect(W*0.5-134,0,268,H);
    }
  }
};
g.YANTRA=Y;g.YANTRA.BAND=BAND;
})(window);
