/* THE POINT · II · THE TURN ────────────────────────────────────────
   396 Hz. Voice: "A timeless perfection cannot know itself. So the
   point moved — with love — and the One became the many."

   So this world is not a place with nine things in it. It is ONE
   THING LEAVING, nine times, and still leaving. Every star here is a
   ray that departed the particle at the centre — and the particle at
   the centre is the same one he has been touching since the first
   post. Nothing is placed. Everything is emitted.

   THE EXACT INVERSION OF I. In The Point, acting interrupts and
   stillness admits. Here stillness is the one thing that cannot work:
   a perfection that stops moving cannot know itself. So

     THE READING MATERIAL OF THIS WORLD IS FOLLOWING.

   He takes hold of a ray and travels out along it. Each section
   arrives one turn further from the centre — SAY near the origin,
   OPEN out at the rim — so reading a star IS the movement from One to
   many, performed rather than described. Stop, and the arm reels him
   gently back toward the centre; nothing is lost, and the Return is
   always where he started.

   What the light does, because the content says it does:
     · spanda — the throb. The centre pulses on the breath clock, and
       every pulse travels visibly down all nine arms at once.
     · the rays — one light becoming many. Near the centre the light
       is unified and white; the further out along an arm, the more it
       separates into its own hue. The split is literal.
     · attention as physics. The arm he is following brightens and
       slows; the other eight dim and hurry on without him.

   Nothing is scored. Nothing is counted. ─────────────────────────── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D2=P.DIMS[1], HUE=P.HUES.m2;

/* ── the nine rays ──────────────────────────────────────────────
   One arm per star. The Longing leaves slowly and reaches furthest —
   it is the reason anything left at all. The Mechanics leave in a
   tight bundle, because they are one act described four ways. The
   Choice leaves last and nearly straight: a decision has little curl. */
var RAYS=[];
(function emit(){
  var U=D2.universes, twist=[2.30,1.55,0.72], base=[-0.55,1.05,3.35], spread=[1.02,1.34,0.62];
  U.forEach(function(u,ui){
    u.stars.forEach(function(id,i){
      var n=u.stars.length, f=n<2?0.5:i/(n-1);
      RAYS.push({id:id,n:P.N[id],u:ui,uname:u.name,
        a0:base[ui]+(f-0.5)*spread[ui],       /* where it left the centre */
        k:twist[ui]*(1+(i%2)*0.14),           /* how much it curls */
        reach:ui===0?1.00:ui===1?0.84:0.92,   /* how far it has got */
        rate:0.030+ui*0.012+i*0.004,          /* its own outward drift */
        ph:ui*2.1+i*1.3});
    });
  });
})();
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};

/* the motes leaving the centre — real emission, continuously born */
var MOTES=[];
for(var m=0;m<108;m++)MOTES.push({ray:m%RAYS.length,t:Math.random(),
  v:0.055+Math.random()*0.075,off:(Math.random()-0.5)*0.030});

