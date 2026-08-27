/* THE POINT · III · THE VEIL ───────────────────────────────────────
   417 Hz. Voice: "The forgetting was the entry fee, not the
   malfunction. Most of what has you is inherited — and everything
   inherited can be handed back."

   Two claims, and the world has to hold both at once.

   FORGETTING IS THE ENTRY FEE. So the veil is not an obstacle placed
   in front of content. It is the medium — four curtains at four
   depths, drifting at four rates, and it closes behind his hand every
   time. He never gets to lift it. He only ever parts it, where he is,
   while he is there.

   EVERYTHING INHERITED CAN BE HANDED BACK. So the one thing that does
   not close is what he has already read. Each section he receives
   leaves a zone permanently thinner — not clear, thinner. The veil
   remembers what was handed back, and does not take it again.

   THE READING MATERIAL OF THIS WORLD IS PARTING.
     I   admits when he stops.
     II  gives while he goes.
     III gives only where he holds his hand open — and each section
         must be read THROUGH a parting he is actively holding.

   The density he parts is the same field the shader draws. Image and
   content are one event; a star is occluded by exactly the veil that
   is visibly over it.

   And the one that watches back: v-shadow. Part the veil near it and
   his own hand appears on the curtain behind — the diagnostic is that
   the observer shows up in the observed. Nothing is scored. ────── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D3=P.DIMS[2], HUE=P.HUES.m3;

/* ── the nine, and how deeply each is covered ─────────────────────
   Authored from what the universe is, never random. The Old Maps are
   documented — millennia of it — so they lie shallow. The Mechanism is
   by design, so it is covered by design. The Inheritance is the
   deepest: what has you is invisible precisely because you inherited
   it and never chose it. */
var COVER=[0.72,0.94,0.44];
var STARS=[];
(function place(){
  D3.universes.forEach(function(u,ui){
    u.stars.forEach(function(id,i){
      var n=u.stars.length, f=n<2?0.5:i/(n-1);
      var ring=0.30+ui*0.27;
      var a=(-0.62+ui*2.12)+(f-0.5)*1.14;
      STARS.push({id:id,n:P.N[id],u:ui,uname:u.name,
        qx:Math.cos(a)*ring,qy:Math.sin(a)*ring*0.92,
        cover:COVER[ui]*(0.90+((i*7)%5)/5*0.20),
        ph:ui*1.9+i*2.3,
        shadow:id==='v-shadow'});
    });
  });
})();
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};

