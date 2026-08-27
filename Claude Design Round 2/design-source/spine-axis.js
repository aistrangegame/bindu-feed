/* THE INSTRUMENT · THE SPINE ───────────────────────────────────────
   One axis for the whole instrument.

   Everything ever built here is a scale of ONE space. Pulling out from
   the story he is reading gives the Universe — everything he has lived,
   as sky. Pushing into the dot inside that story gives the Point —
   the nine enclosures, walked inward. The Feed is not a screen among
   screens: it is ground level, Z = 0, the place the axis passes
   through at life size.

        Z   register                              voice
       −4   the sky            everything lived
       −3   a region           one room of the Feed
       −2   a world            one story, close
       −1   the fall           who sat with it · what you left here
        0   the Feed           the turn — one story, life size
       +1   the gate           the deal
       +2   I · The Point      285
       +3   II · The Turn      396
       +4   III · The Veil     417
       +5   IV · The Chamber   528
       +6   V · The Mirrors    639
       +7   VI · The Return    741
       +8   VII · The Dance    852
       +9   the centre         963 → 136.1

   Shell i (i = Z + 4) has rim 2^(Z_now − Z_i) in screen radii, so every
   register exists at every moment at its own scale. Nothing is ever
   created or destroyed as he moves. That is the whole law.

   THE PARTICLE: created once, here, and never again. Every dot he
   touches anywhere in the instrument is this object. It is why the
   centre can say "every dot you touched was me" and be telling the
   plain truth rather than making a beautiful claim. ───────────── */
(function(g){
'use strict';

var Z0=-4, ZN=9, NSHELL=14;

var REG=[
  {z:-4,key:'sky',   name:'the sky',        sub:'everything you have lived',            hz:110},
  {z:-3,key:'region',name:'a region',       sub:'one room of the Feed',                 hz:174},
  {z:-2,key:'world', name:'a world',        sub:'one story, close',                     hz:198},
  {z:-1,key:'fall',  name:'the fall',       sub:'who sat with it \u00b7 what you left here', hz:84},
  {z: 0,key:'feed',  name:'the Feed',       sub:'the turn',                             hz:136.1},
  {z: 1,key:'gate',  name:'the gate',       sub:'the deal',                             hz:174},
  {z: 2,key:'d1',    name:'The Point',      roman:'I',   dim:1, hz:285},
  {z: 3,key:'d2',    name:'The Turn',       roman:'II',  dim:2, hz:396},
  {z: 4,key:'d3',    name:'The Veil',       roman:'III', dim:3, hz:417},
  {z: 5,key:'d4',    name:'The Chamber',    roman:'IV',  dim:4, hz:528},
  {z: 6,key:'d5',    name:'The Mirrors',    roman:'V',   dim:5, hz:639},
  {z: 7,key:'d6',    name:'The Return',     roman:'VI',  dim:6, hz:741},
  {z: 8,key:'d7',    name:'The Dance',      roman:'VII', dim:7, hz:852},
  {z: 9,key:'centre',name:'the centre',     sub:'the point, at last',                   hz:963}
];
var BY={};REG.forEach(function(r,i){r.i=i;BY[r.key]=r;});

/* the ceremonies. They are never drifted into: each has its own door,
   and the door only surfaces at the register the ceremony belongs to. */
var DOORS=[
  {z:-1,key:'return',label:'open the return',line:'You came down to it yourself.',
   href:'The Return v2.html?from=descent',tone:126},
  {z:0, key:'rite',  label:'open the rite',  line:'The field is gathering on this one.',
   href:'The Rite v3.html',tone:220},
  /* VI is called The Return because it is about the same thing. Descend
     deep enough into its strata and the kinship becomes a door. */
  {z:7, key:'return6',label:'open the return',line:'This depth and that descent are the same room.',
   href:'The Return v2.html?from=descent',tone:126,deep:true}
];

var Spine={
  Z0:Z0,ZN:ZN,NSHELL:NSHELL,REG:REG,BY:BY,DOORS:DOORS,

  /* ── the geometry every layer must agree on ───────────────────── */
  rim:function(i,Z,R0){return R0*Math.pow(2,(Z+4)-i);},
  weight:function(i,Z){
    var rel=(Z+4)-i;
    if(rel<-2.7||rel>2.0)return 0;
    return sm(-2.7,-1.35,rel)*(1-sm(0.80,1.95,rel));
  },
  /* how fully inhabited a register is — content only speaks near its own scale */
  presence:function(i,Z){
    var d=Math.abs((Z+4)-i);
    return Math.max(0,Math.min(1,1.30-d*1.30));
  },
  at:function(Z){return REG[Math.max(0,Math.min(NSHELL-1,Math.round(Z)+4))];},
  clamp:function(Z){return Math.max(Z0,Math.min(ZN+0.62,Z));},

  /* ── THE PARTICLE ───────────────────────────────────────────────
     One instance. Constructed at load, mutated forever, never replaced.
     Its screen radius is fixed across the whole axis — that is what
     makes it the only fixed thing — except at the centre, where it
     stops being a dot in a world and becomes the world. */
  bindu:{
    born:Date.now(),touches:0,hue:'#E5533C',
    r:function(Z,br){
      var base=3.4+br*0.9;
      var grow=Math.max(0,(Z-8.4)/1.1);
      return base*(1+grow*grow*9);
    },
    /* how much of the frame the particle has become */
    fill:function(Z){return Math.max(0,Math.min(1,(Z-8.6)/0.95));},
    /* what he is touching, at this scale. Always the same object. */
    name:function(Z){
      if(Z<-3.4)return 'a dot in the sky';
      if(Z<-2.4)return 'a light in the room';
      if(Z<-1.4)return 'the story, close';
      if(Z<-0.4)return 'the seed of the well';
      if(Z<0.6) return 'the dot in the post';
      if(Z<1.6) return 'the dot at the gate';
      if(Z<8.6) return 'the point at the centre of the enclosure';
      return 'the point';
    },
    touch:function(){this.touches++;}
  },

  /* the words for where he is — never a number, never a progress bar */
  where:function(Z){
    var r=this.at(Z);
    if(r.roman)return {top:r.roman+' \u00b7 '+r.dim+' of 7',name:r.name,sub:null};
    return {top:null,name:r.name,sub:r.sub};
  },
  doorsAt:function(Z){
    var out=[];
    for(var i=0;i<DOORS.length;i++){
      var d=DOORS[i], near=1-Math.min(1,Math.abs(Z-d.z)/0.42);
      if(near>0.02)out.push({d:d,near:near});
    }
    return out;
  }
};
function sm(a,b,x){x=Math.max(0,Math.min(1,(x-a)/(b-a)));return x*x*(3-2*x);}

/* dance-world.js was written against the Point's own nest and expects
   rim() and weight() on a global NEST. The spine answers to the same
   contract, shifted onto the shared axis, so that world runs unchanged
   inside the one body. */
g.SPINE=Spine;
g.NEST_SHIM={
  rim:function(k,depth,R0){return Spine.rim(k+5,depth+1,R0);},
  weight:function(k,depth){return Spine.weight(k+5,depth+1);}
};
})(window);
