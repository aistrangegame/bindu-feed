/* THE POINT — the sound instrument.
   The ladder ported verbatim from the reference build: nine steps up into the unknown,
   landing home one octave down. 174 → 285 · 396 · 417 · 528 · 639 · 741 · 852 → 963 → 136.1 (OM).
   Beating narrows 8.0 → 4.0 Hz (alpha into theta). Two oscillators panned L/R: binaural on
   headphones, a slow shimmer on speakers. The drone breathes at 0.1 Hz.
   Added for the cathedral: a stone room on the master bus, and the step between enclosures
   sounded rather than cut. Nothing samples; nothing loops. */
(function(g){
'use strict';
const FREQS=[174,285,396,417,528,639,741,852,963,136.1];
const BEATS=[8,7.5,7,6.5,6,5.5,5,4.5,4.2,4];
const T0=performance.now();

const Snd={
  ctx:null,on:false,master:null,bus:null,verb:null,cur:null,curIdx:-1,
  freqs:FREQS,beats:BEATS,

  /* the 0.1 Hz breath, readable by the visuals so image and sound are one event */
  phase(){return ((performance.now()-T0)/10000)%1;},
  breath(){return (Math.sin(this.phase()*2*Math.PI)+1)/2;},

  _stone(secs,decay){
    const sr=this.ctx.sampleRate,len=Math.floor(sr*secs),b=this.ctx.createBuffer(2,len,sr);
    for(let ch=0;ch<2;ch++){const d=b.getChannelData(ch);
      for(let i=0;i<len;i++){const t=i/len;d[i]=(Math.random()*2-1)*Math.pow(1-t,1/decay)*0.55;}}
    return b;
  },
  ensure(){
    if(this.ctx)return;
    const AC=g.AudioContext||g.webkitAudioContext;if(!AC)return;
    this.ctx=new AC();
    this.master=this.ctx.createGain();this.master.gain.value=0;
    this.master.connect(this.ctx.destination);
    /* the size of the room, heard before it is seen */
    this.bus=this.ctx.createGain();this.bus.gain.value=1;
    const cv=this.ctx.createConvolver();cv.buffer=this._stone(7.5,0.6);
    const wet=this.ctx.createGain();wet.gain.value=0.42;
    this.bus.connect(this.master);this.bus.connect(cv);cv.connect(wet);wet.connect(this.master);
    this.verb=wet;
  },
  drone(i){
    const t=this.ctx.currentTime,f=FREQS[i],b=BEATS[i];
    const gn=this.ctx.createGain();gn.gain.value=0;
    const lfo=this.ctx.createOscillator();lfo.frequency.value=0.1;
    const lg=this.ctx.createGain();lg.gain.value=0.028;
    lfo.connect(lg);lg.connect(gn.gain);lfo.start();
    const mk=(freq,pan)=>{
      const o=this.ctx.createOscillator();o.type='sine';o.frequency.value=freq;
      const og=this.ctx.createGain();og.gain.value=0.5;o.connect(og);
      if(this.ctx.createStereoPanner){const p=this.ctx.createStereoPanner();p.pan.value=pan;og.connect(p);p.connect(gn);}
      else og.connect(gn);
      o.start();return o;
    };
    const o1=mk(f,-0.6),o2=mk(f+b,0.6);
    const o3=this.ctx.createOscillator();o3.type='sine';o3.frequency.value=f*2;
    const o3g=this.ctx.createGain();o3g.gain.value=0.06;o3.connect(o3g);o3g.connect(gn);o3.start();
    gn.connect(this.bus);
    gn.gain.setTargetAtTime(0.055,t,1.4);
    return {g:gn,stop:()=>{gn.gain.setTargetAtTime(0,this.ctx.currentTime,0.9);
      setTimeout(()=>{[o1,o2,o3,lfo].forEach(o=>{try{o.stop();}catch(e){}});},3400);}};
  },
  /* the enclosure changes: the new drone rises while the old falls, and the interval
     between them is sounded — the step up the ladder is heard, never cut */
  world(i){
    if(!this.on||!this.ctx)return;
    i=Math.max(0,Math.min(i,FREQS.length-1));
    if(i===this.curIdx)return;
    const from=this.curIdx;this.curIdx=i;
    if(this.cur)this.cur.stop();
    this.cur=this.drone(i);
    if(from>=0)this.step(from,i);
  },
  step(from,to){
    if(!this.on||!this.ctx)return;
    const t=this.ctx.currentTime,a=FREQS[from],b=FREQS[to];
    const o=this.ctx.createOscillator();o.type='sine';
    o.frequency.setValueAtTime(a*2,t);
    o.frequency.exponentialRampToValueAtTime(Math.max(40,b*2),t+2.6);
    const gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.035,t+0.6);gn.gain.setTargetAtTime(0,t+1.6,0.6);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+4);
  },
  blip(i){
    if(!this.on||!this.ctx)return;
    const f=FREQS[Math.min(i,FREQS.length-1)]*2,t=this.ctx.currentTime;
    const o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f;
    const gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.07,t+0.02);gn.gain.exponentialRampToValueAtTime(0.0001,t+0.7);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+0.8);
  },
  glide(i,down){
    if(!this.on||!this.ctx)return;
    const f=FREQS[Math.min(i,FREQS.length-1)],t=this.ctx.currentTime;
    const o=this.ctx.createOscillator();o.type='sine';
    o.frequency.setValueAtTime(down?f:f/2,t);
    o.frequency.exponentialRampToValueAtTime(down?f/2:f,t+2.2);
    const gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.06,t+0.15);gn.gain.setTargetAtTime(0,t+1.6,0.5);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+3.5);
  },
  shimmer(){
    if(!this.on||!this.ctx)return;
    const t=this.ctx.currentTime;
    [285,396,528,639,852].forEach((f,i)=>{
      const o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f*2;
      const gn=this.ctx.createGain(),st=t+i*0.18;
      gn.gain.setValueAtTime(0,st);gn.gain.linearRampToValueAtTime(0.03,st+0.1);
      gn.gain.exponentialRampToValueAtTime(0.0001,st+1.6);
      o.connect(gn);gn.connect(this.bus);o.start(st);o.stop(st+1.8);
    });
  },
  /* OM, struck once — the landing. The room keeps it for eight seconds. */
  om(){
    if(!this.on||!this.ctx)return;
    const t=this.ctx.currentTime;
    [136.1,272.2,408.3].forEach((f,i)=>{
      const o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f;
      const gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
      gn.gain.linearRampToValueAtTime(0.06/(i+1),t+0.9);
      gn.gain.exponentialRampToValueAtTime(0.0001,t+9);
      o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+9.4);
    });
  },
  toggle(idx){
    this.ensure();if(!this.ctx)return this.on;
    if(this.ctx.state==='suspended')this.ctx.resume();
    this.on=!this.on;
    const t=this.ctx.currentTime;
    if(this.on){this.master.gain.setTargetAtTime(0.9,t,0.7);this.curIdx=-1;this.world(idx||0);}
    else{this.master.gain.setTargetAtTime(0,t,0.5);
      if(this.cur){this.cur.stop();this.cur=null;this.curIdx=-1;}}
    return this.on;
  }
};
g.Snd=Snd;
})(window);
