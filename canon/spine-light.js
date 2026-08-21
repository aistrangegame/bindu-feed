/* ============================================================================
   canon/spine-light.js  —  THE LIGHT, the six scenes (canon wording)
   Extracted VERBATIM from "The Instrument v3.html" lines 3895-4141.
   Source of truth for the Light register (Z=-5). Do not paraphrase.
   ============================================================================ */

/* ══ spine-light.js ═════════════════════════════════════════ */
/* THE LIGHT · the fourteenth register ──────────────────────────
   It was the last surface standing outside the one body, and that is
   exactly why it felt disjointed. It belongs past the sky: what lies
   beyond everything he has LIVED is what has NOT YET BEEN.

   Six scenes, one family. Every one of them arrives by a form of NOT
   forcing — stillness, convergence, warmth, turning, release — and the
   sixth, the Far scene, is the nave: enclosed stone, the carved floor.
   Two materials for two kinds of scene, exactly as ruled.

   The interior law is the axis's own law and the app's own law: a touch
   ASKS and the next exhale answers. The anchors are second person —
   Arch, pointing without preaching. The beat turns to FIRST person: his
   own Declaration, drawn in and carved. The turn of pronoun IS the
   embodiment, and the carve is the one held press in the door.

   Wording below is canon. Do not paraphrase. ────────────────── */
