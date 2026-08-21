/* ============================================================================
   canon/spine-sound.js  —  THE TRAVEL REGISTER, the nine new sound calls
   Extracted VERBATIM from "The Instrument v3.html" lines 4142-4308.
   Covers: travel, trail, strain, give, rush, gate, carry, thin, ungrip
   (plus the B.axis override that trails the register you just left).
   The BASE voices (bed/bowl/threshold/ring/ink/nave) live in field-sound.js —
   this file is the travel/stillness layer that was only ever inlined in the HTML.
   Do not paraphrase; port the numbers verbatim to Swift Sound/.
   ============================================================================ */

/* ══ spine-sound.js · THE TRAVEL REGISTER ══════════════════════════ */
/* The movement had thresholds and no journey: struck at the crossings,
   silent in between. Now three things run at once, exactly as ruled —
   a GLIDE underneath (one tone riding the ladder continuously, so he
   can hear where he is with his eyes shut), the CROSSINGS struck over
   it, and the register he LEFT still sounding behind him as he goes.
   Plus the surface: strain while it holds, a break when it gives. ── */
(function(g){
'use strict';
var B=g.BODY;if(!B)return;
function noise(ctx){var sr=ctx.sampleRate,b=ctx.createBuffer(1,Math.floor(sr*2),sr),d=b.getChannelData(0);
  for(var i=0;i<d.length;i++)d[i]=Math.random()*2-1;return b;}

/* the ladder, read continuously instead of in steps */
B.hzAt=function(Z){var R=g.SPINE.REG, q=Math.max(0,Math.min(14,Z+5));
  var i=Math.floor(q), f=q-i, a=R[i].hz, b=R[Math.min(14,i+1)].hz;
  return a*Math.pow(b/a,f);};

/* ── the glide: one voice that IS the camera ──────────────────── */
B.travel=function(Z,speed){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  if(!this._tv){
    var o=this.ctx.createOscillator();o.type='sine';
    var o2=this.ctx.createOscillator();o2.type='sine';
    var gn=this.ctx.createGain();gn.gain.value=0;
    var lp=this.ctx.createBiquadFilter();lp.type='lowpass';lp.frequency.value=2400;
    o.connect(gn);o2.connect(gn);gn.connect(lp);lp.connect(this.bus);o.start();o2.start();
    var n=this.ctx.createBufferSource();n.buffer=noise(this.ctx);n.loop=true;
    var bp=this.ctx.createBiquadFilter();bp.type='bandpass';bp.Q.value=1.1;
    var ng=this.ctx.createGain();ng.gain.value=0;
    n.connect(bp);bp.connect(ng);ng.connect(this.bus);n.start();
    this._tv={o:o,o2:o2,g:gn,n:ng,bp:bp};
  }
  var v=this._tv, hz=this.hzAt(Z), s=Math.min(1,speed*150);
  try{
    v.o.frequency.setTargetAtTime(hz,t,0.07);
    v.o2.frequency.setTargetAtTime(hz*1.006,t,0.07);
    v.g.gain.setTargetAtTime(s*0.030,t,0.11);
    v.bp.frequency.setTargetAtTime(hz*2.4,t,0.14);
    v.n.gain.setTargetAtTime(s*s*0.022,t,0.16);
  }catch(e){}
};

/* ── what he left, still sounding behind him ──────────────────── */
B.trail=function(hz){
  if(!this.on||!this.ctx||!hz)return;
  var t=this.ctx.currentTime, self=this;
  [1,2].forEach(function(m,i){
    var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=hz*m;
    o.frequency.setTargetAtTime(hz*m*0.985,t,3.5);        /* it falls away as it goes */
    var gn=self.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.026/(i+1.6),t+0.5);
    gn.gain.exponentialRampToValueAtTime(0.0001,t+7.5);
    o.connect(gn);gn.connect(self.bus);o.start(t);o.stop(t+7.8);
  });
};

/* ── the surface under load ───────────────────────────────────── */
B.strain=function(f){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  if(!this._sf){
    var n=this.ctx.createBufferSource();n.buffer=noise(this.ctx);n.loop=true;
    var bp=this.ctx.createBiquadFilter();bp.type='bandpass';bp.Q.value=7;
    var gn=this.ctx.createGain();gn.gain.value=0;
    n.connect(bp);bp.connect(gn);gn.connect(this.bus);n.start();
    this._sf={g:gn,bp:bp};
  }
  f=Math.max(0,Math.min(1,f));
  try{
    this._sf.g.gain.setTargetAtTime(f*f*0.030,t,0.12);
    this._sf.bp.frequency.setTargetAtTime(300+f*1500,t,0.14);
  }catch(e){}
};
/* it gives: the strain snaps and the far side rings */
B.give=function(hz){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  var n=this.ctx.createBufferSource();n.buffer=noise(this.ctx);
  var bp=this.ctx.createBiquadFilter();bp.type='bandpass';bp.frequency.value=1600;bp.Q.value=0.8;
  var gn=this.ctx.createGain();gn.gain.setValueAtTime(0.055,t);
  gn.gain.exponentialRampToValueAtTime(0.0001,t+0.5);
  n.connect(bp);bp.connect(gn);gn.connect(this.bus);n.start(t);n.stop(t+0.6);
  this.threshold(hz);
};
/* ── a perspective taken up: three steps, and they stay in the room ── */
B.carry=function(hz){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime,self=this;
  [1,1.5,2].forEach(function(m,i){
    var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=hz*m;
    var gn=self.ctx.createGain(),st=t+i*0.30;
    gn.gain.setValueAtTime(0,st);gn.gain.linearRampToValueAtTime(0.034/(i*0.6+1),st+0.25);
    gn.gain.exponentialRampToValueAtTime(0.0001,st+6.5);
    o.connect(gn);gn.connect(self.bus);o.start(st);o.stop(st+6.8);
  });
};
/* ── the passage, sounded ──────────────────────────────────────────
   Falling through a throat is not a threshold; it is a rush that
   builds, opens, and is swallowed by the arrival. */
B.rush=function(f,dir){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  if(!this._rs){
    var n=this.ctx.createBufferSource();n.buffer=noise(this.ctx);n.loop=true;
    var bp=this.ctx.createBiquadFilter();bp.type='bandpass';bp.Q.value=0.9;
    var gn=this.ctx.createGain();gn.gain.value=0;
    n.connect(bp);bp.connect(gn);gn.connect(this.bus);n.start();
    this._rs={g:gn,bp:bp};
  }
  var env=f<=0?0:Math.sin(Math.min(1,f)*Math.PI);
  try{
    this._rs.g.gain.setTargetAtTime(env*0.042,t,0.08);
    this._rs.bp.frequency.setTargetAtTime(dir>0?(260+f*2600):(2600-f*2200),t,0.10);
  }catch(e){}
};
/* a gate passing over him */
B.gate=function(hz){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  var o=this.ctx.createOscillator();o.type='sine';o.frequency.setValueAtTime(hz*3,t);
  o.frequency.exponentialRampToValueAtTime(hz*1.5,t+0.9);
  var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
  gn.gain.linearRampToValueAtTime(0.048,t+0.05);
  gn.gain.exponentialRampToValueAtTime(0.0001,t+1.6);
  o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+1.8);
};
/* ── the stillness gate, sounded ──────────────────────────────────
   The one place in the instrument where sound answers the ABSENCE of
   his hand. It does not count up at him; it opens. */
