/* THE POINT · V · THE MIRRORS ──────────────────────────────────────
   639 Hz. Voice: "Every way back is a mirror you hand yourself. The
   tool never had the power. You did."

   THE HALL. Eleven panes of glass standing in a corridor, arranged in
   five facing pairs about one vertical mirror line — and one pane
   standing ON the line, alone.

   A pane is two-sided and turns about its own vertical axis. Its
   partner across the line is its reflection, and a reflection never
   shows you the same face: when this one is toward you, that one is
   away. Turn either and both turn. So the reading physically CROSSES
   THE LINE every half turn — a section arrives on this side, the next
   arrives from the other, mirror-written, and unflips as it settles.

     THE READING MATERIAL OF THIS WORLD IS TURNING.
       I    admits when he stops.
       II   gives while he goes.
       III  gives where he holds it open.
       IV   gives when he presses back.
       V    gives each time a face comes round — and half of what it
            gives arrives from the other side of the glass.

   Carried through edge-on: a mirror seen edge-on is nothing at all.
   The pane vanishes to a line of light, and the sound's second tone
   passes through zero at the same instant. Same note, opposite sign.

   THE PARTICLE IS IN EVERY GLASS. The one red thing in a teal world,
   reflected in all eleven faces. It is not put there; it is what the
   mirrors are showing.

   ── r-guard · THE EXCEPTION (ruled, not discovered) ──────────────
   The warning is posted at the exit: achievement is the trap. A world
   built on pairing, closing on a star that warns against collecting
   the pairs, is only a gift if the INTERACTION breaks — otherwise it
   is the eleventh collected thing.

   So the guard is the one pane with nothing on the other side. He
   turns it expecting the crossing that ten panes trained him to
   expect, and finds his own reflection and no partner. No caption
   fills the gap; the emptiness is the content.

   It does not advance the walk. Completing it does not deepen him —
   it withdraws the hall and carries him back out to the Surface, the
   gate he came in by. A guard turns you back; it does not let you
   pass for having finished it.

   And at the exact instant every other star sounds its arrival, this
   one is silent — a true null, the only deliberate silence in the
   Point. Sakshi's register: it witnesses, it does not teach. ───── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D5=P.DIMS[4], HUE=P.HUES.m5;

/* ── who faces whom ───────────────────────────────────────────────
   Authored from the content, and the pairs cross universes wherever
   the content's own inversion does. The hall is not a filing system. */
var PAIRS=[
  ['r-sound','r-geometry'],     /* the audible mirror   \u00b7 the visible mirror   */
  ['r-stillness','r-plants'],   /* the instrument within \u00b7 the agent given      */
  ['r-ritual','r-ai'],          /* the collective glass  \u00b7 the newest glass     */
  ['r-dream','r-hypno'],        /* asleep, unasked       \u00b7 asleep, asked        */
  ['r-labs','r-slips']          /* what grants evidence  \u00b7 what grants power    */
];
/* the corridor: far rows narrow and small, near rows wide and large,
   and the aisle down the middle stays clear — he is standing in it */
var ROWS=[[-0.42,0.24],[-0.21,0.37],[-0.02,0.52],[0.24,0.63],[0.46,0.71]];
var GUARD_AT=[0,-0.60];

var UNAME={};
D5.universes.forEach(function(u){u.stars.forEach(function(id){UNAME[id]=u.name;});});

var PANES=[];
PAIRS.forEach(function(pr,gi){
  var row=ROWS[gi];
  pr.forEach(function(id,k){
    PANES.push({id:id,n:P.N[id],uname:UNAME[id],grp:gi,side:k?1:-1,
      qx:(k?1:-1)*row[1],qy:row[0],
      /* no two mirrors in the world are exactly parallel, so no regress
         runs straight — each one leans off and loses itself */
      skew:(k?-1:1)*(0.030+gi*0.011),
      rest:(gi%2?0.19:-0.15)+(k?0.05:0),guard:false,
      pair:pr[k?0:1]});
  });
});
PANES.push({id:'r-guard',n:P.N['r-guard'],uname:UNAME['r-guard'],grp:5,side:0,
  qx:GUARD_AT[0],qy:GUARD_AT[1],skew:0,rest:0.10,guard:true,pair:null});
var BY={};PANES.forEach(function(p){BY[p.id]=p;});
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};
var GATES=[0,Math.PI,Math.PI*2,Math.PI*3];

