/* FIELD SOUND — the ceremonial sound layer.
   Generated, never recorded. Nothing samples; nothing loops.
   Names mirror the app's Sound/ layer so the Swift port maps 1:1:
   SonicContext (bed) · BreathVoice (per-presence) · ThresholdTone (transitions).
   Felt, not heard: the ceiling is deliberately low. Muting is a fade, never a cut. */
(function(global){
'use strict';
var CEIL=0.55;
var reduced=global.matchMedia&&global.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* Per-presence timbre. Each voice is the same field heard from one angle —
   same tuning as the bed, differing only in body and behaviour. */
var CHAR={
  bindu:{wave:'sine',partials:[1,2,3],gain:0.055,atk:0.6,rel:5.0,flicker:6.2,pan:0},
  neev:{wave:'sine',partials:[0.5,1],gain:0.07,atk:3.4,rel:8.0,pan:-0.15},
  gaia:{wave:'triangle',partials:[1,1.5],gain:0.05,atk:1.6,rel:6.0,pan:-0.3},
  sid:{wave:'sine',partials:[1,1.2],gain:0.05,atk:1.2,rel:6.5,pan:0.25},
  arch:{wave:'triangle',partials:[1,2],gain:0.048,atk:0.9,rel:4.5,vib:4.6,pan:0.35},
  shweta:{wave:'sine',partials:[1],gain:0.012,atk:4.0,rel:9.0,air:0.028,pan:0},
  karishma:{wave:'sine',partials:[1,2,3.02],gain:0.036,atk:2.0,rel:7.0,shimmer:true,pan:0.4},
  sakshi:{wave:'sine',partials:[1],gain:0.026,atk:5.0,rel:10.0,pan:-0.4},
  ashrey:{wave:'sine',partials:[1,2],gain:0.042,atk:1.4,rel:6.0,pan:0.15},
  lalita:{wave:'sine',partials:[1,1.5],gain:0.04,atk:2.2,rel:8.0,gliss:1.02,pan:0},
  ash:{wave:'sine',partials:[1,2,4],gain:0.05,atk:1.0,rel:5.5,pan:0}
};
/* Each presence's own frequency — the tone it sounds as it takes the field. */
var HZ={bindu:110,neev:82,gaia:146,sid:174,arch:220,shweta:329,karishma:392,sakshi:285,ashrey:196,lalita:396,ash:261};

var FieldSound={
  ctx:null,master:null,bus:null,bed:null,bedFilter:null,bedLfo:null,
  muted:true,aged:false,inkNode:null,ringStep:0,

  init:function(){
    if(this.ctx)return;
    var C=global.AudioContext||global.webkitAudioContext; if(!C)return;
    this.ctx=new C();
    this.master=this.ctx.createGain(); this.master.gain.value=0;
    this.bus=this.ctx.createGain(); this.bus.gain.value=1;
    var conv=this.ctx.createConvolver(); conv.buffer=this._air(3.6,0.34);
    var wet=this.ctx.createGain(); wet.gain.value=0.5;
    this.bus.connect(this.master); this.bus.connect(conv); conv.connect(wet); wet.connect(this.master);
    this.master.connect(this.ctx.destination);
  },
  _air:function(secs,decay){
    var sr=this.ctx.sampleRate,len=Math.floor(sr*secs),b=this.ctx.createBuffer(2,len,sr);
    for(var ch=0;ch<2;ch++){var d=b.getChannelData(ch);
      for(var i=0;i<len;i++){var t=i/len;d[i]=(Math.random()*2-1)*Math.pow(1-t,1/decay)*0.6;}}
    return b;
  },
  _pan:function(v){ if(!this.ctx.createStereoPanner)return null; var p=this.ctx.createStereoPanner(); p.pan.value=v||0; return p; },

  /* the bed: room-tuned breath drone, swelling on the room's own pace */
  startBed:function(rootHz,breathSecs){
    rootHz=rootHz||110; breathSecs=breathSecs||10;
    this.init(); if(!this.ctx)return;
    if(this.ctx.state==='suspended')this.ctx.resume();
    if(this.bed)return;
    var t=this.ctx.currentTime;
    var g=this.ctx.createGain(); g.gain.value=0.030;
    var f=this.ctx.createBiquadFilter(); f.type='lowpass'; f.frequency.value=900; f.Q.value=0.6;
    var root=this.ctx.createOscillator(); root.type='sine'; root.frequency.value=rootHz;
    var fifth=this.ctx.createOscillator(); fifth.type='sine'; fifth.frequency.value=rootHz*1.5;
    var fg=this.ctx.createGain(); fg.gain.value=0.16;
    var lfo=this.ctx.createOscillator(); lfo.frequency.value=1/Math.max(2,breathSecs);
    var lg=this.ctx.createGain(); lg.gain.value=0.014;
    lfo.connect(lg); lg.connect(g.gain);
    root.connect(f); fifth.connect(fg); fg.connect(f); f.connect(g); g.connect(this.bus);
    root.start(t); fifth.start(t); lfo.start(t);
    this.bed={root:root,fifth:fifth,g:g,rootHz:rootHz}; this.bedFilter=f; this.bedLfo=lfo;
    this.apply();
  },

  /* patina — the same bed, aged. The Return opens here. */
  agedBed:function(rootHz,breathSecs){
    rootHz=rootHz||84; breathSecs=breathSecs||13;
    this.startBed(rootHz,breathSecs);
    if(!this.ctx||this.aged)return; this.aged=true;
    var t=this.ctx.currentTime;
    this.bedFilter.frequency.linearRampToValueAtTime(430,t+6);       // warmth closes in
    this.bed.root.frequency.linearRampToValueAtTime(rootHz*0.996,t+8); // settles a few cents flat
    this.bed.fifth.frequency.linearRampToValueAtTime(rootHz*1.5*0.994,t+8);
    if(this.bedLfo)this.bedLfo.frequency.linearRampToValueAtTime(1/(breathSecs*1.35),t+6);
    var w=this.ctx.createOscillator(); w.frequency.value=0.07;        // slow tape wobble
    var wg=this.ctx.createGain(); wg.gain.value=0.9;
    w.connect(wg); wg.connect(this.bed.root.frequency); w.start(t);
  },

  apply:function(){ if(this.master&&this.ctx)this.master.gain.linearRampToValueAtTime(this.muted?0:CEIL,this.ctx.currentTime+1.4); },
  setMuted:function(m){ this.muted=m; if(this.ctx){ if(!m&&this.ctx.state==='suspended')this.ctx.resume(); this.apply(); } },

  /* BreathVoice — a presence takes the field */
  voice:function(key,hz,dur){
    if(!this.ctx||this.muted||reduced)return;
    var c=CHAR[key]||CHAR.ash, self=this;
    hz=hz||HZ[key]||220;
    var t=this.ctx.currentTime, life=dur||(c.atk+c.rel);
    var vg=this.ctx.createGain(); vg.gain.setValueAtTime(0,t);
    vg.gain.linearRampToValueAtTime(c.gain,t+c.atk);
    vg.gain.linearRampToValueAtTime(0,t+life);
    var pan=this._pan(c.pan);
    if(pan){vg.connect(pan);pan.connect(this.bus);}else vg.connect(this.bus);
    c.partials.forEach(function(mult,i){
      var o=self.ctx.createOscillator(); o.type=c.wave; o.frequency.value=hz*mult;
      var pg=self.ctx.createGain(); pg.gain.value=1/(i+1.6);
      o.connect(pg); pg.connect(vg);
      if(c.gliss&&i===1)o.frequency.linearRampToValueAtTime(hz*mult*c.gliss,t+life);
      if(c.vib){var v=self.ctx.createOscillator(); v.frequency.value=c.vib;
        var vgn=self.ctx.createGain(); vgn.gain.value=hz*0.006;
        v.connect(vgn); vgn.connect(o.frequency); v.start(t); v.stop(t+life+0.2);}
      o.start(t); o.stop(t+life+0.2);
    });
    if(c.flicker){ // Bindu: the ember, alive
      var fl=this.ctx.createOscillator(); fl.frequency.value=c.flicker;
      var fg=this.ctx.createGain(); fg.gain.value=c.gain*0.45;
      fl.connect(fg); fg.connect(vg.gain); fl.start(t); fl.stop(t+life+0.2);
    }
    if(c.air){ // Shweta: the gap the sound moves through
      var n=this.ctx.createBufferSource(); n.buffer=this._air(life,0.9);
      var nf=this.ctx.createBiquadFilter(); nf.type='bandpass'; nf.frequency.value=hz*4; nf.Q.value=0.7;
      var ng=this.ctx.createGain(); ng.gain.setValueAtTime(0,t);
      ng.gain.linearRampToValueAtTime(c.air,t+c.atk); ng.gain.linearRampToValueAtTime(0,t+life);
      n.connect(nf); nf.connect(ng); ng.connect(this.bus); n.start(t);
    }
    if(c.shimmer){ // Karishma: grace, arriving from above
      var s=this.ctx.createOscillator(); s.type='sine'; s.frequency.value=hz*6;
      var sg=this.ctx.createGain(); sg.gain.setValueAtTime(0,t);
      sg.gain.linearRampToValueAtTime(c.gain*0.18,t+c.atk*1.6);
      sg.gain.linearRampToValueAtTime(0,t+life);
      s.connect(sg); sg.connect(this.bus); s.start(t); s.stop(t+life+0.2);
    }
    if(this.bed){ // the bed steps back while a voice speaks, then returns
      var bg=this.bed.g.gain; bg.cancelScheduledValues(t);
      bg.linearRampToValueAtTime(0.018,t+c.atk);
      bg.linearRampToValueAtTime(0.030,t+life+1.6);
    }
  },

  /* ThresholdTone — one movement gives way to the next */
  threshold:function(hz,dur){
    hz=hz||198; dur=dur||5;
    if(!this.ctx||this.muted||reduced)return;
    var t=this.ctx.currentTime;
    var g=this.ctx.createGain(); g.gain.setValueAtTime(0,t);
    g.gain.linearRampToValueAtTime(0.032,t+dur*0.42);
    g.gain.linearRampToValueAtTime(0,t+dur);
    var o=this.ctx.createOscillator(); o.type='sine'; o.frequency.value=hz;
    var o2=this.ctx.createOscillator(); o2.type='sine'; o2.frequency.value=hz*2.002;
    var g2=this.ctx.createGain(); g2.gain.value=0.22;
    o.connect(g); o2.connect(g2); g2.connect(g); g.connect(this.bus);
    o.start(t); o2.start(t); o.stop(t+dur+0.1); o2.stop(t+dur+0.1);
  },

  /* the Bowl — struck once, a long room. The bed holds its breath. */
  bowl:function(hz){
    hz=hz||220;
    if(!this.ctx||this.muted)return;
    var t=this.ctx.currentTime,dur=11,self=this;
    var g=this.ctx.createGain();
    g.gain.setValueAtTime(0,t);
    g.gain.linearRampToValueAtTime(0.075,t+0.09);
    g.gain.exponentialRampToValueAtTime(0.0001,t+dur);
    [1,2.004,2.98,4.02].forEach(function(m,i){
      var o=self.ctx.createOscillator(); o.type='sine'; o.frequency.value=hz*m;
      var pg=self.ctx.createGain(); pg.gain.value=1/(i*2.2+1);
      o.connect(pg); pg.connect(g); o.start(t); o.stop(t+dur);
    });
    g.connect(this.bus);
    if(this.bed){var bg=this.bed.g.gain; bg.cancelScheduledValues(t);
      bg.linearRampToValueAtTime(0.006,t+1.2); bg.linearRampToValueAtTime(0.030,t+9);}
  },

  /* a ring forms — each return lands one step further up the series */
  ring:function(step){
    if(!this.ctx||this.muted)return;
    var n=typeof step==='number'?step:++this.ringStep;
    var base=(this.bed&&this.bed.rootHz)||84;
    var R=[2,3,4,4.5,6,8], hz=base*R[Math.min(n,R.length-1)];
    var t=this.ctx.currentTime,dur=9;
    var g=this.ctx.createGain(); g.gain.setValueAtTime(0,t);
    g.gain.linearRampToValueAtTime(0.036,t+3.2);  // grows outward; never strikes
    g.gain.linearRampToValueAtTime(0.020,t+6);
    g.gain.linearRampToValueAtTime(0,t+dur);
    var o=this.ctx.createOscillator(); o.type='sine';
    o.frequency.setValueAtTime(hz*0.985,t);
    o.frequency.linearRampToValueAtTime(hz,t+4);  // settles into tune as it lands
    var o2=this.ctx.createOscillator(); o2.type='sine'; o2.frequency.value=hz*1.5;
    var g2=this.ctx.createGain(); g2.gain.value=0.14;
    o.connect(g); o2.connect(g2); g2.connect(g); g.connect(this.bus);
    o.start(t); o2.start(t); o.stop(t+dur); o2.stop(t+dur);
  },

  /* ink — while you write, the field leans in. A held tone, never clicks. */
  inkOn:function(hz){
    if(!this.ctx||this.muted||this.inkNode||reduced)return;
    var t=this.ctx.currentTime;
    var g=this.ctx.createGain(); g.gain.setValueAtTime(0,t);
    g.gain.linearRampToValueAtTime(0.014,t+2.4);
    var o=this.ctx.createOscillator(); o.type='sine'; o.frequency.value=hz||174;
    var f=this.ctx.createBiquadFilter(); f.type='lowpass'; f.frequency.value=600;
    o.connect(f); f.connect(g); g.connect(this.bus); o.start(t);
    this.inkNode={o:o,g:g};
  },
  inkTouch:function(){
    if(!this.inkNode||this.muted||reduced)return;
    var t=this.ctx.currentTime,g=this.inkNode.g.gain;
    g.cancelScheduledValues(t);
    g.linearRampToValueAtTime(0.022,t+0.12);
    g.linearRampToValueAtTime(0.014,t+1.1);
  },
  inkOff:function(){
    if(!this.inkNode)return;
    var t=this.ctx.currentTime,n=this.inkNode; this.inkNode=null;
    n.g.gain.cancelScheduledValues(t);
    n.g.gain.linearRampToValueAtTime(0,t+1.8);
    n.o.stop(t+2);
  },

  /* ─── THE ROOM OPENS ────────────────────────────────
     The Gathering happens in a room. The Light happens in a NAVE.
     A cathedral's whole acoustic signature is its tail — 8 seconds of
     stone giving your own sound back to you, changed. Opening this is
     the single most spatial thing the sound layer can do: the listener
     hears the size of the space before he sees it. */
  openTheRoom:function(dur){
    dur=dur||5;
    this.init(); if(!this.ctx)return;
    if(!this.nave){
      var c=this.ctx.createConvolver(); c.buffer=this._air(8.5,0.62);   // the long stone tail
      var w=this.ctx.createGain(); w.gain.value=0;
      var pre=this.ctx.createBiquadFilter(); pre.type='highpass'; pre.frequency.value=180;
      this.bus.connect(pre); pre.connect(c); c.connect(w); w.connect(this.master);
      this.nave=w;
    }
    var t=this.ctx.currentTime;
    this.nave.gain.cancelScheduledValues(t);
    this.nave.gain.linearRampToValueAtTime(0.85,t+dur);
  },
  closeTheRoom:function(dur){
    if(!this.nave||!this.ctx)return;
    var t=this.ctx.currentTime;
    this.nave.gain.cancelScheduledValues(t);
    this.nave.gain.linearRampToValueAtTime(0,t+(dur||6));
  },

  /* ─── THE LIGHT — the photographic negative of the Gathering ───
     The Gathering FILLS: voices arrive one after another into the dark.
     The Light REMOVES. So the sound does the opposite of everything above:
     it draws in, holds, drains, strikes once, and leaves silence. */

  /* the long breath IN, and the hold. The bed rises, tightens, then stops. */
  breathIn:function(dur){
    dur=dur||6;
    this.init(); if(!this.ctx)return;
    if(this.ctx.state==='suspended')this.ctx.resume();
    if(!this.bed)this.startBed(110,10);
    if(this.muted)return;
    var t=this.ctx.currentTime;
    if(this.bedLfo)this.bedLfo.frequency.linearRampToValueAtTime(0.001,t+dur*0.7); // the breathing stops
    if(this.bedFilter)this.bedFilter.frequency.linearRampToValueAtTime(2600,t+dur); // brightens as it draws in
    var g=this.bed.g.gain; g.cancelScheduledValues(t);
    g.linearRampToValueAtTime(0.052,t+dur*0.78);   // swells
    g.linearRampToValueAtTime(0.040,t+dur);        // and holds. Does not release.
    var rise=this.ctx.createOscillator(); rise.type='sine';
    rise.frequency.setValueAtTime(this.bed.rootHz,t);
    rise.frequency.linearRampToValueAtTime(this.bed.rootHz*1.5,t+dur);
    var rg=this.ctx.createGain(); rg.gain.setValueAtTime(0,t);
    rg.gain.linearRampToValueAtTime(0.026,t+dur*0.8);
    rg.gain.linearRampToValueAtTime(0.018,t+dur);
    rise.connect(rg); rg.connect(this.bus); rise.start(t); rise.stop(t+dur+8);
    this._held=rise;
  },

  /* the veil drawn away — everything drains downward and out.
     Nothing arrives here. This is the sound of subtraction. */
  veilLift:function(dur){
    dur=dur||3;
    if(!this.ctx||this.muted)return;
    var t=this.ctx.currentTime;
    if(this.bedFilter)this.bedFilter.frequency.linearRampToValueAtTime(120,t+dur); // the room closes and goes
    if(this.bed){var g=this.bed.g.gain; g.cancelScheduledValues(t); g.linearRampToValueAtTime(0,t+dur);}
    if(this._held){var h=this._held; try{h.stop(t+dur+0.1);}catch(e){} this._held=null;}
    var n=this.ctx.createBufferSource(); n.buffer=this._air(dur,0.55);   // the texture draining
    var nf=this.ctx.createBiquadFilter(); nf.type='lowpass';
    nf.frequency.setValueAtTime(3000,t); nf.frequency.linearRampToValueAtTime(90,t+dur);
    var ng=this.ctx.createGain(); ng.gain.setValueAtTime(0.030,t); ng.gain.linearRampToValueAtTime(0,t+dur);
    n.connect(nf); nf.connect(ng); ng.connect(this.bus); n.start(t);
  },

  /* the bare light — almost nothing. A single high room-tone, barely there,
     so the silence has an edge to it. The breath cues ride on this. */
  lightBed:function(breathSecs){
    breathSecs=breathSecs||10;
    if(!this.ctx||this.muted||this.lightNode)return;
    var t=this.ctx.currentTime;
    var g=this.ctx.createGain(); g.gain.setValueAtTime(0,t);
    g.gain.linearRampToValueAtTime(0.012,t+6);
    var o=this.ctx.createOscillator(); o.type='sine'; o.frequency.value=528;
    var o2=this.ctx.createOscillator(); o2.type='sine'; o2.frequency.value=792;
    var g2=this.ctx.createGain(); g2.gain.value=0.3;
    var lfo=this.ctx.createOscillator(); lfo.frequency.value=1/breathSecs;
    var lg=this.ctx.createGain(); lg.gain.value=0.006;
    lfo.connect(lg); lg.connect(g.gain);
    o.connect(g); o2.connect(g2); g2.connect(g); g.connect(this.bus);
    o.start(t); o2.start(t); lfo.start(t);
    this.lightNode={o:o,o2:o2,lfo:lfo,g:g};
  },
  lightOff:function(dur){
    if(!this.lightNode||!this.ctx)return;
    var t=this.ctx.currentTime,n=this.lightNode; this.lightNode=null;
    n.g.gain.cancelScheduledValues(t); n.g.gain.linearRampToValueAtTime(0,t+(dur||5));
    n.o.stop(t+(dur||5)+0.2); n.o2.stop(t+(dur||5)+0.2); n.lfo.stop(t+(dur||5)+0.2);
  },

  /* walking back out — the dark returns, and with it the breathing */
  darkReturns:function(){
    if(!this.ctx)return;
    var t=this.ctx.currentTime;
    this.lightOff(5);
    if(this.bedFilter)this.bedFilter.frequency.linearRampToValueAtTime(900,t+7);
    if(this.bedLfo)this.bedLfo.frequency.linearRampToValueAtTime(0.1,t+7);
    if(this.bed){var g=this.bed.g.gain; g.cancelScheduledValues(t); g.linearRampToValueAtTime(0.030,t+7);}
  },

  /* aliases the prototypes already call */
  start:function(){this.startBed();},
  startBreath:function(hz){this.startBed(hz);this.setMuted(false);},
  setOn:function(v){this.setMuted(!v);},
  tone:function(hz,dur){this.threshold(hz,dur||5);},
  seal:function(hz){this.bowl(hz);},
  hzFor:function(k){return HZ[k]||220;}
};
global.FieldSound=FieldSound;
global.Sound=FieldSound;
})(window);