var Two={
  RAYS:RAYS,DIM:D2,HUE:HUE,
  following:null,   /* the ray he has hold of */
  out:0,            /* how far along it he has travelled, 0 \u2192 1 */
  given:0,
  reeling:0,
  hits:[],

  reset:function(){this.following=null;this.out=0;this.given=0;this.reeling=0;},

  /* the point on a ray at fraction f (0 = the centre, 1 = its reach) */
  pt:function(r,f,cx,cy,rim,t){
    var rr=Math.pow(Math.max(0.0001,f),0.82)*r.reach;
    var ang=r.a0+Math.log(Math.max(0.02,rr)+0.02)*r.k+t*r.rate*0.20;
    return [cx+Math.cos(ang)*rr*rim*0.92, cy+Math.sin(ang)*rr*rim*0.92, ang, rr];
  },

  /* ── following ─────────────────────────────────────────────────
     Take hold near the centre and travel out. Distance from the
     centre IS progress: he is not charging anything, he is going
     somewhere. Let go and the arm reels him back. */
  take:function(px,py,cx,cy,rim,t){
    var best=null,bd=1e9;
    for(var i=0;i<RAYS.length;i++){
      /* nearest arm, sampled along its length */
      for(var s=0.10;s<=1.0;s+=0.10){
        var p=this.pt(RAYS[i],s,cx,cy,rim,t);
        var d=Math.hypot(p[0]-px,p[1]-py);
        if(d<44&&d<bd){bd=d;best={r:RAYS[i],f:s};}
      }
    }
    if(best){
      if(best.r!==this.following){this.following=best.r;this.given=0;this.reeling=0;}
      this.out=Math.max(this.out,best.f*0.55);
      return best.r;
    }
    return null;
  },
  drag:function(px,py,cx,cy,rim,t){
    if(!this.following)return null;
    /* how far out his hand is, in the geometry of this arm */
    var d=Math.hypot(px-cx,py-cy)/(rim*0.92*this.following.reach);
    this.out=Math.max(0,Math.min(1,Math.pow(Math.max(0,Math.min(1,d)),1/0.82)));
    var gates=[0.20,0.44,0.68,0.90];
    if(this.given<4&&this.out>=gates[this.given]){
      this.given++;
      return {k:['say','walk','hand','open'][this.given-1],i:this.given};
    }
    return null;
  },
  release:function(){if(this.following)this.reeling=1;},
  update:function(dt,holding){
    if(!holding&&this.following){
      /* the arm reels back \u2014 gently, and it keeps what it gave */
      this.out=Math.max(0,this.out-dt*0.30);
      if(this.out<=0.02){this.following=null;this.given=0;this.reeling=0;}
    }
    if(this.reeling>0)this.reeling=Math.max(0,this.reeling-dt*0.7);
  },
  /* how much of the world the reading has taken over */
  displaced:function(){return this.given/4;},

  /* ── the world ───────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(7,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var dsp=this.displaced(), A=p*(1-dsp*0.54);
    this.hits=[];
    if(A<=0.004)return;
    x.save();

    /* spanda \u2014 the throb. One pulse per breath, travelling out along
       every arm at once. The centre is not still; it is departing. */
    var pulse=(g.BODY?g.BODY.phase():0);
    for(var i=0;i<RAYS.length;i++){
      var r=RAYS[i], mine=this.following===r;
      var dim=this.following?(mine?1:0.26):1;
      /* the arm itself, drawn as the trail of one thing leaving */
      var steps=26, prev=null;
      x.beginPath();
      for(var s2=0;s2<=steps;s2++){
        var f=s2/steps, pt=this.pt(r,f,cx,cy,rim,t);
        if(!s2)x.moveTo(pt[0],pt[1]);else x.lineTo(pt[0],pt[1]);
        prev=pt;
      }
      x.strokeStyle=rgba(HUE,A*(mine?0.30:0.11)*dim*(0.7+br*0.3));
      x.lineWidth=mine?1.2:0.6;x.stroke();

      /* the wave of the throb, riding out along this arm */
      var wf=((pulse+r.ph*0.05)%1);
      var wp=this.pt(r,wf,cx,cy,rim,t);
      var wa=A*dim*0.34*Math.sin(wf*Math.PI);
      if(wa>0.01){
        var wg=x.createRadialGradient(wp[0],wp[1],0,wp[0],wp[1],13);
        wg.addColorStop(0,rgba(split(wf),wa));wg.addColorStop(1,rgba(HUE,0));
        x.fillStyle=wg;x.beginPath();x.arc(wp[0],wp[1],13,0,TAU);x.fill();
      }

      /* the star, out at the far end of its own departure */
      var end=this.pt(r,mine?Math.max(0.34,this.out):0.94,cx,cy,rim,t);
      var R=Math.max(2.2,rim*0.016)*(mine?1.34:1);
      var al=A*dim*(mine?0.94:0.56);
      var col=split(mine?this.out:0.94);
      var gr=x.createRadialGradient(end[0],end[1],0,end[0],end[1],R*9);
      gr.addColorStop(0,rgba(col,al*0.52));
      gr.addColorStop(0.20,rgba(col,al*0.20));
      gr.addColorStop(1,rgba(col,0));
      x.fillStyle=gr;x.beginPath();x.arc(end[0],end[1],R*9,0,TAU);x.fill();
      x.beginPath();x.arc(end[0],end[1],R,0,TAU);
      x.fillStyle=rgba(mix(col,'#FFFCF6',0.5),Math.min(1,al*1.2));x.fill();

      x.textAlign='center';x.textBaseline='middle';
      if(rim>150&&A>0.10){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*dim*0.34);
        x.fillText(STATUS[r.n.st],end[0],end[1]-R*5.4);
      }
      if(mine&&this.out>0.06){
        x.font='italic 13.5px Lora, Georgia, serif';
        x.fillStyle=rgba('#FFFCF6',A*Math.min(1,this.out*3)*0.90);
        x.fillText(r.n.t,end[0],end[1]+R*6.4);
      }
      /* he can only take hold near the centre \u2014 the origin is the door */
      var grab=this.pt(r,0.22,cx,cy,rim,t);
      this.hits.push({r:r,x:grab[0],y:grab[1],rad:34});
    }

    /* the motes: everything here is still leaving */
    for(var k=0;k<MOTES.length;k++){
      var mo=MOTES[k], ray=RAYS[mo.ray];
      mo.t+=mo.v*0.016;if(mo.t>1)mo.t-=1;
      var mp=this.pt(ray,mo.t,cx,cy,rim,t);
      var mdim=this.following?(this.following===ray?1:0.22):0.72;
      var ma=A*mdim*0.30*Math.sin(mo.t*Math.PI);
      if(ma<=0.006)continue;
      x.beginPath();x.arc(mp[0]+mo.off*rim,mp[1]+mo.off*rim*0.6,0.9,0,TAU);
      x.fillStyle=rgba(split(mo.t),ma);x.fill();
    }

    /* the three universes, named where their bundle leaves */
    if(A>0.06&&rim>140){
      for(var ui=0;ui<D2.universes.length;ui++){
        var mem=RAYS.filter(function(q){return q.u===ui;});
        var mid=mem[Math.floor(mem.length/2)];
        var lp=this.pt(mid,0.62,cx,cy,rim,t);
        x.save();x.translate(lp[0],lp[1]);x.rotate(lp[2]+Math.PI/2);
        x.textAlign='center';x.textBaseline='middle';
        x.font='7.5px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*(this.following&&this.following.u!==ui?0.16:0.40));
        x.fillText(D2.universes[ui].name.toUpperCase(),0,0);
        x.restore();
      }
    }

    /* what the world asks, in words */
    x.textAlign='center';x.textBaseline='middle';
    x.font='8.5px "Space Mono", monospace';
    if(!this.following&&A>0.30){
      x.fillStyle=rgba('#EDE8E3',A*0.38*(0.7+br*0.4));
      x.fillText('TAKE A RAY NEAR THE CENTRE \u00b7 THEN GO OUT',cx,H-150);
    }else if(this.following){
      var word=this.given>=4?'far out, and still leaving':
        this.out<0.12?'holding it':this.out<0.44?'going':
        this.out<0.72?'further':'far out';
      x.fillStyle=rgba('#EDE8E3',A*0.44);
      x.fillText(word.toUpperCase(),cx,H-150);
    }
    x.restore();
  }
};

/* one light becoming many: white at the origin, its own hue further out */
function split(f){return mix('#FFFDF8',HUE,Math.min(1,Math.pow(Math.max(0,f),0.62)*1.12));}
function rgba(h,a){
  var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';
}
function mix(a,b,f){
  var pa=[parseInt(a.slice(1,3),16),parseInt(a.slice(3,5),16),parseInt(a.slice(5,7),16)];
  var pb=[parseInt(b.slice(1,3),16),parseInt(b.slice(3,5),16),parseInt(b.slice(5,7),16)];
  var hx=function(v){v=Math.round(Math.max(0,Math.min(255,v))).toString(16);return v.length<2?'0'+v:v;};
  return '#'+hx(pa[0]+(pb[0]-pa[0])*f)+hx(pa[1]+(pb[1]-pa[1])*f)+hx(pa[2]+(pb[2]-pa[2])*f);
}
g.TWO=Two;
})(window);