B.thin=function(f){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  if(!this._th){
    var o=this.ctx.createOscillator();o.type='sine';o.frequency.value=174;
    var o2=this.ctx.createOscillator();o2.type='sine';o2.frequency.value=261;
    var gn=this.ctx.createGain();gn.gain.value=0;
    o.connect(gn);o2.connect(gn);gn.connect(this.bus);o.start();o2.start();
    this._th={g:gn,o:o,o2:o2};
  }
  f=Math.max(0,Math.min(1,f));
  try{
    this._th.g.gain.setTargetAtTime(f*f*0.026,t,0.35);
    this._th.o2.frequency.setTargetAtTime(261+f*87,t,0.5);
  }catch(e){}
};
/* the field answering an ungrip. A breath, never a reward. */
B.ungrip=function(){
  if(!this.on||!this.ctx)return;
  var t=this.ctx.currentTime;
  var o=this.ctx.createOscillator();o.type='sine';o.frequency.setValueAtTime(174,t);
  o.frequency.setTargetAtTime(232,t,1.2);
  var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
  gn.gain.linearRampToValueAtTime(0.024,t+0.45);
  gn.gain.exponentialRampToValueAtTime(0.0001,t+3.4);
  o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+3.6);
};
/* the register voice, and the one before it left to fade on its own */
var axis=B.axis;
B.axis=function(Z){
  if(!this.on||!this.ctx)return;
  var was=this.cur?this.cur.f:0;
  axis.call(this,Z);
  if(was&&this.cur&&this.cur.f!==was)this.trail(was);
};
})(window);
