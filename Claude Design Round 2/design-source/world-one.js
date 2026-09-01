/* THE POINT · I · THE POINT ────────────────────────────────────────
   285 Hz. Bone white. The first enclosure past the gate, and the
   hardest bar in the instrument: almost nothing, and it still has to
   hold.

   Its voice: "Before anything: I AM. The one fact that cannot stop
   being true, wearing every face including this one."

   So the world is built out of that sentence rather than illustrating
   it. There is no marketplace here, no lanes, no bodies in motion —
   ten stars in three universes, and the emptiness between them is not
   empty space to be filled. It is the subject.

   THE READING MATERIAL OF THIS WORLD IS STILLNESS.
   Everywhere else a star is opened, caught, unfolded. Here nothing
   opens by being acted on. He comes to rest near one and STAYS — and
   as he stays, the star admits him: SAY, then WALK, then HAND, then
   OPEN, each one surfacing out of the white rather than arriving.
   Move, and it closes without complaint and without penalty. The
   world's whole gesture is the one thing the world is about.

   And the honest inversion, which is the reason this world goes first:
   the reading does not appear on top of the emptiness. It appears
   INSIDE it — the sections displace the field, so the more he is
   given, the less there is around it. By the fourth, the star's own
   light is nearly all that is left.

   Nothing is scored. Nothing is counted. There is no timer shown.
   ─────────────────────────────────────────────────────────────── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D1=P.DIMS[0], HUE=P.HUES.m1;

/* ── the ten, placed as a still figure ───────────────────────────
   Not rings, not lanes. The Recognition sits as a settled row across
   the middle — five plain statements, at rest. The Enquiry sits below
   it, three of them, slightly apart, because a question is not at
   rest. The Laboratories sit far out at the edge, two of them,
   arriving by their own road. */
var STARS=[];
(function place(){
  var recs=D1.universes[0].stars, enq=D1.universes[1].stars, lab=D1.universes[2].stars;
  recs.forEach(function(id,i){
    var f=recs.length<2?0.5:i/(recs.length-1);
    STARS.push({id:id,n:P.N[id],u:0,ux:(f-0.5)*1.34,uy:-0.10,
      drift:0.10+i*0.03,ph:i*1.7});
  });
  enq.forEach(function(id,i){
    var f=enq.length<2?0.5:i/(enq.length-1);
    STARS.push({id:id,n:P.N[id],u:1,ux:(f-0.5)*0.86,uy:0.40,
      drift:0.26+i*0.05,ph:2.2+i*2.1});
  });
  lab.forEach(function(id,i){
    STARS.push({id:id,n:P.N[id],u:2,ux:i?0.90:-0.90,uy:-0.62,
      drift:0.07,ph:4.1+i*3.0});
  });
})();
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};