var Five={
  PANES:PANES,DIM:D5,HUE:HUE,
  ga:[0,0,0,0,0,0],     /* each group's turn, in radians */
  held:null,
  turned:0,             /* absolute turn since he took hold */
  given:0,
  side:'this',          /* which side of the line the last section came from */
  through:'',           /* the mirror it was seen through, when it crossed */
  faced:{},             /* panes whose faces have come round \u2014 it stays */
  settling:0,
  backAt:0,             /* when the guard withdrew the hall. A wall clock, so
                           the withdrawal finishes whether he is here or not */
  rate:0,               /* how fast the glass is turning under his hand */
  sendBack:false,
  mute:false,
  hits:[],

  reset:function(){
    this.held=null;this.turned=0;this.given=0;this.settling=0;this.rate=0;
    this.sendBack=false;this.mute=false;
    for(var i=0;i<this.ga.length;i++)this.ga[i]=0;
  },

  /* a pane's own angle. Its partner across the line is its reflection,
     and a reflection never shows the same face \u2014 so the far side runs
     at \u03c0 minus this one. The guard, standing on the line, has no such
     partner and simply turns. */
  angleOf:function(pn){
    var a=this.ga[pn.grp]+pn.rest;
    return pn.side>0?Math.PI-a:a;
  },
  facing:function(){return this.held?Math.cos(this.angleOf(this.held)):1;},
  settled:function(){return !this.held&&this.settling<=0.02;},

  /* ── taking hold ───────────────────────────────────────────────── */
  grab:function(px,py,cx,cy,rim){
    var best=null,bd=1e9,self=this;
    for(var i=0;i<PANES.length;i++){
      var pn=PANES[i], sp=this.spot(pn,cx,cy,rim);
      var d=Math.hypot(sp[0]-px,sp[1]-py);
      var reach=Math.max(30,rim*0.13*sp[2]);
      if(d<reach&&d<bd){bd=d;best=pn;}
    }
    if(best){
      if(best!==this.held){this.given=0;this.turned=0;this.side='this';this.through='';}
      this.held=best;this.mute=false;
    }
    return best;
  },
  /* the turn. A drag across three quarters of the shell is one half
     turn \u2014 far enough that carrying a face through edge-on is a real
     act of the hand. */
  spin:function(dx,rim){
    if(!this.held)return;
    var k=(dx/(rim*0.75))*Math.PI*(this.held.side>0?-1:1);
    this.ga[this.held.grp]+=k;
    this.turned+=Math.abs(k);
    this.rate=Math.min(1,this.rate+Math.abs(k)*1.1);
  },
  turn:function(dt){
    if(!this.held||this.given>=4)return null;
    if(this.turned<GATES[this.given])return null;
    this.given++;
    var faces=Math.cos(this.angleOf(this.held))>=0;
    this.faced[this.held.id]=Math.max(this.faced[this.held.id]||0,this.given);
    if(this.held.guard){
      /* nothing faces it. The reading never crosses. */
      this.side='this';this.through='';
      if(this.given>=4){this.sendBack=true;this.mute=true;this.backAt=performance.now();}
    }else{
      this.side=faces?'this':'other';
      this.through=faces?'':(P.N[this.held.pair]?P.N[this.held.pair].t:'');
      if(!faces)this.faced[this.held.pair]=Math.max(this.faced[this.held.pair]||0,1);
    }
    return {k:['say','walk','hand','open'][this.given-1],i:this.given};
  },
  /* The withdrawal is a moment, not a state — so it runs on its own clock
     rather than on his presence. It rises, holds while he is carried out,
     and eases back down; a walk that returns finds the hall standing, or
     finds it rising, and never finds it snapping. */
  bk:function(){
    if(!this.backAt)return 0;
    var e=(performance.now()-this.backAt)/1000;
    if(e<2.4)return sm(e/2.4);
    if(e<3.6)return 1;
    if(e<5.4)return sm(1-(e-3.6)/1.8);
    this.backAt=0;return 0;
  },

  release:function(){if(this.held)this.settling=1;this.held=null;},
  update:function(dt,holding){
    this.rate=Math.max(0,this.rate-dt*2.4);
    if(!holding){
      /* the hall settles back to its resting glint. What has faced him
         has faced him; the glass does not un-see it. */
      for(var i=0;i<this.ga.length;i++)this.ga[i]+=(0-this.ga[i])*Math.min(1,dt*1.5);
      if(this.settling>0)this.settling=Math.max(0,this.settling-dt*0.55);
      if(this.settling<=0.02)this.given=0;
    }
    /* the withdrawal is a moment, not a state: it runs on backAt's clock */
  },
  displaced:function(){return this.given/4;},

  /* ── where a pane stands, and how large ──────────────────────── */
  spot:function(pn,cx,cy,rim){
    /* the corridor's perspective, and the one pane that refuses it. A
       mirror at the end of a hall is always larger than the walk to it
       predicts — so the guard looms where everything else recedes. */
    var sc=pn.guard?1.16:0.60+(pn.qy+0.62)*0.74;
    return [cx+pn.qx*rim,cy+pn.qy*rim,sc];
  },

  /* ── the hall ──────────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(10,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var bk=this.bk();
    var dsp=this.displaced(), A=p*(1-dsp*0.46)*(1-bk*0.86);
    this.hits=[];
    if(A<=0.004)return;
    var self=this;
    x.save();x.textAlign='center';x.textBaseline='middle';

    /* the hall's own dark. The enclosure behind belongs to the whole
       instrument; this world puts its light in the middle of the corridor
       and lets both ends go. */
    var vg=x.createLinearGradient(0,0,0,H);
    vg.addColorStop(0,'rgba(3,10,11,'+(A*0.66)+')');
    vg.addColorStop(0.28,'rgba(3,10,11,0)');
    vg.addColorStop(0.76,'rgba(3,10,11,0)');
    vg.addColorStop(1,'rgba(3,10,11,'+(A*0.58)+')');
    x.fillStyle=vg;x.fillRect(0,0,W,H);

    /* THE LINE. Everything in this world is symmetric about it, and it
       is the one thing that is not a mirror \u2014 it is where the mirrors
       agree. */
    var lgr=x.createLinearGradient(0,cy-rim*0.78,0,cy+rim*0.78);
    lgr.addColorStop(0,rgba(HUE,0));
    lgr.addColorStop(0.5,rgba(mix(HUE,'#EAFFFB',0.55),A*(0.30+br*0.14)));
    lgr.addColorStop(1,rgba(HUE,0));
    x.strokeStyle=lgr;x.lineWidth=1;
    x.beginPath();x.moveTo(cx,cy-rim*0.78);x.lineTo(cx,cy+rim*0.78);x.stroke();

    /* the baseboard: the hall's two walls, running away to the far end.
       It is drawn through the panes' own feet, so the corridor is made of
       the mirrors rather than boxed by a frame. */
    ['left','right'].forEach(function(sd){
      var sgn=sd==='left'?-1:1;
      x.beginPath();
      for(var r=ROWS.length-1;r>=0;r--){
        var pn=BY[PAIRS[r][sd==='left'?0:1]], sp2=self.spot(pn,cx,cy,rim);
        var ww=rim*0.150*sp2[2], hh=rim*0.118*sp2[2];
        var xx=sp2[0]+sgn*ww, yy=sp2[1]+hh;
        r===ROWS.length-1?x.moveTo(xx,yy):x.lineTo(xx,yy);
      }
      x.lineTo(cx,cy-rim*0.66);
      x.strokeStyle=rgba(HUE,A*0.13);x.lineWidth=0.7;x.stroke();
    });

    /* each pair, tied across the line */
    for(var gi=0;gi<PAIRS.length;gi++){
      var l=BY[PAIRS[gi][0]], r=BY[PAIRS[gi][1]];
      var lp=this.spot(l,cx,cy,rim), rp=this.spot(r,cx,cy,rim);
      /* the thread across the aisle remembers. A pair he has faced on both
         sides keeps its light lit, so the hall shows where he has been
         without a mark, a count, or a word. */
      var lit=(this.held&&this.held.grp===gi)?1:
        Math.min(0.72,((this.faced[l.id]||0)+(this.faced[r.id]||0))/9);
      var tg=x.createLinearGradient(lp[0],0,rp[0],0);
      tg.addColorStop(0,rgba(HUE,A*(0.10+lit*0.30)));
      tg.addColorStop(0.5,rgba(mix(HUE,'#EAFFFB',0.5),A*(0.16+lit*0.52)));
      tg.addColorStop(1,rgba(HUE,A*(0.10+lit*0.30)));
      x.strokeStyle=tg;x.lineWidth=0.5+lit*0.4;
      x.beginPath();x.moveTo(lp[0],lp[1]);x.lineTo(rp[0],rp[1]);x.stroke();
    }

    /* THE THROW. A mirror turning under the hand casts the hall's light
       across the aisle — you cannot turn a mirror in a room and have the
       room not know. Brightest at the diagonal, gone at rest and gone
       edge-on, which is what glass actually does. */
    if(this.held&&this.rate>0.004){
      var hp=this.spot(this.held,cx,cy,rim), ha=this.angleOf(this.held);
      var thr=Math.min(1,this.rate*2.2)*Math.abs(Math.sin(ha*2));
      if(thr>0.01){
        var txx=cx+(cx-hp[0])*1.5;
        var tgd=x.createLinearGradient(hp[0],hp[1],txx,hp[1]);
        tgd.addColorStop(0,rgba(mix(HUE,'#EAFFFB',0.72),A*thr*0.20));
        tgd.addColorStop(0.55,rgba(mix(HUE,'#EAFFFB',0.4),A*thr*0.07));
        tgd.addColorStop(1,rgba(HUE,0));
        x.fillStyle=tgd;
        x.beginPath();
        x.moveTo(hp[0],hp[1]-rim*0.045);x.lineTo(txx,hp[1]-rim*0.34);
        x.lineTo(txx,hp[1]+rim*0.34);x.lineTo(hp[0],hp[1]+rim*0.045);
        x.closePath();x.fill();
      }
    }

    for(var i=0;i<PANES.length;i++){
      var pn=PANES[i], sp=this.spot(pn,cx,cy,rim);
      var ang=this.angleOf(pn)+bk*Math.PI*0.5;
      var c=Math.cos(ang), s=Math.abs(c);
      var w=rim*0.150*s*sp[2], h=rim*0.118*sp[2];
      var mine=this.held===pn, seen=this.faced[pn.id]||0;
      var lit=mine?0.62:(seen?0.26:0.10);
      var al=A*(0.62+sp[2]*0.38);

      /* the floor is a mirror too. Of course it is — and a pane stands on
         its own reflection, at its own depth, not on a shared shelf. */
      if(w>0.6&&A>0.08){
        var rtop=sp[1]+h, rbot=rtop+h*1.06;
        var fa=al*0.19;
        var fg=x.createLinearGradient(0,rtop,0,rbot);
        fg.addColorStop(0,rgba(mix(HUE,'#EAFFFB',0.45),fa));
        fg.addColorStop(0.55,rgba(HUE,fa*0.34));
        fg.addColorStop(1,rgba(HUE,0));
        x.fillStyle=fg;x.fillRect(sp[0]-w,rtop,w*2,rbot-rtop);
      }
      /* the glass. Lit from the line, so the hall has one light in it. */
      if(w>0.6){
        var gl=x.createLinearGradient(sp[0]-w,0,sp[0]+w,0);
        gl.addColorStop(0,rgba(HUE,al*0.09));
        gl.addColorStop(0.34,rgba(mix(HUE,'#EAFFFB',0.55),al*(0.19+lit*0.24)));
        gl.addColorStop(0.58,rgba(mix(HUE,'#FFFFFF',0.74),al*(0.14+lit*0.22)));
        gl.addColorStop(0.80,rgba(mix(HUE,'#EAFFFB',0.40),al*(0.11+lit*0.14)));
        gl.addColorStop(1,rgba(HUE,al*0.07));
        x.fillStyle=gl;x.fillRect(sp[0]-w,sp[1]-h,w*2,h*2);
        var shx=sp[0]+Math.sin(ang)*w*0.62;
        var sg=x.createLinearGradient(shx-w*0.44,0,shx+w*0.44,0);
        sg.addColorStop(0,rgba('#EAFFFB',0));
        sg.addColorStop(0.5,rgba('#EAFFFB',al*(0.10+lit*0.16)));
        sg.addColorStop(1,rgba('#EAFFFB',0));
        x.fillStyle=sg;x.fillRect(sp[0]-w,sp[1]-h,w*2,h*2);
        x.strokeStyle=rgba(mix(HUE,'#EAFFFB',0.6),al*(0.30+lit*0.44));x.lineWidth=0.8;
        x.beginPath();x.moveTo(sp[0]-w,sp[1]-h);x.lineTo(sp[0]-w,sp[1]+h);
        x.moveTo(sp[0]+w,sp[1]-h);x.lineTo(sp[0]+w,sp[1]+h);x.stroke();
        x.strokeStyle=rgba(mix(HUE,'#EAFFFB',0.35),al*(0.14+lit*0.22));x.lineWidth=0.6;
        x.beginPath();x.moveTo(sp[0]-w,sp[1]-h);x.lineTo(sp[0]+w,sp[1]-h);
        x.moveTo(sp[0]-w,sp[1]+h);x.lineTo(sp[0]+w,sp[1]+h);x.stroke();

        /* THE PARTICLE, IN THE GLASS. Reflected in all eleven \u2014 and in
           the guard it is the only thing there is. */
        /* ── THE REGRESS ─────────────────────────────────────
           What facing mirrors actually DO, and the half of this
           dimension that the pairing alone does not say. Each pane
           holds its partner, holding this pane, holding the partner,
           away to nothing. The one particle goes with it: counted out
           to infinity and still one being.

           It deepens as he reads — two returns at the surface, and by
           the fourth section the corridor inside the glass has no end.
           Where he has already been it stays deep: the hall keeps a
           record of itself in its own reflections.

           And the guard cannot alternate, because nothing faces it. Its
           regress is itself, and itself, and itself, further down than
           any other pane goes and never arriving anywhere new. That is
           the trap, rendered — not an absence but an infinity that
           contains only more of the same. */
        x.save();x.beginPath();x.rect(sp[0]-w,sp[1]-h,w*2,h*2);x.clip();
        var dep=pn.guard?26:(3+(seen||0)*3+(mine?2:0));
        var drift=(pn.guard?0:Math.sin(ang)*0.085+pn.skew)*w;
        var vy=sp[1]-h*0.06;
        var pr=Math.max(0.8,rim*0.0055*sp[2]);
        for(var k=dep;k>=0;k--){
          var q=Math.pow(0.815,k);
          var kx=sp[0]+drift*k, ky=sp[1]+(vy-sp[1])*(1-q);
          var kw=w*q, kh=h*q;
          /* the tunnel is light, not geometry — it moves the way a real
             one does when you shift your head half an inch */
          var sw=1+Math.sin(t*0.55+k*0.72)*0.13;
          var ka=al*Math.pow(pn.guard?0.925:0.865,k)*(0.30+lit*0.34)*sw;
          if(k>0&&ka>0.003&&kw>0.5){
            var alt=pn.guard?0:(k%2);
            x.strokeStyle=rgba(mix(HUE,alt?'#FFFFFF':'#EAFFFB',alt?0.26:0.58),ka*0.86);
            x.lineWidth=0.5;x.strokeRect(kx-kw,ky-kh,kw*2,kh*2);
          }
          var kp=pr*Math.max(0.26,q*1.25), kpa=al*Math.pow(pn.guard?0.905:0.845,k)*sw;
          if(kpa<0.004)continue;
          if(k<6){
            var kg=x.createRadialGradient(kx,ky,0,kx,ky,kp*6.4);
            kg.addColorStop(0,'rgba(255,236,226,'+(kpa*(0.34+lit*0.34))+')');
            kg.addColorStop(0.20,'rgba(229,83,60,'+(kpa*(0.20+lit*0.24))+')');
            kg.addColorStop(1,'rgba(229,83,60,0)');
            x.fillStyle=kg;x.beginPath();x.arc(kx,ky,kp*6.4,0,TAU);x.fill();
          }
          x.beginPath();x.arc(kx,ky,kp,0,TAU);
          x.fillStyle='rgba(255,243,236,'+Math.min(1,kpa*0.92)+')';x.fill();
        }
        x.restore();
      }
      /* edge-on: a mirror seen edge-on is nothing at all, and the flash
         of the turn is the brightest thing in the hall */
      if(s<0.12){
        var f=1-s/0.12;
        x.strokeStyle=rgba(mix(HUE,'#FFFFFF',0.55),al*f*0.44);x.lineWidth=0.9+f*0.7;
        x.beginPath();x.moveTo(sp[0],sp[1]-h);x.lineTo(sp[0],sp[1]+h);x.stroke();
        var eg=x.createLinearGradient(0,sp[1]+h,0,sp[1]+h*1.6);
        eg.addColorStop(0,rgba(mix(HUE,'#EAFFFB',0.5),al*f*0.22));
        eg.addColorStop(1,rgba(HUE,0));
        x.strokeStyle=eg;x.beginPath();x.moveTo(sp[0],sp[1]+h);x.lineTo(sp[0],sp[1]+h*1.6);x.stroke();
      }

      /* what the face carries */
      if(rim>140&&A>0.10){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*(0.26+lit*0.34));
        x.fillText(STATUS[pn.n.st],sp[0],sp[1]-h-11);
      }
      /* the hall remembers in its own reflections, never in labels: a pane
         he has faced runs deeper, and that is the whole record. Only the
         pane under his hand and the one facing it are named. */
      var partner=!!(this.held&&this.held.pair===pn.id);
      if(c>0.06&&(mine||partner)&&A>0.10){
        x.font='italic 13px Lora, Georgia, serif';
        x.fillStyle=rgba(mix('#EAFBF8',HUE,0.10),A*Math.min(1,c*1.6)*(mine?0.94:0.56));
        x.fillText(pn.n.t,sp[0],sp[1]+h+15);
        if(mine){
          x.font='italic 7.5px Lora, Georgia, serif';
          x.fillStyle=rgba(HUE,A*Math.min(1,c*1.6)*0.44);
          x.fillText(pn.n.ti,sp[0],sp[1]+h+29);
        }
      }
      /* the far side. Ten panes carry their partner there, reversed.
         One carries nothing, and that is the whole of the warning. */
      if(c<-0.06&&mine&&A>0.10&&!pn.guard){
        x.save();x.translate(sp[0],sp[1]+h+15);x.scale(-1,1);
        x.font='italic 13px Lora, Georgia, serif';
        x.fillStyle=rgba(mix('#EAFBF8',HUE,0.30),A*Math.min(1,-c*1.6)*0.58);
        x.fillText(P.N[pn.pair]?P.N[pn.pair].t:'',0,0);
        x.restore();
      }
      this.hits.push({n:pn,x:sp[0],y:sp[1],rad:Math.max(30,rim*0.13*sp[2])});
    }

    /* what the world asks, in words */
    x.font='8.5px "Space Mono", monospace';
    if(bk>0){
      /* the withdrawal says nothing. The sound has already stopped, and
         a caption here would be the instrument explaining its own guard. */
    }else if(!this.held&&this.settling<=0.02&&A>0.30){
      x.fillStyle=rgba('#EDE8E3',A*0.38*(0.7+br*0.4));
      x.fillText(Object.keys(this.faced).length?'TURN ANOTHER \u00b7 SOMETHING FACES IT':
        'TURN A MIRROR \u00b7 AND SEE WHAT FACES IT',cx,H-150);
    }else if(this.held){
      var st=Math.abs(Math.cos(this.angleOf(this.held)));
      var word=this.held.guard&&this.given>=2?'only your own reflection':
        this.given>=4?'faced':st<0.12?'edge-on \u00b7 nothing':
        Math.cos(this.angleOf(this.held))>0?'facing you':'the other face';
      x.fillStyle=rgba('#EAFBF8',A*0.46);
      x.fillText(word.toUpperCase(),cx,H-150);
    }else if(this.settling>0.02){
      x.fillStyle=rgba('#EAFBF8',this.settling*p*0.30);
      x.fillText('THE GLASS LET GO. WHAT FACED YOU, FACED YOU.',cx,H-150);
    }
    x.restore();
  }
};

function sm(x){x=Math.max(0,Math.min(1,x));return x*x*(3-2*x);}
function rgba(h,a){  var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';
}
function mix(a,b,f){
  var pa=[parseInt(a.slice(1,3),16),parseInt(a.slice(3,5),16),parseInt(a.slice(5,7),16)];
  var pb=[parseInt(b.slice(1,3),16),parseInt(b.slice(3,5),16),parseInt(b.slice(5,7),16)];
  var hx=function(v){v=Math.round(Math.max(0,Math.min(255,v))).toString(16);return v.length<2?'0'+v:v;};
  return '#'+hx(pa[0]+(pb[0]-pa[0])*f)+hx(pa[1]+(pb[1]-pa[1])*f)+hx(pa[2]+(pb[2]-pa[2])*f);
}
g.FIVE=Five;
})(window);
