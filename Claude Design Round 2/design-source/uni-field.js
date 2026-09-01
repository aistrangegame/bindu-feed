/* THE UNIVERSE · THE COMPANY ───────────────────────────────────────
   Who is hanging around each star (Amendment 01 §8.6), and how they are
   drawn at each of the three reading distances:
     far   the sky stays a sky — company shows only as a slight shimmer
     mid   distinct motes in archetype colour, in slow orbit
     near  glyph-presences, settled, with their words

   Derivation, never decoration. An attendant exists because a voice
   actually spoke on that story. Lalita threads a reply everywhere, so
   she is always in the company — and hers is the only orbit that wobbles.
   The Resonance Voice is NOT here: it speaks as "You", from the story
   itself, so it renders as the star's own halo. Nothing is counted. ── */
(function(global){
'use strict';
var U=global.UNI, TAU=U.TAU, hash=U.hash, mix=U.mix, rgba=U.rgba, ring=U.ring, breath=U.breath;

/* ─── the ten vantages, in ceremony order ─────────────────────── */
var VOICES=[
  {key:'bindu',   name:'Bindu',   hex:'#E5533C',g:'\u00B7',role:'Zeroth \u00B7 the point',            hz:136},
  {key:'neev',    name:'Neev',    hex:'#7A8899',g:'\u25BD',role:'Root \u00B7 what holds still',       hz:96},
  {key:'gaia',    name:'Gaia',    hex:'#4A9E6B',g:'\u25C6',role:'Need \u00B7 the ground of wanting',  hz:174},
  {key:'sid',     name:'Sid',     hex:'#C4923A',g:'\u25B3',role:'Hold \u00B7 what carries weight',    hz:220},
  {key:'arch',    name:'Arch',    hex:'#D4607A',g:'\u25EF',role:'Voice \u00B7 what asks to be said',  hz:330},
  {key:'shweta',  name:'Shweta',  hex:'#ABA7A2',g:'\u25CC',role:'Space \u00B7 what it moves through', hz:342},
  {key:'karishma',name:'Karishma',hex:'#D4AE4A',g:'\u2726',role:'Grace \u00B7 the unearned gift',     hz:528},
  {key:'sakshi',  name:'Sakshi',  hex:'#7B82D4',g:'\u25C7',role:'Witness \u00B7 the one who stays',   hz:285},
  {key:'lalita',  name:'Lalita',  hex:'#9B6BD6',g:'\u221E',role:'Meta \u00B7 the play, awake',        hz:396},
  {key:'ashrey',  name:'Ashrey',  hex:'#3AADA8',g:'\u2B21',role:'Synthesis \u00B7 where threads meet',hz:432}
];
var ASH={key:'ash',name:'Ash',hex:'#C0603C',g:'\u25CF',role:'He answered',hz:198};
function hx(h){return [parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)];}
VOICES.forEach(function(v){v.rgb=hx(v.hex);}); ASH.rgb=hx(ASH.hex);
var BY={}; VOICES.forEach(function(v,i){v.order=i;BY[v.key]=v;}); ASH.order=10; BY.ash=ASH;

/* ─── what was said ───────────────────────────────────────────────
   Only where the Archive holds the actual words. C-1052's gathering was
   sealed at the Rite and is carried verbatim. Elsewhere the presence is
   there and silent: he can see who sat with it. Words arrive with
   provisioning; the design never invents them. */
var WORDS={
  'C-1052':{
    gaia:'Before this was philosophy, it was a sensation \u2014 something cold and bright in the chest. The body knew before the mind had language for it.',
    sakshi:'He almost threw it away. \u201CIt falls flat when I go deeper,\u201D he said \u2014 but he kept the recording. Something in him knew the broken place was the doorway.',
    lalita:'You spotted the forgetting from inside the forgetting. The worker on the white floor looked up and remembered there was a lobby. That glance up is the whole game.',
    ash:'I wrote it like a comfort \u2014 the forgetting is the mercy. But I don\u2019t think I believed it yet. Ask me later if the mercy held.'
  }
};

/* ─── the company of one star ─────────────────────────────────── */
function company(s){
  if(s._co)return s._co;
  var out=[];
  if(!s.met||!s.spoke){return (s._co=out);}
  var keys=s.spoke.slice();
  if(keys.indexOf('lalita')<0)keys.push('lalita');          /* she always threads a reply */
  keys.sort(function(a,b){return BY[a].order-BY[b].order;});
  /* Ash joined where the thread ran past the field and its reply */
  var ash=s.cmts>s.spoke.length+1;
  keys.forEach(function(k,i){
    var v=BY[k], sd=s.seed*3.7+i*11.3;
    out.push({v:v,thread:k==='lalita'&&s.spoke.indexOf('lalita')<0,
      rr:1.62+hash(sd)*0.72,                                 /* orbit radius, in star radii */
      per:3+hash(sd+1.1)*23,                                 /* 3\u201326s — the glyph-cycle family */
      ph:hash(sd+2.2)*TAU, tip:(hash(sd+3.3)-0.5)*0.9,
      wob:k==='lalita'?1:0,
      word:(WORDS[s.codex]||{})[k]||null});
  });
  if(ash){var sd2=s.seed*5.1;
    out.push({v:ASH,ash:true,patina:Math.min(1,s.depth/8),
      rr:1.30+hash(sd2)*0.26,per:8+hash(sd2+1)*14,ph:hash(sd2+2)*TAU,tip:(hash(sd2+3)-0.5)*0.7,wob:0,
      word:(WORDS[s.codex]||{}).ash||null});}
  return (s._co=out);
}

/* where an attendant is, at time t, around a star of screen radius R */
function at(a,px,py,R,t,lens){
  var ang=a.ph+t*TAU/a.per;
  if(a.wob)ang+=Math.sin(t*0.37+a.ph)*0.28;                  /* hers alone may wander */
  var orr=R*a.rr, ct=Math.cos(a.tip), st=Math.sin(a.tip);
  var ox=Math.cos(ang)*orr, oy=Math.sin(ang)*orr*0.42;
  return [px+ox*ct-oy*st, py+ox*st+oy*ct, Math.sin(ang)];    /* z: behind or in front */
}

/* ─── mid distance: the motes ─────────────────────────────────────
   One continuous resolve. Below `hold` they are only the star's shimmer
   (that lives in the sky renderer); above it they separate out. */
function motes(x,s,px,py,R,t,z,lens,dim){
  var co=company(s); if(!co.length)return;
  /* they arrive as the star becomes a disc, and stay through world scale */
  var a0=Math.max(0,Math.min(1,(R-3.4)/5.0))*(1-lens*0.94)*dim;
  if(a0<=0.012)return;
  var br=breath(t);
  for(var i=0;i<co.length;i++){
    var a=co[i], p=at(a,px,py,R,t,lens);
    var back=p[2]<0?0.44:1;                                  /* passing behind the world */
    var sz=Math.max(0.9,Math.min(3.0,R*0.10))*(a.ash?1.14:1)*(0.86+br*0.14);
    var al=a0*back*(0.62+br*0.22)*(a.ash?0.92:1);
    var col=a.ash?mix(a.v.rgb,[255,236,222],0.10*(1-(a.patina||0))):a.v.rgb;
    var g=x.createRadialGradient(p[0],p[1],0,p[0],p[1],sz*5.2);
    g.addColorStop(0,rgba(mix(col,[255,252,246],0.42),al*0.80));
    g.addColorStop(0.26,rgba(col,al*0.34));g.addColorStop(1,rgba(col,0));
    x.fillStyle=g;ring(x,p[0],p[1],sz*5.2);x.fill();
    ring(x,p[0],p[1],sz);x.fillStyle=rgba(mix(col,[255,253,250],0.30),al);x.fill();
    /* his own returns leave the patina on his mote, not on theirs */
    if(a.ash&&a.patina>0.2&&R>18){ring(x,p[0],p[1],sz*2.6);
      x.strokeStyle=rgba(mix(col,U.BONE,0.55),al*0.30*a.patina);x.lineWidth=0.7;x.stroke();}
  }
}

/* how much extra shimmer a well-attended star carries at far zoom —
   the sky's only trace of company, and it is colourless (§8.7) */
function shimmer(s,t){
  var co=company(s); if(!co.length)return 0;
  var n=co.length, w=0;
  for(var i=0;i<n;i++)w+=Math.sin(t*TAU/co[i].per+co[i].ph);
  return 0.06*Math.min(4,n)*(0.5+0.5*w/n);
}

global.UNIFIELD={VOICES:VOICES,ASH:ASH,BY:BY,WORDS:WORDS,
  company:company,at:at,motes:motes,shimmer:shimmer};
})(window);