var One={
  STARS:STARS,DIM:D1,HUE:HUE,
  near:null,        /* the star he has come to rest near */
  still:0,          /* 0 \u2192 1, how long he has stayed */
  given:0,          /* how many sections the star has admitted */
  leaving:0,        /* the soft close when he moves */
  hits:[],

  reset:function(){this.near=null;this.still=0;this.given=0;this.leaving=0;},

  /* ── stillness ────────────────────────────────────────────────
     Touching a star CHOOSES it. That is all touching does — it does
     not open anything. What opens it is letting go and STAYING: each
     time he is still long enough that it is clear he is not passing
     through, the star admits one more thing. Reaching for it again
     interrupts, and it closes without complaint. */
  pick:function(px,py){
    var best=null,bd=1e9;
    for(var i=0;i<STARS.length;i++){
      var s=STARS[i];if(s._x===undefined)continue;
      var d=Math.hypot(s._x-px,s._y-py);
      if(d<Math.max(46,s._R*11)&&d<bd){bd=d;best=s;}
    }
    if(best){if(best!==this.near){this.near=best;this.still=0;this.given=0;this.leaving=0;}}
    else if(this.near){if(this.given>0)this.leaving=1;this.near=null;this.still=0;this.given=0;}
    return best;
  },
  update:function(dt,touching,moving){
    if(this.leaving>0)this.leaving=Math.max(0,this.leaving-dt*0.9);
    if(!this.near)return null;
    if(moving){if(this.given>0)this.leaving=1;
      this.near=null;this.still=0;this.given=0;return null;}
    /* acting suspends it — the hand is not how this world is entered */
    if(touching){this.still=Math.max(0,this.still-dt*0.55);return null;}
    this.still=Math.min(1,this.still+dt*0.30);
    var gates=[0.14,0.38,0.64,0.88];
    if(this.given<4&&this.still>=gates[this.given]){
      this.given++;
      return {k:['say','walk','hand','open'][this.given-1],i:this.given};
    }
    return null;
  },

  /* how much the reading has displaced the world. The more he is
     given, the less there is around it. */
  displaced:function(){return this.given/4;},

  /* ── the world ───────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(6,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var dsp=this.displaced(), A=p*(1-dsp*0.62);
    this.hits=[];
    x.save();x.textAlign='center';x.textBaseline='middle';

    /* the Recognition's line: five plain statements, at rest. It is
       drawn as one hairline through them, because they are one claim. */
    if(A>0.02&&rim>90){
      x.beginPath();
      x.moveTo(cx-rim*0.72,cy-rim*0.10);x.lineTo(cx+rim*0.72,cy-rim*0.10);
      x.strokeStyle=rgba(HUE,A*0.18*(0.7+br*0.3));x.lineWidth=0.7;x.stroke();
    }

    for(var i=0;i<STARS.length;i++){
      var s=STARS[i];
      /* they drift, barely. A question drifts more than a statement. */
      var wob=Math.sin(t*0.09+s.ph)*s.drift*0.036;
      var wob2=Math.cos(t*0.07+s.ph*1.3)*s.drift*0.028;
      s._x=cx+(s.ux+wob)*rim*0.72;
      s._y=cy+(s.uy+wob2)*rim*0.72;
      s._R=Math.max(2.4,rim*0.019);
      var isNear=this.near===s;
      /* being stayed with is the only thing that changes a star here */
      var lit=isNear?this.still:0;
      var al=A*(0.66+lit*0.34);
      var hal=s._R*(8+lit*12);
      var gr=x.createRadialGradient(s._x,s._y,0,s._x,s._y,hal);
      gr.addColorStop(0,rgba(HUE,al*(0.44+lit*0.34)));
      gr.addColorStop(0.20,rgba(HUE,al*0.20));
      gr.addColorStop(0.52,rgba(HUE,al*0.06));
      gr.addColorStop(1,rgba(HUE,0));
      x.fillStyle=gr;x.beginPath();x.arc(s._x,s._y,hal,0,TAU);x.fill();
      x.beginPath();x.arc(s._x,s._y,s._R*(1+lit*0.7),0,TAU);
      x.fillStyle=rgba('#FFFCF6',Math.min(1,al*1.25));x.fill();
      /* one ring, and it only exists while he is staying */
      if(lit>0.03){
        x.beginPath();x.arc(s._x,s._y,s._R*(4.6+lit*5.4)*(1+br*0.03),0,TAU);
        x.strokeStyle=rgba(HUE,A*lit*0.34);x.lineWidth=0.8;x.stroke();
      }
      /* status stays intact \u2014 walked \u00b7 in progress \u00b7 seeded */
      if(rim>150&&A>0.10){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*0.32);
        x.fillText(STATUS[s.n.st],s._x,s._y-s._R*7.5);
      }
      /* the title comes only to the one he is with, and only once he
         has actually stayed */
      if(isNear&&this.still>0.06){
        x.font='italic 14px Lora, Georgia, serif';
        x.fillStyle=rgba('#FFFCF6',A*Math.min(1,this.still*3)*0.90);
        x.fillText(s.n.t,s._x,s._y+s._R*10+8);
      }
      this.hits.push({s:s,x:s._x,y:s._y,r:Math.max(30,s._R*9)});
    }

    /* the three universes, named at the edge of their own region \u2014
       they are places, not headings */
    if(A>0.06&&rim>140){
      var us=[[0,cy-rim*0.10-rim*0.13,'left'],[1,cy+rim*0.40+rim*0.13,'left'],
              [2,cy-rim*0.62-rim*0.10,'center']];
      for(var k=0;k<us.length;k++){
        var u=D1.universes[us[k][0]];
        x.font='7.5px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*0.42);
        x.fillText(u.name.toUpperCase(),cx,us[k][1]);
      }
    }

    /* what the world asks of him, in words, once */
    if(!this.near&&this.leaving<=0.02&&A>0.30){
      x.font='8.5px "Space Mono", monospace';
      x.fillStyle=rgba('#EDE8E3',A*0.38*(0.7+br*0.4));
      x.fillText('TOUCH ONE · THEN LET GO AND STAY',cx,H-150);
    }else if(this.near&&this.given<4){
      var word=this.still<0.05?'let go':this.still<0.14?'staying':
        this.given<2?'it is admitting you':'still admitting';
      x.font='8.5px "Space Mono", monospace';
      x.fillStyle=rgba('#EDE8E3',A*0.44);
      x.fillText(word.toUpperCase(),cx,H-150);
    }else if(this.leaving>0.02){
      x.font='8.5px "Space Mono", monospace';
      x.fillStyle=rgba('#EDE8E3',this.leaving*p*0.28);
      x.fillText('IT CLOSED. IT DOES NOT MIND.',cx,H-150);
    }
    x.restore();
  }
};

function rgba(h,a){
  var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';
}
g.ONE=One;
})(window);
