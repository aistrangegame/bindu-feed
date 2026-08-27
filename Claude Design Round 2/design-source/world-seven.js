/* THE POINT · VII · THE DANCE ──────────────────────────────────────
   852 Hz. Voice: "The journey ends in the marketplace, awake, with
   helping hands. Making is remembering; the relations are the practice;
   the seeker was the sought."

   THE LAST WORLD, AND THE ONE THAT BREAKS THE PATTERN OF THE OTHER SIX.

   In every world before this, he acts on a thing. He stays with a star,
   he goes along a ray, he holds a veil open, he presses a wall, he turns
   a mirror, he lets a probe go. Six worlds of one man and one object.

   Here there is no object. There are nine bodies already dancing when he
   arrives — coupled to each other, not to him. They were dancing before
   he came up the axis and they do not stop when he leaves.

     THE READING MATERIAL OF THIS WORLD IS COMPANY.
       I    admits when he stops.
       II   gives while he goes.
       III  gives where he holds it open.
       IV   gives when he presses back.
       V    gives each time a face comes round.
       VI   gives when what he let go of comes back.
       VII  gives faster the more of them are dancing with him. Alone it
            gives, slowly, and completely. It simply gives quicker in
            company, and the difference is the whole teaching.

   ── THE GESTURE · OFFERING A HAND ───────────────────────────────
   He does not grab. He puts his hand out and waits, and the nearest free
   body crosses the floor and takes it. It travels to get there; it is
   not summoned. Then the two of them are one moving thing.

   And then the others see the pair and come. Not all of them, not in an
   order he sets — whoever is near, in whatever order the figure brings
   them. Each one that joins the chain speaks once into the margin of the
   reading, in its own words, and makes the sections arrive faster.

   THE STAR WHOSE READING HE GETS IS THE ONE THAT TOOK HIS HAND. The
   others are not decoration and they are not a score. They are the
   difference between doing this alone and doing this in company, and the
   instrument makes him feel that difference as pace.

   IF HE LETS GO, NOTHING SCATTERS. The figure keeps moving, the reading
   stays where it is, and the ones who danced remain lit. The marketplace
   does not pause for him and it does not punish him. That is picture ten.

   ── THE SOUND · PHASE-LOCK ──────────────────────────────────────
   Every world before this was ONE voice being acted on — narrowed,
   widened, filtered, rung, inverted, delayed. This one is POLYPHONIC.
   Each body in the chain is a real voice at its own harmonic of 852,
   entering slightly out of phase and pulling into lock as the figure
   holds. Five dancing is a five-voice chord that beats and then tunes
   itself. Nothing is added from outside; they simply find each other.

   ── d-map · THE EXCEPTION (ruled) ───────────────────────────────
   The closing star of the whole Point is his own line: "The synthesis is
   a map. The map hasn't become architecture yet."

   It cannot be offered a hand and it will not come for one. It joins by
   itself, once every other body on the floor has danced at least once —
   because a map becomes architecture only after the thing has actually
   been moved through, and not before.

   When it joins, the figure resolves. Everything stops in one frame, the
   nine trails hold where they are, one line is drawn through all nine in
   the order they danced, and its four sections arrive together. That is
   the last reading in the Point, and the door on the other side of it is
   the centre. ─────────────────────────────────────────────────── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D7=P.DIMS[6], HUE=P.HUES.m7;

var UNAME={},UIDX={};
D7.universes.forEach(function(u,ui){u.stars.forEach(function(id){UNAME[id]=u.name;UIDX[id]=ui;});});

/* what each one says when it joins somebody else's dance. Its own hand,
   compressed to the clause that carries across a floor. */
var CALL={
  'd-marketplace':'the mountain was the middle of the story',
  'd-creation':'the building was always the practice',
  'd-reverse':'someone downstream is calling',
  'd-neurons':'neurons don\u2019t carry the whole brain\u2019s stakes alone',
  'd-mitakuye':'all my relations \u2014 stone, water, star',
  'd-father':'awe is one substance; the vocabularies are costumes',
  'd-poets':'when the point cannot be thought, it can be hummed',
  'd-seeker':'there was never a gap to cross',
  'd-map':'judged by whether it changes how you move inside it'
};

