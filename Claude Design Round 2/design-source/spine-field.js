/* THE INSTRUMENT · THE FIELD ───────────────────────────────────────
   One shader for the whole axis. Fourteen shells, all present at all
   times, each at its own scale. The negative side is the Universe —
   sky, region, world, the fall. Zero is the Feed, at life size. The
   positive side is the Point — the gate and the seven enclosures, and
   the centre.

   Shell i's local coordinate is uv · 2^(i − Z_now). So the register he
   is entering was always there, forming inside the one he is standing
   in, and the register he just left is the atmosphere at the edges.
   Nothing is faded between. Nothing cuts. ─────────────────────── */
(function(g){
'use strict';

var VS='attribute vec2 p;void main(){gl_Position=vec4(p,0.,1.);}';

var FS=[
'precision highp float;',
'uniform vec2 uRes;uniform float uT,uZ,uBr,uSync,uSpin,uReveal,uRoom,uDwell;',
'uniform vec2 uSweep;uniform vec3 uWx;uniform vec3 uRm[13];',
'uniform vec3 uHand;uniform vec3 uBack[9];',          /* III · the parting, and what was handed back */
'uniform vec3 uH[14];',
'float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}',
'float nz(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);',
' return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}',
'float fbm(vec2 p){float v=0.,a=.5;for(int i=0;i<4;i++){v+=a*nz(p);p*=2.03;a*=.5;}return v;}',
'float rim(float r,float w){return smoothstep(w,0.,abs(r-1.));}',

/* ── the Universe side ── */
/* −4 · the sky: the thirteen at their TRUE coordinates, every one of
   them lit from a single source at the centre — which is the particle.
   The sweep is a line drawn across everything he has lived. The dwell
   is the recognition: the sky bending its light back toward him. */
'float mSky(vec2 q,float t){float v=0.;',
' for(int i=0;i<13;i++){',
'  vec2 c=uRm[i].xy;float den=uRm[i].z;',
'  float d=length(q-c);',
'  float lit=.44+.56/(1.+length(c)*1.7);',
'  v+=(.0007+den*.0021)*lit/(d*d+.0026);',
'  v+=den*.016*smoothstep(.26,.0,d);',
' }',
' float ang=uSweep.x;vec2 nn=vec2(-sin(ang),cos(ang));',
' v+=uSweep.y*smoothstep(.030,.0,abs(dot(q,nn)))*.34;',
' float a2=atan(q.y,q.x);',
' v+=uDwell*pow(max(0.,cos(13.*a2)),7.)*smoothstep(1.30,.04,length(q))*.11;',
' v+=fbm(q*2.2+vec2(t*.006,0.))*.034;',
' return v*.85;}',
/* −3 · a region: the room's own weather — turbulence, drift, grain */
'float mRegion(vec2 q,float t){float r=length(q);',
' float tb=uWx.x,dr=uWx.y,gr=uWx.z;',
' float neb=fbm(q*(1.1+tb*2.6)+vec2(t*dr,-t*dr*.6));',
' float v=neb*(.13+tb*.17)*smoothstep(1.2,.08,r);',
' v+=gr*nz(q*42.+floor(t*2.5))*.028*smoothstep(1.1,.1,r);',
' v+=(.0010+uDwell*.0008)/(r*r+.0016);',
' return v;}',
/* −2 · a world: a lit body, its terminator, its own weather */
'float mWorld(vec2 q,float t){float r=length(q);',
' float disc=smoothstep(.62,.58,r);',
' vec2 L=normalize(vec2(-.58,-.34));',
' float lam=clamp(dot(normalize(q+1e-5),L)*.5+.55,0.,1.);',
' float surf=fbm(q*(3.4+uWx.x*3.)+vec2(t*.012,t*.004));',
' return disc*(lam*.30+surf*.11)+rim(r/.62,.012)*.18;}',
/* −1 · the fall: his own strata, and the seats around the story */
'float mFall(vec2 q,float t,float br){float r=length(q);',
' float v=.0016/(r*r+.0010);',
' for(int i=0;i<6;i++){float fi=float(i);',
'  float rr=.16+fi*.15;',
'  v+=rim(r/(rr*(1.+br*.012)),.008)*(.13-fi*.016);}',
' return v*.48;}',
/* 0 · the Feed: ground. Almost nothing — the content is the content. */
'float mFeed(vec2 q,float t,float br){float r=length(q);',
' return (.0016+br*.0006)/(r*r+.0012)+fbm(q*1.2+vec2(0.,t*.004))*.022*smoothstep(1.4,.2,r);}',
/* 1 · the gate */
'float mGate(vec2 q,float t){float v=0.;vec2 g0=floor(q*7.);',
' for(int i=0;i<3;i++){vec2 c=(g0+vec2(hash(g0+float(i)),hash(g0+float(i)+9.)))/7.;',
'  float d=length(q-c);v+=.00035/(d*d+.00012);}return v*.6;}',

/* ── the Point side · seven design languages ── */
'float mPoint(vec2 q,float t,float br){float r=length(q);',
' float v=.0012/(r*r+.0006);',
' v+=rim(r/(.44+br*.02),.055)*.10+rim(r/(.78+br*.03),.05)*.06;return v;}',
'float mTurn(vec2 q,float t){float r=length(q),a=atan(q.y,q.x);',
' float s=sin(3.*(a+log(max(r,.02))*1.9-t*.09));',
' return smoothstep(.72,1.,s)*smoothstep(1.05,.28,r)*.5+.0009/(r*r+.001);}',
/* III · THE VEIL. Four curtains at four depths, drifting at four rates.
   The parting is carved out of the density itself — not painted over it —
   and every zone he has already handed back stays permanently thinner.
   The forgetting is the entry fee, so the veil closes behind his hand;
   what was handed back does not come back. */
'float veilDensity(vec2 q,float t){',
' float a=fbm(vec2(q.x*1.7+t*.030,q.y*1.0-t*.016));',
' float b=fbm(vec2(q.x*2.9-t*.021,q.y*1.6+t*.034));',
' float c=fbm(vec2(q.x*5.2+t*.048,q.y*2.7-t*.029));',
' float d=fbm(vec2(q.x*9.1-t*.012,q.y*4.8+t*.019));',
' return smoothstep(.40,.88,a)*.34+smoothstep(.48,.92,b)*.26',
'      +smoothstep(.55,.95,c)*.17+smoothstep(.62,.98,d)*.10;}',
'float parting(vec2 q){',
' float p=0.;',
' if(uHand.z>.001)p=uHand.z*smoothstep(uHand.z*.34+.06,0.,length(q-uHand.xy));',
' for(int i=0;i<9;i++){if(uBack[i].z<=.001)continue;',
'  p=max(p,uBack[i].z*.86*smoothstep(uBack[i].z*.30+.05,0.,length(q-uBack[i].xy)));}',
' return min(1.,p);}',
'float mVeil(vec2 q,float t){float r=length(q);',
' float dens=veilDensity(q,t)*(1.-parting(q));',
' return dens*smoothstep(1.15,.16,r);}',
'float mCham(vec2 q,float t,float br){float r=length(q);',
' vec2 c=q*3.4;vec2 f=abs(fract(c)-.5);float w=smoothstep(.46,.5,max(f.x,f.y));',
' return w*.26*((.5+br*.5)*smoothstep(1.1,.15,r))+rim(r/.62,.035)*.10;}',
'float mMirr(vec2 q,float t){float r=length(q),a=atan(q.y,q.x);',
' float k=6.2831853/8.;a=abs(mod(a+t*.02,k)-k*.5);',
' vec2 m=vec2(cos(a),sin(a))*r;',
' float e=smoothstep(.02,.0,abs(m.y-.12))+smoothstep(.02,.0,abs(m.y+.12));',
' return e*smoothstep(1.05,.2,r)*.30+rim(r/.86,.04)*.08;}',
'float mRet(vec2 q,float t,float br){float r=length(q),a=atan(q.y,q.x);',
' float ray=pow(max(0.,cos(12.*a+t*.05)),22.);',
' return ray*smoothstep(1.2,.1,r)*.42+rim(r/(.55+br*.04),.05)*.12;}',
'float mDance(vec2 q,float t,float sync){float v=0.;float sp=1.-sync*.72;',
' for(int i=0;i<9;i++){float fi=float(i);',
'  float rd=.24+fi*.072;float a=t*(1.55-fi*.085)*sp+fi*2.3999;',
'  vec2 c=vec2(cos(a),sin(a))*rd;float d=length(q-c);',
'  v+=(.0021+sync*.0009)/(d*d+.0016);}',
' return v*.55*smoothstep(1.25,.1,length(q));}',
'float mSeed(vec2 q,float t,float br){float r=length(q);',
' return (.0026+br*.0009)/(r*r+.0004);}',

'float motif(int i,vec2 q,float t,float br,float sync){',
' if(i==0)return mSky(q,t);',
' if(i==1)return mRegion(q,t);',
' if(i==2)return mWorld(q,t);',
' if(i==3)return mFall(q,t,br);',
' if(i==4)return mFeed(q,t,br);',
' if(i==5)return mGate(q,t);',
' if(i==6)return mPoint(q,t,br);',
' if(i==7)return mTurn(q,t);',
' if(i==8)return mVeil(q,t);',
' if(i==9)return mCham(q,t,br);',
' if(i==10)return mMirr(q,t);',
' if(i==11)return mRet(q,t,br);',
' if(i==12)return mDance(q,t,sync);',
' return mSeed(q,t,br);}',

'void main(){',
' vec2 uv=(gl_FragCoord.xy-.5*uRes)/(.5*min(uRes.x,uRes.y));',
' float ca=cos(uSpin),sa=sin(uSpin);uv=vec2(uv.x*ca-uv.y*sa,uv.x*sa+uv.y*ca);',
' float r=length(uv);vec3 col=vec3(0.);',
' float zi=uZ+4.;',
' for(int i=0;i<14;i++){',
'  float rel=zi-float(i);',
'  if(rel<-2.7||rel>2.0)continue;',
'  float w=smoothstep(-2.7,-1.35,rel)*(1.-smoothstep(.80,1.95,rel));',
'  if(w<=.002)continue;',
'  float ahead=smoothstep(-1.35,.0,rel);',
'  w*=.30+.70*ahead;',
/* and what he has already passed recedes, so it reads as atmosphere
   rather than competing with the register he is standing in */
'  w*=1.-.48*smoothstep(.0,1.1,rel);',
'  vec2 q=uv*exp2(float(i)-zi);',
'  float m=motif(i,q,uT,uBr,uSync);',
'  float rr=length(q);',
'  m+=rim(rr,.012+.02*(1.-ahead))*(.30+uBr*.10);',
'  col+=uH[i]*m*w;',
' }',
' col*=.86+uBr*.20;',
' col*=1.-.42*smoothstep(.55,1.5,r);',
' col+=uH[13]*uReveal*(.05+.05*uBr);',
' col+=(hash(gl_FragCoord.xy+fract(uT)*vec2(53.,97.))-.5)*.022;',
' col=col/(1.+col*.55);',
' gl_FragColor=vec4(pow(max(col,0.),vec3(.88)),1.);',
'}'].join('\n');

function hx(h){return [parseInt(h.slice(1,3),16)/255,parseInt(h.slice(3,5),16)/255,parseInt(h.slice(5,7),16)/255];}

var Field={
  gl:null,ok:false,u:{},hues:new Float32Array(42),

  init:function(cv,HUES){
    var gl=null;
    try{gl=cv.getContext('webgl',{antialias:false,alpha:false})||cv.getContext('experimental-webgl');}catch(e){}
    if(!gl)return false;
    this.gl=gl;
    var vs=gl.createShader(gl.VERTEX_SHADER);gl.shaderSource(vs,VS);gl.compileShader(vs);
    var fs=gl.createShader(gl.FRAGMENT_SHADER);gl.shaderSource(fs,FS);gl.compileShader(fs);
    if(!gl.getShaderParameter(fs,gl.COMPILE_STATUS)){console.warn('field',gl.getShaderInfoLog(fs));return false;}
    var pr=gl.createProgram();gl.attachShader(pr,vs);gl.attachShader(pr,fs);gl.linkProgram(pr);
    if(!gl.getProgramParameter(pr,gl.LINK_STATUS)){console.warn('field link');return false;}
    gl.useProgram(pr);
    var buf=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,buf);
    gl.bufferData(gl.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),gl.STATIC_DRAW);
    var loc=gl.getAttribLocation(pr,'p');gl.enableVertexAttribArray(loc);
    gl.vertexAttribPointer(loc,2,gl.FLOAT,false,0,0);
    var self=this;
    ['uRes','uT','uZ','uBr','uSync','uSpin','uReveal','uRoom','uDwell'].forEach(function(n){
      self.u[n]=gl.getUniformLocation(pr,n);});
    this.u.uSweep=gl.getUniformLocation(pr,'uSweep');
    this.u.uWx=gl.getUniformLocation(pr,'uWx');
    this.u.uRm=gl.getUniformLocation(pr,'uRm[0]');
    this.u.uHand=gl.getUniformLocation(pr,'uHand');
    this.u.uBack=gl.getUniformLocation(pr,'uBack[0]');
    this.hand=new Float32Array(3);this.back=new Float32Array(27);
    this.u.uH=gl.getUniformLocation(pr,'uH[0]');
    this.sky=new Float32Array(39);this.wx=new Float32Array([0.4,0.02,0.2]);
    /* the fourteen colours of the axis. Slots 1–3 take the colour of the
       room he is actually in, so the Universe side is never generic. */
    this.base=['#7C8698','#8A93A6','#8A93A6','#8A93A6','#C9C2B6','#0F0E14',
      HUES.m1,HUES.m2,HUES.m3,HUES.m4,HUES.m5,HUES.m6,HUES.m7,'#E5533C'];
    this.setRoom('#8A93A6');
    this.ok=true;return true;
  },
  setSky:function(arr){this.sky=arr;},
  setWeather:function(w){this.wx=new Float32Array(w);},
  setRoom:function(hex){
    if(!this.base)return;
    var hs=this.base.slice();hs[1]=hex;hs[2]=hex;hs[3]=hex;
    var a=this.hues;
    for(var i=0;i<14;i++){var c=hx(hs[i]);a[i*3]=c[0];a[i*3+1]=c[1];a[i*3+2]=c[2];}
  },
  draw:function(o){
    if(!this.ok)return;
    var gl=this.gl;
    gl.viewport(0,0,gl.drawingBufferWidth,gl.drawingBufferHeight);
    gl.uniform2f(this.u.uRes,gl.drawingBufferWidth,gl.drawingBufferHeight);
    gl.uniform1f(this.u.uT,o.t);
    gl.uniform1f(this.u.uZ,o.Z);
    gl.uniform1f(this.u.uBr,o.breath);
    gl.uniform1f(this.u.uSync,o.sync||0);
    gl.uniform1f(this.u.uSpin,o.spin||0);
    gl.uniform1f(this.u.uReveal,o.reveal||0);
    gl.uniform1f(this.u.uDwell,o.dwell||0);
    gl.uniform2f(this.u.uSweep,o.sweepAng||0,o.sweepStr||0);
    if(this.wx)gl.uniform3fv(this.u.uWx,this.wx);
    if(this.sky)gl.uniform3fv(this.u.uRm,this.sky);
    if(o.hand){this.hand[0]=o.hand[0];this.hand[1]=o.hand[1];this.hand[2]=o.hand[2];}
    else{this.hand[2]=0;}
    gl.uniform3fv(this.u.uHand,this.hand);
    gl.uniform3fv(this.u.uBack,o.back||this.back);
    gl.uniform3fv(this.u.uH,this.hues);
    gl.drawArrays(gl.TRIANGLES,0,3);
  }
};
g.FIELD=Field;
})(window);
