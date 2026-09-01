/* THE INSTRUMENT · THE SOUND BODY ──────────────────────────────────
   One graph, built once, never torn down.

   He was unsure between one unbroken body and per-surface voices, and
   asked for the recommendation. This is it, and it is both: ONE
   continuous body — a single context, a single master, one stone room,
   one 0.1 Hz breath clock that starts at load and never restarts — and
   inside it, per-surface VOICES that cross-fade as the axis moves.

   Continuity underneath, character on top. The reason to prefer it:
   the moment a surface owns its own silence, the instrument becomes a
   set of places again. Sound is the only layer that can prove the
   whole thing is one body while he is not looking at the seam.

   The ladder is the Point's, ported: 174 → 285 · 396 · 417 · 528 ·
   639 · 741 · 852 → 963 → 136.1, beats narrowing 8 → 4 Hz. The
   Universe's side of the axis runs beneath it: the room tones, and the
   aged bed of the strata. ───────────────────────────────────────── */
(function(g){
'use strict';
var T0=performance.now();

var Body={
  ctx:null,on:false,master:null,bus:null,ready:false,
  voices:{},          /* one per surface — created once, faded, never stopped */
  cur:null,curKey:'',

  /* the breath of the whole instrument. It runs from load, whether or
     not sound is on, so image and sound are the same event. */
  phase:function(){return ((performance.now()-T0)/10000)%1;},
  breath:function(){return (Math.sin(this.phase()*Math.PI*2)+1)/2;},

  _stone:function(secs,decay){
    var sr=this.ctx.sampleRate,len=Math.floor(sr*secs),b=this.ctx.createBuffer(2,len,sr);
    for(var ch=0;ch<2;ch++){var d=b.getChannelData(ch);
      for(var i=0;i<len;i++){var t=i/len;d[i]=(Math.random()*2-1)*Math.pow(1-t,1/decay)*0.55;}}
    return b;
  },
  ensure:function(){
    if(this.ctx)return;
    var AC=g.AudioContext||g.webkitAudioContext;if(!AC)return;
    this.ctx=new AC();
    this.master=this.ctx.createGain();this.master.gain.value=0;
    this.master.connect(this.ctx.destination);
    this.bus=this.ctx.createGain();this.bus.gain.value=1;
    var cv=this.ctx.createConvolver();cv.buffer=this._stone(7.5,0.6);
    var wet=this.ctx.createGain();wet.gain.value=0.42;
    this.bus.connect(this.master);this.bus.connect(cv);cv.connect(wet);wet.connect(this.master);
    /* THE DELAY LINE — VI's whole physics. A thing sent out comes back
       later, quieter, and each return of it comes back later still. It is
       built once and sits silent until something is actually away. */
    this.echoIn=this.ctx.createGain();this.echoIn.gain.value=1;
    this.dly=this.ctx.createDelay(3.0);this.dly.delayTime.value=0.42;
    var fb=this.ctx.createGain();fb.gain.value=0.44;
    var dtone=this.ctx.createBiquadFilter();dtone.type='lowpass';dtone.frequency.value=2400;
    this.echoIn.connect(this.dly);this.dly.connect(dtone);dtone.connect(fb);fb.connect(this.dly);
    this.dlyOut=this.ctx.createGain();this.dlyOut.gain.value=0.55;
    dtone.connect(this.dlyOut);this.dlyOut.connect(this.master);this.dlyOut.connect(cv);
    this.ready=true;
  },

  /* ── a voice: two oscillators panned L/R, beating, breathing ──── */
  _voice:function(f,beat){
    var t=this.ctx.currentTime;
    var gn=this.ctx.createGain();gn.gain.value=0;
    var lfo=this.ctx.createOscillator();lfo.frequency.value=0.1;
    var lg=this.ctx.createGain();lg.gain.value=0.028;
    lfo.connect(lg);lg.connect(gn.gain);lfo.start();
    var self=this;
    var mk=function(freq,pan){
      var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=freq;
      var og=self.ctx.createGain();og.gain.value=0.5;o.connect(og);
      if(self.ctx.createStereoPanner){var p=self.ctx.createStereoPanner();p.pan.value=pan;og.connect(p);p.connect(gn);}
      else og.connect(gn);
      o.start();return {o:o,g:og};
    };
    var v1=mk(f,-0.6),v2=mk(f+beat,0.6);
    var o1=v1.o,o2=v2.o,o2g=v2.g;
    var o3=this.ctx.createOscillator();o3.type='sine';o3.frequency.value=f*2;
    var o3g=this.ctx.createGain();o3g.gain.value=0.06;o3.connect(o3g);o3g.connect(gn);o3.start();
    /* every voice passes through a filter, wide open by default, so only the
       register that wants it ever hears it */
    var lp=this.ctx.createBiquadFilter();lp.type='lowpass';lp.frequency.value=20000;lp.Q.value=0.7;
    /* and a resonance, flat by default — the chamber is the only register
       that asks the room to ring */
    var pk=this.ctx.createBiquadFilter();pk.type='peaking';pk.frequency.value=f*2;pk.Q.value=1.2;pk.gain.value=0;
    /* and the null: the SAME signal, summed at exactly minus one. Not a
       fade and not a duck — a copy of the voice cancelling the voice.
       It sits at zero for the life of the instrument and is opened in
       exactly one place. */
    var nul=this.ctx.createGain();nul.gain.value=0;
    /* and the distance: a send into the delay line, shut for every register
       but VI, where what is away is heard as the room getting longer */
    var ech=this.ctx.createGain();ech.gain.value=0;
    gn.connect(lp);lp.connect(pk);pk.connect(this.bus);pk.connect(nul);nul.connect(this.bus);
    if(this.echoIn)pk.connect(ech),ech.connect(this.echoIn);
    gn.gain.setTargetAtTime(0.055,t,1.4);
    return {g:gn,f:f,beat:beat,o2:o2,o2g:o2g,nul:nul,ech:ech,lp:lp,pk:pk,o1:o1,
      stop:function(){var c=self.ctx.currentTime;gn.gain.setTargetAtTime(0,c,0.9);
        setTimeout(function(){[o1,o2,o3,lfo].forEach(function(o){try{o.stop();}catch(e){}});},3400);}};
  },

  /* I · THE POINT wants its own audible law: as a star admits him, the
     two tones converge toward unison. The beat narrowing IS the reading
     arriving — by the fourth section the world is very nearly one note. */
  narrow:function(f){
    if(!this.on||!this.cur||!this.cur.o2)return;
    var b=this.cur.beat*(1-Math.max(0,Math.min(1,f))*0.94);
    try{this.cur.o2.frequency.setTargetAtTime(this.cur.f+b,this.ctx.currentTime,1.2);}catch(e){}
  },

  /* II · THE TURN takes exactly the opposite law. The further out he
     travels, the further the second tone departs from the first — one
     note becoming two, then a chord. The One becoming the many, heard.
     Same instrument, same register, opposite direction. */
  widen:function(f){
    if(!this.on||!this.cur||!this.cur.o2)return;
    f=Math.max(0,Math.min(1,f));
    var b=this.cur.beat*(1+f*11);
    try{this.cur.o2.frequency.setTargetAtTime(this.cur.f+b,this.ctx.currentTime,0.5);}catch(e){}
  },
  /* III · THE VEIL is a filter, not a metaphor. The register arrives
     muffled — that is what a veil does to a sound — and parting it opens
     the cutoff. What he has handed back keeps a floor under it, so the
     world is never quite as closed as it was the first time. */
  unveil:function(f,floor){
    if(!this.on||!this.cur||!this.cur.lp)return;
    f=Math.max(0,Math.min(1,f));
    var base=Math.max(f,floor||0);
    var hz=340*Math.pow(58,base);          /* 340 Hz muffled → ~19.7 kHz clear */
    try{this.cur.lp.frequency.setTargetAtTime(hz,this.ctx.currentTime,0.30);}catch(e){}
  },

  /* IV · THE CHAMBER. Pressure is heard as the room ringing under load:
     the resonance sharpens and swells at the register's own frequency, and
     the fundamental sags a little flat — compression lowers pitch, in stone
     as in anything else. Nothing is added from outside the register. */
  bear:function(f){
    if(!this.on||!this.cur)return;
    f=Math.max(0,Math.min(1,f));
    var t=this.ctx.currentTime;
    try{
      if(this.cur.pk){this.cur.pk.gain.setTargetAtTime(f*13,t,0.35);
        this.cur.pk.Q.setTargetAtTime(1.2+f*7,t,0.35);}
      var sag=1-f*0.020;
      if(this.cur.o1)this.cur.o1.frequency.setTargetAtTime(this.cur.f*sag,t,0.5);
      if(this.cur.o2)this.cur.o2.frequency.setTargetAtTime((this.cur.f+this.cur.beat)*sag,t,0.5);
    }catch(e){}
  },
  /* V · THE MIRRORS. The pane's angle IS the sign of the second tone.
     Face on: +. Edge on: zero — a mirror seen edge-on is nothing at all,
     and the second tone is gone at the same instant. Turned away: minus,
     the same note at the same pitch, arriving inverted. It does not go
     quiet; it goes HOLLOW. The tool looks identical on paper and sums to
     less than it was. That is the dimension's whole claim, in physics. */
  reflect:function(c){
    if(!this.on||!this.cur||!this.cur.o2g)return;
    c=Math.max(-1,Math.min(1,c));
    try{this.cur.o2g.gain.setTargetAtTime(0.5*c,this.ctx.currentTime,0.10);}catch(e){}
  },
  /* the one deliberate silence in the Point. Not a fade — the voice
     summed against itself, which is exact. The stone tail already in the
     air keeps decaying, so the hall dies away and then there is nothing. */
  nul:function(secs){
    if(!this.on||!this.ctx||!this.cur||!this.cur.nul)return;
    var t=this.ctx.currentTime, n=this.cur.nul;
    try{n.gain.cancelScheduledValues(t);
      n.gain.setTargetAtTime(-1,t,0.09);
      n.gain.setTargetAtTime(0,t+(secs||4.4),1.8);}catch(e){}
  },

  /* VI · THE RETURN. The room IS the distance it travelled. While
     something of his is away, the register's own voice leans into the
     delay line and the delay lengthens; when everything is home the
     world is dry again. Nothing is added — the same note, arriving late. */
  distance:function(f){
    if(!this.on||!this.ctx)return;
    f=Math.max(0,Math.min(1,f));
    var t=this.ctx.currentTime;
    try{
      if(this.cur&&this.cur.ech)this.cur.ech.gain.setTargetAtTime(f*0.62,t,0.6);
      if(this.dly)this.dly.delayTime.setTargetAtTime(0.30+f*1.35,t,0.9);
    }catch(e){}
  },
  /* the departure. It bends down and away as it goes, the way a thing
     leaving does, and it goes straight into the delay — which is to say
     it is already on its way back the moment he lets go. */
  send:function(f,pan){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='sine';
    o.frequency.setValueAtTime(f*2,t);
    o.frequency.exponentialRampToValueAtTime(f*1.12,t+1.5);
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.075,t+0.05);
    gn.gain.exponentialRampToValueAtTime(0.0001,t+1.7);
    var dest=gn;
    if(this.ctx.createStereoPanner){var pn=this.ctx.createStereoPanner();
      pn.pan.setValueAtTime(0,t);pn.pan.linearRampToValueAtTime(Math.max(-1,Math.min(1,pan||0)),t+1.4);
      gn.connect(pn);dest=pn;}
    o.connect(gn);dest.connect(this.bus);if(this.echoIn)dest.connect(this.echoIn);
    o.start(t);o.stop(t+1.9);
  },
  /* the arrival. The same note he sent, later, quieter, and one interval
     up — a fifth, a sixth, a seventh, and on the fourth return the
     octave: the lap that finally arrives home. It swells IN, backwards,
     because that is the shape of a thing approaching. */
  arrive:function(f,n,when){
    if(!this.on||!this.ctx)return;
    var R=[1.5,5/3,15/8,2], r=R[Math.max(0,Math.min(3,(n||1)-1))];
    var t=this.ctx.currentTime+(when||0);
    var o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f*r;
    var o2=this.ctx.createOscillator();o2.type='sine';o2.frequency.value=f*r*0.5;
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0.0001,t);
    gn.gain.exponentialRampToValueAtTime(0.052/(1+(n||1)*0.22),t+1.15);
    gn.gain.exponentialRampToValueAtTime(0.0001,t+3.4);
    var g2=this.ctx.createGain();g2.gain.value=0.34;
    o.connect(gn);o2.connect(g2);g2.connect(gn);
    gn.connect(this.bus);if(this.echoIn)gn.connect(this.echoIn);
    o.start(t);o2.start(t);o.stop(t+3.6);o2.stop(t+3.6);
  },
  /* Deep Time hands over all four at once, so all four intervals sound
     together: the crossing was made before him, complete. */
  arriveAll:function(f){
    if(!this.on||!this.ctx)return;
    for(var i=1;i<=4;i++)this.arrive(f,i,(i-1)*0.30);
  },

  /* VII · THE DANCE. The only polyphonic register in the instrument.
     Every world before this was ONE voice being acted on — narrowed,
     widened, filtered, rung, inverted, delayed. Here each body that
     joins the chain is a real voice of its own at a harmonic of 852,
     entering out of tune and pulling into lock as the figure holds.
     Nothing is added from outside. They simply find each other. */
  dancers:[],
  join:function(k){
    if(!this.on||!this.ctx)return;
    var R=[1,1.5,2,2.5,3], f=852*R[Math.max(0,Math.min(4,k))];
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f;
    var det=(k%2?1:-1)*(11+k*5);
    o.detune.setValueAtTime(det,t);
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.030/(1+k*0.42),t+1.3);
    var pn=null;
    if(this.ctx.createStereoPanner){pn=this.ctx.createStereoPanner();
      pn.pan.value=(k%2?1:-1)*Math.min(0.7,0.18+k*0.16);}
    o.connect(gn);
    if(pn){gn.connect(pn);pn.connect(this.bus);}else gn.connect(this.bus);
    o.start(t);
    this.dancers.push({o:o,g:gn,f:f,det:det});
    this.blip(f*0.25);
  },
  /* how in time they are. The detune closes as the lock rises, so the
     chord beats when it forms and tunes itself as they dance. */
  ensemble:function(lock){
    if(!this.on||!this.ctx||!this.dancers.length)return;
    var t=this.ctx.currentTime, k=1-Math.max(0,Math.min(1,lock));
    for(var i=0;i<this.dancers.length;i++){
      try{this.dancers[i].o.detune.setTargetAtTime(this.dancers[i].det*k,t,0.5);}catch(e){}
    }
  },
  leaveAll:function(){
    if(!this.ctx||!this.dancers.length)return;
    var t=this.ctx.currentTime;
    this.dancers.forEach(function(d){try{d.g.gain.setTargetAtTime(0,t,0.8);d.o.stop(t+3.4);}catch(e){}});
    this.dancers=[];
  },
  /* the close of the Point. All nine sound at once, pull to one note,
     and the one note rises toward the centre's own. */
  resolve:function(){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime,self=this;
    this.leaveAll();
    [1,9/8,5/4,4/3,3/2,5/3,15/8,2,3].forEach(function(r,i){
      var o=self.ctx.createOscillator();o.type='sine';
      o.frequency.setValueAtTime(852*r,t+i*0.09);
      o.frequency.exponentialRampToValueAtTime(852,t+5.2);
      var gn=self.ctx.createGain();gn.gain.setValueAtTime(0,t+i*0.09);
      gn.gain.linearRampToValueAtTime(0.026,t+i*0.09+0.7);
      gn.gain.exponentialRampToValueAtTime(0.0001,t+8.6);
      o.connect(gn);gn.connect(self.bus);o.start(t+i*0.09);o.stop(t+8.8);
    });
    var u=this.ctx.createOscillator();u.type='sine';
    u.frequency.setValueAtTime(852,t+4.6);
    u.frequency.linearRampToValueAtTime(963,t+9.4);
    var ug=this.ctx.createGain();ug.gain.setValueAtTime(0,t+4.6);
    ug.gain.linearRampToValueAtTime(0.05,t+6.4);
    ug.gain.exponentialRampToValueAtTime(0.0001,t+12);
    u.connect(ug);ug.connect(this.bus);u.start(t+4.6);u.stop(t+12.2);
  },

  /* the strike — an impression taken. Struck, not rung. */
  strike:function(f0){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='triangle';o.frequency.setValueAtTime(f0*0.5,t);
    o.frequency.exponentialRampToValueAtTime(f0*0.48,t+0.5);
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.085,t+0.012);
    gn.gain.exponentialRampToValueAtTime(0.0001,t+1.5);
    var bp=this.ctx.createBiquadFilter();bp.type='bandpass';bp.frequency.value=f0*1.5;bp.Q.value=2.2;
    o.connect(gn);gn.connect(bp);bp.connect(this.bus);o.start(t);o.stop(t+1.7);
  },

  /* and once he is far out, the many arrive as an actual chord — struck
     from the register's own fifth and octave, never from outside it */
  many:function(f0){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime,self=this;
    [1.5,2,3].forEach(function(r,i){
      var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=f0*r;
      var gn=self.ctx.createGain(),st=t+i*0.22;
      gn.gain.setValueAtTime(0,st);gn.gain.linearRampToValueAtTime(0.030/(i*0.5+1),st+0.4);
      gn.gain.exponentialRampToValueAtTime(0.0001,st+5.4);
      o.connect(gn);gn.connect(self.bus);o.start(st);o.stop(st+5.6);
    });
  },

  /* ── the axis, sounded. One call per frame; it does the rest. ──── */
  axis:function(Z){
    if(!this.on||!this.ctx)return;
    var r=g.SPINE.at(Z), key=r.key;
    if(key===this.curKey)return;
    var from=this.cur?this.cur.f:0;
    this.curKey=key;
    if(this.cur)this.cur.stop();
    var beat=8-Math.max(0,Math.min(8,(Z+4)))*0.45;
    this.cur=this._voice(r.hz,Math.max(4,beat));
    if(from)this.slide(from,r.hz);
  },
  /* the step between registers is heard, never cut */
  slide:function(a,b){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='sine';
    o.frequency.setValueAtTime(a*2,t);
    o.frequency.exponentialRampToValueAtTime(Math.max(40,b*2),t+2.6);
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.032,t+0.6);gn.gain.setTargetAtTime(0,t+1.6,0.6);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+4);
  },
  blip:function(f){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='sine';o.frequency.value=f*2;
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.07,t+0.02);gn.gain.exponentialRampToValueAtTime(0.0001,t+0.7);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+0.8);
  },
  /* the threshold at a ceremony door: struck, and slightly flat, so the
     crossing is heard as a crossing */
  threshold:function(f){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime;
    var o=this.ctx.createOscillator();o.type='sine';
    o.frequency.setValueAtTime(f*0.985,t);
    o.frequency.linearRampToValueAtTime(f,t+2.2);
    var gn=this.ctx.createGain();gn.gain.setValueAtTime(0,t);
    gn.gain.linearRampToValueAtTime(0.06,t+0.5);gn.gain.exponentialRampToValueAtTime(0.0001,t+6);
    o.connect(gn);gn.connect(this.bus);o.start(t);o.stop(t+6.4);
  },
  shimmer:function(){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime,self=this;
    [285,396,528,639,852].forEach(function(f,i){
      var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=f*2;
      var gn=self.ctx.createGain(),st=t+i*0.18;
      gn.gain.setValueAtTime(0,st);gn.gain.linearRampToValueAtTime(0.03,st+0.1);
      gn.gain.exponentialRampToValueAtTime(0.0001,st+1.6);
      o.connect(gn);gn.connect(self.bus);o.start(st);o.stop(st+1.8);
    });
  },
  om:function(){
    if(!this.on||!this.ctx)return;
    var t=this.ctx.currentTime,self=this;
    [136.1,272.2,408.3].forEach(function(f,i){
      var o=self.ctx.createOscillator();o.type='sine';o.frequency.value=f;
      var gn=self.ctx.createGain();gn.gain.setValueAtTime(0,t);
      gn.gain.linearRampToValueAtTime(0.06/(i+1),t+0.9);
      gn.gain.exponentialRampToValueAtTime(0.0001,t+9);
      o.connect(gn);gn.connect(self.bus);o.start(t);o.stop(t+9.4);
    });
  },
  toggle:function(Z){
    this.ensure();if(!this.ctx)return this.on;
    if(this.ctx.state==='suspended')this.ctx.resume();
    this.on=!this.on;
    var t=this.ctx.currentTime;
    if(this.on){this.master.gain.setTargetAtTime(0.9,t,0.7);this.curKey='';this.axis(Z||0);}
    else{this.master.gain.setTargetAtTime(0,t,0.5);
      if(this.cur){this.cur.stop();this.cur=null;this.curKey='';}}
    return this.on;
  }
};
g.BODY=Body;
})(window);