var Three={
  STARS:STARS,DIM:D3,HUE:HUE,
  hand:null,        /* where he is holding the veil open, in shell-local coords */
  open:0,           /* how wide, 0 \u2192 1 */
  reading:null,     /* the star being read through the parting */
  given:0,
  back:[],          /* what has been handed back \u2014 permanent, and it is a list */
  closing:0,
  hits:[],

  reset:function(){this.hand=null;this.open=0;this.reading=null;this.given=0;this.closing=0;},

  /* ── the parting ───────────────────────────────────────────────
     His hand opens the veil only while it is there. Distance decides
     nothing; presence does. */
  place:function(qx,qy){
    this.hand=[qx,qy];
    this.open=Math.min(1,this.open+0.34);
    var best=null,bd=1e9;
    for(var i=0;i<STARS.length;i++){
      var s=STARS[i], d=Math.hypot(s.qx-qx,s.qy-qy);
      if(d<0.19&&d<bd){bd=d;best=s;}
    }
    if(best!==this.reading){this.reading=best;this.given=0;}
    return best;
  },
  move:function(qx,qy){
    this.hand=[qx,qy];
    var best=null,bd=1e9;
    for(var i=0;i<STARS.length;i++){
      var s=STARS[i], d=Math.hypot(s.qx-qx,s.qy-qy);
      if(d<0.19&&d<bd){bd=d;best=s;}
    }
    if(best!==this.reading){this.reading=best;this.given=0;}
  },
  /* he is holding it open. Sections arrive while he holds, and only while. */
  hold:function(dt){
    if(!this.hand)return null;
    this.open=Math.min(1,this.open+dt*0.42);
    if(!this.reading)return null;
    var gates=[0.30,0.52,0.74,0.94];
    if(this.given<4&&this.open>=gates[this.given]){
      this.given++;
      /* what he has just been given is handed back \u2014 that zone stays thin */
      this.handBack(this.reading,this.given);
      return {k:['say','walk','hand','open'][this.given-1],i:this.given};
    }
    return null;
  },
  handBack:function(s,n){
    for(var i=0;i<this.back.length;i++){
      if(this.back[i].id===s.id){this.back[i].r=Math.max(this.back[i].r,0.06+n*0.026);return;}
    }
    this.back.push({id:s.id,x:s.qx,y:s.qy,r:0.06+n*0.026});
  },
  isBack:function(s){
    for(var i=0;i<this.back.length;i++)if(this.back[i].id===s.id)return this.back[i].r;
    return 0;
  },
  release:function(){
    if(this.hand)this.closing=1;
    this.hand=null;
  },
  update:function(dt,holding){
    if(!holding){
      /* the veil closes behind his hand. It always does. */
      this.open=Math.max(0,this.open-dt*0.70);
      if(this.open<=0.02){this.reading=null;this.given=0;}
    }
    if(this.closing>0)this.closing=Math.max(0,this.closing-dt*0.8);
  },
  displaced:function(){return this.given/4;},

  /* what the shader needs: the parting, and the permanent thin places */
  uHand:function(){return this.hand?[this.hand[0],this.hand[1],this.open*0.62]:[0,0,0];},
  uBack:function(){
    var a=new Float32Array(27);
    for(var i=0;i<Math.min(9,this.back.length);i++){
      a[i*3]=this.back[i].x;a[i*3+1]=this.back[i].y;a[i*3+2]=this.back[i].r;
    }
    return a;
  },

  /* ── the world ───────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(8,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var dsp=this.displaced(), A=p*(1-dsp*0.50);
    this.hits=[];
    if(A<=0.004)return;
    var toS=function(q){return [cx+q[0]*rim,cy+q[1]*rim];};
    x.save();x.textAlign='center';x.textBaseline='middle';

    for(var i=0;i<STARS.length;i++){
      var s=STARS[i], sp=toS([s.qx,s.qy]);
      /* how much of the veil is actually over this star, right now */
      var lift=0;
      if(this.hand){
        var d=Math.hypot(s.qx-this.hand[0],s.qy-this.hand[1]);
        lift=this.open*Math.max(0,1-d/(this.open*0.34+0.09));
      }
      var kept=this.isBack(s);
      if(kept>0)lift=Math.max(lift,0.78);
      var shown=Math.max(0.06,1-s.cover*(1-lift));
      var mine=this.reading===s;
      /* backlit: it is not lit from in front, it shines THROUGH */
      var R=Math.max(2.0,rim*0.014)*(1+shown*0.55);
      var al=A*shown*(mine?1:0.86);
      var hal=R*(6+shown*11);
      var gr=x.createRadialGradient(sp[0],sp[1],0,sp[0],sp[1],hal);
      gr.addColorStop(0,rgba(mix(HUE,'#FFFBFF',0.44+shown*0.36),al*(0.34+shown*0.40)));
      gr.addColorStop(0.22,rgba(HUE,al*0.20));
      gr.addColorStop(1,rgba(HUE,0));
      x.fillStyle=gr;x.beginPath();x.arc(sp[0],sp[1],hal,0,TAU);x.fill();
      x.beginPath();x.arc(sp[0],sp[1],R,0,TAU);
      x.fillStyle=rgba(mix(HUE,'#FFFDFF',0.30+shown*0.55),Math.min(1,al*1.15));x.fill();
      /* the thin place it left behind, once handed back \u2014 a ring that stays */
      if(kept>0){
        x.beginPath();x.arc(sp[0],sp[1],kept*rim,0,TAU);
        x.strokeStyle=rgba(HUE,A*0.16);x.lineWidth=0.7;x.stroke();
      }
      if(shown>0.42&&rim>150){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*shown*0.40);
        x.fillText(STATUS[s.n.st],sp[0],sp[1]-R*5.0);
      }
      /* a title can only be read where the veil is actually parted */
      if(mine&&shown>0.44){
        x.font='italic 13.5px Lora, Georgia, serif';
        x.fillStyle=rgba('#FFFDFF',A*Math.min(1,(shown-0.44)/0.4)*0.92);
        x.fillText(s.n.t,sp[0],sp[1]+R*5.6);
      }
      this.hits.push({s:s,x:sp[0],y:sp[1],rad:rim*0.19});
    }

    /* the hand on the curtain. And where he is near the one that watches
       back, his own hand appears on the veil behind it \u2014 the observer,
       showing up in the observed. */
    if(this.hand){
      var hp=toS(this.hand), hr=(this.open*0.34+0.09)*rim;
      var hg=x.createRadialGradient(hp[0],hp[1],0,hp[0],hp[1],hr);
      hg.addColorStop(0,rgba('#FFFBFF',A*this.open*0.16));
      hg.addColorStop(0.6,rgba(HUE,A*this.open*0.06));
      hg.addColorStop(1,rgba(HUE,0));
      x.fillStyle=hg;x.beginPath();x.arc(hp[0],hp[1],hr,0,TAU);x.fill();
      x.beginPath();x.arc(hp[0],hp[1],hr,0,TAU);
      x.strokeStyle=rgba(HUE,A*this.open*0.22);x.lineWidth=0.8;x.stroke();
      if(this.reading&&this.reading.shadow&&this.open>0.30){
        var sh=toS([this.reading.qx,this.reading.qy]);
        var ox=(sh[0]-hp[0])*0.36, oy=(sh[1]-hp[1])*0.36;
        x.beginPath();x.arc(sh[0]+ox,sh[1]+oy,hr*0.72,0,TAU);
        x.fillStyle='rgba(6,4,12,'+(A*(this.open-0.30)*0.42)+')';x.fill();
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba('#FFFBFF',A*(this.open-0.30)*0.42);
        x.fillText('THAT IS YOUR OWN HAND',sh[0]+ox,sh[1]+oy+hr*0.95);
      }
    }

    /* the three universes, named at the depth they lie at */
    if(A>0.06&&rim>140){
      for(var ui=0;ui<D3.universes.length;ui++){
        var mem=STARS.filter(function(q){return q.u===ui;});
        var mid=mem[Math.floor(mem.length/2)], mp=toS([mid.qx,mid.qy]);
        var dep=1-COVER[ui];
        x.font='7.5px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*(0.20+dep*0.34));
        x.fillText(D3.universes[ui].name.toUpperCase(),mp[0],mp[1]-rim*0.11);
      }
    }

    /* what the world asks, in words */
    x.font='8.5px "Space Mono", monospace';
    if(!this.hand&&this.closing<=0.02&&A>0.30){
      x.fillStyle=rgba('#EDE8E3',A*0.38*(0.7+br*0.4));
      x.fillText(this.back.length?'PART IT AGAIN, SOMEWHERE ELSE':'PART IT WITH YOUR HAND \u00b7 AND HOLD IT OPEN',cx,H-150);
    }else if(this.hand){
      var word=!this.reading?'nothing here yet':
        this.given>=4?'handed back':this.open<0.30?'holding it open':
        this.given<2?'it is thinning':'thinner';
      x.fillStyle=rgba('#EDE8E3',A*0.44);
      x.fillText(word.toUpperCase(),cx,H-150);
    }else if(this.closing>0.02){
      x.fillStyle=rgba('#EDE8E3',this.closing*p*0.30);
      x.fillText('IT CLOSED BEHIND YOU. IT ALWAYS DOES.',cx,H-150);
    }
    x.restore();
  }
};

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
g.THREE=Three;
})(window);