var BODIES=[];
D7.universes.forEach(function(u,ui){
  u.stars.forEach(function(id,i){
    var a=(ui*3+i)/9*TAU;
    BODIES.push({id:id,n:P.N[id],uni:ui,uname:u.name,
      x:Math.cos(a)*0.52,y:Math.sin(a)*0.46,      /* normalised to rim */
      vx:0,vy:0,ph:a*1.7%TAU,w:0.62+((ui*3+i)%5)*0.055,
      danced:false,chain:-1,near:0,trail:[],
      last:(id==='d-map')});
  });
});
var BY={};BODIES.forEach(function(b,i){b.i=i;BY[b.id]=b;});
var MAP=BY['d-map'];
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};
/* the pace. Alone it takes about eight seconds of dancing to reach the
   fourth. With four others in the chain it takes under four. */
var GATE=[1.5,3.3,5.5,8.1];

var DUST=[];
for(var q=0;q<130;q++){
  var da=Math.random()*TAU, dr=Math.sqrt(Math.random())*0.74;
  DUST.push({x:Math.cos(da)*dr,y:Math.sin(da)*dr,vx:0,vy:0,s:0.35+Math.random()*0.9});
}

var Seven={
  BODIES:BODIES,DIM:D7,HUE:HUE,CALL:CALL,
  hand:null,          /* where his hand is, in rim-normalised floor coords */
  chain:[],           /* bodies dancing with him, in the order they joined */
  carry:0,            /* how much dancing has been done, at the chain's rate */
  given:0,
  lock:0,             /* the order parameter of the chain's phases, 0 \u2192 1 */
  swirl:0,
  resolved:0,         /* d-map's close, 0 \u2192 1 */
  order:[],           /* every body that has danced, in the order it did */
  joinedNow:null,     /* the body that joined this frame - the page reads it */
  joinedQ:[],         /* several can take a hand in the same frame; none is lost */
  gaveNow:null,
  session:0,          /* each dance is its own reading, not a running total */
  hits:[],

  /* leaving the register lets go of his hand. It does not stop the
     figure and it does not un-dance anybody. */
  reset:function(){
    this.hand=null;this.joinedQ=[];
    for(var i=0;i<this.chain.length;i++)this.chain[i].chain=-1;
    this.chain=[];this.carry=0;this.given=0;
  },
  reading:function(){return this.resolved>0?MAP:(this.chain.length?this.chain[0]:null);},
  displaced:function(){
    if(!this.reading())return -1;
    if(this.hand&&!this.resolved)return -1;      /* he needs the floor to dance on */
    return Math.min(1,this.given/4)*0.54;
  },

  /* ── offering a hand ───────────────────────────────────────────── */
  offer:function(px,py,cx,cy,rim){
    if(this.resolved)return null;
    this.hand={x:(px-cx)/rim,y:(py-cy)/rim};
    return true;
  },
  moveHand:function(px,py,cx,cy,rim){
    if(!this.hand||this.resolved)return;
    this.hand.x=(px-cx)/rim;this.hand.y=(py-cy)/rim;
  },
  letGo:function(){
    if(!this.hand)return;
    this.hand=null;this.joinedQ=[];
    for(var i=0;i<this.chain.length;i++){this.chain[i].chain=-1;this.chain[i].near=0;}
    this.chain=[];this.carry=0;this.given=0;
  },

  /* ── the figure ────────────────────────────────────────────────
     Nine coupled bodies. Cohesion, separation, alignment with their own
     universe, one slow shared swirl, and Kuramoto phase coupling — so
     they fall into time with each other the way anything that dances
     together does. He is a tenth body when his hand is down. */
  update:function(dt){
    dt=Math.min(0.05,dt);
    this.joinedNow=null;this.gaveNow=null;
    var res=this.resolved, damp=res?Math.max(0,1-res*1.6):1;
    this.swirl+=dt*0.16*damp;
    var i,j,b,o;

    /* who is in the chain, and where the chain wants each of them */
    var ch=this.chain;
    for(i=0;i<BODIES.length;i++)BODIES[i]._t=null;
    if(this.hand&&!res){
      var prev=this.hand, L=0.22;
      for(i=0;i<ch.length;i++){
        var ang=Math.atan2(ch[i].y-prev.y,ch[i].x-prev.x);
        ch[i]._t={x:prev.x+Math.cos(ang)*L,y:prev.y+Math.sin(ang)*L};
        prev=ch[i];
      }
    }

    var mx=0,my=0;
    for(i=0;i<BODIES.length;i++){mx+=BODIES[i].x;my+=BODIES[i].y;}
    mx/=BODIES.length;my/=BODIES.length;

    for(i=0;i<BODIES.length;i++){
      b=BODIES[i];
      var ax=0,ay=0;
      if(b._t){
        /* a held hand is a spring, not a weld */
        ax+=(b._t.x-b.x)*11.0;ay+=(b._t.y-b.y)*11.0;
      }else{
        /* cohesion, gently */
        ax+=(mx-b.x)*0.52;ay+=(my-b.y)*0.52;
        /* the shared swirl — the floor's own current */
        var r=Math.hypot(b.x,b.y)||0.001;
        ax+=(-b.y/r)*0.78*(0.4+r);ay+=(b.x/r)*0.78*(0.4+r);
        /* and toward a pair that is dancing, if one is */
        if(ch.length&&this.hand&&!b.last){
          var hx=this.hand.x-b.x, hy=this.hand.y-b.y, hd=Math.hypot(hx,hy)||1;
          var pull=Math.min(1.05,0.30/(hd*hd+0.13));
          ax+=hx/hd*pull;ay+=hy/hd*pull;
        }
      }
      /* separation, and alignment with its own universe */
      for(j=0;j<BODIES.length;j++){
        if(j===i)continue;
        o=BODIES[j];
        var dx=b.x-o.x,dy=b.y-o.y,d2=dx*dx+dy*dy;
        if(d2<0.0484&&d2>1e-6){var d=Math.sqrt(d2);
          ax+=dx/d*(0.22-d)*9.5;ay+=dy/d*(0.22-d)*9.5;}
        if(o.uni===b.uni){ax+=(o.vx-b.vx)*0.30;ay+=(o.vy-b.vy)*0.30;}
      }
      /* the pulse: every body moves a little more on its own upbeat, so
         the ensemble breathes together once they are in time */
      var pu=0.86+Math.cos(b.ph)*0.20;
      b.vx=(b.vx+ax*dt)*0.955;b.vy=(b.vy+ay*dt)*0.955;
      b.x+=b.vx*dt*pu*damp;b.y+=b.vy*dt*pu*damp;
      /* the floor has an edge, and it is soft */
      var rr=Math.hypot(b.x,b.y);
      if(rr>0.76){var k=0.76/rr;b.x*=k;b.y*=k;b.vx*=0.72;b.vy*=0.72;}
      b.trail.push(b.x,b.y);
      if(b.trail.length>184)b.trail.splice(0,2);
    }

    /* PHASE. Kuramoto: each body drifts at its own rate and is pulled
       toward everyone it is coupled to. Inside the chain the coupling is
       strong, so a chain comes into time with itself and the floor hears
       it happen. */
    var K=1.9;
    for(i=0;i<BODIES.length;i++){
      b=BODIES[i];
      var s=0,cnt=0;
      for(j=0;j<BODIES.length;j++){
        if(j===i)continue;o=BODIES[j];
        var both=(b.chain>=0&&o.chain>=0);
        var w=both?1:(o.uni===b.uni?0.30:0.10);
        s+=w*Math.sin(o.ph-b.ph);cnt+=w;
      }
      b.ph+=(b.w+(cnt?K*s/cnt:0))*dt*damp;
      if(b.ph>TAU*4)b.ph-=TAU*4;
    }
    /* how in time the chain is — the number the sound and the shader use */
    if(ch.length){
      var sx=0,sy=0;
      for(i=0;i<ch.length;i++){sx+=Math.cos(ch[i].ph);sy+=Math.sin(ch[i].ph);}
      this.lock+=((Math.hypot(sx,sy)/ch.length)-this.lock)*Math.min(1,dt*2.2);
    }else this.lock=Math.max(0,this.lock-dt*1.1);

    /* ── who joins ───────────────────────────────────────────────
       The nearest free body takes his offered hand. After that, anyone
       who stays close to the chain long enough joins it. Nobody is
       chosen; it is whoever the figure brings. */
    if(this.hand&&!res){
      if(!ch.length){
        var best=null,bd=1e9;
        for(i=0;i<BODIES.length;i++){
          b=BODIES[i];if(b.last)continue;
          var dd=Math.hypot(b.x-this.hand.x,b.y-this.hand.y);
          if(dd<bd){bd=dd;best=b;}
        }
        if(best&&bd<0.19){this._join(best);}
      }else if(ch.length<5){
        for(i=0;i<BODIES.length;i++){
          b=BODIES[i];
          if(b.chain>=0)continue;
          if(b.last)continue;
          var cd=1e9;
          for(j=0;j<ch.length;j++)cd=Math.min(cd,Math.hypot(b.x-ch[j].x,b.y-ch[j].y));
          if(cd<0.28){b.near+=dt;if(b.near>1.9&&ch.length<5)this._join(b);}
          else b.near=Math.max(0,b.near-dt*1.4);
        }
      }
      /* the pace: the sections come faster the more of them there are — and
         it does not start until somebody has actually taken the hand. The
         wait for a body to cross the floor is not dancing, and a section
         spent during it would be handed to nobody. */
      if(ch.length){
        this.carry+=dt*(0.52+ch.length*0.46);
        if(this.given<4&&this.carry>=GATE[this.given]){
          this.given++;
          this.gaveNow={k:['say','walk','hand','open'][this.given-1],i:this.given};
        }
      }
    }

    /* ── d-map. It comes when everyone else has danced, and not before,
       and it is not asked. ─────────────────────────────────────── */
    if(!res&&!MAP.danced&&ch.length){
      var all=true;
      for(i=0;i<BODIES.length;i++)if(!BODIES[i].last&&!BODIES[i].danced)all=false;
      if(all){this._join(MAP);this.resolved=0.0001;this.given=4;
        this.gaveNow={k:'say',i:1,all:true};}
    }
    if(this.resolved>0)this.resolved=Math.min(1,this.resolved+dt*0.40);
    return this.lock;
  },
  _join:function(b){
    if(!this.chain.length)this.session++;
    b.chain=this.chain.length;this.chain.push(b);b.near=0;
    if(!b.danced){b.danced=true;this.order.push(b.id);}
    this.joinedNow=b;this.joinedQ.push(b);
  },
  /* the page drains this — every hand that was taken gets its line */
  tookHand:function(){return this.joinedQ.length?this.joinedQ.shift():null;},
  danceCount:function(){var c=0;for(var i=0;i<BODIES.length;i++)if(BODIES[i].danced)c++;return c;},

  /* ── the floor ─────────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(12,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var dsp=Math.max(0,this.displaced()), A=p*(1-dsp*0.44);
    var res=this.resolved;
    this.hits=[];
    if(A<=0.004)return;
    var self=this, i,j,b;
    var X=function(v){return cx+v*rim;}, Y=function(v){return cy+v*rim;};
    x.save();x.textAlign='center';x.textBaseline='middle';

    /* THE FLOOR. Warm, occupied, ordinary. It is the marketplace, not a
       shrine: the light is low and level and comes from nowhere special. */
    var fg=x.createRadialGradient(cx,cy,0,cx,cy,rim*0.88);
    fg.addColorStop(0,rgba(HUE,A*0.055*(0.8+br*0.4)));
    fg.addColorStop(0.62,rgba(HUE,A*0.030));
    fg.addColorStop(1,rgba(HUE,0));
    x.fillStyle=fg;x.beginPath();x.arc(cx,cy,rim*0.88,0,TAU);x.fill();
    x.beginPath();x.arc(cx,cy,rim*0.76,0,TAU);
    x.strokeStyle=rgba(HUE,A*0.10);x.lineWidth=0.6;x.stroke();

    /* the dust they stir. Nothing here is decoration: it is moved by the
       bodies that pass, which is how you can see that they have weight. */
    for(i=0;i<DUST.length;i++){
      var d=DUST[i], ax=0,ay=0;
      for(j=0;j<BODIES.length;j++){
        b=BODIES[j];
        var dx=d.x-b.x,dy=d.y-b.y,dd=dx*dx+dy*dy+0.004;
        if(dd<0.05){ax+=b.vx*0.030/dd;ay+=b.vy*0.030/dd;}
      }
      d.vx=(d.vx+ax)*0.90;d.vy=(d.vy+ay)*0.90;
      d.x+=d.vx*0.016;d.y+=d.vy*0.016;
      var dr2=Math.hypot(d.x,d.y);
      if(dr2>0.78){d.x*=0.78/dr2;d.y*=0.78/dr2;d.vx*=-0.4;d.vy*=-0.4;}
      var da2=A*(0.05+Math.min(0.20,Math.hypot(d.vx,d.vy)*0.9))*d.s;
      if(da2<0.004)continue;
      x.fillStyle=rgba(HUE,da2);
      x.fillRect(X(d.x)-d.s*0.7,Y(d.y)-d.s*0.7,d.s*1.4,d.s*1.4);
    }

    /* THE CHOREOGRAPHY, DRAWN. Each body carries the path it has actually
       just taken \u2014 nine braided curves, and together they are the figure.
       When d-map closes the world they stop where they are and stay. */
    for(i=0;i<BODIES.length;i++){
      b=BODIES[i];
      var tl=b.trail, n=tl.length/2;
      if(n<3)continue;
      var lit=b.chain>=0?1:(b.danced?0.52:0.26);
      x.beginPath();
      for(j=0;j<n;j++){var xx=X(tl[j*2]),yy=Y(tl[j*2+1]);j?x.lineTo(xx,yy):x.moveTo(xx,yy);}
      x.strokeStyle=rgba(HUE,A*(0.05+lit*0.11)*(1+res*1.4));
      x.lineWidth=0.5+lit*0.4;x.stroke();
      /* and the last stretch of it brighter, so motion has a direction */
      x.beginPath();
      for(j=Math.max(0,n-26);j<n;j++){var x2=X(tl[j*2]),y2=Y(tl[j*2+1]);
        j===Math.max(0,n-26)?x.moveTo(x2,y2):x.lineTo(x2,y2);}
      x.strokeStyle=rgba(mix(HUE,'#FFF3DC',0.44),A*(0.08+lit*0.24));
      x.lineWidth=0.7+lit*0.5;x.stroke();
    }

    /* THE CHAIN. Held hands sag; they are not beams. */
    if(this.chain.length&&(this.hand||res)){
      var pts=[];
      if(this.hand)pts.push([X(this.hand.x),Y(this.hand.y)]);
      for(i=0;i<this.chain.length;i++)pts.push([X(this.chain[i].x),Y(this.chain[i].y)]);
      for(i=0;i<pts.length-1;i++){
        var a1=pts[i],a2=pts[i+1];
        var sagd=Math.hypot(a2[0]-a1[0],a2[1]-a1[1]);
        var slack=Math.max(0,rim*0.20-sagd)*0.9+3;
        x.beginPath();x.moveTo(a1[0],a1[1]);
        x.quadraticCurveTo((a1[0]+a2[0])/2,(a1[1]+a2[1])/2+slack,a2[0],a2[1]);
        x.strokeStyle=rgba(mix(HUE,'#FFF3DC',0.5),A*(0.20+this.lock*0.36));
        x.lineWidth=0.8+this.lock*0.7;x.stroke();
      }
    }

    /* ONE LINE THROUGH ALL NINE, in the order they danced. Drawn only at
       the close, and it is the shape the whole world was making. */
    if(res>0.02){
      x.beginPath();
      for(i=0;i<this.order.length;i++){
        var ob=BY[this.order[i]];if(!ob)continue;
        i?x.lineTo(X(ob.x),Y(ob.y)):x.moveTo(X(ob.x),Y(ob.y));
      }
      x.strokeStyle=rgba(mix(HUE,'#FFF6E4',0.62),A*res*0.62);
      x.lineWidth=0.9;x.stroke();
    }

    /* THE BODIES */
    for(i=0;i<BODIES.length;i++){
      b=BODIES[i];
      var bx=X(b.x),by=Y(b.y);
      var mine=b.chain>=0, r6=Math.max(2.0,rim*0.017)*(mine?1.42:1)+br*0.4;
      var al=A*(mine?1:(b.danced?0.82:0.62));
      var glow=(0.30+(mine?0.40:0)+(b.danced?0.12:0))*(0.82+Math.cos(b.ph)*0.18);

      /* it stands on the floor: a shadow under it, offset by its own motion */
      x.beginPath();
      x.ellipse(bx-b.vx*2.2,by+r6*2.4,r6*2.6,r6*0.85,0,0,TAU);
      x.fillStyle='rgba(0,0,0,'+(A*0.24)+')';x.fill();

      var bg=x.createRadialGradient(bx,by,0,bx,by,r6*9);
      bg.addColorStop(0,rgba(mix(HUE,'#FFF7E8',0.74),al*glow));
      bg.addColorStop(0.20,rgba(HUE,al*glow*0.52));
      bg.addColorStop(1,rgba(HUE,0));
      x.fillStyle=bg;x.beginPath();x.arc(bx,by,r6*9,0,TAU);x.fill();
      x.beginPath();x.arc(bx,by,r6,0,TAU);
      x.fillStyle=rgba(mix('#FFF8EC',HUE,mine?0.06:0.28),al*(0.72+glow*0.28));x.fill();

      /* ITS PHASE, drawn as an arc around it. As the chain comes into
         time the arcs line up, and you can watch it happen. */
      if(rim>120){
        var pa=b.ph%TAU;
        x.beginPath();x.arc(bx,by,r6*3.1,pa-0.42,pa+0.42);
        x.strokeStyle=rgba(mix(HUE,'#FFF3DC',mine?0.5:0.1),al*(0.20+(mine?this.lock*0.52:0.10)));
        x.lineWidth=mine?1.3:0.8;x.stroke();
      }
      /* d-map keeps its own mark until it comes: the one that is waiting */
      if(b.last&&!b.danced){
        x.setLineDash([2,5]);
        x.strokeStyle=rgba(HUE,al*0.24*(0.55+br*0.6));x.lineWidth=0.7;
        x.beginPath();x.arc(bx,by,r6*5.4,0,TAU);x.stroke();x.setLineDash([]);
      }
      if(rim>150&&A>0.10&&!mine){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*0.30);
        x.fillText(STATUS[b.n.st],bx,by-r6*4.2);
      }
      this.hits.push({n:b,x:bx,y:by,rad:Math.max(30,rim*0.09)});
    }

    /* who is dancing, named — the head, and whoever came last with the one
       line it said. The floor does not repeat the whole margin back at him;
       the rest are lit bodies in time, and that is enough. Labels are pushed
       outward from the middle of the floor so they never sit on each other. */
    if(rim>130&&A>0.10&&this.chain.length){
      var shown=[this.chain[0]];
      if(this.chain.length>1)shown.push(this.chain[this.chain.length-1]);
      for(i=0;i<shown.length;i++){
        b=shown[i];
        var nx=X(b.x),ny=Y(b.y);
        if(i){
          /* the joiner's label leans away along the chain, not out along the
             same radius as the head — two names on one line never collide */
          var pv=this.chain[this.chain.length-2]||this.chain[0];
          var lvx=b.x-pv.x, lvy=b.y-pv.y, lvl=Math.hypot(lvx,lvy)||0.001;
          nx+=lvx/lvl*(26+rim*0.03);ny+=lvy/lvl*(26+rim*0.03)+4;
        }else{
          var orx=b.x,ory=b.y,orl=Math.hypot(orx,ory)||0.001;
          var off=20+rim*0.02;
          nx+=orx/orl*off;ny+=ory/orl*off+7;
        }
        x.font=(i?'italic 11px':'italic 13px')+' Lora, Georgia, serif';
        x.fillStyle=rgba('#FFF6E8',A*(i?0.62:0.94));
        x.fillText(b.n.t,nx,ny);
        if(i){x.font='italic 7.5px Lora, Georgia, serif';
          x.fillStyle=rgba(HUE,A*0.50);x.fillText(CALL[b.id]||'',nx,ny+11);}
      }
    }

    /* HIS HAND. Open, and waiting to be taken. */
    if(this.hand&&!res){
      var hx2=X(this.hand.x),hy2=Y(this.hand.y);
      var wait=this.chain.length?0:(0.5+Math.sin(t*3.1)*0.5);
      var hg=x.createRadialGradient(hx2,hy2,0,hx2,hy2,24);
      hg.addColorStop(0,rgba('#FFF8EC',A*(0.52+this.lock*0.3)));
      hg.addColorStop(0.3,rgba(HUE,A*0.26));
      hg.addColorStop(1,rgba(HUE,0));
      x.fillStyle=hg;x.beginPath();x.arc(hx2,hy2,24,0,TAU);x.fill();
      x.beginPath();x.arc(hx2,hy2,3.2,0,TAU);x.fillStyle=rgba('#FFFAF2',A*0.94);x.fill();
      if(!this.chain.length){
        x.beginPath();x.arc(hx2,hy2,9+wait*7,0,TAU);
        x.strokeStyle=rgba(HUE,A*0.34*(1-wait*0.7));x.lineWidth=0.8;x.stroke();
      }
    }

    /* what the world says. It never counts and it never scores. */
    x.font='8.5px "Space Mono", monospace';
    var line;
    if(res>0.02){
      /* a world that has closed is not a dead surface. It says what it is
         and it says where the way on runs — which is the only direction
         left in the instrument. */
      x.fillStyle=rgba('#FFF3DC',A*0.40*(0.72+br*0.36));
      x.fillText('THE MAP BECAME ARCHITECTURE',cx,H-166);
      x.fillStyle=rgba(HUE,A*0.42*(0.55+br*0.55));
      x.fillText('THE DOOR OUT IS THE DOOR IN \u00b7 PULL UP',cx,H-150);
      x.restore();return;
    }
    if(!this.hand)line=this.danceCount()?'OFFER A HAND AGAIN \u00b7 THEY ARE STILL DANCING':
      'THEY WERE DANCING BEFORE YOU CAME \u00b7 OFFER A HAND';
    else if(!this.chain.length)line='SOMEONE IS COMING ACROSS THE FLOOR';
    else if(this.chain.length===1)line='YOU ARE DANCING \u00b7 IT GOES QUICKER IN COMPANY';
    else line=this.chain.length+' HANDS \u00b7 THE DANCE IS CARRYING YOU';
    x.fillStyle=rgba('#FFF3DC',A*0.46*(0.72+br*0.36));
    x.fillText(line,cx,H-150);
    x.restore();
  }
};

function rgba(h,a){var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';}
function mix(a,b,f){
  var pa=[parseInt(a.slice(1,3),16),parseInt(a.slice(3,5),16),parseInt(a.slice(5,7),16)];
  var pb=[parseInt(b.slice(1,3),16),parseInt(b.slice(3,5),16),parseInt(b.slice(5,7),16)];
  var hx=function(v){v=Math.round(Math.max(0,Math.min(255,v))).toString(16);return v.length<2?'0'+v:v;};
  return '#'+hx(pa[0]+(pb[0]-pa[0])*f)+hx(pa[1]+(pb[1]-pa[1])*f)+hx(pa[2]+(pb[2]-pa[2])*f);
}
g.SEVEN=Seven;
})(window);