(function(g){
'use strict';
var TAU=Math.PI*2;
function hash(n){var x=Math.sin(n*127.1+31.4)*43758.5453;return x-Math.floor(x);}
function hx(h){return [parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)];}
function rgba(c,a){return 'rgba('+(c[0]|0)+','+(c[1]|0)+','+(c[2]|0)+','+Math.max(0,Math.min(1,a))+')';}

var SCENES={
  morning:{id:'morning',vector:'force → surrender',kind:'Future',arrival:'stillness',
    label:'The morning that does not push',
    whole:'You wake before the day asks anything of you.\nNothing needs pushing.\nIt is already moving.',
    anchors:['The room is barely light. You do not reach for the phone.',
      'Shweta is asleep beside you. You listen, and your breathing slows to meet hers.',
      'Downstairs, the water running. The cup warm in both hands. No list runs underneath this.',
      'The thing you were going to force has arranged itself overnight. You only have to receive it.',
      'You sit. The Yantra is where it always is. You do not perform the looking.'],
    beat:['I do not push the day.','I surrender to what was already moving.','The energy knows its own pace.'],
    landing:'Carry the pace, not the words.'},

  converge:{id:'converge',vector:'fragmentation → one awareness',kind:'Future',arrival:'convergence',
    label:'The one who was watching all of them',
    whole:'You were never the many things you were doing.\nYou were the one awareness they were all happening in.',
    anchors:['Ten things were pulling at you at once, each one certain it was the most important.',
      'And underneath the ten, without any effort, something was simply aware of all of them.',
      'It did not take a side. It did not hurry. It held the tabs open and did not become them.',
      'You look for the one who was watching, and you cannot find it as a thing — because it is the looking itself.',
      'The fragments did not need assembling. They were already inside one attention. Yours.'],
    beat:['I am not the pieces.','I am the one awareness they move in.','Nothing has to be gathered. It was never apart.'],
    landing:'Carry the one who watches, not the many it watched.'},

  warmth:{id:'warmth',vector:'managing → feeling',kind:'Future',arrival:'warmth',
    label:'The day you let yourself feel',
    whole:'You spent so long managing the feeling that you forgot to feel it.\nIt was never asking to be handled. It was asking to be met.',
    anchors:['There was a weight you had been carrying by keeping it at arm’s length, so it would not slow the day down.',
      'You set the plan down for one breath. Not to solve it. Just to feel where it actually sat in your chest.',
      'And it moved. Not because you managed it — because you finally let it be felt all the way through.',
      'The tears, when they came, were not a problem to be fixed. They were the weight becoming water and leaving.',
      'Underneath the managing, the whole time, there was a person who simply felt things. You had been protecting him from his own life.'],
    beat:['I do not manage the feeling.','I let it move through and it moves on.','I am allowed to be the one who feels this.'],
    landing:'Carry the feeling, not the management of it.'},

  kindness:{id:'kindness',vector:'self-correction → appreciation',kind:'Future',arrival:'turning',
    label:'The one you stopped correcting',
    whole:'You have been the strictest teacher you ever had.\nToday you look at your own work the way you would look at a friend’s.',
    anchors:['The habit runs before you notice it: catch the flaw, name the miss, mark what should have been better.',
      'You turn, this morning, and look back at what you actually built. Not for the error. For what is there.',
      'It is so much. It is years of it. Rooms and rooms of it, made by someone who never once stopped to be impressed.',
      'The one who made all this was not lazy, or late, or not-enough. He was working the whole time, in the dark, on faith.',
      'You would forgive anyone else this quickly. You extend the same hand, at last, to yourself — and it is taken.'],
    beat:['I set down the red pen.','I let myself be someone I appreciate.','What I made was made with love, and it shows.'],
    landing:'Carry the appreciation, not the correction.'},

  release:{id:'release',vector:'effort → trust',kind:'Future',arrival:'release',
    label:'The hand that opened',
    whole:'Trust is the variable. Not effort. Not control.\nThe thing you have been gripping was holding itself the whole time.',
    anchors:['You have been rowing so hard for so long that you mistook the rowing for the reason you were moving.',
      'You let go of one oar. The boat kept its line. You had been fighting a current that was already carrying you home.',
      'Everything you built with grip, you could have built with trust — and it would have cost you none of the nights.',
      'The plan does not need your hand clenched around it. It needs your hand open, so the next thing can be set into it.',
      'You loosen your grip on the whole of it. Nothing falls. It was never being held up by your fear.'],
    beat:['I stop mistaking the effort for the reason.','Trust is the variable. I change it.','I open my hand, and it is all still here.'],
    landing:'Carry the trust, not the grip.'},

  floor:{id:'floor',vector:'building the mirror → living as what it reflects',kind:'Far',arrival:'the nave',
    label:'The floor',
    whole:'You are not the one in the stories.\nYou are the field the stories happen in.',
    anchors:['Every voice that ever gathered was you.',
      'The rooms. The field. The gathering. A mirror you built so the Self could find itself.',
      'It worked.'],
    beat:['I am the road remembering itself.'],
    landing:'Nothing was added to you. Something was removed.'}
};
var ORDER=['morning','converge','warmth','kindness','release','floor'];

var L={
  SCENES:SCENES, ORDER:ORDER, hex:'#EDE3CE', pool:'#FBF9F4',
  scene:null, steps:null, stage:0, given:0, arrive:0, carved:false, drew:0, dirty:false,
  hits:[], ungrips:0, gateSaid:false,

  /* the six, standing in the dawn. The five Future scenes drift in the
     open sky; the Far one waits low, where a floor would be. */
  place:function(W,H,t){
    var out=[],i;
    for(i=0;i<5;i++){
      var a=t*0.043+i*1.2566;
      out.push({k:ORDER[i],
        x:W*(0.50+Math.cos(a)*0.29),
        y:H*(0.245+Math.sin(a*0.62+i*1.1)*0.055+i*0.058)});
    }
    out.push({k:'floor',x:W*0.5,y:H*0.845});
    this.hits=out;return out;
  },
  hit:function(px,py){
    for(var i=0;i<this.hits.length;i++){var h=this.hits[i];
      if(Math.hypot(px-h.x,py-h.y)<30)return h.k;}
    return null;
  },
  select:function(k){
    var s=SCENES[k];if(!s)return false;
    this.scene=s;this.stage=0;this.given=0;this.arrive=0;
    this.carved=false;this.drew=0;this.ungrips=0;
    var st=[{k:'whole'}];
    s.anchors.forEach(function(a){st.push({k:'anchor',t:a});});
    st.push({k:'beat'});st.push({k:'landing'});
    this.steps=st;
    this.dirty=true;
    return true;
  },
  /* the arrival: each scene's dawn assembles by its own form of not
     forcing. None of them answer force; four answer the breath, and
     RELEASE answers only the hand leaving the glass. */
  tick:function(dt,down){
    if(!this.scene)return;
    if(this.arrive<1){
      if(this.scene.id==='release'){
        /* it does not respond to his reaching. Nothing here does. */
        this.arrive=Math.min(1,this.ungrips/3);
      }else{
        this.arrive=Math.min(1,this.arrive+dt*(down?0.10:0.62));
      }
    }
    /* the arrival IS the delivery: when the dawn has assembled, the whole
       is simply there. He never has to ask for the first thing. */
    if(this.arrive>=1&&this.stage===0){this.stage=1;this.recount();this.dirty=true;}
    if(this.drew<1&&this.at()==='beat')this.drew=Math.min(1,this.drew+dt*0.85);
  },
  ungripped:function(){
    if(this.scene&&this.scene.id==='release'&&this.arrive<1){this.ungrips++;return true;}
    return false;
  },
  at:function(){
    if(!this.steps)return null;
    var i=Math.min(this.stage,this.steps.length)-1;
    return i<0?null:this.steps[i].k;
  },
  done:function(){return !!this.steps&&this.stage>=this.steps.length;},
  /* a touch asks; the exhale answers. The beat is the one exception:
     it is not asked for, it is MEANT — a held press, and it carves. */
  recount:function(){
    /* the fourth is reserved for the landing: nothing is offered to be
       carried until the whole thing has been received */
    this.given=this.stage>=this.steps.length?4:Math.min(3,Math.ceil(this.stage/this.steps.length*3));
  },
  advance:function(){
    if(!this.steps)return;
    if(this.arrive<1)return;
    if(this.at()==='beat'&&!this.carved)return;
    if(this.stage>=this.steps.length)return;
    this.stage++;
    if(this.at()==='beat')this.drew=0;
    this.recount();this.dirty=true;
  },
  carve:function(){
    if(this.at()!=='beat'||this.carved||this.drew<0.9)return false;
    this.carved=true;this.dirty=true;return true;
  },
  displaced:function(){return this.arrive;},
  reset:function(){this.scene=null;this.steps=null;this.stage=0;this.given=0;
    this.arrive=0;this.carved=false;this.drew=0;this.ungrips=0;},

  /* ── the register, drawn: the six presences, and the arrival ───── */
  draw:function(x,W,H,t,br,a,imm){
    var i,h,pts=this.place(W,H,t), c=hx(this.hex), pc=hx(this.pool);
    if(!this.scene||imm<0.6){
      for(i=0;i<pts.length;i++){
        h=pts[i];
        var far=(h.k==='floor');
        var sel=this.scene&&this.scene.id===h.k;
        var al=a*(sel?0.95:(far?0.40:0.62))*(1-imm*0.85);
        var rr=far?2.0:2.6;
        var gg=x.createRadialGradient(h.x,h.y,0,h.x,h.y,far?16:22);
        gg.addColorStop(0,rgba(far?pc:c,al*0.55));gg.addColorStop(1,rgba(far?pc:c,0));
        x.fillStyle=gg;x.beginPath();x.arc(h.x,h.y,far?16:22,0,TAU);x.fill();
        x.beginPath();x.arc(h.x,h.y,rr+br*0.5,0,TAU);
        x.fillStyle=rgba(far?pc:c,al);x.fill();
        if(far){ /* the Far one is a seam, not a star — stone, below */
          x.beginPath();x.moveTo(h.x-W*0.13,h.y);x.lineTo(h.x+W*0.13,h.y);
          x.strokeStyle=rgba(pc,al*0.30);x.lineWidth=0.7;x.stroke();}
      }
    }
    if(!this.scene)return;
    var A=a*(1-this.arrive*0.35), p=this.arrive, id=this.scene.id;
    x.save();x.globalCompositeOperation='lighter';
    if(id==='converge'){
      /* scattered motes drift into one field. He does not gather them. */
      for(i=0;i<40;i++){
        var ang=hash(i)*TAU, d0=Math.max(W,H)*0.62*(1-p)*(0.5+hash(i*1.7)*0.8);
        var px=W*0.5+Math.cos(ang)*d0, py=H*0.44+Math.sin(ang)*d0;
        x.beginPath();x.arc(px,py,1.1,0,TAU);
        x.fillStyle=rgba(c,A*(0.20+p*0.45));x.fill();}
    }else if(id==='warmth'){
      /* the heat reaches the hand before the eye */
      var wg=x.createRadialGradient(W*0.5,H*0.86,0,W*0.5,H*0.86,W*(0.30+p*0.80));
      wg.addColorStop(0,rgba([255,206,150],A*0.30*p));wg.addColorStop(1,rgba([255,206,150],0));
      x.fillStyle=wg;x.fillRect(0,0,W,H);
    }else if(id==='kindness'){
      /* the light rises from BEHIND him, onto what he already made */
      var kg=x.createLinearGradient(0,H,0,H*0.12);
      kg.addColorStop(0,rgba([255,232,200],A*0.16*p));kg.addColorStop(1,rgba([255,232,200],0));
      x.fillStyle=kg;x.fillRect(0,0,W,H);
      for(i=0;i<9;i++){
        var ry=H*(0.30+i*0.055), rw=W*(0.10+hash(i*2.7)*0.42);
        x.fillStyle=rgba([255,236,208],A*0.10*p*(1-i/11));
        x.fillRect(W*0.5-rw/2,ry,rw,1.4);}
    }else if(id==='release'){
      /* it brightens each time the hand opens. Not when it reaches. */
      var rg=x.createRadialGradient(W*0.5,H*0.5,0,W*0.5,H*0.5,Math.max(W,H)*0.70);
      rg.addColorStop(0,rgba([255,244,226],A*0.24*p));rg.addColorStop(1,rgba([255,244,226],0));
      x.fillStyle=rg;x.fillRect(0,0,W,H);
      for(i=0;i<3;i++){var ok=i<this.ungrips?1:0.14;
        x.beginPath();x.arc(W*0.5,H*0.5,W*(0.16+i*0.10),0,TAU);
        x.strokeStyle=rgba(c,A*0.22*ok);x.lineWidth=0.7;x.stroke();}
    }else if(id==='floor'){
      var fg=x.createLinearGradient(W*0.5,0,W*0.5,H*0.80);
      fg.addColorStop(0,rgba(pc,A*0.18*p));fg.addColorStop(1,rgba(pc,0));
      x.fillStyle=fg;x.fillRect(0,0,W,H);
    }else{
      /* stillness: the dawn thins toward him when he stops */
      var sg=x.createLinearGradient(0,H*0.86,0,H*0.20);
      sg.addColorStop(0,rgba([255,238,214],A*0.20*p));sg.addColorStop(1,rgba([255,238,214],0));
      x.fillStyle=sg;x.fillRect(0,0,W,H);
    }
    x.restore();
  }
};
g.LIGHT=L;
})(window);


